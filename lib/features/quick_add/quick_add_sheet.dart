import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../core/domain/app_icons.dart';
import '../../core/domain/custom_fields.dart';
import '../../core/domain/relation.dart';
import '../../core/utils/normalize.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/db/database.dart';
import '../../data/models/entry_view.dart';
import '../../data/providers.dart';
import '../../data/repositories/draft_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/services/image_service.dart';
import '../../design_system/design_system.dart';
import '../barcode/barcode_scan_sheet.dart';
import '../categories/category_providers.dart';
import '../collections/collection_providers.dart';
import '../entry/pending_photos_field.dart';
import '../home/home_providers.dart';
import 'category_picker.dart';
import 'quick_add_draft.dart';
import 'type_for_category.dart';

/// Быстрое добавление записи (§11).
///
/// Обязательное поле — только название. Остальное раскрывается по кнопке
/// «Добавить подробности». Открывается диалогом на широком экране и нижним
/// листом на узком.
class QuickAddSheet extends ConsumerStatefulWidget {
  const QuickAddSheet({
    super.key,
    this.prefill,
    this.initialCategory,
    this.queue = const [],
    this.duplicateOf,
  });

  /// Данные, полученные сканированием штрихкода.
  final ScannedProduct? prefill;

  /// Категория, подставляемая заранее: форма открыта из ветки категорий.
  final CategoryRow? initialCategory;

  /// Очередь отсканированного подряд: следующая позиция подставляется сама
  /// после сохранения предыдущей — форму на каждую не открывают заново.
  final List<ScannedProduct> queue;

  /// Запись, с которой снимается копия: «то же, но другой бренд».
  final EntryView? duplicateOf;

