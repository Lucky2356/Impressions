import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../core/domain/relation.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/db/database.dart';
import '../../data/providers.dart';
import '../../data/services/revision_service.dart';
import '../../data/services/transfer_service.dart';
import '../../design_system/design_system.dart';
import '../quick_add/category_picker.dart';
import 'entry_photos.dart';
import 'entry_providers.dart';
import 'entry_tags.dart';

/// Карточка записи: путь категорий, отношение, оценка, заметка, история версий
/// с восстановлением (§18) и архивирование (§24).
class EntryDetailSheet extends ConsumerStatefulWidget {
  const EntryDetailSheet({super.key, required this.entryId});

  final String entryId;

  static Future<void> show(BuildContext context, String entryId) {
    final wide =
        MediaQuery.sizeOf(context).width >= AppDimens.breakpointExpanded;
    if (wide) {
      return showDialog(
        context: context,
        builder: (_) => Dialog(
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: 640,
            height: 700,
            child: EntryDetailSheet(entryId: entryId),
          ),
        ),
      );
    }
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.92,
        child: EntryDetailSheet(entryId: entryId),
      ),
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
        final relation = _relationOf(d.entry.relation);
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
                      if (isOwn)
                        AppIconButton(
                          icon: Icons.edit_rounded,
                          tooltip: l10n.entryEditObject,
                          onPressed: () => _editObject(d),
                        ),
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
                  if (_showHistory)
                    for (final rev in d.history)
                      _RevisionRow(
                        dateLabel: DateFormat(
                          'd MMMM y, HH:mm',
                          'ru',
                        ).format(rev.createdAt),
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

  Relation? _relationOf(String? name) {
    if (name == null) return null;
    for (final r in Relation.values) {
      if (r.name == name) return r;
    }
    return null;
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
    final result = await showDialog<_ObjectEdit>(
      context: context,
      builder: (_) => _ObjectEditDialog(object: d.object),
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.entryRestored)));
  }

  /// Добавление записи в подборку с возможностью создать новую (§27).
  Future<void> _addToCollection(String entryId) async {
    final l10n = AppLocalizations.of(context);
    final profile = ref.read(activeProfileProvider);
    if (profile == null) return;

    final repo = ref.read(collectionRepositoryProvider);
    final existing = await repo.listWithCounts(profile.id);
    final already = await repo.collectionsOfEntry(entryId);
    if (!mounted) return;

    final chosen = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l10n.collectionAddTo),
        children: [
          for (final v in existing)
            SimpleDialogOption(
              onPressed: already.contains(v.collection.id)
                  ? null
                  : () => Navigator.of(ctx).pop(v.collection.id),
              child: Row(
                children: [
                  Icon(
                    already.contains(v.collection.id)
                        ? Icons.check_rounded
                        : Icons.collections_bookmark_outlined,
                    size: 18,
                  ),
                  const SizedBox(width: AppDimens.space12),
                  Expanded(child: Text(v.collection.name)),
                ],
              ),
            ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(ctx).pop('__new__'),
            child: Row(
              children: [
                const Icon(Icons.add_rounded, size: 18),
                const SizedBox(width: AppDimens.space12),
                Expanded(child: Text(l10n.collectionCreate)),
              ],
            ),
          ),
        ],
      ),
    );
    if (chosen == null || !mounted) return;

    var collectionId = chosen;
    if (chosen == '__new__') {
      final name = await TextInputDialog.show(
        context,
        title: l10n.collectionCreate,
        label: l10n.collectionNameLabel,
      );
      if (name == null || !mounted) return;
      final created = await repo.create(profile.id, name);
      collectionId = created.id;
    }

    await repo.addEntry(collectionId, entryId);
    _bump();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.collectionAdded)));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.transferAlreadyHave)));
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.transferDone)));
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
                    : DateFormat('d MMMM y', 'ru').format(value!),
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

/// Результат правки описания объекта.
typedef _ObjectEdit = ({String title, String? creator, int? year});

/// Диалог правки названия, бренда и года объекта.
class _ObjectEditDialog extends StatefulWidget {
  const _ObjectEditDialog({required this.object});
  final ObjectRow object;

  @override
  State<_ObjectEditDialog> createState() => _ObjectEditDialogState();
}

class _ObjectEditDialogState extends State<_ObjectEditDialog> {
  late final _title = TextEditingController(text: widget.object.title);
  late final _creator = TextEditingController(
    text: widget.object.creator ?? '',
  );
  late final _year = TextEditingController(
    text: widget.object.year?.toString() ?? '',
  );

  @override
  void dispose() {
    _title.dispose();
    _creator.dispose();
    _year.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return AlertDialog(
      title: Text(l10n.entryEditObject),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.entryEditObjectHint,
              style: context.text.labelSmall?.copyWith(color: c.textMuted),
            ),
            const SizedBox(height: AppDimens.space16),
            TextField(
              controller: _title,
              autofocus: true,
              decoration: InputDecoration(labelText: l10n.quickAddNameLabel),
            ),
            const SizedBox(height: AppDimens.space16),
            TextField(
              controller: _creator,
              decoration: InputDecoration(labelText: l10n.entryCreatorLabel),
            ),
            const SizedBox(height: AppDimens.space16),
            TextField(
              controller: _year,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.entryYearLabel),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () {
            final title = _title.text.trim();
            if (title.isEmpty) return;
            final creator = _creator.text.trim();
            Navigator.of(context).pop((
              title: title,
              creator: creator.isEmpty ? null : creator,
              year: int.tryParse(_year.text.trim()),
            ));
          },
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
