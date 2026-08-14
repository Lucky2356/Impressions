import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/repositories/category_repository.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';

import 'query_counter.dart';

/// Чем занята ветка категорий — по типам записей.
///
/// Форма добавления подставляет тип по тому, что в ветке уже лежит. Раньше
/// ради этого поднималась вся ветка с обложками — на каждое открытие формы и
/// на каждую смену категории в ней. Считать это должна база.
void main() {
  late AppDatabase db;
  late QueryCounter counter;
  late EntryRepository entries;
  late CategoryRepository categories;
  late ProfileRow me;
  late ObjectTypeRow food;
  late ObjectTypeRow places;

  setUp(() async {
    (db, counter) = openCountingDb();
    entries = EntryRepository(db);
    categories = CategoryRepository(db);
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    food = await entries.createObjectType(me.id, 'Продукты');
    places = await entries.createObjectType(me.id, 'Места');
  });

  tearDown(() => db.close());

  Future<ProfileEntryRow> add(
    String title, {
    required ObjectTypeRow type,
    String? categoryId,
  }) async {
    final object = await entries.createObject(typeId: type.id, title: title);
    return entries.createEntry(
      profileId: me.id,
      objectId: object.id,
      primaryCategoryId: categoryId,
    );
  }

  test('считает записи каждого типа в перечисленных категориях', () async {
    final shelf = await categories.createRoot(me.id, 'Отпуск');
    final other = await categories.createRoot(me.id, 'Дом');
    await add('Пляж', type: places, categoryId: shelf.id);
    await add('Парк', type: places, categoryId: shelf.id);
    await add('Мороженое', type: food, categoryId: shelf.id);
    await add('Хлеб', type: food, categoryId: other.id);

    final counts = await entries.typeCountsInCategories(me.id, [shelf.id]);

    expect(counts, {'Места': 2, 'Продукты': 1});
  });

  test('ветка целиком считается вместе с подкатегориями', () async {
    final root = await categories.createRoot(me.id, 'Отпуск');
    final child = await categories.createChild(root.id, 'Юг');
    await add('Пляж', type: places, categoryId: child.id);
    await add('Мороженое', type: food, categoryId: root.id);

    final counts = await entries.typeCountsInCategories(me.id, [
      root.id,
      child.id,
    ]);

    expect(counts, {'Места': 1, 'Продукты': 1});
  });

  test('архивная запись в счёт не идёт', () async {
    final shelf = await categories.createRoot(me.id, 'Отпуск');
    final gone = await add('Пляж', type: places, categoryId: shelf.id);
    await add('Парк', type: places, categoryId: shelf.id);

    await entries.archiveEntries([gone.id]);

    expect(await entries.typeCountsInCategories(me.id, [shelf.id]), {
      'Места': 1,
    });
  });

  test('запись на нескольких полках ветки не считается дважды', () async {
    final root = await categories.createRoot(me.id, 'Отпуск');
    final child = await categories.createChild(root.id, 'Юг');
    final entry = await add('Пляж', type: places, categoryId: root.id);
    await entries.addCategory(entry.id, child.id);

    final counts = await entries.typeCountsInCategories(me.id, [
      root.id,
      child.id,
    ]);

    expect(counts, {'Места': 1});
  });

  test('пустая ветка ничего не подсказывает', () async {
    final shelf = await categories.createRoot(me.id, 'Пустая');

    expect(await entries.typeCountsInCategories(me.id, [shelf.id]), isEmpty);
    expect(await entries.typeCountsInCategories(me.id, const []), isEmpty);
  });

  test('перевес типа считается одним запросом, а не чтением ветки', () async {
    final shelf = await categories.createRoot(me.id, 'Отпуск');
    for (var i = 0; i < 200; i++) {
      await add('Место $i', type: places, categoryId: shelf.id);
    }

    counter.reset();
    final counts = await entries.typeCountsInCategories(me.id, [shelf.id]);

    expect(counts, {'Места': 200});
    expect(counter.statements, 1);
  });
}
