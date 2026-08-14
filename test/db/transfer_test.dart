import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/repositories/category_repository.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/services/transfer_service.dart';

import 'query_counter.dart';
import 'test_db.dart';

void main() {
  test('перенос не копирует чужую оценку и отношение (§12)', () async {
    final db = openTestDb();
    addTearDown(db.close);
    final profiles = ProfileRepository(db);
    final entries = EntryRepository(db);
    final transfer = TransferService(db);

    final other = await profiles.createOwnProfile(firstName: 'Максим');
    final me = await profiles.createOwnProfile(firstName: 'Александр');
    final type = await entries.createObjectType(other.id, 'Фильмы');
    final obj = await entries.createObject(
      typeId: type.id,
      title: 'Интерстеллар',
    );
    final theirs = await entries.createEntry(
      profileId: other.id,
      objectId: obj.id,
      relation: 'love',
      rating: 9.5,
    );

    final result = await transfer.transfer(
      sourceEntryId: theirs.id,
      targetProfileId: me.id,
    );

    final mine = await (db.select(
      db.profileEntries,
    )..where((e) => e.id.equals(result.entryId))).getSingle();

    expect(mine.relation, isNull, reason: 'Чужое отношение не копируется');
    expect(mine.rating, isNull, reason: 'Чужая оценка не копируется');
    expect(mine.status, TransferService.defaultStatus);
    expect(mine.sourceEntryId, theirs.id);
    expect(mine.recommendedByProfileId, other.id);

    // Исходная запись не изменилась.
    final theirsAfter = await (db.select(
      db.profileEntries,
    )..where((e) => e.id.equals(theirs.id))).getSingle();
    expect(theirsAfter.relation, 'love');
    expect(theirsAfter.rating, 9.5);
  });

  test('сопоставление категорий находит совпадающий путь (§7.4)', () async {
    final db = openTestDb();
    addTearDown(db.close);
    final profiles = ProfileRepository(db);
    final entries = EntryRepository(db);
    final cats = CategoryRepository(db);
    final transfer = TransferService(db);

    final other = await profiles.createOwnProfile(firstName: 'Источник');
    final me = await profiles.createOwnProfile(firstName: 'Я');

    // У источника: Продукты / Колбасы
    final srcProducts = await cats.createRoot(other.id, 'Продукты');
    final srcSausages = await cats.createChild(srcProducts.id, 'Колбасы');
    // У меня такой же путь существует.
    final myProducts = await cats.createRoot(me.id, 'Продукты');
    final mySausages = await cats.createChild(myProducts.id, 'Колбасы');

    final type = await entries.createObjectType(other.id, 'Продукты');
    final obj = await entries.createObject(
      typeId: type.id,
      title: 'Папа может',
    );
    final theirs = await entries.createEntry(
      profileId: other.id,
      objectId: obj.id,
      primaryCategoryId: srcSausages.id,
    );

    final suggestion = await transfer.suggestCategory(
      sourceEntryId: theirs.id,
      targetProfileId: me.id,
    );
    expect(suggestion.sourcePathNames, ['Продукты', 'Колбасы']);
    expect(suggestion.isExactMatch, isTrue);
    expect(suggestion.matchedCategoryId, mySausages.id);

    final result = await transfer.transfer(
      sourceEntryId: theirs.id,
      targetProfileId: me.id,
    );
    expect(result.categoryId, mySausages.id);
  });

  test('недостающий путь категорий создаётся по запросу (§7.4)', () async {
    final db = openTestDb();
    addTearDown(db.close);
    final profiles = ProfileRepository(db);
    final entries = EntryRepository(db);
    final cats = CategoryRepository(db);
    final transfer = TransferService(db);

    final other = await profiles.createOwnProfile(firstName: 'Источник');
    final me = await profiles.createOwnProfile(firstName: 'Я');

    final srcProducts = await cats.createRoot(other.id, 'Продукты');
    final srcSausages = await cats.createChild(srcProducts.id, 'Колбасы');
    final type = await entries.createObjectType(other.id, 'Продукты');
    final obj = await entries.createObject(
      typeId: type.id,
      title: 'Папа может',
    );
    final theirs = await entries.createEntry(
      profileId: other.id,
      objectId: obj.id,
      primaryCategoryId: srcSausages.id,
    );

    // У меня категорий нет вовсе.
    final suggestion = await transfer.suggestCategory(
      sourceEntryId: theirs.id,
      targetProfileId: me.id,
    );
    expect(suggestion.matchedCategoryId, isNull);
    expect(suggestion.missingNames, ['Продукты', 'Колбасы']);

    final result = await transfer.transfer(
      sourceEntryId: theirs.id,
      targetProfileId: me.id,
      mode: TransferCategoryMode.autoCreate,
    );

    final crumbs = await cats.breadcrumb(result.categoryId!);
    expect(crumbs.map((c) => c.name).toList(), ['Продукты', 'Колбасы']);
    // Дерево источника не затронуто.
    final srcRoots = await cats.roots(other.id);
    expect(srcRoots.length, 1);
  });

  test('режим «без категории» не создаёт категорий', () async {
    final db = openTestDb();
    addTearDown(db.close);
    final profiles = ProfileRepository(db);
    final entries = EntryRepository(db);
    final cats = CategoryRepository(db);
    final transfer = TransferService(db);

    final other = await profiles.createOwnProfile(firstName: 'Источник');
    final me = await profiles.createOwnProfile(firstName: 'Я');
    final srcRoot = await cats.createRoot(other.id, 'Продукты');
    final type = await entries.createObjectType(other.id, 'Продукты');
    final obj = await entries.createObject(typeId: type.id, title: 'Объект');
    final theirs = await entries.createEntry(
      profileId: other.id,
      objectId: obj.id,
      primaryCategoryId: srcRoot.id,
    );

    final result = await transfer.transfer(
      sourceEntryId: theirs.id,
      targetProfileId: me.id,
      mode: TransferCategoryMode.noCategory,
    );

    expect(result.categoryId, isNull);
    expect(await cats.roots(me.id), isEmpty);
  });

  test('перенос пачкой не поднимает дерево на каждую запись', () async {
    final (db, counter) = openCountingDb();
    addTearDown(db.close);
    final profiles = ProfileRepository(db);
    final entries = EntryRepository(db);
    final cats = CategoryRepository(db);
    final transfer = TransferService(db);

    final other = await profiles.createOwnProfile(firstName: 'Источник');
    final me = await profiles.createOwnProfile(firstName: 'Я');
    final srcProducts = await cats.createRoot(other.id, 'Продукты');
    final srcSausages = await cats.createChild(srcProducts.id, 'Колбасы');
    final type = await entries.createObjectType(other.id, 'Продукты');

    final theirs = <String>[];
    for (var i = 0; i < 20; i++) {
      final obj = await entries.createObject(
        typeId: type.id,
        title: 'Колбаса $i',
      );
      final entry = await entries.createEntry(
        profileId: other.id,
        objectId: obj.id,
        primaryCategoryId: srcSausages.id,
      );
      theirs.add(entry.id);
    }

    counter.reset();
    for (final id in theirs) {
      await transfer.transfer(
        sourceEntryId: id,
        targetProfileId: me.id,
        mode: TransferCategoryMode.autoCreate,
      );
    }

    // Ветка заводится один раз: вторая запись из тех же «Колбас» должна лечь
    // в них, а не завести вторые такие же.
    final myRoots = await cats.roots(me.id);
    expect(myRoots.map((c) => c.name), ['Продукты']);
    expect((await cats.children(myRoots.single.id)).map((c) => c.name), [
      'Колбасы',
    ]);
    expect(
      counter.matching('FROM "categories"'),
      lessThan(20),
      reason: 'деревья читались по два на каждую запись',
    );
  });

  test('объект переиспользуется, тип создаётся в целевом профиле', () async {
    final db = openTestDb();
    addTearDown(db.close);
    final profiles = ProfileRepository(db);
    final entries = EntryRepository(db);
    final transfer = TransferService(db);

    final other = await profiles.createOwnProfile(firstName: 'Источник');
    final me = await profiles.createOwnProfile(firstName: 'Я');
    final type = await entries.createObjectType(other.id, 'Фильмы');
    final obj = await entries.createObject(typeId: type.id, title: 'Дюна');
    final theirs = await entries.createEntry(
      profileId: other.id,
      objectId: obj.id,
    );

    final result = await transfer.transfer(
      sourceEntryId: theirs.id,
      targetProfileId: me.id,
    );

    final mine = await (db.select(
      db.profileEntries,
    )..where((e) => e.id.equals(result.entryId))).getSingle();
    expect(mine.objectId, obj.id, reason: 'Объект общий, дубль не создаётся');

    final myTypes = await entries.objectTypes(me.id);
    expect(myTypes.map((t) => t.name), contains('Фильмы'));

    final allObjects = await db.select(db.objects).get();
    expect(allObjects.length, 1);
  });
}
