import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../core/domain/app_icons.dart';
import '../../core/domain/custom_fields.dart';
import '../../core/domain/relation.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/db/database.dart';
import '../../data/providers.dart';
import '../../data/services/image_service.dart';
import '../../design_system/design_system.dart';
import '../barcode/barcode_scan_sheet.dart';
import '../collections/collection_providers.dart';
import '../entry/pending_photos_field.dart';
import '../home/home_providers.dart';
import 'category_picker.dart';

/// Быстрое добавление записи (§11).
///
/// Обязательное поле — только название. Остальное раскрывается по кнопке
/// «Добавить подробности». Открывается диалогом на широком экране и нижним
/// листом на узком.
class QuickAddSheet extends ConsumerStatefulWidget {
  const QuickAddSheet({super.key, this.prefill, this.initialCategory});

  /// Данные, полученные сканированием штрихкода.
  final ScannedProduct? prefill;

  /// Категория, подставляемая заранее: форма открыта из ветки категорий.
  final CategoryRow? initialCategory;

  /// Показывает форму подходящим для платформы способом.
  static Future<bool> show(
    BuildContext context, {
    ScannedProduct? prefill,
    CategoryRow? initialCategory,
  }) async {
    final wide =
        MediaQuery.sizeOf(context).width >= AppDimens.breakpointExpanded;
    final result = wide
        ? await showDialog<bool>(
            context: context,
            builder: (_) => Dialog(
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: 560,
                child: QuickAddSheet(
                  prefill: prefill,
                  initialCategory: initialCategory,
                ),
              ),
            ),
          )
        : await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (_) => QuickAddSheet(
              prefill: prefill,
              initialCategory: initialCategory,
            ),
          );
    return result ?? false;
  }

  @override
  ConsumerState<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<QuickAddSheet> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _note = TextEditingController();

  String? _typeId;
  CategoryRow? _category;
  Relation? _relation;
  double? _rating;
  bool _showDetails = false;
  bool _busy = false;

  /// Штрихкод и бренд, полученные сканированием.
  String? _barcode;
  String? _creator;

  /// Значения пользовательских полей типа (§9).
  final Map<String, String> _customValues = {};

  /// Когда впечатление случилось на самом деле (§10).
  DateTime? _impressionDate;

  /// Фотографии, выбранные до сохранения: привязать их можно только к уже
  /// созданной версии записи (§16, §18).
  List<Uint8List> _photos = const [];

  /// Названия тегов, которые получит запись (§7.2).
  final List<String> _tags = [];

  /// Подборка, в которую запись попадёт сразу (§27).
  String? _collectionId;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
    _applyPrefill(widget.prefill);
  }

  void _applyPrefill(ScannedProduct? scanned) {
    if (scanned == null) return;
    _title.text = scanned.suggestedTitle;
    _barcode = scanned.code.isProductCode ? scanned.code.value : null;
    _creator = scanned.info?.brand;
    _showDetails = true;
  }

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    final scanned = await BarcodeScanSheet.show(context);
    if (scanned == null || !mounted) return;
    setState(() => _applyPrefill(scanned));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final profile = ref.read(activeProfileProvider);
    final typeId = _typeId;
    if (profile == null || typeId == null) return;

    setState(() => _busy = true);
    try {
      final repo = ref.read(entryRepositoryProvider);
      final title = _title.text.trim();

      // Штрихкод определяет товар однозначно: если он уже заводился, берём
      // существующий объект, не спрашивая про дубли.
      ObjectRow? object;
      final code = _barcode;
      if (code != null) object = await repo.findByBarcode(code);

      if (object == null) {
        // Поиск возможных дублей (§26): автоматически ничего не объединяем,
        // только предлагаем использовать существующий объект.
        final candidates = await repo.findDuplicateCandidates(typeId, title);
        if (candidates.isNotEmpty && mounted) {
          final chosen = await _askDuplicate(candidates);
          if (chosen == _DuplicateChoice.cancelled) return;
          if (chosen == _DuplicateChoice.useExisting) {
            object = candidates.first;
          }
        }
      }

      object ??= await repo.createObject(
        typeId: typeId,
        title: title,
        creator: _creator,
        barcode: _barcode,
        customFields: _customValues.isEmpty
            ? null
            : CustomField.encodeValues(_customValues),
      );

      final entry = await repo.createEntry(
        profileId: profile.id,
        objectId: object.id,
        relation: _relation?.name,
        rating: _rating,
        detailedNote: _note.text.trim().isEmpty ? null : _note.text.trim(),
        impressionDate: _impressionDate,
        primaryCategoryId: _category?.id,
      );

      for (final name in _tags) {
        await repo.addTag(profile.id, entry.id, name);
      }

      final collectionId = _collectionId;
      if (collectionId != null) {
        await ref
            .read(collectionRepositoryProvider)
            .addEntry(collectionId, entry.id);
      }

      await _attachPhotos(entry);

      ref.read(dataRefreshProvider.notifier).bump();
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Переносит выбранные в форме снимки в хранилище и привязывает к записи.
  ///
  /// Порядок сохраняется, первый становится обложкой — её видно в каталоге.
  /// Отклонённые файлы просто пропускаем: запись уже создана, и терять её
  /// из-за одной неудачной картинки нельзя.
  Future<void> _attachPhotos(ProfileEntryRow entry) async {
    final revisionId = entry.currentRevisionId;
    if (_photos.isEmpty || revisionId == null) return;

    final images = ImageService(ref.read(appDatabaseProvider));
    var rejected = 0;
    for (final bytes in _photos) {
      final result = await images.addFromBytes(bytes);
      final attachment = switch (result) {
        ImageAdded(attachment: final a) => a,
        ImageDuplicate(attachment: final a) => a,
        ImageRejected() => null,
      };
      if (attachment == null) {
        rejected++;
        continue;
      }
      await images.attachToEntry(
        entryId: entry.id,
        attachmentId: attachment.id,
        revisionId: revisionId,
      );
    }

    if (rejected > 0 && mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.photoRejected)));
    }
  }

  Future<void> _addTag() async {
    final l10n = AppLocalizations.of(context);
    final profile = ref.read(activeProfileProvider);
    if (profile == null) return;

    // Подсказываем уже заведённые теги: иначе «Острое» и «острое» разъедутся
    // в две метки.
    final existing = await ref
        .read(entryRepositoryProvider)
        .tagsOfProfile(profile.id);
    if (!mounted) return;

    final name = await TextInputDialog.show(
      context,
      title: l10n.tagAdd,
      label: l10n.tagNameLabel,
      suggestions: [for (final t in existing) t.name],
    );
    final trimmed = name?.trim() ?? '';
    if (trimmed.isEmpty) return;
    if (_tags.any((t) => t.toLowerCase() == trimmed.toLowerCase())) return;
    setState(() => _tags.add(trimmed));
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _impressionDate ?? now,
      firstDate: DateTime(now.year - 50),
      lastDate: now,
      locale: const Locale('ru'),
    );
    if (picked != null) setState(() => _impressionDate = picked);
  }

  /// Поля, заданные для выбранного типа объекта (§9).
  List<Widget> _customFieldInputs(
    List<ObjectTypeRow> types,
    AppLocalizations l10n,
  ) {
    final type = types.where((t) => t.id == _typeId).firstOrNull;
    if (type == null) return const [];
    final fields = CustomField.decodeSchema(type.fieldsSchema);
    if (fields.isEmpty) return const [];

    return [
      const SizedBox(height: AppDimens.space20),
      Text(l10n.fieldsValuesTitle, style: context.text.titleMedium),
      for (final field in fields) ...[
        const SizedBox(height: AppDimens.space12),
        if (field.kind == FieldKind.boolean)
          Row(
            children: [
              Expanded(child: Text(field.name)),
              Switch(
                value: _customValues[field.key] == 'true',
                onChanged: (v) =>
                    setState(() => _customValues[field.key] = '$v'),
              ),
            ],
          )
        else if (field.kind == FieldKind.choice)
          DropdownButtonFormField<String>(
            initialValue: _customValues[field.key],
            decoration: InputDecoration(labelText: field.name),
            items: [
              for (final choice in field.choices)
                DropdownMenuItem(value: choice, child: Text(choice)),
            ],
            onChanged: (v) =>
                setState(() => _customValues[field.key] = v ?? ''),
          )
        else
          TextFormField(
            initialValue: _customValues[field.key],
            keyboardType: field.kind == FieldKind.number
                ? TextInputType.number
                : TextInputType.text,
            decoration: InputDecoration(labelText: field.name),
            onChanged: (v) => _customValues[field.key] = v,
          ),
      ],
    ];
  }

  /// Спрашивает, что делать с найденными похожими объектами (§26).
  Future<_DuplicateChoice> _askDuplicate(List<ObjectRow> candidates) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<_DuplicateChoice>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.duplicateTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.duplicateMessage),
            const SizedBox(height: AppDimens.space12),
            for (final o in candidates.take(5))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.link_rounded, size: 16),
                    const SizedBox(width: AppDimens.space8),
                    Expanded(child: Text(o.title)),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(ctx).pop(_DuplicateChoice.keepSeparate),
            child: Text(l10n.duplicateKeepSeparate),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(ctx).pop(_DuplicateChoice.useExisting),
            child: Text(l10n.duplicateUseExisting),
          ),
        ],
      ),
    );
    return result ?? _DuplicateChoice.cancelled;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final types = ref.watch(objectTypesProvider);

    // Подставляем первый тип по умолчанию.
    final typeList = types.value ?? const <ObjectTypeRow>[];
    if (_typeId == null && typeList.isNotEmpty) {
      _typeId = typeList.first.id;
    }

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.space20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.quickAddTitle,
                        style: context.text.headlineSmall,
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.barcodeScanAction,
                      onPressed: _busy ? null : _scan,
                      icon: const Icon(Icons.qr_code_scanner_rounded),
                    ),
                    IconButton(
                      tooltip: l10n.commonClose,
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.space16),
                TextFormField(
                  controller: _title,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: l10n.quickAddNameLabel,
                    hintText: l10n.quickAddNameHint,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.quickAddNameRequired
                      : null,
                ),
                if (_barcode != null) ...[
                  const SizedBox(height: AppDimens.space8),
                  Row(
                    children: [
                      Icon(
                        Icons.qr_code_2_rounded,
                        size: 16,
                        color: c.accentPrimary,
                      ),
                      const SizedBox(width: AppDimens.space8),
                      Expanded(
                        child: Text(
                          l10n.quickAddBarcodeHint(_barcode!),
                          style: context.text.labelSmall?.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppDimens.space16),
                // Тип и категорию принимают за одно и то же: два одинаковых
                // поля друг под другом читались как повтор. Теперь они стоят
                // рядом, а под ними написано, чем отличаются.
                LayoutBuilder(
                  builder: (context, cns) {
                    final typeField = DropdownButtonFormField<String>(
                      initialValue: _typeId,
                      // Без общего значка слева: у каждого типа он свой, и два
                      // значка подряд в свёрнутом поле выглядели как ошибка.
                      decoration: InputDecoration(
                        labelText: l10n.quickAddTypeLabel,
                      ),
                      // Без ограничения список типов раскрывался на всю высоту
                      // экрана и перекрывал форму.
                      menuMaxHeight: 320,
                      borderRadius: AppDimens.brMd,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                      ),
                      items: [
                        for (final t in typeList)
                          DropdownMenuItem(
                            value: t.id,
                            child: Row(
                              children: [
                                Icon(
                                  AppIcons.byKey(t.icon),
                                  size: 18,
                                  color: c.textSecondary,
                                ),
                                const SizedBox(width: AppDimens.space12),
                                Flexible(
                                  child: Text(
                                    t.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (v) => setState(() => _typeId = v),
                    );
                    final categoryField = _CategoryField(
                      category: _category,
                      onPick: () async {
                        final picked = await CategoryPicker.show(context);
                        if (picked != null) {
                          setState(
                            () => _category = picked.cleared
                                ? null
                                : picked.category,
                          );
                        }
                      },
                    );
                    if (cns.maxWidth < 420) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          typeField,
                          const SizedBox(height: AppDimens.space12),
                          categoryField,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: typeField),
                        const SizedBox(width: AppDimens.space12),
                        Expanded(child: categoryField),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppDimens.space8),
                Text(
                  l10n.quickAddTypeVsCategory,
                  style: context.text.labelSmall?.copyWith(color: c.textMuted),
                ),
                const SizedBox(height: AppDimens.space16),
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
                        selected: _relation == r,
                        onSelected: (s) =>
                            setState(() => _relation = s ? r : null),
                        avatar: Icon(
                          r.icon,
                          size: 16,
                          color: _relation == r ? r.accent(c) : c.textSecondary,
                        ),
                        label: Text(r.label(l10n)),
                      ),
                  ],
                ),
                const SizedBox(height: AppDimens.space16),
                // Оценка и фотографии — на виду, а не за кнопкой «Подробности»:
                // это то, ради чего запись и заводят. Под кнопкой осталось
                // остальное — заметка, дата, теги, подборка, поля типа.
                Row(
                  children: [
                    Text(
                      l10n.quickAddRatingLabel,
                      style: context.text.labelSmall?.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _rating == null
                          ? l10n.quickAddRatingNone
                          : _rating!.toStringAsFixed(1),
                      style: context.text.labelMedium,
                    ),
                  ],
                ),
                Slider(
                  value: _rating ?? 0,
                  min: 0,
                  max: 10,
                  divisions: 20,
                  label: (_rating ?? 0).toStringAsFixed(1),
                  onChanged: (v) => setState(() => _rating = v),
                ),
                if (_rating != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => setState(() => _rating = null),
                      child: Text(l10n.quickAddRatingNone),
                    ),
                  ),
                const SizedBox(height: AppDimens.space16),
                PendingPhotosField(
                  photos: _photos,
                  enabled: !_busy,
                  onChanged: (list) => setState(() => _photos = list),
                ),
                const SizedBox(height: AppDimens.space16),
                if (!_showDetails)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => setState(() => _showDetails = true),
                      icon: const Icon(Icons.tune_rounded, size: 18),
                      label: Text(l10n.quickAddDetails),
                    ),
                  ),
                if (_showDetails) ...[
                  TextFormField(
                    controller: _note,
                    minLines: 2,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: l10n.quickAddNoteLabel,
                    ),
                  ),
                  const SizedBox(height: AppDimens.space16),
                  _ImpressionDateField(
                    value: _impressionDate,
                    onPick: _pickDate,
                    onClear: () => setState(() => _impressionDate = null),
                  ),
                  const SizedBox(height: AppDimens.space20),
                  // Теги и подборка — прямо здесь. Раньше за каждым из них
                  // приходилось открывать уже сохранённую запись.
                  _TagsField(
                    tags: _tags,
                    onAdd: _addTag,
                    onRemove: (t) => setState(() => _tags.remove(t)),
                  ),
                  const SizedBox(height: AppDimens.space16),
                  _CollectionField(
                    value: _collectionId,
                    onChanged: (id) => setState(() => _collectionId = id),
                  ),
                  // Пользовательские поля выбранного типа (§9).
                  ..._customFieldInputs(typeList, l10n),
                ],
                const SizedBox(height: AppDimens.space24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(l10n.commonCancel),
                      ),
                    ),
                    const SizedBox(width: AppDimens.space12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _busy || typeList.isEmpty ? null : _save,
                        // Сохранение с фотографиями занимает заметное время:
                        // каждый снимок разбирается и сжимается. Раньше кнопка
                        // просто гасла, и было непонятно, идёт ли что-нибудь.
                        child: _busy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(l10n.commonSave),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryField extends StatelessWidget {
  const _CategoryField({required this.category, required this.onPick});

  final CategoryRow? category;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return InkWell(
      onTap: onPick,
      borderRadius: AppDimens.brMd,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.quickAddCategoryLabel,
          suffixIcon: const Icon(Icons.chevron_right_rounded),
        ),
        child: Text(
          category?.name ?? l10n.quickAddNoCategory,
          style: context.text.bodyMedium?.copyWith(
            color: category == null ? c.textMuted : c.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// Что делать с найденными похожими объектами (§26).
enum _DuplicateChoice { useExisting, keepSeparate, cancelled }

/// Теги новой записи (§7.2).
class _TagsField extends StatelessWidget {
  const _TagsField({
    required this.tags,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> tags;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l10n.tagsLabel, style: context.text.titleMedium),
            const Spacer(),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(l10n.tagAdd),
            ),
          ],
        ),
        if (tags.isEmpty)
          Text(
            l10n.tagsHint,
            style: context.text.labelSmall?.copyWith(color: c.textMuted),
          )
        else
          Wrap(
            spacing: AppDimens.space8,
            runSpacing: AppDimens.space8,
            children: [
              for (final tag in tags)
                InputChip(
                  label: Text(tag),
                  onDeleted: () => onRemove(tag),
                  deleteIcon: const Icon(Icons.close_rounded, size: 16),
                ),
            ],
          ),
      ],
    );
  }
}

