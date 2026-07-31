import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/repositories/category_repository.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/models/entry_view.dart';

import 'test_db.dart';

/// Каталог берёт из базы страницу, а не весь профиль.
///
/// Раньше выборка отдавала все подходящие записи, и для каждой собирались
/// обложки и путь категорий, хотя на экране их шестьдесят. Это происходило на
/// каждое изменение фильтра и каждые 250 мс набора в поиске.
void main() {
  late AppDatabase db;
  late EntryRepository entries;
  late ProfileRow me;
  late ObjectTypeRow type;
  late CategoryRow branch;

  setUp(() async {
    db = openTestDb();
    entries = EntryRepository(db);
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    type = await entries.createObjectType(me.id, 'Продукты');
    branch = await CategoryRepository(db).createRoot(me.id, 'Колбасы');

    for (var i = 0; i < 120; i++) {
      final object = await entries.createObject(
        typeId: type.id,
        title: 'Запись ${i.toString().padLeft(3, '0')}',
      );
      await entries.createEntry(
        profileId: me.id,
        objectId: object.id,
        primaryCategoryId: branch.id,
      );
    }
  });

  tearDown(() => db.close());

  test('страница не зависит от размера профиля', () async {
    final page = await entries.entryViews(
      me.id,
      limit: 20,
      sort: EntrySort.title,
    );
    expect(page, hasLength(20));
    expect(page.first.title, 'Запись 000');
  });

  test('смещение отдаёт следующий кусок', () async {
    final second = await entries.entryViews(
      me.id,
      limit: 20,
      offset: 20,
      sort: EntrySort.title,
    );
    expect(second.first.title, 'Запись 020');
  });

  test('внутри ветки постранично тоже, и счёт отдельно', () async {
    // Раньше при фильтре по категории `LIMIT` не применялся вовсе: отбор шёл
    // уже после выборки, и в память поднималась вся ветка.
    final page = await entries.entryViews(
      me.id,
      categoryIds: [branch.id],
      limit: 20,
      sort: EntrySort.title,
    );
    expect(page, hasLength(20));

    final all = await entries.matchingEntryIds(
      me.id,
      categoryIds: [branch.id],
      sort: EntrySort.title,
    );
    expect(all, hasLength(120));
  });

  test('идентификаторы идут в том же порядке, что и карточки', () async {
    final ids = await entries.matchingEntryIds(me.id, sort: EntrySort.title);
    final views = await entries.entryViews(
      me.id,
      entryIds: ids.take(10).toList(),
      sort: EntrySort.title,
    );
    expect([for (final v in views) v.entryId], ids.take(10));
  });

  test('пустая ветка не отдаёт ничего', () async {
    final empty = await CategoryRepository(db).createRoot(me.id, 'Пусто');
    expect(
      await entries.matchingEntryIds(me.id, categoryIds: [empty.id]),
      isEmpty,
    );
    expect(await entries.entryViews(me.id, categoryIds: [empty.id]), isEmpty);
  });
}
