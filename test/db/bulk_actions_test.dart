import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/core/domain/relation.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/repositories/category_repository.dart';
import 'package:impressions/data/repositories/collection_repository.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';

import 'query_counter.dart';

/// Массовые действия каталога: пачкой, а не по одной записи.
///
/// Раньше панель выделения звала обычный метод в цикле. Оценка на три сотни
/// записей означала три сотни транзакций, а внутри каждой — чтение записи,
/// чтение хеша текущей версии, вставку версии, обновление ссылки и перенос
/// вложений. Здесь проверяется и то, что результат остался прежним, и то,
/// что обращений к базе стало на порядки меньше.
void main() {
  late AppDatabase db;
  late QueryCounter counter;
  late EntryRepository entries;
  late String profileId;
  late String typeId;

  setUp(() async {
    (db, counter) = openCountingDb();
    entries = EntryRepository(db);
    final me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    profileId = me.id;
    typeId = (await entries.createObjectType(me.id, 'Всё подряд')).id;
  });

  tearDown(() => db.close());

  Future<String> addEntry(String title) async {
    final obj = await entries.createObject(typeId: typeId, title: title);
    final entry = await entries.createEntry(
      profileId: profileId,
      objectId: obj.id,
      relation: Relation.like.name,
    );
    return entry.id;
  }

  Future<List<String>> addEntries(int count) async {
    final ids = <String>[];
    for (var i = 0; i < count; i++) {
      ids.add(await addEntry('Запись $i'));
    }
    return ids;
  }

  Future<ProfileEntryRow> entryOf(String id) =>
      (db.select(db.profileEntries)..where((e) => e.id.equals(id))).getSingle();

  Future<int> revisionCount(String entryId) async {
    final rows = await (db.select(
      db.profileEntryRevisions,
    )..where((r) => r.entryId.equals(entryId))).get();
    return rows.length;
  }

  group('Оценка и отношение всей пачке', () {
    test('результат тот же, что и у прежнего цикла по одной', () async {
      final oneByOne = await addEntries(3);
      final batch = await addEntries(3);

      for (final id in oneByOne) {
        await entries.updateEntry(
          id,
          rating: 4.5,
          relation: Relation.love.name,
        );
      }
      await entries.updateEntries(
        batch,
        rating: 4.5,
        relation: Relation.love.name,
      );

      for (final id in [...oneByOne, ...batch]) {
        final row = await entryOf(id);
        expect(row.rating, 4.5, reason: id);
        expect(row.relation, Relation.love.name, reason: id);
        expect(await revisionCount(id), 2, reason: 'первая версия и правка');
      }
    });

    test('версию получает каждая изменённая запись', () async {
      final ids = await addEntries(20);
      final before = {
        for (final id in ids) id: (await entryOf(id)).currentRevisionId,
      };

      await entries.updateEntries(ids, rating: 3.0);

      for (final id in ids) {
        final row = await entryOf(id);
        expect(row.currentRevisionId, isNot(before[id]), reason: id);
        final revision = await (db.select(
          db.profileEntryRevisions,
        )..where((r) => r.id.equals(row.currentRevisionId!))).getSingle();
        expect(revision.parentRevisionId, before[id]);
        expect(revision.payloadJson, contains('"rating":3.0'));
      }
    });

    test('запись без изменений новой версии не получает', () async {
      final ids = await addEntries(3);
      await entries.updateEntries(ids, rating: 3.0);
      final after = {
        for (final id in ids) id: (await entryOf(id)).currentRevisionId,
      };

      await entries.updateEntries(ids, rating: 3.0);

      for (final id in ids) {
        expect((await entryOf(id)).currentRevisionId, after[id]);
        expect(await revisionCount(id), 2);
      }
    });

    test('фотографии переезжают на новую версию', () async {
      final id = await addEntry('С фотографией');
      final entry = await entryOf(id);
      await db
          .into(db.attachments)
          .insert(
            AttachmentsCompanion.insert(
              id: 'att',
              sha256: 'hash',
              storagePath: 'media/att.jpg',
              mimeType: 'image/jpeg',
              byteSize: 10,
              createdAt: DateTime.now(),
            ),
          );
      await db
          .into(db.revisionAttachments)
          .insert(
            RevisionAttachmentsCompanion.insert(
              id: 'link',
              entityKind: 'entry',
              revisionId: entry.currentRevisionId!,
              attachmentId: 'att',
              isPrimary: const Value(true),
            ),
          );

      await entries.updateEntries([id], rating: 5.0);

      final fresh = await entryOf(id);
      final links = await (db.select(
        db.revisionAttachments,
      )..where((ra) => ra.revisionId.equals(fresh.currentRevisionId!))).get();
      expect(
        links,
        hasLength(1),
        reason: 'иначе фотография пропадёт из записи',
      );
      expect(links.single.attachmentId, 'att');
      expect(links.single.isPrimary, isTrue);
    });

    test('300 записей — одна транзакция вместо трёхсот', () async {
      final ids = await addEntries(300);

      counter.reset();
      await entries.updateEntries(ids, rating: 5.0);

      expect(
        counter.transactions,
        1,
        reason: 'каждая транзакция — отдельная запись в журнал',
      );
      expect(
        counter.statements,
        lessThan(10),
        reason: 'прежний цикл делал больше тысячи запросов',
      );
    });
  });

  group('Категория всей пачке', () {
    test('новая основная встаёт, прежняя снимается', () async {
      final cats = CategoryRepository(db);
      final was = await cats.createRoot(profileId, 'Было');
      final now = await cats.createRoot(profileId, 'Стало');
      final ids = await addEntries(5);
      await entries.setPrimaryCategories(ids, was.id);

      await entries.setPrimaryCategories(ids, now.id);

      for (final id in ids) {
        final links = await (db.select(
          db.entryCategories,
        )..where((ec) => ec.entryId.equals(id))).get();
        final primary = links.where((l) => l.isPrimary).toList();
        expect(primary, hasLength(1), reason: 'основная категория одна');
        expect(primary.single.categoryId, now.id);
      }
    });

    test('300 записей — одна транзакция', () async {
      final cat = await CategoryRepository(db).createRoot(profileId, 'Полка');
      final ids = await addEntries(300);

      counter.reset();
      await entries.setPrimaryCategories(ids, cat.id);

      expect(counter.transactions, 1);
      expect(counter.statements, isZero, reason: 'всё уходит одним пакетом');
    });
  });

  group('Теги всей пачке', () {
    test('тег заводится один раз и висит на всех', () async {
      final ids = await addEntries(5);

      final tag = await entries.addTagToEntries(profileId, ids, 'вечернее');

      expect(await entries.tagsOfProfile(profileId), hasLength(1));
      for (final id in ids) {
        expect((await entries.tagsOfEntry(id)).single.id, tag.id);
      }
    });

    test('повторное навешивание не плодит связей', () async {
      final ids = await addEntries(3);
      await entries.addTagToEntries(profileId, ids, 'вечернее');

      await entries.addTagToEntries(profileId, ids, 'Вечернее');

      expect(await entries.tagsOfProfile(profileId), hasLength(1));
      expect(await entries.tagUsage(profileId), hasLength(1));
      expect(await entries.tagsOfEntry(ids.first), hasLength(1));
    });

    test('снятие убирает тег со всех выделенных и ни с кого больше', () async {
      final ids = await addEntries(4);
      final other = await addEntry('Чужая');
      final tag = await entries.addTagToEntries(profileId, [
        ...ids,
        other,
      ], 'вечернее');

      await entries.removeTagFromEntries(ids, tag.id);

      for (final id in ids) {
        expect(await entries.tagsOfEntry(id), isEmpty, reason: id);
      }
      expect((await entries.tagsOfEntry(other)).single.id, tag.id);
    });

    test(
      'список тегов выделенного — один проход, а не запрос на запись',
      () async {
        final ids = await addEntries(300);
        await entries.addTagToEntries(profileId, ids, 'бета');
        await entries.addTagToEntries(profileId, ids.take(5).toList(), 'альфа');

        counter.reset();
        final tags = await entries.tagsOfEntries(ids);

        expect(tags.map((t) => t.name), ['альфа', 'бета']);
        expect(counter.statements, lessThan(5));
      },
    );
  });

  group('Архив пачкой', () {
    test('уходят и возвращаются все', () async {
      final ids = await addEntries(5);

      await entries.archiveEntries(ids);
      for (final id in ids) {
        expect((await entryOf(id)).archivedAt, isNotNull, reason: id);
      }

      await entries.restoreEntries(ids);
      for (final id in ids) {
        expect((await entryOf(id)).archivedAt, isNull, reason: id);
      }
    });

    test('300 записей — один запрос', () async {
      final ids = await addEntries(300);

      counter.reset();
      await entries.archiveEntries(ids);

      expect(counter.statements, 1);
      expect(counter.transactions, isZero);
    });
  });

  group('Подборка пачкой', () {
    late CollectionRepository collections;
    late String collectionId;

    setUp(() async {
      collections = CollectionRepository(db);
      collectionId = (await collections.create(profileId, 'Летнее')).id;
    });

    Future<List<String>> inCollection() async {
      final rows =
          await (db.select(db.collectionEntries)
                ..where((ce) => ce.collectionId.equals(collectionId))
                ..orderBy([(ce) => OrderingTerm(expression: ce.sortOrder)]))
              .get();
      return rows.map((r) => r.entryId).toList();
    }

    test('порядок добавления сохраняется', () async {
      final ids = await addEntries(5);

      await collections.addEntries(collectionId, ids);

      expect(await inCollection(), ids);
    });

    test('уже лежащие в подборке не задваиваются', () async {
      final ids = await addEntries(4);
      await collections.addEntries(collectionId, ids.take(2).toList());

      await collections.addEntries(collectionId, ids);

      expect(await inCollection(), ids, reason: 'прежние остаются на местах');
    });

    test('одна запись дважды в наборе кладётся один раз', () async {
      final ids = await addEntries(2);

      await collections.addEntries(collectionId, [...ids, ids.first]);

      expect(await inCollection(), ids);
    });

    test('300 записей не поднимают подборку заново на каждую', () async {
      final ids = await addEntries(300);

      counter.reset();
      await collections.addEntries(collectionId, ids);

      expect(counter.statements, 1, reason: 'один взгляд на подборку');
      expect(counter.transactions, 1);
      expect(counter.batched, 300);
    });
  });
}