/// Подборка, в которую запись попадёт сразу после сохранения (§27).
class _CollectionField extends ConsumerWidget {
  const _CollectionField({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(activeProfileProvider);
    final collections = ref.watch(collectionsProvider).value ?? const [];

    Future<void> create() async {
      if (profile == null) return;
      final name = await TextInputDialog.show(
        context,
        title: l10n.collectionCreate,
        label: l10n.collectionNameLabel,
      );
      if (name == null) return;
      final created = await ref
          .read(collectionRepositoryProvider)
          .create(profile.id, name);
      ref.read(dataRefreshProvider.notifier).bump();
      onChanged(created.id);
    }

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String?>(
            initialValue: collections.any((c) => c.collection.id == value)
                ? value
                : null,
            decoration: InputDecoration(labelText: l10n.collectionAddTo),
            menuMaxHeight: 320,
            borderRadius: AppDimens.brMd,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
            items: [
              DropdownMenuItem(
                value: null,
                child: Text(l10n.quickAddNoCategory),
              ),
              for (final v in collections)
                DropdownMenuItem(
                  value: v.collection.id,
                  child: Text(v.collection.name),
                ),
            ],
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: AppDimens.space8),
        AppIconButton(
          icon: Icons.add_rounded,
          tooltip: l10n.collectionCreate,
          onPressed: create,
        ),
      ],
    );
  }
}

/// Выбор даты впечатления в форме добавления.
class _ImpressionDateField extends StatelessWidget {
  const _ImpressionDateField({
    required this.value,
    required this.onPick,
    required this.onClear,
  });

  final DateTime? value;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return InkWell(
      onTap: onPick,
      borderRadius: AppDimens.brMd,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.entryImpressionDate,
          suffixIcon: value == null
              ? const Icon(Icons.event_rounded)
              : IconButton(
                  tooltip: l10n.entryImpressionDateClear,
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded),
                ),
        ),
        child: Text(
          value == null
              ? l10n.entryImpressionDateNone
              : DateFormat('d MMMM y', 'ru').format(value!),
          style: context.text.bodyMedium?.copyWith(
            color: value == null ? c.textMuted : c.textPrimary,
          ),
        ),
      ),
    );
  }
}
