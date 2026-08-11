import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/models/entry_view.dart';
import 'package:impressions/data/repositories/category_repository.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';

import 'test_db.dart';

/// Каталог берёт у базы окно строк и число найденного.
///
/// Раньше сюда поднимался список идентификаторов всего подходящего — на каждую
/// букву в поиске и каждое переключение фильтра, — а нужны из него были только
/// длина и первые шестьдесят строк.
void main() {
  late AppDatabase db;
  late EntryRepository entries;
  late CategoryRepository categories;
  late ProfileRow me;
  late ObjectTypeRow type;

  setUp(() async {
    db = openTestDb();
    entries = EntryRepository(db);
    categories = CategoryRepository(db);
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    type = await entries.createObjectType(me.id, 'Продукты');
  });

  tearDown(() => db.close());

  Future<ProfileEntryRow> add(
    String title, {
    String? categoryId,
    double? rating,
    String? relation,
  }) async {
    final object = await entries.createObject(typeId: type.id, title: title);
    return entries.createEntry(
      profileId: me.id,
      objectId: object.id,
      rating: rating,
      relation: relation,
      primaryCategoryId: categoryId,
    );
  }

  test('окно короче найденного, а счёт считает всё', () async {
    for (var i = 0; i < 25; i++) {
      await add('Запись $i');
    }

    final page = await entries.entryPage(me.id, limit: 10);

    expect(page.total, 25);
    expect(page.items, hasLength(10));
    expect(page.hasMore, isTrue);
  });

  test('страница совпадает с прежней выборкой по порядку', () async {
    for (var i = 0; i < 12; i++) {
      await add('Запись $i', rating: (i % 10) + 0.5);
    }

    for (final sort in EntrySort.values) {
      for (final reverse in [false, true]) {
        final page = await entries.entryPage(
          me.id,
          sort: sort,
          reverseSort: reverse,
          limit: 5,
        );
        final views = await entries.entryViews(
          me.id,
          sort: sort,
          reverseSort: reverse,
          limit: 5,
        );

        expect(
          page.items.map((e) => e.entryId),
          views.map((e) => e.entryId),
          reason: 'порядок $sort, разворот $reverse',
        );
        expect(page.total, 12);
      }
    }
  });

  test('фильтры сужают и окно, и счёт', () async {
    final food = await categories.createRoot(me.id, 'Еда');
    final sausages = await categories.createChild(food.id, 'Колбасы');
    for (var i = 0; i < 8; i++) {
      await add('Колбаса $i', categoryId: sausages.id, relation: 'like');
    }
    for (var i = 0; i < 5; i++) {
      await add('Прочее $i');
    }

    final byCategory = await entries.entryPage(
      me.id,
      categoryIds: [sausages.id],
      limit: 3,
    );
    expect(byCategory.total, 8);
    expect(byCategory.items, hasLength(3));

    final byRelation = await entries.entryPage(
      me.id,
      relation: 'like',
      limit: 100,
    );
    expect(byRelation.total, 8);

    final none = await entries.entryPage(me.id, relation: 'avoid', limit: 10);
    expect(none.total, 0);
    expect(none.items, isEmpty);
    expect(none.hasMore, isFalse);
  });

  test('смещение отдаёт следующий кусок без повторов', () async {
    for (var i = 0; i < 10; i++) {
      await add('Запись $i');
    }

    final first = await entries.entryPage(me.id, limit: 4);
    final second = await entries.entryPage(me.id, limit: 4, offset: 4);

    final firstIds = first.items.map((e) => e.entryId).toSet();
    final secondIds = second.items.map((e) => e.entryId).toSet();
    expect(firstIds.intersection(secondIds), isEmpty);
    expect(second.total, 10);
  });

  test('архивные записи не попадают ни в окно, ни в счёт', () async {
    final kept = await add('Остаётся');
    final gone = await add('Уходит');
    await entries.archiveEntry(gone.id);

    final page = await entries.entryPage(me.id, limit: 10);

    expect(page.total, 1);
    expect(page.items.single.entryId, kept.id);
  });
}
