import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/repositories/category_repository.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';

import 'test_db.dart';

/// Объединение веток (§7.1).
///
/// Раньше свести две одинаковые по смыслу категории было нечем: оставалось
/// перекладывать записи руками по одной. При этом просто перевести связи
/// запросом нельзя — у записи, лежащей в обеих категориях, столкнётся
/// первичный ключ, а у записи с двумя основными — уникальный индекс.
void main() {
  late AppDatabase db;
  late CategoryRepository cats;
  late EntryRepository entries;
  late ProfileRepository profiles;
  late String profileId;
  late String typeId;

  setUp(() async {
    db = openTestDb();
    cats = CategoryRepository(db);
    entries = EntryRepository(db);
    profiles = ProfileRepository(db);
    final me = await profiles.createOwnProfile(firstName: 'Я');
    profileId = me.id;
    typeId = (await entries.createObjectType(profileId, 'Продукты')).id;
  });
  tearDown(() => db.close());

  Future<String> entry(String title, {String? category}) async {
    final obj = await entries.createObject(typeId: typeId, title: title);
    final row = await entries.createEntry(
      profileId: profileId,
      objectId: obj.id,
      primaryCategoryId: category,
    );
    return row.id;
  }

  Future<List<EntryCategoryRow>> linksOf(String entryId) => (db.select(
    db.entryCategories,
  )..where((l) => l.entryId.equals(entryId))).get();

  Future<CategoryRow> reload(String id) =>
      (db.select(db.categories)..where((c) => c.id.equals(id))).getSingle();

  test('записи и подкатегории переезжают, исходная уходит в архив', () async {
    final from = await cats.createRoot(profileId, 'Колбаса');
    final to = await cats.createRoot(profileId, 'Колбасы');
    final kid = await cats.createChild(from.id, 'Варёные');
    final grandKid = await cats.createChild(kid.id, 'Докторская');
    final e = await entry('Папа может', category: from.id);

    final result = await cats.merge(sourceId: from.id, targetId: to.id);

    expect(result.movedEntries, 1);
    expect(result.movedChildren, 1);

    final links = await linksOf(e);
    expect(links.single.categoryId, to.id);
    expect(links.single.isPrimary, isTrue);

    expect((await reload(kid.id)).parentId, to.id);
    expect(
      (await reload(grandKid.id)).path,
      '${to.id}/${kid.id}/${grandKid.id}',
      reason: 'внук переехал вместе с веткой',
    );
    expect((await reload(from.id)).archivedAt, isNotNull);
  });

  test(
    'запись, лежавшая в обеих, не задваивается и остаётся с основной',
    () async {
      final from = await cats.createRoot(profileId, 'Откуда');
      final to = await cats.createRoot(profileId, 'Куда');
      final e = await entry('Двойная', category: from.id);
      // Та же запись лежит и в цели — дополнительной категорией.
      await entries.addCategory(e, to.id);

      await cats.merge(sourceId: from.id, targetId: to.id);

      final links = await linksOf(e);
      expect(links, hasLength(1), reason: 'связь не задвоилась');
      expect(links.single.categoryId, to.id);
      expect(
        links.single.isPrimary,
        isTrue,
        reason: 'основная категория не потерялась при переезде',
      );
    },
  );

  test('дополнительная связь остаётся дополнительной', () async {
    final from = await cats.createRoot(profileId, 'Откуда');
    final to = await cats.createRoot(profileId, 'Куда');
    final e = await entry('Основная в цели', category: to.id);
    await entries.addCategory(e, from.id);

    await cats.merge(sourceId: from.id, targetId: to.id);

    final links = await linksOf(e);
    expect(links, hasLength(1));
    expect(links.single.isPrimary, isTrue);
  });

  test('архивные подкатегории переезжают тоже', () async {
    // Иначе они остались бы висеть под архивированной исходной веткой, и
    // достать их из архива было бы некуда.
    final from = await cats.createRoot(profileId, 'Откуда');
    final to = await cats.createRoot(profileId, 'Куда');
    final kid = await cats.createChild(from.id, 'Забытая');
    await cats.archive(kid.id);

    await cats.merge(sourceId: from.id, targetId: to.id);

    expect((await reload(kid.id)).parentId, to.id);
  });

  test('слияние с самой собой и со своей подкатегорией отклоняется', () async {
    final root = await cats.createRoot(profileId, 'Корень');
    final kid = await cats.createChild(root.id, 'Ребёнок');

    expect(
      () => cats.merge(sourceId: root.id, targetId: root.id),
      throwsA(isA<CategoryTreeException>()),
    );
    expect(
      () => cats.merge(sourceId: root.id, targetId: kid.id),
      throwsA(isA<CategoryTreeException>()),
    );
    expect((await reload(root.id)).archivedAt, isNull);
  });

  test('категории разных профилей не сводятся', () async {
    final other = await profiles.createOwnProfile(firstName: 'Чужой');
    final mine = await cats.createRoot(profileId, 'Моя');
    final theirs = await cats.createRoot(other.id, 'Чужая');

    expect(
      () => cats.merge(sourceId: mine.id, targetId: theirs.id),
      throwsA(isA<CategoryTreeException>()),
    );
  });

  test('пустая ветка сводится без записей и детей', () async {
    final from = await cats.createRoot(profileId, 'Пустая');
    final to = await cats.createRoot(profileId, 'Цель');

    final result = await cats.merge(sourceId: from.id, targetId: to.id);

    expect(result.movedEntries, 0);
    expect(result.movedChildren, 0);
    expect((await reload(from.id)).archivedAt, isNotNull);
  });

  test('сведённую ветку можно убрать насовсем — детей у неё уже нет', () async {
    final from = await cats.createRoot(profileId, 'Откуда');
    final to = await cats.createRoot(profileId, 'Куда');
    await cats.createChild(from.id, 'Ребёнок');

    await cats.merge(sourceId: from.id, targetId: to.id);

    expect(await cats.children(from.id, includeArchived: true), isEmpty);
  });
}
