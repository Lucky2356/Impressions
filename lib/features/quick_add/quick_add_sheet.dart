import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../core/domain/app_icons.dart';
import '../../core/domain/custom_fields.dart';
import '../../core/domain/entry_status.dart';
import '../../core/domain/relation.dart';
import '../../core/utils/normalize.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/db/database.dart';
import '../../data/models/category_tree.dart';
import '../../data/models/entry_view.dart';
import '../../data/providers.dart';
import '../../data/repositories/draft_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/services/image_service.dart';
import '../../design_system/design_system.dart';
import '../barcode/barcode_scan_sheet.dart';
import '../categories/category_providers.dart';
import '../entry/pending_photos_field.dart';
import '../entry/status_field.dart';
import '../home/home_providers.dart';
import 'category_picker.dart';
import 'quick_add_draft.dart';
import 'quick_add_fields.dart';

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
    final result = await showAdaptiveSheet<bool>(
      context,
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

  /// Ещё полки, на которых должна лежать запись (§7.2).
  final List<CategoryRow> _extraCategories = [];
  Relation? _relation;
  double? _rating;

  /// Стадия записи (§10): «дошли ли вы до этого».
  ///
  /// Отдельно от отношения: заводя задумку, человек ставит стадию и не ставит
  /// мнения — раньше для этого приходилось выбирать отношение «Хочу
  /// попробовать», то есть отвечать не на тот вопрос.
  String? _status;

  /// Прогресс, если тип знает, в чём его считать.
  final _progressCurrent = TextEditingController();
  final _progressTotal = TextEditingController();

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
    _progressCurrent.addListener(_scheduleDraftSave);
    _progressTotal.addListener(_scheduleDraftSave);
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
    _progressCurrent.dispose();
    _progressTotal.dispose();
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
    _pauseFieldListeners();
    _title.text = draft.title;
    _note.text = draft.note;
    _progressCurrent.text = draft.progressCurrent?.toString() ?? '';
    _progressTotal.text = draft.progressTotal?.toString() ?? '';
    _resumeFieldListeners();

    super.setState(() {
      _status = draft.status;
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
    status: _status,
    progressCurrent: progressValueOf(_progressCurrent),
    progressTotal: progressValueOf(_progressTotal),
    showDetails: _showDetails,
    barcode: _barcode,
    creator: _creator,
    customValues: Map.of(_customValues),
    impressionDate: _impressionDate,
    tags: List.of(_tags),
    collectionId: _collectionId,
  );

  /// Снимает слушателей полей на время подстановки: иначе первое же
  /// присвоение запустило бы запись наполовину восстановленного черновика.
  void _pauseFieldListeners() {
    _title.removeListener(_scheduleDraftSave);
    _note.removeListener(_scheduleDraftSave);
    _progressCurrent.removeListener(_scheduleDraftSave);
    _progressTotal.removeListener(_scheduleDraftSave);
  }

  void _resumeFieldListeners() {
    _title.addListener(_scheduleDraftSave);
    _note.addListener(_scheduleDraftSave);
    _progressCurrent.addListener(_scheduleDraftSave);
    _progressTotal.addListener(_scheduleDraftSave);
  }

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
    _progressCurrent.clear();
    _progressTotal.clear();
    // Форма остаётся открытой: то, что человек наберёт дальше, снова надо
    // беречь.
    _draftOff = false;
    super.setState(() {
      _typePicked = false;
      _category = widget.initialCategory;
      _relation = null;
      _rating = null;
      _status = null;
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
    _pauseFieldListeners();
    _title.clear();
    _note.clear();
    _progressCurrent.clear();
    _progressTotal.clear();
    _resumeFieldListeners();

    super.setState(() {
      _rating = null;
      _relation = null;
      _status = null;
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
        status: _status,
        progressCurrent: progressValueOf(_progressCurrent),
        progressTotal: progressValueOf(_progressTotal),
        detailedNote: _note.text.trim().isEmpty ? null : _note.text.trim(),
        impressionDate: _impressionDate,
        primaryCategoryId: _category?.id,
        extraCategoryIds: [for (final x in _extraCategories) x.id],
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
      showMessage(context, l10n.photoRejected);
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
  Future<DuplicateAnswer> _askDuplicate(List<ObjectRow> candidates) async {
    final result = await showDialog<DuplicateAnswer>(
      context: context,
      builder: (ctx) =>
          DuplicateDialog(candidates: candidates.take(5).toList()),
    );
    return result ?? const DuplicateAnswer.cancelled();
  }

  /// Добавляет ещё одну полку, не предлагая уже занятые.
  Future<void> _pickExtraCategory() async {
    final taken = {?_category?.id, for (final x in _extraCategories) x.id};
    final picked = await CategoryPicker.show(
      context,
      title: AppLocalizations.of(context).categoryExtraAdd,
      allowClear: false,
      excludeIds: taken,
    );
    final category = picked?.category;
    if (category == null) return;
    setState(() => _extraCategories.add(category));
  }

  /// Тип, заданный веткой, и откуда он взят; null — ветка ничего не говорит.
  ///
  /// Раньше тип угадывался по совпадению названий категории и типа. Правило
  /// жило в коде, нигде не показывалось и не правилось — теперь это поле
  /// ветки, и форма говорит, из какой именно.
  ({String typeId, CategoryRow from})? _branchType(List<ObjectTypeRow> types) {
    final category = _category;
    if (category == null || types.isEmpty) return null;
    final categories = ref.watch(allCategoriesProvider).value ?? const [];

    final found = CategoryTree.defaultTypeFor(categories, category);
    if (found == null) return null;
    // Тип мог быть убран из профиля: ссылка обнулится не сразу, а подставлять
    // несуществующее нельзя.
    if (!types.any((t) => t.id == found.typeId)) return null;
    return found;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final types = ref.watch(objectTypesProvider);
    final typeList = types.value ?? const <ObjectTypeRow>[];

    // Тип по категории, а не первый из списка: форма, открытая из «Мест ›
    // Парков», предлагала «Продукты» просто потому, что этот тип идёт первым.
    final fromBranch = _branchType(typeList);
    if (!_typePicked && typeList.isNotEmpty) {
      _typeId = fromBranch?.typeId ?? _typeId ?? typeList.first.id;
    }

    // Стадии и единица прогресса — свойства типа, поэтому смена типа меняет и
    // набор чипов. Стадия, которой у нового типа нет, не показывается вовсе:
    // выбранной она выглядела бы, не будучи ни одной из предложенных.
    final type = typeList.where((t) => t.id == _typeId).firstOrNull;
    final statuses = EntryStatus.decode(type?.statusesJson);
    final progressUnit = type?.progressUnit;

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
                  DraftBanner(onDiscard: _discardDraft),
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
                        // Ключи стадий общие, но набор у каждого типа свой:
                        // «Читаю» в товарах взяться неоткуда.
                        final next = typeList
                            .where((t) => t.id == v)
                            .firstOrNull;
                        final keys = EntryStatus.decode(
                          next?.statusesJson,
                        ).map((s) => s.key);
                        if (!keys.contains(_status)) _status = null;
                      }),
                    );
                    final categoryField = CategoryField(
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
                // Дополнительные полки прячутся за ссылкой: форма и так
                // плотная, а нужны они изредка.
                ExtraCategoriesField(
                  categories: _extraCategories,
                  onAdd: _pickExtraCategory,
                  onRemove: (id) => setState(
                    () => _extraCategories.removeWhere((x) => x.id == id),
                  ),
                ),
                const SizedBox(height: AppDimens.space8),
                Text(
                  // Подстановка типа больше не догадка: видно, какая ветка её
                  // задала, и туда же можно пойти и поправить.
                  fromBranch == null || _typePicked
                      ? l10n.quickAddTypeVsCategory
                      : l10n.categoryDefaultTypeFrom(fromBranch.from.name),
                  style: context.text.labelSmall?.copyWith(color: c.textMuted),
                ),
                const SizedBox(height: AppDimens.space16),
                // Стадия перед отношением: заводя задумку, человек отвечает
                // «ещё не дошёл» и не отвечает «понравилось». Раньше для
                // первого приходилось выбирать отношение «Хочу попробовать».
                if (statuses.isNotEmpty) ...[
                  StatusField(
                    statuses: statuses,
                    value: _status,
                    onChanged: (key) => setState(() => _status = key),
                    showEmptyHint: false,
                  ),
                  const SizedBox(height: AppDimens.space16),
                ],
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
                  ImpressionDateField(
                    value: _impressionDate,
                    onPick: _pickDate,
                    onClear: () => setState(() => _impressionDate = null),
                  ),
                  const SizedBox(height: AppDimens.space16),
                  // Прогресс — под «Подробностями»: у большинства записей его
                  // не ведут, а форма и так плотная.
                  if (progressUnit != null) ...[
                    ProgressField(
                      unit: progressUnit,
                      current: _progressCurrent,
                      total: _progressTotal,
                      enabled: !_busy,
                    ),
                    const SizedBox(height: AppDimens.space16),
                  ],
                  const SizedBox(height: AppDimens.space4),
                  // Теги и подборка — прямо здесь. Раньше за каждым из них
                  // приходилось открывать уже сохранённую запись.
                  TagsField(
                    tags: _tags,
                    onAdd: _addTag,
                    onRemove: (t) => setState(() => _tags.remove(t)),
                  ),
                  const SizedBox(height: AppDimens.space16),
                  CollectionField(
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
