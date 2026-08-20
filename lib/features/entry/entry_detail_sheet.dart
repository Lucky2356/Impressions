import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../core/utils/dates.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/db/database.dart';
import '../../data/providers.dart';
import '../../data/services/purge_service.dart';
import '../../data/services/revision_service.dart';
import '../../data/services/transfer_service.dart';
import '../../design_system/design_system.dart';
import '../collections/collection_picker.dart';
import '../quick_add/category_picker.dart';
import '../search/recent_store.dart';
import 'entry_object_dialogs.dart';
import 'entry_disclosure.dart';
import 'entry_hero.dart';
import 'entry_opinion.dart';
import 'entry_photos.dart';
import 'entry_visits.dart';
import 'entry_providers.dart';
import 'entry_tags.dart';

/// Карточка записи: путь категорий, отношение, оценка, заметка, история версий
/// с восстановлением (§18) и архивирование (§24).
class EntryDetailSheet extends ConsumerStatefulWidget {
  const EntryDetailSheet({super.key, required this.entryId});

  final String entryId;

  static Future<void> show(BuildContext context, String entryId) {
    return showAdaptiveSheet<void>(
      context,
      width: 640,
      height: 700,
      heightFactor: 0.92,
      builder: (_) => EntryDetailSheet(entryId: entryId),
    );
  }

  @override
  ConsumerState<EntryDetailSheet> createState() => _EntryDetailSheetState();
}

class _EntryDetailSheetState extends ConsumerState<EntryDetailSheet> {
  /// Ключ карточки впечатления: через него закрытие дописывает набранное.
  ///
  /// Поля ввода живут в ней самой — иначе половина этого файла была бы про
  /// сохранение заметки и прогресса.
  final _opinionKey = GlobalKey<EntryOpinionCardState>();

