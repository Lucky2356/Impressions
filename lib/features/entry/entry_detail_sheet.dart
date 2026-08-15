import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../core/utils/dates.dart';
import '../../core/domain/relation.dart';
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
import 'entry_photos.dart';
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
  final _note = TextEditingController();
  final _noteFocus = FocusNode();
  bool _noteInitialised = false;
  bool _showHistory = false;

  /// Текст заметки, который уже лежит в базе.
  ///
  /// Заметка сохранялась только по кнопке: закрыли карточку крестиком, свайпом
  /// вниз или нажатием мимо — набранное пропадало молча. Отношение, оценка и
  /// дата рядом сохраняются сразу, поэтому и ожидание было такое же.
  String _savedNote = '';

  @override
  void initState() {
    super.initState();
    // Открытая запись попадает в недавние: закрыли — и искали её снова.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) =>
          ref.read(recentStoreProvider.notifier).rememberEntry(widget.entryId),
    );
    _noteFocus.addListener(() {
      if (!_noteFocus.hasFocus) _saveNoteIfChanged();
    });
  }

  @override
  void dispose() {
    _noteFocus.dispose();
    _note.dispose();
    super.dispose();
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
        if (didPop) _saveNoteIfChanged();
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
        if (!_noteInitialised) {
          _note.text = d.entry.detailedNote ?? '';
          _savedNote = _note.text;
          _noteInitialised = true;
        }
        final relation = Relation.byName(d.entry.relation);
        final revisionDate = localeDate(context, 'd MMMM y, HH:mm');
        // Чужую запись нельзя редактировать: мнение принадлежит её автору (§6.2).
        // Вместо редактирования предлагается добавить её себе (§12).
        final active = ref.watch(activeProfileProvider);
        final isOwn = active != null && d.entry.profileId == active.id;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Шапка
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.space20,
                AppDimens.space16,
                AppDimens.space8,
                AppDimens.space8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.entryDetailTitle,
                      style: context.text.headlineSmall,
                    ),
                  ),
                  if (isOwn) ...[
                    IconButton(
                      tooltip: l10n.collectionAddTo,
                      onPressed: () => _addToCollection(d.entry.id),
                      icon: const Icon(Icons.playlist_add_rounded),
                    ),
                    IconButton(
                      tooltip: l10n.entryArchive,
                      onPressed: () => _archive(d.entry.id),
                      icon: const Icon(Icons.archive_outlined),
                    ),
                  ],
                  IconButton(
                    tooltip: l10n.commonClose,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: c.border),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppDimens.space20),
                children: [
                  // Хлебные крошки: Продукты / Колбасы / Папа может (§7.6).
                  // Нажатие меняет категорию: раньше переложить запись можно
                  // было только правой кнопкой в каталоге, о чём догадаться
                  // неоткуда.
                  InkWell(
                    onTap: isOwn ? () => _pickCategory(d.entry.id) : null,
                    borderRadius: AppDimens.brSm,
                    child: Row(
                      children: [
                        Expanded(
                          child: Breadcrumbs(
                            crumbs: [
                              for (final name in d.categoryPath) Crumb(name),
                              if (d.categoryPath.isEmpty)
                                Crumb(l10n.quickAddNoCategory),
                              Crumb(d.object.title),
                            ],
                          ),
                        ),
                        if (isOwn)
                          Icon(
                            Icons.drive_file_move_outline,
                            size: 16,
                            color: c.textMuted,
                          ),
                      ],
                    ),
                  ),
                  if (isOwn || d.extraCategories.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: AppDimens.space8),
                      child: _ExtraCategories(
                        categories: d.extraCategories,
                        onAdd: isOwn ? () => _addCategory(d.entry.id) : null,
                        onRemove: isOwn
                            ? (id) => _removeCategory(d.entry.id, id)
                            : null,
                      ),
                    ),
                  const SizedBox(height: AppDimens.space12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          d.object.title,
                          style: context.text.displayMedium,
                        ),
                      ),
                      // Правка описания самого объекта: название, бренд, год.
                      // Раньше их нельзя было изменить вовсе — даже опечатку.
                      if (isOwn) ...[
                        AppIconButton(
                          icon: Icons.edit_rounded,
                          tooltip: l10n.entryEditObject,
                          onPressed: () => _editObject(d),
                        ),
                        // Свести два одинаковых объекта можно было только
                        // заведя всё заново: диалог похожих работает лишь в
                        // момент создания записи.
                        AppIconButton(
                          icon: Icons.merge_rounded,
                          tooltip: l10n.entryMerge,
                          onPressed: () => _mergeObject(d),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppDimens.space4),
                  Text(
                    [
                      d.typeName,
                      if (d.object.creator != null) d.object.creator!,
                      if (d.object.year != null) '${d.object.year}',
                    ].join(' · '),
                    style: context.text.bodyMedium?.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                  // Откуда запись взялась. Приложение помечало перенесённые
                  // записи с самого начала и нигде этого не показывало.
                  if (d.recommendedBy != null) ...[
                    const SizedBox(height: AppDimens.space8),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 16,
                          color: c.accentPrimary,
                        ),
                        const SizedBox(width: AppDimens.space8),
                        Flexible(
                          child: Text(
                            l10n.entryRecommendedBy(d.recommendedBy!),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.bodySmall?.copyWith(
                              color: c.accentPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppDimens.space16),

                  // Дата впечатления (§10): по ней можно сортировать каталог,
                  // но задать её раньше было негде.
                  _ImpressionDateRow(
                    value: d.entry.impressionDate,
                    editable: isOwn,
                    onPick: () => _pickImpressionDate(d),
                    onClear: () => _setImpressionDate(d.entry.id, null),
                  ),
                  const SizedBox(height: AppDimens.space24),

                  // Чужая запись: мнение источника только для чтения (§12).
                  if (!isOwn) ...[
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
                    const SizedBox(height: AppDimens.space20),
                  ],

                  // Отношение
                  Text(
                    l10n.quickAddRelationLabel,
                    style: context.text.labelSmall?.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimens.space8),
                  Wrap(
                    spacing: AppDimens.space8,
                    runSpacing: AppDimens.space8,
                    children: [
                      for (final r in Relation.values)
                        ChoiceChip(
                          selected: relation == r,
                          onSelected: isOwn
                              ? (s) => _setRelation(d.entry.id, s ? r : null)
                              : null,
                          avatar: Icon(
                            r.icon,
                            size: 16,
                            color: relation == r
                                ? r.accent(c)
                                : c.textSecondary,
                          ),
                          label: Text(r.label(l10n)),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.space20),

                  // Оценка
                  Row(
                    children: [
                      Text(
                        l10n.quickAddRatingLabel,
                        style: context.text.labelSmall?.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      RatingView(value: d.entry.rating, compact: true),
                    ],
                  ),
                  Slider(
                    value: d.entry.rating ?? 0,
                    min: 0,
                    max: 10,
                    divisions: 20,
                    label: (d.entry.rating ?? 0).toStringAsFixed(1),
                    onChanged: isOwn ? (v) => _setRating(d.entry.id, v) : null,
                  ),
                  if (d.entry.rating != null && isOwn)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => _setRating(d.entry.id, null),
                        child: Text(l10n.quickAddRatingNone),
                      ),
                    ),
                  const SizedBox(height: AppDimens.space12),

                  // Заметка
                  TextField(
                    controller: _note,
                    focusNode: _noteFocus,
                    minLines: 3,
                    maxLines: 8,
                    readOnly: !isOwn,
                    decoration: InputDecoration(labelText: l10n.entryNoteLabel),
                    onEditingComplete: () => _saveNote(d.entry.id),
                  ),
                  if (isOwn) ...[
                    const SizedBox(height: AppDimens.space8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: () => _saveNote(d.entry.id),
                        child: Text(l10n.commonSave),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppDimens.space20),
                  Divider(color: c.divider),
                  const SizedBox(height: AppDimens.space16),

                  // Теги (§7.2)
                  EntryTags(entryId: d.entry.id, editable: isOwn),

                  const SizedBox(height: AppDimens.space16),
                  Divider(color: c.divider),
                  const SizedBox(height: AppDimens.space16),

                  // Доступность записи при передаче (§25)
                  PrivacySelector(
                    value: d.entry.privacy,
                    onChanged: isOwn ? (v) => _setPrivacy(d.entry.id, v) : null,
                  ),

                  const SizedBox(height: AppDimens.space16),
                  Divider(color: c.divider),
                  const SizedBox(height: AppDimens.space16),

                  // Фотографии (§16)
                  EntryPhotos(
                    entryId: d.entry.id,
                    revisionId: d.entry.currentRevisionId,
                  ),

                  const SizedBox(height: AppDimens.space16),
                  Divider(color: c.divider),
                  const SizedBox(height: AppDimens.space8),

                  // Похожее рядом: тот же тип, близкая оценка или общий тег.
                  _SimilarEntries(entryId: d.entry.id),

                  // История версий
                  InkWell(
                    onTap: () => setState(() => _showHistory = !_showHistory),
                    borderRadius: AppDimens.brSm,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimens.space8,
                      ),
                      child: Row(
                        children: [
                          Text(
                            l10n.entryHistory,
                            style: context.text.titleMedium,
                          ),
                          const Spacer(),
                          Text(
                            '${d.history.length}',
                            style: context.text.labelSmall?.copyWith(
                              color: c.textMuted,
                            ),
                          ),
                          Icon(
                            _showHistory
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: c.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Форматтер один на всю историю: у записи, правленной двести
                  // раз, здесь заводилось двести штук за кадр.
                  if (_showHistory)
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
        );
      },
    );
  }

  // ---- Вспомогательные виджеты вынесены ниже по файлу ----

  Future<void> _setRelation(String entryId, Relation? r) async {
    await ref
        .read(entryRepositoryProvider)
        .updateEntry(entryId, relation: r?.name);
    _bump();
  }

  Future<void> _setRating(String entryId, double? value) async {
    await ref.read(entryRepositoryProvider).updateEntry(entryId, rating: value);
    _bump();
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

  Future<void> _saveNote(String entryId) async {
    final text = _note.text.trim();
    _savedNote = text;
    // Репозиторий берём до `await`: карточку могли уже закрыть, и после
    // ожидания `ref` обращаться некуда.
    final repo = ref.read(entryRepositoryProvider);
    await repo.updateEntry(entryId, detailedNote: text.isEmpty ? null : text);
    if (mounted) _bump();
  }

  /// Дописывает заметку, если её меняли.
  ///
  /// Без сравнения с сохранённым каждое закрытие карточки заводило бы новую
  /// версию записи (§18) — история заросла бы пустыми правками.
  void _saveNoteIfChanged() {
    if (!_noteInitialised) return;
    if (_note.text.trim() == _savedNote.trim()) return;
    _saveNote(widget.entryId);
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

  Future<void> _pickImpressionDate(EntryDetail d) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: d.entry.impressionDate ?? now,
      firstDate: DateTime(now.year - 50),
      lastDate: now,
      locale: const Locale('ru'),
    );
    if (picked == null) return;
    await _setImpressionDate(d.entry.id, picked);
  }

  Future<void> _setImpressionDate(String entryId, DateTime? date) async {
    await ref
        .read(entryRepositoryProvider)
        .updateEntry(
          entryId,
          impressionDate: date,
          clearImpressionDate: date == null,
        );
    _bump();
  }

  Future<void> _restore(String entryId, String revisionId) async {
    final l10n = AppLocalizations.of(context);
    final db = ref.read(appDatabaseProvider);
    await RevisionService(db).restoreEntryRevision(entryId, revisionId);
    _noteInitialised = false;
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
/// запись завели.
class _ImpressionDateRow extends StatelessWidget {
  const _ImpressionDateRow({
    required this.value,
    required this.editable,
    required this.onPick,
    required this.onClear,
  });

  final DateTime? value;
  final bool editable;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    if (value == null && !editable) return const SizedBox.shrink();

    return Row(
      children: [
        Icon(Icons.event_rounded, size: 18, color: c.textSecondary),
        const SizedBox(width: AppDimens.space8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.entryImpressionDate,
                style: context.text.labelSmall?.copyWith(
                  color: c.textSecondary,
                ),
              ),
              Text(
                value == null
                    ? l10n.entryImpressionDateNone
                    : localeDate(context, 'd MMMM y').format(value!),
                style: context.text.bodyMedium,
              ),
            ],
          ),
        ),
        if (editable) ...[
          if (value != null)
            AppIconButton(
              icon: Icons.close_rounded,
              tooltip: l10n.entryImpressionDateClear,
              onPressed: onClear,
            ),
          AppIconButton(
            icon: Icons.edit_calendar_rounded,
            tooltip: l10n.entryImpressionDate,
            onPressed: onPick,
          ),
        ],
      ],
    );
  }
}

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
    final c = context.colors;

    return Wrap(
      spacing: AppDimens.space8,
      runSpacing: AppDimens.space8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (categories.isNotEmpty)
          Text(
            l10n.categoryExtra,
            style: context.text.labelSmall?.copyWith(color: c.textMuted),
          ),
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
            label: Text(categories.isEmpty ? l10n.categoryExtra : ''),
            visualDensity: VisualDensity.compact,
            tooltip: l10n.categoryExtraAdd,
            onPressed: onAdd,
          ),
      ],
    );
  }
}
