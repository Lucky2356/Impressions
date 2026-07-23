import 'package:drift/drift.dart';

import '../../core/utils/ids.dart';
import '../../core/utils/normalize.dart';
import '../db/database.dart';
import '../models/entry_view.dart';
import '../services/revision_service.dart';

/// Репозиторий типов объектов, объектов и записей профилей (§6).
/// Объект (общая информация) и запись профиля (мнение) разделены.
///
/// Все изменения объектов и записей фиксируются как неизменяемые версии (§18).
class EntryRepository {
  EntryRepository(this.db) : revisions = RevisionService(db);
  final AppDatabase db;
  final RevisionService revisions;

  // ---- Типы объектов ----

  Future<ObjectTypeRow> createObjectType(
    String profileId,
    String name, {
    String? icon,
    int? color,
    bool builtIn = false,
    int sortOrder = 0,
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
            createdAt: DateTime.now(),
          ),
        );
    await revisions.commitObject(id);
    return (db.select(db.objects)..where((o) => o.id.equals(id))).getSingle();
  }

  /// Обновляет объект и фиксирует новую версию (§18).
  Future<void> updateObject(
    String objectId, {
    String? title,
    String? altTitle,
    String? summary,
    String? creator,
    int? year,
  }) async {
    await (db.update(db.objects)..where((o) => o.id.equals(objectId))).write(
      ObjectsCompanion(
        title: title == null ? const Value.absent() : Value(title),
        normalizedTitle: title == null
            ? const Value.absent()
            : Value(Normalize.name(title)),
        altTitle: altTitle == null ? const Value.absent() : Value(altTitle),
        normalizedAltTitle: altTitle == null
            ? const Value.absent()
            : Value(Normalize.name(altTitle)),
        summary: summary == null ? const Value.absent() : Value(summary),
        creator: creator == null ? const Value.absent() : Value(creator),
        year: year == null ? const Value.absent() : Value(year),
      ),
    );
    await revisions.commitObject(objectId);
  }

  /// Поиск возможных дублей объекта (§26): по нормализованному названию в рамках
  /// типа. Не объединяет автоматически — только предлагает кандидатов.
  Future<List<ObjectRow>> findDuplicateCandidates(
    String typeId,
    String title, {
    String? barcode,
  }) async {
    final norm = Normalize.forMatch(title);
    final q = db.select(db.objects)..where((o) => o.typeId.equals(typeId));
    final rows = await q.get();
    return rows.where((o) {
      if (barcode != null && o.barcode == barcode) return true;
      final on = Normalize.forMatch(o.title);
      final oa = o.altTitle == null ? '' : Normalize.forMatch(o.altTitle!);
      return on == norm || oa == norm || on.contains(norm) || norm.contains(on);
    }).toList();
  }

  // ---- Записи профиля ----

  Future<ProfileEntryRow> createEntry({
    required String profileId,
    required String objectId,
    String? relation,
    double? rating,
    String? status,
    String? shortNote,
    String? detailedNote,
    String privacy = 'shareable',
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
              shortNote: Value(shortNote),
              detailedNote: Value(detailedNote),
              privacy: Value(privacy),
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
    Object? shortNote = _unset,
    Object? detailedNote = _unset,
    String? privacy,
    DateTime? impressionDate,
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
        shortNote: val<String>(shortNote),
        detailedNote: val<String>(detailedNote),
        privacy: privacy == null ? const Value.absent() : Value(privacy),
        impressionDate: impressionDate == null
            ? const Value.absent()
            : Value(impressionDate),
      ),
    );
    await revisions.commitEntry(entryId);
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
  Future<void> setPrimaryCategory(String entryId, String categoryId) async {
    await db.transaction(() async {
      await (db.update(db.entryCategories)
            ..where((ec) => ec.entryId.equals(entryId)))
          .write(const EntryCategoriesCompanion(isPrimary: Value(false)));
      await _link(entryId, categoryId, primary: true);
    });
  }

  Future<void> addCategory(String entryId, String categoryId) =>
      _link(entryId, categoryId, primary: false);

  Future<List<ProfileEntryRow>> entriesByProfile(String profileId) {
    return (db.select(db.profileEntries)
          ..where((e) => e.profileId.equals(profileId) & e.archivedAt.isNull())
          ..orderBy([
            (e) =>
                OrderingTerm(expression: e.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Записи в категории или во всей ветке (§7.5).
  Future<List<ProfileEntryRow>> entriesInCategories(
    List<String> categoryIds,
  ) async {
    if (categoryIds.isEmpty) return [];
    final query =
        db.select(db.profileEntries).join([
            innerJoin(
              db.entryCategories,
              db.entryCategories.entryId.equalsExp(db.profileEntries.id),
            ),
          ])
          ..where(db.entryCategories.categoryId.isIn(categoryIds))
          ..where(db.profileEntries.archivedAt.isNull())
          ..groupBy([db.profileEntries.id]);
    final rows = await query.get();
    return rows.map((r) => r.readTable(db.profileEntries)).toList();
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

  /// Находит тег профиля по названию или создаёт новый и вешает на запись.
  Future<TagRow> addTag(String profileId, String entryId, String name) async {
    final normalized = Normalize.name(name);
    var tag =
        await (db.select(db.tags)..where(
              (t) =>
                  t.profileId.equals(profileId) &
                  t.normalizedName.equals(normalized),
            ))
            .getSingleOrNull();

    if (tag == null) {
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
      tag = await (db.select(
        db.tags,
      )..where((t) => t.id.equals(id))).getSingle();
    }

    await db
        .into(db.entryTags)
        .insert(
          EntryTagsCompanion.insert(entryId: entryId, tagId: tag.id),
          mode: InsertMode.insertOrIgnore,
        );
    return tag;
  }

  Future<void> removeTag(String entryId, String tagId) {
    return (db.delete(
      db.entryTags,
    )..where((et) => et.entryId.equals(entryId) & et.tagId.equals(tagId))).go();
  }

  Future<void> archiveEntry(String entryId) async {
    await (db.update(db.profileEntries)..where((e) => e.id.equals(entryId)))
        .write(ProfileEntriesCompanion(archivedAt: Value(DateTime.now())));
  }

  // ---- Представления для UI ----

  /// Записи профиля с названием объекта, типом и путём основной категории.
  ///
  /// [categoryIds] — ограничить выбранными категориями (обычно вся ветка).
  Future<List<EntryView>> entryViews(
    String profileId, {
    List<String>? categoryIds,
    String? relation,
    String? typeId,
    String? search,
    EntrySort sort = EntrySort.recent,
    int? limit,
    int offset = 0,
  }) async {
    final query =
        db.select(db.profileEntries).join([
            innerJoin(
              db.objects,
              db.objects.id.equalsExp(db.profileEntries.objectId),
            ),
            innerJoin(
              db.objectTypes,
              db.objectTypes.id.equalsExp(db.objects.typeId),
            ),
          ])
          ..where(db.profileEntries.profileId.equals(profileId))
          ..where(db.profileEntries.archivedAt.isNull())
          ..orderBy(switch (sort) {
            EntrySort.recent => [
              OrderingTerm(
                expression: db.profileEntries.createdAt,
                mode: OrderingMode.desc,
              ),
            ],
            EntrySort.title => [
              OrderingTerm(expression: db.objects.normalizedTitle),
            ],
            EntrySort.rating => [
              OrderingTerm(
                expression: db.profileEntries.rating,
                mode: OrderingMode.desc,
              ),
            ],
            EntrySort.impressionDate => [
              OrderingTerm(
                expression: db.profileEntries.impressionDate,
                mode: OrderingMode.desc,
              ),
            ],
          });

    if (relation != null) {
      query.where(db.profileEntries.relation.equals(relation));
    }
    if (typeId != null) {
      query.where(db.objects.typeId.equals(typeId));
    }
    if (search != null && search.trim().isNotEmpty) {
      final needle = '%${Normalize.name(search)}%';
      query.where(
        db.objects.normalizedTitle.like(needle) |
            db.objects.normalizedAltTitle.like(needle),
      );
    }
    // Пагинация применяется только когда не требуется постфильтрация по
    // категориям (иначе limit исказил бы результат).
    if (limit != null && categoryIds == null) {
      query.limit(limit, offset: offset);
    }

    var rows = await query.get();

    // Основные категории записей.
    final entryIds = rows
        .map((r) => r.readTable(db.profileEntries).id)
        .toList();
    final links = entryIds.isEmpty
        ? <EntryCategoryRow>[]
        : await (db.select(
            db.entryCategories,
          )..where((ec) => ec.entryId.isIn(entryIds))).get();

    if (categoryIds != null) {
      final allowed = categoryIds.toSet();
      final matching = links
          .where((l) => allowed.contains(l.categoryId))
          .map((l) => l.entryId)
          .toSet();
      rows = rows
          .where((r) => matching.contains(r.readTable(db.profileEntries).id))
          .toList();
      if (limit != null) {
        rows = rows.skip(offset).take(limit).toList();
      }
    }

    final primaryByEntry = <String, String>{};
    for (final l in links) {
      if (l.isPrimary) primaryByEntry[l.entryId] = l.categoryId;
    }

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

    return [
      for (final r in rows)
        () {
          final entry = r.readTable(db.profileEntries);
          final obj = r.readTable(db.objects);
          final type = r.readTable(db.objectTypes);
          return EntryView(
            entryId: entry.id,
            objectId: obj.id,
            title: obj.title,
            typeName: type.name,
            subtitle: obj.creator ?? obj.summary,
            categoryPath: pathNamesFor(primaryByEntry[entry.id]),
            relation: entry.relation,
            rating: entry.rating,
            status: entry.status,
            createdAt: entry.createdAt,
          );
        }(),
    ];
  }

  /// Сводка по профилю для главной.
  Future<ProfileStats> stats(String profileId) async {
    Future<int> countOf(Future<int> f) => f;

    final entriesCount = await countOf(
      (db.selectOnly(db.profileEntries)
            ..addColumns([db.profileEntries.id.count()])
            ..where(
              db.profileEntries.profileId.equals(profileId) &
                  db.profileEntries.archivedAt.isNull(),
            ))
          .map((r) => r.read(db.profileEntries.id.count()) ?? 0)
          .getSingle(),
    );

    final categoriesCount = await countOf(
      (db.selectOnly(db.categories)
            ..addColumns([db.categories.id.count()])
            ..where(
              db.categories.profileId.equals(profileId) &
                  db.categories.archivedAt.isNull(),
            ))
          .map((r) => r.read(db.categories.id.count()) ?? 0)
          .getSingle(),
    );

    final collectionsCount = await countOf(
      (db.selectOnly(db.collections)
            ..addColumns([db.collections.id.count()])
            ..where(
              db.collections.profileId.equals(profileId) &
                  db.collections.archivedAt.isNull(),
            ))
          .map((r) => r.read(db.collections.id.count()) ?? 0)
          .getSingle(),
    );

    final wantCount = await countOf(
      (db.selectOnly(db.profileEntries)
            ..addColumns([db.profileEntries.id.count()])
            ..where(
              db.profileEntries.profileId.equals(profileId) &
                  db.profileEntries.archivedAt.isNull() &
                  db.profileEntries.relation.equals('wantToTry'),
            ))
          .map((r) => r.read(db.profileEntries.id.count()) ?? 0)
          .getSingle(),
    );

    return ProfileStats(
      entries: entriesCount,
      categories: categoriesCount,
      collections: collectionsCount,
      wantToTry: wantCount,
    );
  }
}
