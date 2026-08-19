import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../../core/domain/entry_status.dart';
import '../../core/utils/chunks.dart';
import '../../core/utils/ids.dart';
import '../../core/utils/normalize.dart';
import '../db/database.dart';
import '../models/entry_view.dart';
import '../services/image_service.dart';
import '../services/revision_service.dart';

/// Репозиторий типов объектов, объектов и записей профилей (§6).
/// Объект (общая информация) и запись профиля (мнение) разделены.
///
/// Все изменения объектов и записей фиксируются как неизменяемые версии (§18).
class EntryRepository {
  /// [mediaDirectory] задаёт каталог изображений в тестах: обложки в списках
  /// собираются как абсолютные пути, а в приложении их корень — папка данных.
  EntryRepository(this.db, {Directory? mediaDirectory})
    : revisions = RevisionService(db),
      _images = ImageService(db, mediaDirectory: mediaDirectory);

  final AppDatabase db;
  final RevisionService revisions;
  final ImageService _images;

  // ---- Типы объектов ----

  Future<ObjectTypeRow> createObjectType(
    String profileId,
    String name, {
    String? icon,
    int? color,
    bool builtIn = false,
    int sortOrder = 0,
    String? statusesJson,
    String? progressUnit,
  }) async {
    final id = Ids.newId();
    await db
        .into(db.objectTypes)
        .insert(
          ObjectTypesCompanion.insert(
            id: id,
            profileId: profileId,
            name: name,
            normalizedName: Normalize.name(name),
            icon: Value(icon),
            color: Value(color),
            builtIn: Value(builtIn),
            sortOrder: Value(sortOrder),
            statusesJson: Value(statusesJson),
            progressUnit: Value(progressUnit),
            createdAt: DateTime.now(),
          ),
        );
    return (db.select(
      db.objectTypes,
    )..where((t) => t.id.equals(id))).getSingle();
  }