  /// Показывает форму подходящим для платформы способом.
  static Future<bool> show(
    BuildContext context, {
    ScannedProduct? prefill,
    CategoryRow? initialCategory,
    List<ScannedProduct> queue = const [],
    EntryView? duplicateOf,
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
                  queue: queue,
                  duplicateOf: duplicateOf,
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
              queue: queue,
              duplicateOf: duplicateOf,
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

  /// Курсор в названии: после «Сохранить и ещё» он должен вернуться сюда.
  final _titleFocus = FocusNode();

  String? _typeId;

  /// Тип выбран человеком, а не подставлен по категории.
  ///
  /// Пока этого не случилось, смена категории меняет и тип: иначе угаданное
  /// один раз значение застревало бы после того, как категорию поправили.
  bool _typePicked = false;

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

  /// Черновик восстановлен — над формой висит полоска с «Очистить».
  bool _draftRestored = false;

  /// Черновик прочитан: до этого сохранять нечего и нельзя — можно затереть
  /// то, что ещё не успели подставить.
  bool _draftLoaded = false;

  /// Черновик больше не ведём.
  ///
  /// После сохранения записи форма ещё раз дёргает `setState` — гасит кружок
  /// на кнопке. Без этого признака черновик, только что удалённый, тут же
  /// записывался обратно, и следующее добавление предлагало продолжить то,
  /// что уже сохранено.
  bool _draftOff = false;

  Timer? _draftTimer;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
    // Пачка сканирования: первый код подставляется сразу, остальные ждут
    // своей очереди.
    _queue = List.of(widget.queue);
    _applyPrefill(
      widget.prefill ?? (_queue.isEmpty ? null : _queue.removeAt(0)),
    );
    _applyDuplicate();
    // Набор в полях сам по себе не вызывает setState, поэтому черновик
    // отмечается изменённым отдельно.
    _title.addListener(_scheduleDraftSave);
    _note.addListener(_scheduleDraftSave);
    _restoreDraft();
  }

  /// Заполняет форму по записи, с которой снимают копию.
  ///
  /// Тип и категория берутся по названию: карточка знает их именами, а форме
  /// нужны идентификаторы.
  Future<void> _applyDuplicate() async {
    final source = widget.duplicateOf;
    final profile = ref.read(activeProfileProvider);
    if (source == null || profile == null) return;

    _title.text = source.title;
    _relation = Relation.values
        .where((r) => r.name == source.relation)
        .firstOrNull;
    _rating = source.rating;
    _showDetails = true;

    final types = await ref
        .read(entryRepositoryProvider)
        .objectTypes(profile.id);
    final type = types
        .where((t) => Normalize.name(t.name) == Normalize.name(source.typeName))
        .firstOrNull;

    CategoryRow? category;
    if (source.categoryPath.isNotEmpty) {
      final all = await ref.read(allCategoriesProvider.future);
      final wanted = Normalize.name(source.categoryPath.last);
      category = all.where((c) => c.normalizedName == wanted).firstOrNull;
    }
    if (!mounted) return;

    super.setState(() {
      if (type != null) {
        _typeId = type.id;
        _typePicked = true;
      }
      _category ??= category;
    });
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
    _draftTimer?.cancel();
    _titleFocus.dispose();
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  /// Любое изменение формы откладывает запись черновика.
  ///
  /// Через `setState`, потому что через него проходят все изменения формы:
  /// иначе пришлось бы дописывать вызов в каждый обработчик и однажды забыть.
  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    _scheduleDraftSave();
  }

  /// Подставляет незаконченную форму с прошлого раза.
  ///
  /// Форма живёт в модальном окне и до «Сохранить» не хранится нигде: Android
  /// выгружает приложение, пока человек выбирает фотографию в галерее, и всё
  /// набранное пропадает. Со сканированием черновик не подставляется — там
  /// поля заполнены осознанно и подмена сбила бы с толку.
  Future<void> _restoreDraft() async {
    final profile = ref.read(activeProfileProvider);
    if (profile == null ||
        widget.prefill != null ||
        widget.duplicateOf != null) {
      _draftLoaded = true;
      return;
    }

    final saved = await ref
        .read(draftRepositoryProvider)
        .read(profile.id, DraftRepository.quickAddKind);
    if (!mounted) return;
    if (saved == null) {
      await _restoreLastPlace();
      _draftLoaded = true;
      return;
    }

    final draft = QuickAddDraft.fromJson(saved);
    if (draft.isEmpty) {
      await _restoreLastPlace();
      _draftLoaded = true;
      return;
    }

    // Категорию черновик хранит идентификатором: её надо найти в дереве.
    // Открытая из ветки форма свою категорию не отдаёт — человек только что
    // указал её нажатием.
    CategoryRow? category = widget.initialCategory;
    if (category == null && draft.categoryId != null) {
      final categories = await ref.read(allCategoriesProvider.future);
      if (!mounted) return;
      category = categories.where((c) => c.id == draft.categoryId).firstOrNull;
    }

    // Слушатели полей сняты на время подстановки: иначе первое же присвоение
    // запустило бы запись наполовину восстановленного черновика.
    _title.removeListener(_scheduleDraftSave);
    _note.removeListener(_scheduleDraftSave);
    _title.text = draft.title;
    _note.text = draft.note;
    _title.addListener(_scheduleDraftSave);
    _note.addListener(_scheduleDraftSave);

    super.setState(() {
      _typeId = draft.typeId;
      _typePicked = draft.typePicked;
      _category = category;
      _relation = Relation.values
          .where((r) => r.name == draft.relation)
          .firstOrNull;
      _rating = draft.rating;
      _showDetails = draft.showDetails || _showDetails;
      _barcode = draft.barcode;
      _creator = draft.creator;
      _customValues
        ..clear()
        ..addAll(draft.customValues);
      _impressionDate = draft.impressionDate;
      _tags
        ..clear()
        ..addAll(draft.tags);
      _collectionId = draft.collectionId;
      _draftRestored = true;
      _draftLoaded = true;
    });
  }

  /// Подставляет категорию и тип из прошлой записи.
  ///
  /// Записи подряд обычно кладут в одно место, а форма помнила категорию
  /// только при входе из ветки: с главной и из каталога её выбирали каждый
  /// раз заново. Черновик важнее — это незаконченная работа, а не привычка,
  /// поэтому подстановка идёт только когда черновика нет.
  Future<void> _restoreLastPlace() async {
    if (widget.initialCategory != null) return;

    final settings = ref.read(settingsRepositoryProvider);
    final categoryId = await settings.get(SettingKeys.quickAddLastCategory);
    final typeId = await settings.get(SettingKeys.quickAddLastType);
    if (!mounted) return;

    CategoryRow? category;
    if (categoryId != null && categoryId.isNotEmpty) {
      final categories = await ref.read(allCategoriesProvider.future);
      if (!mounted) return;
      category = categories.where((c) => c.id == categoryId).firstOrNull;
    }
    if (category == null && (typeId == null || typeId.isEmpty)) return;

    // Через super.setState: обычный setState записал бы черновик, и следующее
    // открытие формы предложило бы «продолжить» пустую подстановку.
    super.setState(() {
      _category ??= category;
      if (typeId != null && typeId.isNotEmpty) _typeId ??= typeId;
    });
  }

  /// Запоминает, куда положили, — чтобы следующая запись открылась там же.
  Future<void> _rememberLastPlace() async {
    final settings = ref.read(settingsRepositoryProvider);
    await settings.set(SettingKeys.quickAddLastCategory, _category?.id ?? '');
    await settings.set(SettingKeys.quickAddLastType, _typeId ?? '');
  }

  QuickAddDraft _draft() => QuickAddDraft(
    title: _title.text,
    note: _note.text,
    typeId: _typeId,
    typePicked: _typePicked,
    categoryId: _category?.id,
    relation: _relation?.name,
    rating: _rating,
    showDetails: _showDetails,
    barcode: _barcode,
    creator: _creator,
    customValues: Map.of(_customValues),
    impressionDate: _impressionDate,
    tags: List.of(_tags),
    collectionId: _collectionId,
  );

  /// Пишет черновик с задержкой: на каждую букву в базу ходить незачем.
  void _scheduleDraftSave() {
    if (!_draftLoaded || _draftOff) return;
    _draftTimer?.cancel();
    _draftTimer = Timer(const Duration(milliseconds: 600), _saveDraft);
  }

  Future<void> _saveDraft() async {
    final profile = ref.read(activeProfileProvider);
    if (profile == null || !mounted) return;
    final drafts = ref.read(draftRepositoryProvider);
    final draft = _draft();
    // Пустой черновик не хранится и стирает прежний: иначе форма предлагала бы
    // продолжить то, что человек уже очистил.
    if (draft.isEmpty) {
      await drafts.clear(profile.id, DraftRepository.quickAddKind);
      return;
    }
    await drafts.write(
      profile.id,
      DraftRepository.quickAddKind,
      draft.toJson(),
    );
  }

  /// Убирает черновик — после сохранения записи и по кнопке «Очистить».
  Future<void> _clearDraft() async {
    _draftTimer?.cancel();
    _draftOff = true;
    final profile = ref.read(activeProfileProvider);
    if (profile == null) return;
    await ref
        .read(draftRepositoryProvider)
        .clear(profile.id, DraftRepository.quickAddKind);
  }

  /// Сбрасывает форму к пустой по кнопке в полоске черновика.
  void _discardDraft() {
    _clearDraft();
    _title.clear();
    _note.clear();
    // Форма остаётся открытой: то, что человек наберёт дальше, снова надо
    // беречь.
    _draftOff = false;
    super.setState(() {
      _typePicked = false;
      _category = widget.initialCategory;
      _relation = null;
      _rating = null;
      _barcode = null;
      _creator = null;
      _customValues.clear();
      _impressionDate = null;
      _tags.clear();
      _collectionId = null;
      _draftRestored = false;
    });
  }

  Future<void> _scan() async {
    final scanned = await BarcodeScanSheet.show(context);
    if (scanned == null || !mounted) return;
    setState(() => _applyPrefill(scanned));
  }

  /// Сколько записей заведено подряд, не закрывая форму.
  int _savedInARow = 0;

  /// Отсканированное, что ещё ждёт своей формы.
  List<ScannedProduct> _queue = const [];

  /// Сохраняет и оставляет форму открытой для следующей записи.
  ///
  /// Заводя пять записей подряд, форму открывали пять раз, хотя категория и
  /// тип уже подставляются сами. Место, тип и подборка остаются, остальное
  /// очищается, курсор снова в названии.
  Future<void> _saveAndContinue() async {
    await _save(keepOpen: true);
  }

  /// Готовит форму к следующей записи: место остаётся, остальное очищается.
  void _resetForNext() {
    _title.removeListener(_scheduleDraftSave);
    _note.removeListener(_scheduleDraftSave);
    _title.clear();
    _note.clear();
    _title.addListener(_scheduleDraftSave);
    _note.addListener(_scheduleDraftSave);

    super.setState(() {
      _rating = null;
      _relation = null;
      _photos = const [];
      _tags.clear();
      _barcode = null;
      _creator = null;
      _customValues.clear();
      _impressionDate = null;
      // Следующий код из пачки заполняет форму сам.
      if (_queue.isNotEmpty) _applyPrefill(_queue.removeAt(0));
    });
    _titleFocus.requestFocus();
  }

  Future<void> _save({bool keepOpen = false}) async {
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
          final answer = await _askDuplicate(candidates);
          if (answer.cancelled) return;
          object = answer.chosen;
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

      // Запись создана — черновику больше нечего беречь.
      await _clearDraft();
      await _rememberLastPlace();

      ref.read(dataRefreshProvider.notifier).bump();
      if (!mounted) return;
      if (keepOpen || _queue.isNotEmpty) {
        _savedInARow++;
        _resetForNext();
      } else {
        Navigator.of(context).pop(true);
      }
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
            onChanged: (v) {
              _customValues[field.key] = v;
              _scheduleDraftSave();
            },
          ),
      ],
    ];
  }

  /// Спрашивает, что делать с найденными похожими объектами (§26).
  ///
  /// Похожих бывает несколько, и раньше диалог их показывал, а привязывал
  /// всегда к первому: увидели «Чай зелёный», «Чай чёрный», «Чай с бергамотом»,
  /// нажали «Использовать существующий» — и запись молча уходила к первому.
  /// Теперь строку выбирают, и кнопка без выбора не работает.
  Future<_DuplicateAnswer> _askDuplicate(List<ObjectRow> candidates) async {
    final result = await showDialog<_DuplicateAnswer>(
      context: context,
      builder: (ctx) =>
          _DuplicateDialog(candidates: candidates.take(5).toList()),
    );
    return result ?? const _DuplicateAnswer.cancelled();
  }

  /// Тип, подсказанный выбранной категорией; null — подсказки нет.
  String? _guessType(List<ObjectTypeRow> types) {
    final category = _category;
    if (category == null) return null;
    final categories = ref.watch(allCategoriesProvider).value ?? const [];

    // Сначала по имени ветки: это попадает почти всегда и ничего не читает.
    final byName = typeForCategory(
      category: category,
      categories: categories,
      types: types,
    );
    if (byName != null) return byName;

    // И только если имя ничего не сказало — смотрим, что в ветке уже лежит.
    final entries =
        ref.watch(categoryEntriesProvider(category.id)).value ??
        const <EntryView>[];
    if (entries.isEmpty) return null;
    return typeForCategory(
      category: category,
      categories: categories,
      types: types,
      branchTypeNames: [for (final e in entries) e.typeName],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final types = ref.watch(objectTypesProvider);
    final typeList = types.value ?? const <ObjectTypeRow>[];

    // Тип по категории, а не первый из списка: форма, открытая из «Мест ›
    // Парков», предлагала «Продукты» просто потому, что этот тип идёт первым.
    if (!_typePicked && typeList.isNotEmpty) {
      _typeId = _guessType(typeList) ?? _typeId ?? typeList.first.id;
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
                if (_draftRestored) ...[
                  const SizedBox(height: AppDimens.space12),
                  _DraftBanner(onDiscard: _discardDraft),
                ],
                const SizedBox(height: AppDimens.space16),
                TextFormField(
                  controller: _title,
                  focusNode: _titleFocus,
                  autofocus: true,
                  // Enter сохраняет: поле и так под курсором, а тянуться за
                  // кнопкой вниз ради самой частой формы в приложении незачем.
                  // Повторное нажатие безопасно — мешает `_busy`.
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) {
                    if (!_busy) _save();
                  },
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
                      // Ключ по значению: `initialValue` у поля формы
                      // применяется только при создании, а тип приходит
                      // позже — вместе с ответом на запрос категорий.
                      key: ValueKey(_typeId),
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
                      onChanged: (v) => setState(() {
                        _typeId = v;
                        _typePicked = true;
                      }),
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
                RatingPicker(
                  value: _rating,
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
                if (_queue.isNotEmpty) ...[
                  Text(
                    l10n.barcodeBatchQueue(_queue.length),
                    style: context.text.labelSmall?.copyWith(
                      color: context.colors.accentPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimens.space8),
                ],
                if (_savedInARow > 0) ...[
                  Text(
                    l10n.quickAddSavedInARow(_savedInARow),
                    style: context.text.labelSmall?.copyWith(
                      color: context.colors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppDimens.space8),
                ],
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.of(context).pop(_savedInARow > 0),
                        child: Text(
                          _savedInARow > 0
                              ? l10n.commonClose
                              : l10n.commonCancel,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimens.space12),
                    // Записи заводят сериями, а форма закрывалась после каждой.
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _busy || typeList.isEmpty
                            ? null
                            : _saveAndContinue,
                        child: Text(l10n.quickAddSaveAndMore),
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

/// Полоска о восстановленном черновике.
///
/// Не диалог: продолжить недописанное человек хочет почти всегда, а спрашивать
/// об этом до того, как он увидел форму, — лишний шаг. Полоска говорит, что
/// произошло, и даёт начать с чистого листа.
class _DraftBanner extends StatelessWidget {
  const _DraftBanner({required this.onDiscard});

  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space12,
        AppDimens.space8,
        AppDimens.space8,
        AppDimens.space8,
      ),
      decoration: BoxDecoration(
        color: c.accentSoft,
        borderRadius: AppDimens.brMd,
      ),
      child: Row(
        children: [
          Icon(Icons.history_rounded, size: 18, color: c.accentPrimary),
          const SizedBox(width: AppDimens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.quickAddDraftRestored, style: context.text.bodySmall),
                Text(
                  l10n.quickAddDraftNoPhotos,
                  style: context.text.labelSmall?.copyWith(color: c.textMuted),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onDiscard,
            child: Text(l10n.quickAddDraftDiscard),
          ),
        ],
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

/// Что решили насчёт найденных похожих объектов (§26).
class _DuplicateAnswer {
  const _DuplicateAnswer.useExisting(ObjectRow object)
    : chosen = object,
      cancelled = false;
  const _DuplicateAnswer.keepSeparate() : chosen = null, cancelled = false;
  const _DuplicateAnswer.cancelled() : chosen = null, cancelled = true;

  /// Выбранный объект; null — заводим новый.
  final ObjectRow? chosen;

  /// Диалог закрыли, ничего не решив: сохранение отменяется.
  final bool cancelled;
}

/// Выбор среди похожих объектов.
class _DuplicateDialog extends StatefulWidget {
  const _DuplicateDialog({required this.candidates});

  final List<ObjectRow> candidates;

  @override
  State<_DuplicateDialog> createState() => _DuplicateDialogState();
}

class _DuplicateDialogState extends State<_DuplicateDialog> {
  /// Ничего не выбрано заранее: подставленный выбор человек принимает не
  /// глядя, а объединение объектов — не то, что стоит делать за него.
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selected = widget.candidates
        .where((o) => o.id == _selectedId)
        .firstOrNull;

    return AlertDialog(
      title: Text(l10n.duplicateTitle),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.duplicateMessage),
            const SizedBox(height: AppDimens.space12),
            RadioGroup<String>(
              groupValue: _selectedId,
              onChanged: (v) => setState(() => _selectedId = v),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final o in widget.candidates)
                    RadioListTile<String>(
                      value: o.id,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(
                        o.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: o.creator == null ? null : Text(o.creator!),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(const _DuplicateAnswer.keepSeparate()),
          child: Text(l10n.duplicateKeepSeparate),
        ),
        FilledButton(
          onPressed: selected == null
              ? null
              : () => Navigator.of(
                  context,
                ).pop(_DuplicateAnswer.useExisting(selected)),
          child: Text(l10n.duplicateUseExisting),
        ),
      ],
    );
  }
}

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