  @override
  void initState() {
    super.initState();
    // Открытая запись попадает в недавние: закрыли — и искали её снова.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) =>
          ref.read(recentStoreProvider.notifier).rememberEntry(widget.entryId),
    );
  }

  void _bump() => ref.read(dataRefreshProvider.notifier).bump();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final detail = ref.watch(entryDetailProvider(widget.entryId));

    // Карточку закрывают четырьмя способами: крестиком, нажатием мимо, свайпом
    // вниз и кнопкой «Назад». Все четыре снимают маршрут, поэтому дописывать
    // заметку надёжнее всего здесь, а не в каждом обработчике.
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        // Карточку закрывают четырьмя способами: крестиком, нажатием мимо,
        // свайпом вниз и кнопкой «Назад». Все четыре снимают маршрут, поэтому
        // дописывать набранное надёжнее всего здесь.
        if (didPop) _opinionKey.currentState?.saveIfChanged();
      },
      child: _content(context, l10n, c, detail),
    );
  }

  Widget _content(
    BuildContext context,
    AppLocalizations l10n,
    AppColors c,
    AsyncValue<EntryDetail?> detail,
  ) {
    return detail.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorState(error: e),
      data: (d) {
        if (d == null) {
          return Center(child: Text(l10n.commonNothingFound));
        }
        final revisionDate = localeDate(context, 'd MMMM y, HH:mm');
        // Чужую запись нельзя редактировать: мнение принадлежит её автору (§6.2).
        // Вместо редактирования предлагается добавить её себе (§12).
        final active = ref.watch(activeProfileProvider);
        final isOwn = active != null && d.entry.profileId == active.id;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Шапка: только выход и меню действий. Раньше здесь стояло слово
            // «Запись» и три значка, а название самой записи лежало ниже — и
            // первым, что читал глаз, была служебная подпись.
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.space20,
                AppDimens.space8,
                AppDimens.space8,
                AppDimens.space8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.entryDetailTitle,
                      style: context.text.labelSmall?.copyWith(
                        color: c.textMuted,
                      ),
                    ),
                  ),
                  if (isOwn) _menu(l10n, c, d),
                  IconButton(
                    tooltip: l10n.commonClose,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.space20,
                  0,
                  AppDimens.space20,
                  AppDimens.space32,
                ),
                children: [
                  EntryHero(
                    detail: d,
                    coverPath: d.coverPath,
                    editable: isOwn,
                    onPickCategory: () => _pickCategory(d.entry.id),
                  ),

                  // Чужая запись: мнение источника только для чтения (§12).
                  if (!isOwn) ...[
                    const SizedBox(height: AppDimens.space16),
                    Container(
                      padding: const EdgeInsets.all(AppDimens.space16),
                      decoration: BoxDecoration(
                        color: c.accentSoft,
                        borderRadius: AppDimens.brMd,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.transferTitle,
                            style: context.text.titleMedium,
                          ),
                          const SizedBox(height: AppDimens.space4),
                          Text(
                            l10n.transferDone,
                            style: context.text.bodySmall?.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppDimens.space12),
                          TransferButton(
                            onPressed: () => _transferToMe(d.entry.id),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: AppDimens.space20),

                  // То, ради чего карточку открывают, — одной карточкой.
                  EntryOpinionCard(
                    key: _opinionKey,
                    detail: d,
                    editable: isOwn,
                  ),

                  const SizedBox(height: AppDimens.space20),

                  // Повторные впечатления (§10) и фотографии (§16) — это
                  // содержимое записи, поэтому они открыты, а не свёрнуты.
                  EntryVisitsBlock(
                    entryId: d.entry.id,
                    visits: d.visits,
                    canEdit: isOwn,
                  ),
                  const SizedBox(height: AppDimens.space20),
                  EntryPhotos(
                    entryId: d.entry.id,
                    revisionId: d.entry.currentRevisionId,
                  ),
                  const SizedBox(height: AppDimens.space24),

                  // Дальше — то, что спрашивают редко. Раскрытым это занимало
                  // больше половины карточки.
                  EntryDisclosure(
                    title: l10n.tagsTitle,
                    child: EntryTags(entryId: d.entry.id, editable: isOwn),
                  ),
                  EntryDisclosure(
                    title: l10n.categoryExtra,
                    badge: d.extraCategories.isEmpty
                        ? null
                        : '${d.extraCategories.length}',
                    // Если запись и правда лежит на двух полках, это про то,
                    // где она находится, а не про редкую настройку: прятать
                    // такое нельзя. Пустой раздел остаётся свёрнутым.
                    initiallyOpen: d.extraCategories.isNotEmpty,
                    child: _ExtraCategories(
                      categories: d.extraCategories,
                      onAdd: isOwn ? () => _addCategory(d.entry.id) : null,
                      onRemove: isOwn
                          ? (id) => _removeCategory(d.entry.id, id)
                          : null,
                    ),
                  ),
                  EntryDisclosure(
                    title: l10n.privacyLabel,
                    child: PrivacySelector(
                      value: d.entry.privacy,
                      onChanged: isOwn
                          ? (v) => _setPrivacy(d.entry.id, v)
                          : null,
                    ),
                  ),
                  EntryDisclosure(
                    title: l10n.entrySimilar,
                    child: _SimilarEntries(entryId: d.entry.id),
                  ),
                  EntryDisclosure(
                    title: l10n.entryHistory,
                    badge: '${d.history.length}',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Форматтер один на всю историю: у записи, правленной
                        // двести раз, здесь заводилось двести штук за кадр.
                        for (final rev in d.history)
                          _RevisionRow(
                            dateLabel: revisionDate.format(rev.createdAt),
                            isCurrent: rev.id == d.entry.currentRevisionId,
                            onRestore: rev.id == d.entry.currentRevisionId
                                ? null
                                : () => _restore(d.entry.id, rev.id),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Действия над записью — в одном меню.
  ///
  /// Их пять, и раньше три висели значками в шапке, а два — рядом с названием
  /// объекта, хотя относятся к объекту, а не к тому, что вы о нём думаете.
  Widget _menu(AppLocalizations l10n, AppColors c, EntryDetail d) {
    return PopupMenuButton<String>(
      tooltip: '',
      icon: Icon(Icons.more_horiz_rounded, color: c.textSecondary),
      onSelected: (value) {
        switch (value) {
          case 'collection':
            _addToCollection(d.entry.id);
          case 'object':
            _editObject(d);
          case 'merge':
            _mergeObject(d);
          case 'archive':
            _archive(d.entry.id);
        }
      },
      itemBuilder: (_) => [
        _item('collection', Icons.playlist_add_rounded, l10n.collectionAddTo),
        _item('object', Icons.edit_rounded, l10n.entryEditObject),
        _item('merge', Icons.merge_rounded, l10n.entryMerge),
        const PopupMenuDivider(),
        _item('archive', Icons.archive_outlined, l10n.entryArchive),
      ],
    );
  }

  PopupMenuItem<String> _item(String value, IconData icon, String label) {
    return PopupMenuItem(
      value: value,
      height: 40,
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: AppDimens.space12),
          Flexible(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  // ---- Вспомогательные виджеты вынесены ниже по файлу ----

  /// Кладёт запись ещё на одну полку (§7.2).
  ///
  /// Основная категория остаётся прежней: она задаёт путь записи, а
  /// дополнительные — просто ещё места, где её найдут.
  Future<void> _addCategory(String entryId) async {
    final entries = ref.read(entryRepositoryProvider);
    final taken = {
      ?await entries.primaryCategoryOf(entryId),
      ...await entries.extraCategoriesOf(entryId),
    };
    if (!mounted) return;

    final picked = await CategoryPicker.show(
      context,
      title: AppLocalizations.of(context).categoryExtraAdd,
      allowClear: false,
      excludeIds: taken,
    );
    final category = picked?.category;
    if (category == null) return;
    await entries.addCategory(entryId, category.id);
    _bump();
  }

  Future<void> _removeCategory(String entryId, String categoryId) async {
    await ref.read(entryRepositoryProvider).removeCategory(entryId, categoryId);
    _bump();
  }

  Future<void> _setPrivacy(String entryId, String privacy) async {
    await ref
        .read(entryRepositoryProvider)
        .updateEntry(entryId, privacy: privacy);
    _bump();
  }

  /// Правка описания объекта. Фиксируется новой версией (§18), поэтому
  /// прежнее название остаётся в истории.
  Future<void> _editObject(EntryDetail d) async {
    final result = await showDialog<ObjectEdit>(
      context: context,
      builder: (_) => ObjectEditDialog(object: d.object),
    );
    if (result == null) return;
    await ref
        .read(entryRepositoryProvider)
        .updateObject(
          d.object.id,
          title: result.title,
          altTitle: result.altTitle,
          summary: result.summary,
          creator: result.creator,
          year: result.year,
        );
    _bump();
  }

  /// Сводит объект записи с другим таким же.
  ///
  /// Кандидатов ищем тем же правилом, что и при создании записи, — только без
  /// самого объекта. Записи переезжают на выбранный, а опустевший объект
  /// убирается, если на него больше никто не смотрит.
  Future<void> _mergeObject(EntryDetail d) async {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(entryRepositoryProvider);
    final candidates = (await repo.findDuplicateCandidates(
      d.object.typeId,
      d.object.title,
    )).where((o) => o.id != d.object.id).toList();
    if (!mounted) return;

    if (candidates.isEmpty) {
      showMessage(context, l10n.entryMergeEmpty);
      return;
    }

    final target = await showDialog<ObjectRow>(
      context: context,
      builder: (_) => MergeDialog(candidates: candidates.take(5).toList()),
    );
    if (target == null || !mounted) return;

    await PurgeService(
      ref.read(appDatabaseProvider),
    ).mergeObjects(mergeId: d.object.id, keepId: target.id);
    _bump();
    if (!mounted) return;
    showMessage(context, l10n.entryMergeDone);
  }

  /// Переложить запись в другую категорию прямо из карточки.
  Future<void> _pickCategory(String entryId) async {
    final picked = await CategoryPicker.show(context);
    final category = picked?.category;
    if (picked == null || picked.cleared || category == null) return;
    await ref
        .read(entryRepositoryProvider)
        .setPrimaryCategory(entryId, category.id);
    _bump();
  }

  Future<void> _restore(String entryId, String revisionId) async {
    final l10n = AppLocalizations.of(context);
    final db = ref.read(appDatabaseProvider);
    await RevisionService(db).restoreEntryRevision(entryId, revisionId);
    _bump();
    if (!mounted) return;
    showMessage(context, l10n.entryRestored);
  }

  /// Добавление записи в подборку с возможностью создать новую (§27).
  Future<void> _addToCollection(String entryId) async {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(collectionRepositoryProvider);
    // Подборки, в которых запись уже лежит: они показаны с галочкой и не
    // выбираются.
    final already = await repo.collectionsOfEntry(entryId);
    if (!mounted) return;

    final collectionId = await CollectionPicker.show(
      context,
      ref,
      disabled: already.toSet(),
    );
    if (collectionId == null || !mounted) return;

    await repo.addEntry(collectionId, entryId);
    _bump();
    if (!mounted) return;
    showMessage(context, l10n.collectionAdded);
  }

  /// Добавляет чужую запись в активный профиль (§12).
  Future<void> _transferToMe(String sourceEntryId) async {
    final l10n = AppLocalizations.of(context);
    final active = ref.read(activeProfileProvider);
    if (active == null) return;

    final service = TransferService(ref.read(appDatabaseProvider));
    final source = await ref.read(entryDetailProvider(sourceEntryId).future);
    if (source != null &&
        await service.hasEntryFor(active.id, source.object.id)) {
      if (!mounted) return;
      showMessage(context, l10n.transferAlreadyHave);
      return;
    }

    await service.transfer(
      sourceEntryId: sourceEntryId,
      targetProfileId: active.id,
      mode: TransferCategoryMode.autoCreate,
    );
    _bump();
    if (!mounted) return;
    Navigator.of(context).pop();
    showMessage(context, l10n.transferDone);
  }

  /// Архивирование без вопроса «точно?»: рядом сразу появляется «Вернуть».
  ///
  /// Диалог здесь ничего не защищал — действие обратимо, — а разбор каталога
  /// это десятки таких движений подряд. Подтверждение осталось там, где вернуть
  /// нечем: удаление насовсем, восстановление из копии, удаление тега.
  Future<void> _archive(String entryId) async {
    final l10n = AppLocalizations.of(context);

    // «Вернуть» нажимают, когда карточки уже нет: её `ref` к этому времени
    // отвязан от дерева и падает с «Using "ref" when a widget is about to or
    // has been unmounted». Поэтому берём хранилище провайдеров заранее — оно
    // живёт выше карточки и переживает её закрытие.
    final container = ProviderScope.containerOf(context, listen: false);

    await ref.read(entryRepositoryProvider).archiveEntry(entryId);
    _bump();
    if (!mounted) return;
    Navigator.of(context).pop();

    // Сообщение показываем уже поверх экрана, с которого пришли: карточка
    // закрыта, и её ScaffoldMessenger вместе с ней.
    showUndoSnackBar(
      context,
      message: l10n.entryArchived,
      onUndo: () async {
        await container.read(entryRepositoryProvider).restoreEntry(entryId);
        container.read(dataRefreshProvider.notifier).bump();
      },
    );
  }
}

class _RevisionRow extends StatelessWidget {
  const _RevisionRow({
    required this.dateLabel,
    required this.isCurrent,
    required this.onRestore,
  });

  final String dateLabel;
  final bool isCurrent;
  final VoidCallback? onRestore;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.space8),
      child: Row(
        children: [
          Icon(
            isCurrent ? Icons.radio_button_checked : Icons.history_rounded,
            size: 18,
            color: isCurrent ? c.accentPrimary : c.textMuted,
          ),
          const SizedBox(width: AppDimens.space12),
          Expanded(
            child: Text(
              l10n.entryVersionAt(dateLabel),
              style: context.text.bodySmall,
            ),
          ),
          if (onRestore != null)
            TextButton(
              onPressed: onRestore,
              child: Text(l10n.entryRestoreRevision),
            ),
        ],
      ),
    );
  }
}

/// Строка с датой впечатления: когда это было на самом деле, а не когда

/// Похожие записи под карточкой.
///
/// Данные для такой связи лежали с самого начала — тип, оценка, теги, — но
/// нигде не сводились: приложение знало о вкусах больше, чем показывало.
class _SimilarEntries extends ConsumerWidget {
  const _SimilarEntries({required this.entryId});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final similar =
        ref.watch(similarEntriesProvider(entryId)).value ?? const [];
    if (similar.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n.entrySimilar, style: context.text.titleSmall),
        const SizedBox(height: AppDimens.space8),
        for (final entry in similar)
          InkWell(
            onTap: () => EntryDetailSheet.show(context, entry.entryId),
            borderRadius: AppDimens.brSm,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimens.space8,
                horizontal: AppDimens.space4,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodyMedium,
                    ),
                  ),
                  const SizedBox(width: AppDimens.space8),
                  RatingView(value: entry.rating, compact: true),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppDimens.space8),
        Divider(color: c.divider),
        const SizedBox(height: AppDimens.space8),
      ],
    );
  }
}