  Future<List<ObjectTypeRow>> objectTypes(String profileId) {
    return (db.select(db.objectTypes)
          ..where((t) => t.profileId.equals(profileId) & t.archivedAt.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .get();
  }

  // ---- Объекты ----

  Future<ObjectRow> createObject({
    required String typeId,
    required String title,
    String? altTitle,
    String? summary,
    String? creator,
    int? year,
    String? barcode,
    String? customFields,
  }) async {
    final id = Ids.newId();
    await db
        .into(db.objects)
        .insert(
          ObjectsCompanion.insert(
            id: id,
            typeId: typeId,
            title: title,
            normalizedTitle: Normalize.name(title),
            altTitle: Value(altTitle),
            normalizedAltTitle: Value(
              altTitle == null ? null : Normalize.name(altTitle),
            ),
            summary: Value(summary),
            creator: Value(creator),
            year: Value(year),
            barcode: Value(barcode),
            customFields: Value(customFields),
            createdAt: DateTime.now(),
          ),
        );
    await revisions.commitObject(id);
    return (db.select(db.objects)..where((o) => o.id.equals(id))).getSingle();
  }

  /// Обновляет объект и фиксирует новую версию (§18).
  /// Правит описание объекта. Не переданное поле остаётся прежним, `null`
  /// стирает его — как в [updateEntry], по тому же маркеру [_unset].
  ///
  /// До 1.19.0 `null` значил «не трогать», и убрать однажды введённые бренд,
  /// год или оригинальное название было нечем.
  Future<void> updateObject(
    String objectId, {
    String? title,
    Object? altTitle = _unset,
    Object? summary = _unset,
    Object? creator = _unset,
    Object? year = _unset,
  }) async {
    Value<T?> val<T>(Object? v) =>
        identical(v, _unset) ? const Value.absent() : Value(v as T?);

    final alt = val<String>(altTitle);
    await (db.update(db.objects)..where((o) => o.id.equals(objectId))).write(
      ObjectsCompanion(
        title: title == null ? const Value.absent() : Value(title),
        normalizedTitle: title == null
            ? const Value.absent()
            : Value(Normalize.name(title)),
        altTitle: alt,
        // Нормализованное написание идёт следом за самим названием: разойдись
        // они, поиск находил бы объект по стёртому названию.
        normalizedAltTitle: alt.present
            ? Value(alt.value == null ? null : Normalize.name(alt.value!))
            : const Value.absent(),
        summary: val<String>(summary),
        creator: val<String>(creator),
        year: val<int>(year),
      ),
    );
    await revisions.commitObject(objectId);
  }

  /// Объект с таким штрихкодом, если он уже заводился.
  ///
  /// Штрихкод определяет товар однозначно, поэтому повторное сканирование
  /// должно вести к существующему объекту, а не создавать копию.
  Future<ObjectRow?> findByBarcode(String barcode) {
    return (db.select(db.objects)
          ..where((o) => o.barcode.equals(barcode))
          ..limit(1))
        .getSingleOrNull();
  }

  /// С какой длины название считается похожим по вхождению.
  ///
  /// Короткое слово входит почти во всё: заводя «Чай», человек получал диалог
  /// со списком всех чаёв, а «Сок» — со всеми соками. Совпадение целиком
  /// проверяется всегда, вхождение — только для названий подлиннее.
  static const int _minLengthForPartialMatch = 6;

  /// Поиск возможных дублей объекта (§26): по нормализованному названию в рамках
  /// типа. Не объединяет автоматически — только предлагает кандидатов.
  ///
  /// Отбор идёт запросом по `idx_objects_norm_title` и по штрихкоду, а не
  /// чтением всех объектов типа: при полном каталоге это был проход по всей
  /// таблице на каждое сохранение.
  Future<List<ObjectRow>> findDuplicateCandidates(
    String typeId,
    String title, {
    String? barcode,
  }) async {
    final norm = Normalize.forMatch(title);
    if (norm.isEmpty) return const [];

    // Сужаем выборку в базе: точное совпадение ловится индексом
    // `idx_objects_norm_title`, а похожие — по первому слову. Раньше сюда
    // поднимались все объекты типа и каждый нормализовался в Dart: при полном
    // каталоге это проход по всей таблице на каждое сохранение.
    final firstWord = norm.split(' ').first;
    final rows =
        await (db.select(db.objects)
              ..where((o) => o.typeId.equals(typeId))
              ..where(
                (o) =>
                    o.normalizedTitle.equals(norm) |
                    o.normalizedAltTitle.equals(norm) |
                    o.normalizedTitle.like('%$firstWord%') |
                    (barcode == null
                        ? const Constant(false)
                        : o.barcode.equals(barcode)),
              ))
            .get();

    // Точное правило — здесь: в колонке лежит название с пунктуацией, а
    // сравниваем мы очищенные.
    return rows.where((o) {
      if (barcode != null && o.barcode == barcode) return true;
      final on = Normalize.forMatch(o.title);
      final oa = o.altTitle == null ? '' : Normalize.forMatch(o.altTitle!);
      if (on == norm || oa == norm) return true;
      // Короткое название входит почти во всё, поэтому вхождением его не
      // проверяем — иначе «Чай» предлагал бы объединить со всеми чаями.
      if (norm.length < _minLengthForPartialMatch) return false;
      if (on.contains(norm)) return true;
      return on.length >= _minLengthForPartialMatch && norm.contains(on);
    }).toList();
  }

  // ---- Записи профиля ----

  Future<ProfileEntryRow> createEntry({
    required String profileId,
    required String objectId,
    String? relation,
    double? rating,
    String? status,
    int? progressCurrent,
    int? progressTotal,
    String? shortNote,
    String? detailedNote,
    String privacy = 'shareable',
    DateTime? impressionDate,
    String? primaryCategoryId,
    List<String> extraCategoryIds = const [],
  }) async {
    final id = Ids.newId();
    await db.transaction(() async {
      await db
          .into(db.profileEntries)
          .insert(
            ProfileEntriesCompanion.insert(
              id: id,
              profileId: profileId,
              objectId: objectId,
              relation: Value(relation),
              rating: Value(rating),
              status: Value(status),
              progressCurrent: Value(progressCurrent),
              progressTotal: Value(progressTotal),
              shortNote: Value(shortNote),
              detailedNote: Value(detailedNote),
              privacy: Value(privacy),
              impressionDate: Value(impressionDate),
              createdAt: DateTime.now(),
            ),
          );
      if (primaryCategoryId != null) {
        await _link(id, primaryCategoryId, primary: true);
      }
      for (final cat in extraCategoryIds) {
        await _link(id, cat, primary: false);
      }
    });
    await revisions.commitEntry(id);
    return (db.select(
      db.profileEntries,
    )..where((e) => e.id.equals(id))).getSingle();
  }

  /// Обновляет запись профиля и фиксирует новую версию (§18).
  /// Мнение одного профиля не влияет на записи других профилей (§6.2).
  Future<void> updateEntry(
    String entryId, {
    Object? relation = _unset,
    Object? rating = _unset,
    Object? status = _unset,
    Object? progressCurrent = _unset,
    Object? progressTotal = _unset,
    Object? shortNote = _unset,
    Object? detailedNote = _unset,
    String? privacy,
    DateTime? impressionDate,

    /// Явно стереть дату впечатления: `impressionDate: null` означает
    /// «не менять», иначе дату нельзя было бы убрать.
    bool clearImpressionDate = false,
  }) async {
    Value<T?> val<T>(Object? v) =>
        identical(v, _unset) ? const Value.absent() : Value(v as T?);

    await (db.update(
      db.profileEntries,
    )..where((e) => e.id.equals(entryId))).write(
      ProfileEntriesCompanion(
        relation: val<String>(relation),
        rating: val<double>(rating),
        status: val<String>(status),
        progressCurrent: val<int>(progressCurrent),
        progressTotal: val<int>(progressTotal),
        shortNote: val<String>(shortNote),
        detailedNote: val<String>(detailedNote),
        privacy: privacy == null ? const Value.absent() : Value(privacy),
        impressionDate: clearImpressionDate
            ? const Value(null)
            : (impressionDate == null
                  ? const Value.absent()
                  : Value(impressionDate)),
      ),
    );
    await revisions.commitEntry(entryId);
  }

  /// Ставит одно и то же полю сразу у набора записей.
  ///
  /// Массовые действия каталога раньше звали [updateEntry] в цикле: на каждую
  /// запись — свой `UPDATE`, своя транзакция и свой обход версий. Оценка на
  /// три сотни выделенных записей замораживала окно на несколько секунд.
  Future<void> updateEntries(
    List<String> entryIds, {
    Object? relation = _unset,
    Object? rating = _unset,
    Object? status = _unset,
  }) async {
    if (entryIds.isEmpty) return;
    Value<T?> val<T>(Object? v) =>
        identical(v, _unset) ? const Value.absent() : Value(v as T?);

    final change = ProfileEntriesCompanion(
      relation: val<String>(relation),
      rating: val<double>(rating),
      status: val<String>(status),
    );
    for (final chunk in chunked(entryIds)) {
      await (db.update(
        db.profileEntries,
      )..where((e) => e.id.isIn(chunk))).write(change);
    }
    await revisions.commitEntries(entryIds);
  }

  /// История повторов записи, свежие сверху.
  Future<List<EntryVisitRow>> visitsOf(String entryId) {
    return (db.select(db.entryVisits)
          ..where((v) => v.entryId.equals(entryId))
          ..orderBy([
            (v) =>
                OrderingTerm(expression: v.occurredAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Сколько раз к записи возвращались — для пометки на карточке.
  ///
  /// Одним запросом на весь список: спрашивать про каждую карточку отдельно
  /// значит шестьдесят запросов на страницу каталога.
  Future<Map<String, int>> visitCounts(Iterable<String> entryIds) async {
    final ids = entryIds.toSet();
    if (ids.isEmpty) return const {};
    final count = db.entryVisits.id.count();
    final rows =
        await (db.selectOnly(db.entryVisits)
              ..addColumns([db.entryVisits.entryId, count])
              ..where(db.entryVisits.entryId.isIn(ids.toList()))
              ..groupBy([db.entryVisits.entryId]))
            .get();
    final byEntry = <String, int>{};
    for (final row in rows) {
      final id = row.read(db.entryVisits.entryId);
      if (id != null) byEntry[id] = row.read(count) ?? 0;
    }
    return byEntry;
  }

  /// Добавляет ещё один раз и подтягивает за ним саму запись.
  ///
  /// Запись хранит последнее: её оценка и дата впечатления становятся такими
  /// же, как у самого свежего посещения. Иначе каталог показывал бы оценку
  /// первого раза, а карточка — второго, и это выглядело бы сбоем.
  Future<EntryVisitRow> addVisit({
    required String entryId,
    required DateTime occurredAt,
    double? rating,
    String? note,
  }) async {
    final row = EntryVisitRow(
      id: Ids.newId(),
      entryId: entryId,
      occurredAt: occurredAt,
      rating: rating,
      note: note,
      createdAt: DateTime.now(),
    );
    await db.into(db.entryVisits).insert(row);
    await _syncEntryWithLatestVisit(entryId);
    return row;
  }

  /// Убирает один раз из истории и возвращает запись к предыдущему.
  Future<void> removeVisit(String visitId) async {
    final visit = await (db.select(
      db.entryVisits,
    )..where((v) => v.id.equals(visitId))).getSingleOrNull();
    if (visit == null) return;
    await (db.delete(db.entryVisits)..where((v) => v.id.equals(visitId))).go();
    await _syncEntryWithLatestVisit(visit.entryId);
  }

  /// Приводит запись к самому свежему посещению.
  ///
  /// Когда посещений не осталось, оценку и дату не трогаем: они были у записи
  /// и до того, как повторы появились, и стирать их из-за удаления повтора —
  /// потеря того, чего человек не отменял.
  Future<void> _syncEntryWithLatestVisit(String entryId) async {
    final latest =
        await (db.select(db.entryVisits)
              ..where((v) => v.entryId.equals(entryId))
              ..orderBy([
                (v) => OrderingTerm(
                  expression: v.occurredAt,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(1))
            .getSingleOrNull();
    if (latest == null) return;

    await (db.update(
      db.profileEntries,
    )..where((e) => e.id.equals(entryId))).write(
      ProfileEntriesCompanion(
        rating: Value(latest.rating),
        impressionDate: Value(latest.occurredAt),
      ),
    );
    await revisions.commitEntries([entryId]);
  }

  /// Маркер «поле не передано» — позволяет отличить null от отсутствия.
  static const Object _unset = Object();

  Future<void> _link(
    String entryId,
    String categoryId, {
    required bool primary,
  }) {
    return db
        .into(db.entryCategories)
        .insert(
          EntryCategoriesCompanion.insert(
            entryId: entryId,
            categoryId: categoryId,
            isPrimary: Value(primary),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  /// Устанавливает основную категорию записи, снимая прежнюю основную.
  /// Основная категория записи — та, по которой строится её путь.
  ///
  /// Нужна там, где перенос надо уметь отменить: без прежнего значения
  /// «Вернуть» некуда возвращать.
  Future<String?> primaryCategoryOf(String entryId) async {
    final link =
        await (db.select(db.entryCategories)..where(
              (ec) => ec.entryId.equals(entryId) & ec.isPrimary.equals(true),
            ))
            .getSingleOrNull();
    return link?.categoryId;
  }

  Future<void> setPrimaryCategory(String entryId, String categoryId) async {
    await db.transaction(() async {
      await (db.update(db.entryCategories)
            ..where((ec) => ec.entryId.equals(entryId)))
          .write(const EntryCategoriesCompanion(isPrimary: Value(false)));
      await _link(entryId, categoryId, primary: true);
    });
  }

  /// Ставит одну основную категорию сразу набору записей.
  ///
  /// Порядок важен: сначала со всех выделенных снимается прежняя основная,
  /// потом ставится новая. Частичный уникальный индекс по `entry_id` не
  /// потерпит двух основных у одной записи, а внутри пакета команды идут в том
  /// порядке, в каком записаны.
  Future<void> setPrimaryCategories(
    List<String> entryIds,
    String categoryId,
  ) async {
    if (entryIds.isEmpty) return;
    await db.batch((batch) {
      for (final chunk in chunked(entryIds)) {
        batch.update(
          db.entryCategories,
          const EntryCategoriesCompanion(isPrimary: Value(false)),
          where: (ec) => ec.entryId.isIn(chunk),
        );
      }
      for (final id in entryIds) {
        batch.insert(
          db.entryCategories,
          EntryCategoriesCompanion.insert(
            entryId: id,
            categoryId: categoryId,
            isPrimary: const Value(true),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> addCategory(String entryId, String categoryId) =>
      _link(entryId, categoryId, primary: false);

  /// Убирает дополнительную категорию.
  ///
  /// Основную не трогает: запись без основной категории теряет путь, и в
  /// каталоге у неё вместо крошек оказывается пустота.
  Future<void> removeCategory(String entryId, String categoryId) async {
    await (db.delete(db.entryCategories)..where(
          (ec) =>
              ec.entryId.equals(entryId) &
              ec.categoryId.equals(categoryId) &
              ec.isPrimary.equals(false),
        ))
        .go();
  }

  /// Дополнительные категории записи — всё, кроме основной (§7.2).
  Future<List<String>> extraCategoriesOf(String entryId) async {
    final links =
        await (db.select(db.entryCategories)..where(
              (ec) => ec.entryId.equals(entryId) & ec.isPrimary.equals(false),
            ))
            .get();
    return [for (final l in links) l.categoryId];
  }

  // ---- Теги (§7.2) ----
  //
  // Теги — свободные метки без вложенности. Это отдельный от категорий
  // механизм: категории образуют иерархию, теги — плоские метки.

  Future<List<TagRow>> tagsOfProfile(String profileId) {
    return (db.select(db.tags)
          ..where((t) => t.profileId.equals(profileId))
          ..orderBy([(t) => OrderingTerm(expression: t.normalizedName)]))
        .get();
  }

  Future<List<TagRow>> tagsOfEntry(String entryId) async {
    final links = await (db.select(
      db.entryTags,
    )..where((et) => et.entryId.equals(entryId))).get();
    if (links.isEmpty) return const [];
    final ids = links.map((l) => l.tagId).toList();
    return (db.select(db.tags)..where((t) => t.id.isIn(ids))).get();
  }

  /// Теги, стоящие хотя бы на одной записи из набора, по алфавиту.
  ///
  /// Нужен панели массовых действий: снять предлагаем из того, что на
  /// выделенном и стоит. Раньше это был запрос на каждую выделенную запись.
  Future<List<TagRow>> tagsOfEntries(List<String> entryIds) async {
    if (entryIds.isEmpty) return const [];

    final tagIds = <String>{};
    for (final chunk in chunked(entryIds)) {
      final links = await (db.select(
        db.entryTags,
      )..where((et) => et.entryId.isIn(chunk))).get();
      tagIds.addAll(links.map((l) => l.tagId));
    }
    if (tagIds.isEmpty) return const [];

    final tags = <TagRow>[];
    for (final chunk in chunked(tagIds.toList())) {
      tags.addAll(
        await (db.select(db.tags)..where((t) => t.id.isIn(chunk))).get(),
      );
    }
    tags.sort((a, b) => a.normalizedName.compareTo(b.normalizedName));
    return tags;
  }

  /// Находит тег профиля по названию или заводит новый.
  Future<TagRow> _ensureTag(String profileId, String name) async {
    final normalized = Normalize.name(name);
    final existing =
        await (db.select(db.tags)..where(
              (t) =>
                  t.profileId.equals(profileId) &
                  t.normalizedName.equals(normalized),
            ))
            .getSingleOrNull();
    if (existing != null) return existing;

    final id = Ids.newId();
    await db
        .into(db.tags)
        .insert(
          TagsCompanion.insert(
            id: id,
            profileId: profileId,
            name: name,
            normalizedName: normalized,
          ),
        );
    return (db.select(db.tags)..where((t) => t.id.equals(id))).getSingle();
  }

  /// Находит тег профиля по названию или создаёт новый и вешает на запись.
  Future<TagRow> addTag(String profileId, String entryId, String name) async {
    final tag = await _ensureTag(profileId, name);
    await db
        .into(db.entryTags)
        .insert(
          EntryTagsCompanion.insert(entryId: entryId, tagId: tag.id),
          mode: InsertMode.insertOrIgnore,
        );
    return tag;
  }

  /// Вешает один тег на набор записей.
  ///
  /// Тег ищется и заводится один раз до цикла: раньше [addTag] в цикле искал
  /// его заново на каждую запись, а первая итерация ещё и создавала.
  Future<TagRow> addTagToEntries(
    String profileId,
    List<String> entryIds,
    String name,
  ) async {
    final tag = await _ensureTag(profileId, name);
    if (entryIds.isEmpty) return tag;

    await db.batch((batch) {
      for (final id in entryIds) {
        batch.insert(
          db.entryTags,
          EntryTagsCompanion.insert(entryId: id, tagId: tag.id),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
    return tag;
  }

  Future<void> removeTag(String entryId, String tagId) {
    return (db.delete(
      db.entryTags,
    )..where((et) => et.entryId.equals(entryId) & et.tagId.equals(tagId))).go();
  }

  /// Снимает один тег с набора записей.
  Future<void> removeTagFromEntries(List<String> entryIds, String tagId) async {
    for (final chunk in chunked(entryIds)) {
      await (db.delete(
        db.entryTags,
      )..where((et) => et.entryId.isIn(chunk) & et.tagId.equals(tagId))).go();
    }
  }

  /// Сколько записей помечено каждым тегом профиля.
  ///
  /// Нужно, чтобы человек понимал, что удаляет: тег на сорока записях и тег с
  /// опечаткой на одной выглядят в списке одинаково.
  Future<Map<String, int>> tagUsage(String profileId) async {
    final tag = db.alias(db.tags, 't');
    final link = db.alias(db.entryTags, 'et');
    final count = link.entryId.count();

    final rows =
        await (db.selectOnly(tag)
              ..addColumns([tag.id, count])
              ..join([
                leftOuterJoin(
                  link,
                  link.tagId.equalsExp(tag.id),
                  useColumns: false,
                ),
              ])
              ..where(tag.profileId.equals(profileId))
              ..groupBy([tag.id]))
            .get();

    return {for (final row in rows) row.read(tag.id)!: row.read(count) ?? 0};
  }

  /// Переименовывает тег, а при совпадении имени — сливает с существующим.
  ///
  /// Совпадение считается по [Normalize.name], который сворачивает регистр и
  /// «ё»: «Чай», «чай» и «чaй» — один тег, иначе список фильтров зарастает
  /// близнецами. При слиянии связи переезжают на уцелевший тег, а опустевший
  /// удаляется; `insertOrIgnore` не даёт появиться дублю на записи, помеченной
  /// обоими.
  ///
  /// Возвращает тег, который остался.
  Future<TagRow> renameTag(String tagId, String name) async {
    final tag = await (db.select(
      db.tags,
    )..where((t) => t.id.equals(tagId))).getSingle();
    final normalized = Normalize.name(name);

    final twin =
        await (db.select(db.tags)..where(
              (t) =>
                  t.profileId.equals(tag.profileId) &
                  t.normalizedName.equals(normalized) &
                  t.id.equals(tagId).not(),
            ))
            .getSingleOrNull();

    return db.transaction(() async {
      if (twin == null) {
        await (db.update(db.tags)..where((t) => t.id.equals(tagId))).write(
          TagsCompanion(name: Value(name), normalizedName: Value(normalized)),
        );
        return (db.select(
          db.tags,
        )..where((t) => t.id.equals(tagId))).getSingle();
      }

      final links = await (db.select(
        db.entryTags,
      )..where((et) => et.tagId.equals(tagId))).get();
      for (final link in links) {
        await db
            .into(db.entryTags)
            .insert(
              EntryTagsCompanion.insert(entryId: link.entryId, tagId: twin.id),
              mode: InsertMode.insertOrIgnore,
            );
      }
      await (db.delete(
        db.entryTags,
      )..where((et) => et.tagId.equals(tagId))).go();
      await (db.delete(db.tags)..where((t) => t.id.equals(tagId))).go();
      return twin;
    });
  }

  /// Убирает тег отовсюду и удаляет его самого.
  Future<void> deleteTag(String tagId) async {
    await db.transaction(() async {
      await (db.delete(
        db.entryTags,
      )..where((et) => et.tagId.equals(tagId))).go();
      await (db.delete(db.tags)..where((t) => t.id.equals(tagId))).go();
    });
  }

  Future<void> archiveEntry(String entryId) async {
    await (db.update(db.profileEntries)..where((e) => e.id.equals(entryId)))
        .write(ProfileEntriesCompanion(archivedAt: Value(DateTime.now())));
  }

  /// Убирает в архив набор записей — одной датой на всю пачку.
  Future<void> archiveEntries(List<String> entryIds) async {
    if (entryIds.isEmpty) return;
    final now = DateTime.now();
    for (final chunk in chunked(entryIds)) {
      await (db.update(db.profileEntries)..where((e) => e.id.isIn(chunk)))
          .write(ProfileEntriesCompanion(archivedAt: Value(now)));
    }
  }

  /// Возвращает запись из архива (§24). Ничего не удалялось, поэтому связи с
  /// категориями, тегами и фотографиями остаются на месте.
  Future<void> restoreEntry(String entryId) async {
    await (db.update(db.profileEntries)..where((e) => e.id.equals(entryId)))
        .write(const ProfileEntriesCompanion(archivedAt: Value(null)));
  }

  /// Возвращает из архива набор записей.
  Future<void> restoreEntries(List<String> entryIds) async {
    if (entryIds.isEmpty) return;
    for (final chunk in chunked(entryIds)) {
      await (db.update(db.profileEntries)..where((e) => e.id.isIn(chunk)))
          .write(const ProfileEntriesCompanion(archivedAt: Value(null)));
    }
  }

  // ---- Представления для UI ----

  /// Соединение записи с объектом и типом: нужно и выборке карточек, и счёту.
  List<Join> get _entryJoins => [
    innerJoin(db.objects, db.objects.id.equalsExp(db.profileEntries.objectId)),
    innerJoin(db.objectTypes, db.objectTypes.id.equalsExp(db.objects.typeId)),
  ];

  /// Порядок записей: у каждой сортировки свой «обычный».
  ///
  /// Названия идут от А, оценки и даты — от больших. Переключатель
  /// разворачивает именно его, а не приписывает всем одно направление.
  List<OrderingTerm> _ordering(EntrySort sort, bool reverseSort) {
    OrderingMode flip(OrderingMode natural) => reverseSort
        ? (natural == OrderingMode.asc ? OrderingMode.desc : OrderingMode.asc)
        : natural;

    return switch (sort) {
      EntrySort.recent => [
        OrderingTerm(
          expression: db.profileEntries.createdAt,
          mode: flip(OrderingMode.desc),
        ),
      ],
      EntrySort.title => [
        OrderingTerm(
          expression: db.objects.normalizedTitle,
          mode: flip(OrderingMode.asc),
        ),
      ],
      EntrySort.rating => [
        OrderingTerm(
          expression: db.profileEntries.rating,
          mode: flip(OrderingMode.desc),
        ),
      ],
      EntrySort.impressionDate => [
        OrderingTerm(
          expression: db.profileEntries.impressionDate,
          mode: flip(OrderingMode.desc),
        ),
      ],
    };
  }

  /// Условия отбора под фильтрами каталога.
  ///
  /// Возвращает `null`, когда заведомо ничего не подходит: пустой список
  /// идентификаторов, ненайденный поисковый запрос, ни одной помеченной
  /// записи. Так вызывающий отличает «нечего искать» от «ничего не нашлось
  /// после запроса».
  ///
  /// Живут отдельно от самого запроса: по одним и тем же условиям строится и
  /// страница карточек, и счёт «сколько всего нашлось», — а поиск по тексту и
  /// разбор ветки категорий делаются при этом один раз.
  Future<List<Expression<bool>>?> _filters(
    String profileId, {
    List<String>? entryIds,
    List<String>? categoryIds,
    List<String>? tagIds,
    String? relation,
    String? status,
    String? typeId,
    String? search,
    bool withoutRating = false,
    bool withoutCategory = false,
    bool withoutPhoto = false,
    bool recommendedOnly = false,
    DateTime? impressionFrom,
    DateTime? impressionTo,
    bool archived = false,
  }) async {
    final where = <Expression<bool>>[
      db.profileEntries.profileId.equals(profileId),
      archived
          ? db.profileEntries.archivedAt.isNotNull()
          : db.profileEntries.archivedAt.isNull(),
    ];

    if (entryIds != null) {
      if (entryIds.isEmpty) return null;
      where.add(db.profileEntries.id.isIn(entryIds));
    }
    if (relation != null) {
      where.add(db.profileEntries.relation.equals(relation));
    }
    // Ключ стадии общий для всех типов, поэтому «что сейчас в процессе»
    // спрашивается одним условием, а не отдельно про книги, фильмы и продукты.
    if (status != null) {
      where.add(db.profileEntries.status.equals(status));
    }
    if (typeId != null) {
      where.add(db.objects.typeId.equals(typeId));
    }
    if (search != null && search.trim().isNotEmpty) {
      // Полнотекстовый поиск по названиям и по тексту заметок (§29).
      // Прежний `LIKE '%…%'` не мог опереться на индекс и не видел заметок.
      final byTitle = await db.searchObjectIds(search);
      final byNote = await db.searchEntryIdsByNote(search);

      if (byTitle.isEmpty && byNote.isEmpty) {
        // Запрос из одних служебных символов FTS ничего не найдёт, но и
        // отдавать весь каталог нельзя — считаем, что совпадений нет.
        return null;
      }
      final found = <Expression<bool>>[
        if (byTitle.isNotEmpty) db.objects.id.isIn(byTitle),
        if (byNote.isNotEmpty) db.profileEntries.id.isIn(byNote),
      ];
      where.add(found.reduce((a, b) => a | b));
    }
    if (tagIds != null && tagIds.isNotEmpty) {
      // Запись подходит, если помечена хотя бы одним из выбранных тегов.
      final tagged = await (db.select(
        db.entryTags,
      )..where((t) => t.tagId.isIn(tagIds))).get();
      final ids = tagged.map((t) => t.entryId).toSet();
      if (ids.isEmpty) return null;
      where.add(db.profileEntries.id.isIn(ids));
    }
    if (categoryIds != null) {
      // Ветка отбирается запросом, а не после выборки. Раньше это была
      // постфильтрация уже собранных строк, из-за неё `LIMIT` был неточен и
      // каталог поднимал в память весь профиль на каждое изменение фильтра.
      if (categoryIds.isEmpty) return null;
      final links = await (db.select(
        db.entryCategories,
      )..where((ec) => ec.categoryId.isIn(categoryIds))).get();
      final ids = links.map((l) => l.entryId).toSet();
      if (ids.isEmpty) return null;
      where.add(db.profileEntries.id.isIn(ids));
    }

    // «Что я не доделал»: без оценки, мимо категорий, без фотографии. Отвечать
    // на такие вопросы фильтрами «покажи вот такие» было нельзя вовсе.
    if (withoutRating) {
      where.add(db.profileEntries.rating.isNull());
    }
    if (withoutCategory) {
      where.add(
        notExistsQuery(
          db.select(db.entryCategories)
            ..where((ec) => ec.entryId.equalsExp(db.profileEntries.id)),
        ),
      );
    }
    if (withoutPhoto) {
      // Снимки привязаны к версии записи, поэтому смотрим её текущую.
      where.add(
        notExistsQuery(
          db.select(db.revisionAttachments)..where(
            (ra) =>
                ra.entityKind.equals('entry') &
                ra.revisionId.equalsExp(db.profileEntries.currentRevisionId),
          ),
        ),
      );
    }

    // Кто это посоветовал, приложение помнило с самого начала и нигде не
    // показывало — заодно и отобрать такие записи было нельзя.
    if (recommendedOnly) {
      where.add(db.profileEntries.recommendedByProfileId.isNotNull());
    }

    // Окно по дате впечатления: «что было год назад» и «что было за этот год».
    // Именно по дате впечатления, а не заведения записи: впечатление могло
    // случиться задолго до того, как его записали.
    if (impressionFrom != null) {
      where.add(
        db.profileEntries.impressionDate.isBiggerOrEqualValue(impressionFrom),
      );
    }
    if (impressionTo != null) {
      where.add(
        db.profileEntries.impressionDate.isSmallerOrEqualValue(impressionTo),
      );
    }

    return where;
  }

  /// Запрос строк под готовыми условиями, в нужном порядке.
  JoinedSelectStatement _selectMatching(
    List<Expression<bool>> where,
    EntrySort sort,
    bool reverseSort,
  ) {
    final query = db.select(db.profileEntries).join(_entryJoins);
    for (final condition in where) {
      query.where(condition);
    }
    query.orderBy(_ordering(sort, reverseSort));
    return query;
  }

  /// Отбор записей под фильтрами — общий для списка карточек и для счёта.
  Future<JoinedSelectStatement?> _matching(
    String profileId, {
    List<String>? entryIds,
    List<String>? categoryIds,
    List<String>? tagIds,
    String? relation,
    String? status,
    String? typeId,
    String? search,
    EntrySort sort = EntrySort.recent,
    bool reverseSort = false,
    bool withoutRating = false,
    bool withoutCategory = false,
    bool withoutPhoto = false,
    bool recommendedOnly = false,
    DateTime? impressionFrom,
    DateTime? impressionTo,
    bool archived = false,
  }) async {
    final where = await _filters(
      profileId,
      entryIds: entryIds,
      categoryIds: categoryIds,
      tagIds: tagIds,
      relation: relation,
      status: status,
      typeId: typeId,
      search: search,
      withoutRating: withoutRating,
      withoutCategory: withoutCategory,
      withoutPhoto: withoutPhoto,
      recommendedOnly: recommendedOnly,
      impressionFrom: impressionFrom,
      impressionTo: impressionTo,
      archived: archived,
    );
    if (where == null) return null;
    return _selectMatching(where, sort, reverseSort);
  }

  /// Идентификаторы записей под фильтрами, в порядке сортировки.
  ///
  /// Каталогу этого хватает, чтобы узнать, сколько всего нашлось, и отрезать
  /// страницу. Карточки собираются отдельно и только для видимого куска.
  Future<List<String>> matchingEntryIds(
    String profileId, {
    List<String>? entryIds,
    List<String>? categoryIds,
    List<String>? tagIds,
    String? relation,
    String? status,
    String? typeId,
    String? search,
    EntrySort sort = EntrySort.recent,
    bool reverseSort = false,
    bool withoutRating = false,
    bool withoutCategory = false,
    bool withoutPhoto = false,
    bool recommendedOnly = false,
    DateTime? impressionFrom,
    DateTime? impressionTo,
    bool archived = false,
  }) async {
    final query = await _matching(
      profileId,
      entryIds: entryIds,
      categoryIds: categoryIds,
      tagIds: tagIds,
      relation: relation,
      status: status,
      typeId: typeId,
      search: search,
      sort: sort,
      reverseSort: reverseSort,
      withoutRating: withoutRating,
      withoutCategory: withoutCategory,
      withoutPhoto: withoutPhoto,
      recommendedOnly: recommendedOnly,
      impressionFrom: impressionFrom,
      impressionTo: impressionTo,
      archived: archived,
    );
    if (query == null) return const [];
    final rows = await query.get();
    return [for (final r in rows) r.readTable(db.profileEntries).id];
  }

  /// Записи профиля с названием объекта, типом и путём основной категории.
  ///
  /// [categoryIds] — ограничить выбранными категориями (обычно вся ветка).
  Future<List<EntryView>> entryViews(
    String profileId, {

    /// Только эти записи — например, состав подборки.
    List<String>? entryIds,
    List<String>? categoryIds,
    List<String>? tagIds,
    String? relation,
    String? status,
    String? typeId,
    String? search,
    EntrySort sort = EntrySort.recent,
    bool reverseSort = false,
    bool withoutRating = false,
    bool withoutCategory = false,
    bool withoutPhoto = false,
    bool recommendedOnly = false,
    DateTime? impressionFrom,
    DateTime? impressionTo,
    bool archived = false,
    int? limit,
    int offset = 0,
  }) async {
    final query = await _matching(
      profileId,
      entryIds: entryIds,
      categoryIds: categoryIds,
      tagIds: tagIds,
      relation: relation,
      status: status,
      typeId: typeId,
      search: search,
      sort: sort,
      reverseSort: reverseSort,
      withoutRating: withoutRating,
      withoutCategory: withoutCategory,
      withoutPhoto: withoutPhoto,
      recommendedOnly: recommendedOnly,
      impressionFrom: impressionFrom,
      impressionTo: impressionTo,
      archived: archived,
    );
    if (query == null) return const [];
    if (limit != null) query.limit(limit, offset: offset);

    return _viewsOf(profileId, await query.get());
  }

  /// Записи, похожие на эту.
  ///
  /// Похожесть простая и объяснимая: тот же тип, близкая оценка или общий тег.
  /// Приложение знало о вкусах больше, чем показывало: связей между записями на
  /// экране не было вовсе.
  Future<List<EntryView>> similarTo(
    String profileId,
    String entryId, {
    int limit = 5,
  }) async {
    final source = await (db.select(
      db.profileEntries,
    )..where((e) => e.id.equals(entryId))).getSingleOrNull();
    if (source == null) return const [];

    final object = await (db.select(
      db.objects,
    )..where((o) => o.id.equals(source.objectId))).getSingleOrNull();
    if (object == null) return const [];

    // Записи с теми же тегами — самая осмысленная близость: теги человек
    // ставит руками.
    final tagIds = (await (db.select(
      db.entryTags,
    )..where((t) => t.entryId.equals(entryId))).get()).map((t) => t.tagId);
    final byTag = tagIds.isEmpty
        ? <String>{}
        : (await (db.select(
                db.entryTags,
              )..where((t) => t.tagId.isIn(tagIds.toList()))).get())
              .map((t) => t.entryId)
              .where((id) => id != entryId)
              .toSet();

    final rating = source.rating;
    // Набрать заведомо больше, чем покажем: часть кандидатов по тегу может
    // оказаться и близкой по оценке, и тогда порядок решает сумма.
    final cap = limit * 4;

    // Кандидатов отбирает база. Раньше сюда поднимались все записи того же
    // типа — на полном каталоге тысячи строк ради пяти показанных, и так на
    // каждое открытие карточки.
    final scored = <String, int>{};
    if (byTag.isNotEmpty) {
      for (final entry in await _sameTypeEntries(
        profileId: profileId,
        exceptId: entryId,
        typeId: object.typeId,
        only: byTag.toList(),
        cap: cap,
      )) {
        scored[entry.id] = 2 + (_ratingClose(rating, entry.rating) ? 1 : 0);
      }
    }
    if (scored.length < limit && rating != null) {
      for (final entry in await _sameTypeEntries(
        profileId: profileId,
        exceptId: entryId,
        typeId: object.typeId,
        nearRating: rating,
        cap: cap,
      )) {
        scored.putIfAbsent(entry.id, () => 1);
      }
    }
    if (scored.isEmpty) return const [];

    final order = scored.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final ids = [for (final s in order.take(limit)) s.key];
    final views = await entryViews(profileId, entryIds: ids);
    // Порядок задаёт близость, а не выборка.
    views.sort(
      (a, b) => ids.indexOf(a.entryId).compareTo(ids.indexOf(b.entryId)),
    );
    return views;
  }

  /// Сколько живых записей каждого типа лежит в этих категориях.
  ///
  /// Нужно форме: она подставляет тип по тому, что уже лежит в ветке. Раньше
  /// ради этого поднималась вся ветка с обложками — на каждое открытие формы.
  Future<Map<String, int>> typeCountsInCategories(
    String profileId,
    List<String> categoryIds,
  ) async {
    if (categoryIds.isEmpty) return const {};

    final counts = <String, int>{};
    for (final chunk in chunked(categoryIds)) {
      final total = db.profileEntries.id.count(distinct: true);
      final rows =
          await (db.selectOnly(db.profileEntries)
                ..addColumns([db.objectTypes.name, total])
                ..join([
                  innerJoin(
                    db.objects,
                    db.objects.id.equalsExp(db.profileEntries.objectId),
                    useColumns: false,
                  ),
                  innerJoin(
                    db.objectTypes,
                    db.objectTypes.id.equalsExp(db.objects.typeId),
                    useColumns: false,
                  ),
                  innerJoin(
                    db.entryCategories,
                    db.entryCategories.entryId.equalsExp(db.profileEntries.id),
                    useColumns: false,
                  ),
                ])
                ..where(db.profileEntries.profileId.equals(profileId))
                ..where(db.profileEntries.archivedAt.isNull())
                ..where(db.entryCategories.categoryId.isIn(chunk))
                ..groupBy([db.objectTypes.name]))
              .get();

      for (final row in rows) {
        final name = row.read(db.objectTypes.name)!;
        counts[name] = (counts[name] ?? 0) + (row.read(total) ?? 0);
      }
    }
    return counts;
  }

  /// Близки ли оценки настолько, чтобы считать записи похожими.
  static bool _ratingClose(double? a, double? b) =>
      a != null && b != null && (a - b).abs() <= 1.5;

  /// Кандидаты в похожие: живые записи профиля того же типа.
  ///
  /// [only] сужает до перечисленных, [nearRating] — до близких по оценке;
  /// без обоих запрос вернул бы весь тип, чего мы как раз и избегаем.
  Future<List<ProfileEntryRow>> _sameTypeEntries({
    required String profileId,
    required String exceptId,
    required String typeId,
    required int cap,
    List<String>? only,
    double? nearRating,
  }) async {
    if (only == null && nearRating == null) return const [];

    final query =
        db.select(db.profileEntries).join([
            innerJoin(
              db.objects,
              db.objects.id.equalsExp(db.profileEntries.objectId),
            ),
          ])
          ..where(db.profileEntries.profileId.equals(profileId))
          ..where(db.profileEntries.archivedAt.isNull())
          ..where(db.profileEntries.id.equals(exceptId).not())
          ..where(db.objects.typeId.equals(typeId))
          ..limit(cap);

    if (only != null) {
      query.where(db.profileEntries.id.isIn(only));
    } else {
      query.where(
        db.profileEntries.rating.isBetweenValues(
          nearRating! - 1.5,
          nearRating + 1.5,
        ),
      );
    }

    final rows = await query.get();
    return [for (final row in rows) row.readTable(db.profileEntries)];
  }

  /// Страница каталога вместе с общим числом найденного.
  ///
  /// Раньше каталог просил у базы **все** подходящие идентификаторы — только
  /// ради двух чисел: сколько всего нашлось и где отрезать страницу. На каждую
  /// букву в поиске и каждое переключение фильтра в память поднимался весь
  /// профиль. Теперь это счёт в базе и окно из нужных строк, а условия отбора
  /// считаются один раз на оба запроса.
  Future<EntryPage> entryPage(
    String profileId, {
    List<String>? categoryIds,
    List<String>? tagIds,
    String? relation,
    String? status,
    String? typeId,
    String? search,
    EntrySort sort = EntrySort.recent,
    bool reverseSort = false,
    bool withoutRating = false,
    bool withoutCategory = false,
    bool withoutPhoto = false,
    bool recommendedOnly = false,
    DateTime? impressionFrom,
    DateTime? impressionTo,
    bool archived = false,
    required int limit,
    int offset = 0,
  }) async {
    final where = await _filters(
      profileId,
      categoryIds: categoryIds,
      tagIds: tagIds,
      relation: relation,
      status: status,
      typeId: typeId,
      search: search,
      withoutRating: withoutRating,
      withoutCategory: withoutCategory,
      withoutPhoto: withoutPhoto,
      recommendedOnly: recommendedOnly,
      impressionFrom: impressionFrom,
      impressionTo: impressionTo,
      archived: archived,
    );
    if (where == null) return const EntryPage(items: [], total: 0);

    final count = db.profileEntries.id.count();
    final counting = db.selectOnly(db.profileEntries).join(_entryJoins)
      ..addColumns([count]);
    for (final condition in where) {
      counting.where(condition);
    }
    final total = (await counting.getSingle()).read(count) ?? 0;
    if (total == 0) return const EntryPage(items: [], total: 0);

    final page = _selectMatching(where, sort, reverseSort)
      ..limit(limit, offset: offset);
    return EntryPage(
      items: await _viewsOf(profileId, await page.get()),
      total: total,
    );
  }

  /// Собирает карточки по уже выбранным строкам.
  Future<List<EntryView>> _viewsOf(
    String profileId,
    List<TypedResult> rows,
  ) async {
    if (rows.isEmpty) return const [];

    // Основные категории записей — только для выбранных строк.
    final pageEntryIds = rows
        .map((r) => r.readTable(db.profileEntries).id)
        .toList();
    final links = await (db.select(
      db.entryCategories,
    )..where((ec) => ec.entryId.isIn(pageEntryIds))).get();

    final primaryByEntry = <String, String>{};
    for (final l in links) {
      if (l.isPrimary) primaryByEntry[l.entryId] = l.categoryId;
    }

    final covers = await _coversFor(
      rows.map((r) => r.readTable(db.profileEntries)),
    );

    // Карта категорий профиля для построения путей.
    final cats = await (db.select(
      db.categories,
    )..where((c) => c.profileId.equals(profileId))).get();
    final catById = {for (final c in cats) c.id: c};

    List<String> pathNamesFor(String? categoryId) {
      if (categoryId == null) return const [];
      final cat = catById[categoryId];
      if (cat == null) return const [];
      return [
        for (final id in cat.path.split('/'))
          if (catById[id] != null) catById[id]!.name,
      ];
    }

    // Названия стадий у каждого типа свои, а разбор JSON стоит заметно
    // дороже чтения поля: на странице в шестьдесят карточек типов обычно
    // два-три, поэтому разбираем каждый по одному разу.
    final statusesByType = <String, List<EntryStatus>>{};
    List<EntryStatus> statusesOf(ObjectTypeRow type) =>
        statusesByType[type.id] ??= EntryStatus.decode(type.statusesJson);

    return [
      for (final r in rows)
        () {
          final entry = r.readTable(db.profileEntries);
          final obj = r.readTable(db.objects);
          final type = r.readTable(db.objectTypes);
          final status = entry.status == null
              ? null
              : statusesOf(
                  type,
                ).where((s) => s.key == entry.status).firstOrNull;
          return EntryView(
            entryId: entry.id,
            objectId: obj.id,
            title: obj.title,
            typeName: type.name,
            subtitle: obj.creator ?? obj.summary,
            categoryPath: pathNamesFor(primaryByEntry[entry.id]),
            primaryCategoryId: primaryByEntry[entry.id],
            relation: entry.relation,
            rating: entry.rating,
            status: entry.status,
            statusLabel: status?.name,
            progressCurrent: entry.progressCurrent,
            progressTotal: entry.progressTotal,
            progressUnit: type.progressUnit,
            impressionDate: entry.impressionDate,
            createdAt: entry.createdAt,
            coverPath: covers[entry.id],
          );
        }(),
    ];
  }

  /// Фотографии записей ветки — чтобы выбрать из них обложку самой ветке.
  ///
  /// Отдаёт идентификатор вложения вместе с путём: в базе у ветки хранится
  /// идентификатор, а показывать надо файл.
  Future<List<({String attachmentId, String path})>> branchPhotos(
    List<String> categoryIds, {
    int limit = 60,
  }) async {
    if (categoryIds.isEmpty) return const [];

    final links = await (db.select(
      db.entryCategories,
    )..where((ec) => ec.categoryId.isIn(categoryIds))).get();
    return photosOfEntries([for (final l in links) l.entryId], limit: limit);
  }

  /// Фотографии заданных записей — чтобы выбрать из них обложку.
  ///
  /// Ветка и подборка спрашивают одно и то же, только состав задают по-разному:
  /// одна путём, другая списком. Правило «берём главный снимок каждой записи»
  /// живёт здесь в одном экземпляре.
  Future<List<({String attachmentId, String path})>> photosOfEntries(
    List<String> ids, {
    int limit = 60,
  }) async {
    final entryIds = ids.toSet();
    if (entryIds.isEmpty) return const [];

    final entries =
        await (db.select(db.profileEntries)
              ..where((e) => e.id.isIn(entryIds) & e.archivedAt.isNull())
              ..orderBy([
                (e) => OrderingTerm(
                  expression: e.createdAt,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(limit))
            .get();
    if (entries.isEmpty) return const [];

    final covers = await _coversFor(entries);
    final byEntry = await _coverAttachmentIds(entries);
    return [
      for (final e in entries)
        if (covers[e.id] case final path?)
          if (byEntry[e.id] case final id?) (attachmentId: id, path: path),
    ];
  }

  /// Идентификаторы обложек записей — пара к [_coversFor], который отдаёт пути.
  Future<Map<String, String>> _coverAttachmentIds(
    Iterable<ProfileEntryRow> entries,
  ) async {
    final revisionToEntry = <String, String>{
      for (final e in entries)
        if (e.currentRevisionId != null) e.currentRevisionId!: e.id,
    };
    if (revisionToEntry.isEmpty) return const {};

    final links =
        await (db.select(db.revisionAttachments)
              ..where(
                (ra) =>
                    ra.entityKind.equals('entry') &
                    ra.revisionId.isIn(revisionToEntry.keys),
              )
              ..orderBy([
                (ra) => OrderingTerm(
                  expression: ra.isPrimary,
                  mode: OrderingMode.desc,
                ),
                (ra) => OrderingTerm(expression: ra.sortOrder),
              ]))
            .get();

    final result = <String, String>{};
    for (final link in links) {
      final entryId = revisionToEntry[link.revisionId];
      if (entryId == null) continue;
      result.putIfAbsent(entryId, () => link.attachmentId);
    }
    return result;
  }

  /// Несколько обложек на категорию — для карточек-полок (§7).
  ///
  /// Считаются по всей ветке: у корневой полки обычно нет собственных записей,
  /// но её содержимое должно быть видно. Берём только записи с фотографиями,
  /// их обычно немного, поэтому один проход дешевле выборки всего каталога.
  Future<Map<String, List<String>>> categoryCovers(
    String profileId, {
    int perCategory = 3,
  }) async {
    final entries =
        await (db.select(db.profileEntries)..where(
              (e) => e.profileId.equals(profileId) & e.archivedAt.isNull(),
            ))
            .get();
    if (entries.isEmpty) return const {};

    final covers = await _coversFor(entries);
    if (covers.isEmpty) return const {};

    // Основная категория записи и путь до корня.
    final links =
        await (db.select(db.entryCategories)..where(
              (ec) => ec.entryId.isIn(covers.keys) & ec.isPrimary.equals(true),
            ))
            .get();
    if (links.isEmpty) return const {};

    final cats = await (db.select(
      db.categories,
    )..where((c) => c.profileId.equals(profileId))).get();
    final pathById = {for (final c in cats) c.id: c.path};

    final result = <String, List<String>>{};
    for (final link in links) {
      final cover = covers[link.entryId];
      final path = pathById[link.categoryId];
      if (cover == null || path == null) continue;
      for (final ancestorId in path.split('/')) {
        final list = result.putIfAbsent(ancestorId, () => []);
        if (list.length < perCategory) list.add(cover);
      }
    }
    return result;
  }

  /// Обложки для набранной страницы записей: одна миниатюра на запись.
  ///
  /// Фотографии привязаны к версии записи, поэтому идём от её текущей версии.
  /// Обложкой считается снимок с пометкой «главный», а если её нет — первый по
  /// ручному порядку.
  Future<Map<String, String>> _coversFor(
    Iterable<ProfileEntryRow> entries,
  ) async {
    final revisionToEntry = <String, String>{
      for (final e in entries)
        if (e.currentRevisionId != null) e.currentRevisionId!: e.id,
    };
    if (revisionToEntry.isEmpty) return const {};

    final links =
        await (db.select(db.revisionAttachments)
              ..where(
                (ra) =>
                    ra.entityKind.equals('entry') &
                    ra.revisionId.isIn(revisionToEntry.keys),
              )
              ..orderBy([
                (ra) => OrderingTerm(
                  expression: ra.isPrimary,
                  mode: OrderingMode.desc,
                ),
                (ra) => OrderingTerm(expression: ra.sortOrder),
              ]))
            .get();
    if (links.isEmpty) return const {};

    // Первая ссылка на запись и есть обложка: порядок уже задан запросом.
    final attachmentByEntry = <String, String>{};
    for (final link in links) {
      final entryId = revisionToEntry[link.revisionId];
      if (entryId == null) continue;
      attachmentByEntry.putIfAbsent(entryId, () => link.attachmentId);
    }

    final rows = await (db.select(
      db.attachments,
    )..where((a) => a.id.isIn(attachmentByEntry.values.toSet()))).get();
    final fileById = {for (final a in rows) a.id: a.thumbPath ?? a.storagePath};

    // Каталог берём один раз на весь запрос, а не на каждую строку.
    final mediaDir = await _images.mediaDirectoryPath();
    return {
      for (final e in attachmentByEntry.entries)
        if (fileById[e.value] != null)
          e.key: p.join(mediaDir, fileById[e.value]!),
    };
  }
}
