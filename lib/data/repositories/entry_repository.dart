import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

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

  /// Возвращает запись из архива (§24). Ничего не удалялось, поэтому связи с
  /// категориями, тегами и фотографиями остаются на месте.
  Future<void> restoreEntry(String entryId) async {
    await (db.update(db.profileEntries)..where((e) => e.id.equals(entryId)))
        .write(const ProfileEntriesCompanion(archivedAt: Value(null)));
  }

  // ---- Представления для UI ----

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
    String? typeId,
    String? search,
    EntrySort sort = EntrySort.recent,
    bool archived = false,
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
          ..where(
            archived
                ? db.profileEntries.archivedAt.isNotNull()
                : db.profileEntries.archivedAt.isNull(),
          )
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

    if (entryIds != null) {
      if (entryIds.isEmpty) return const [];
      query.where(db.profileEntries.id.isIn(entryIds));
    }
    if (relation != null) {
      query.where(db.profileEntries.relation.equals(relation));
    }
    if (typeId != null) {
      query.where(db.objects.typeId.equals(typeId));
    }
    if (search != null && search.trim().isNotEmpty) {
      // Полнотекстовый поиск по названиям и по тексту заметок (§29).
      // Прежний `LIKE '%…%'` не мог опереться на индекс и не видел заметок.
      final byTitle = await db.searchObjectIds(search);
      final byNote = await db.searchEntryIdsByNote(search);

      if (byTitle.isEmpty && byNote.isEmpty) {
        // Запрос из одних служебных символов FTS ничего не найдёт, но и
        // отдавать весь каталог нельзя — считаем, что совпадений нет.
        return const [];
      }
      final conditions = <Expression<bool>>[
        if (byTitle.isNotEmpty) db.objects.id.isIn(byTitle),
        if (byNote.isNotEmpty) db.profileEntries.id.isIn(byNote),
      ];
      query.where(conditions.reduce((a, b) => a | b));
    }
    if (tagIds != null && tagIds.isNotEmpty) {
      // Запись подходит, если помечена хотя бы одним из выбранных тегов.
      final tagged = await (db.select(
        db.entryTags,
      )..where((t) => t.tagId.isIn(tagIds))).get();
      final ids = tagged.map((t) => t.entryId).toSet();
      if (ids.isEmpty) return const [];
      query.where(db.profileEntries.id.isIn(ids));
    }
    // Пагинация применяется только когда не требуется постфильтрация по
    // категориям (иначе limit исказил бы результат).
    if (limit != null && categoryIds == null) {
      query.limit(limit, offset: offset);
    }

    var rows = await query.get();

    // Основные категории записей.
    final pageEntryIds = rows
        .map((r) => r.readTable(db.profileEntries).id)
        .toList();
    final links = pageEntryIds.isEmpty
        ? <EntryCategoryRow>[]
        : await (db.select(
            db.entryCategories,
          )..where((ec) => ec.entryId.isIn(pageEntryIds))).get();

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
            impressionDate: entry.impressionDate,
            createdAt: entry.createdAt,
            coverPath: covers[entry.id],
          );
        }(),
    ];
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

  /// Развёрнутая статистика профиля (§14).
  ///
  /// Считается одним проходом по записям профиля: агрегировать это в SQL
  /// пришлось бы полудюжиной отдельных запросов, а объёмы здесь — тысячи
  /// строк, а не миллионы.
  Future<ProfileInsights> insights(String profileId) async {
    final entries =
        await (db.select(db.profileEntries)
              ..where((e) => e.profileId.equals(profileId))
              ..where((e) => e.archivedAt.isNull()))
            .get();

    if (entries.isEmpty) {
      return const ProfileInsights(
        total: 0,
        rated: 0,
        averageRating: null,
        ratingBuckets: [],
        byRelation: {},
        topCategories: [],
        byMonth: [],
        withPhotos: 0,
        withNotes: 0,
      );
    }

    final buckets = List<int>.filled(10, 0);
    final byRelation = <String, int>{};
    final byMonth = <DateTime, int>{};
    var ratingSum = 0.0;
    var rated = 0;
    var withNotes = 0;

    for (final e in entries) {
      final rating = e.rating;
      if (rating != null) {
        rated++;
        ratingSum += rating;
        // 10 попадает в последнюю корзину, а не в одиннадцатую.
        buckets[rating.floor().clamp(0, 9)]++;
      }
      final relation = e.relation;
      if (relation != null) {
        byRelation[relation] = (byRelation[relation] ?? 0) + 1;
      }
      if ((e.detailedNote ?? e.shortNote ?? '').trim().isNotEmpty) withNotes++;

      final m = DateTime(e.createdAt.year, e.createdAt.month);
      byMonth[m] = (byMonth[m] ?? 0) + 1;
    }

    // Категории: считаем по ветке, чтобы корневые не выглядели пустыми.
    final entryIds = entries.map((e) => e.id).toSet();
    final links = await (db.select(
      db.entryCategories,
    )..where((ec) => ec.entryId.isIn(entryIds))).get();
    final categories = await (db.select(
      db.categories,
    )..where((c) => c.profileId.equals(profileId))).get();
    final catById = {for (final c in categories) c.id: c};

    final perCategory = <String, int>{};
    for (final link in links) {
      if (!link.isPrimary) continue;
      final cat = catById[link.categoryId];
      if (cat == null) continue;
      for (final ancestorId in cat.path.split('/')) {
        perCategory[ancestorId] = (perCategory[ancestorId] ?? 0) + 1;
      }
    }
    final top =
        perCategory.entries
            .where((e) => catById[e.key] != null)
            .map((e) => (name: catById[e.key]!.name, count: e.value))
            .toList()
          ..sort((a, b) => b.count.compareTo(a.count));

    // Вложения привязаны к версии записи, а не к самой записи, поэтому идём
    // через текущую версию. Считаем записи, а не файлы: одна запись с пятью
    // фотографиями — это одна запись с фотографиями.
    final revisionByEntry = {
      for (final e in entries)
        if (e.currentRevisionId != null) e.currentRevisionId!: e.id,
    };
    final photoLinks = revisionByEntry.isEmpty
        ? <RevisionAttachmentRow>[]
        : await (db.select(db.revisionAttachments)
                ..where((ra) => ra.entityKind.equals('entry'))
                ..where((ra) => ra.revisionId.isIn(revisionByEntry.keys)))
              .get();
    final entriesWithPhotos = photoLinks
        .map((ra) => revisionByEntry[ra.revisionId])
        .nonNulls
        .toSet();

    final months = byMonth.keys.toList()..sort();

    return ProfileInsights(
      total: entries.length,
      rated: rated,
      averageRating: rated == 0 ? null : ratingSum / rated,
      ratingBuckets: buckets,
      byRelation: byRelation,
      topCategories: top.take(8).toList(),
      byMonth: [for (final m in months) (month: m, count: byMonth[m]!)],
      withPhotos: entriesWithPhotos.length,
      withNotes: withNotes,
    );
  }
}