/// Дополнительные категории записи (§7.2).
///
/// Основная остаётся крошками выше — иерархия делает разницу очевидной без
/// объяснений: путь один, а полок, на которых запись лежит, может быть
/// несколько.
class _ExtraCategories extends StatelessWidget {
  const _ExtraCategories({required this.categories, this.onAdd, this.onRemove});

  final List<CategoryRow> categories;
  final VoidCallback? onAdd;
  final void Function(String categoryId)? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Wrap(
      spacing: AppDimens.space8,
      runSpacing: AppDimens.space8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Подписи «Ещё категории» здесь больше нет: так называется сам раздел,
        // внутри которого лежат эти чипы, и повторять название дважды незачем.
        for (final category in categories)
          Chip(
            label: Text(category.name),
            visualDensity: VisualDensity.compact,
            onDeleted: onRemove == null ? null : () => onRemove!(category.id),
            deleteButtonTooltipMessage: l10n.categoryExtraRemove,
          ),
        if (onAdd != null)
          ActionChip(
            avatar: const Icon(Icons.add_rounded, size: 16),
            label: Text(categories.isEmpty ? l10n.commonAdd : ''),
            visualDensity: VisualDensity.compact,
            tooltip: l10n.categoryExtraAdd,
            onPressed: onAdd,
          ),
      ],
    );
  }
}
