import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';

import 'test_db.dart';

/// «ё» и «е» в поиске — одна буква.
///
/// Токенизатор `unicode61` их не сближает: «елка» не находила «Ёлку», а
/// «зелен» не находила «зелёную» вовсе. Индекс поэтому набирается уже
/// свёрнутым текстом, и запрос сворачивается тем же правилом.
void main() {
  test('поиск по названию не различает «ё» и «е»', () async {
    final db = openTestDb();
    addTearDown(db.close);
    final profiles = ProfileRepository(db);
    final entries = EntryRepository(db);

    final me = await profiles.createOwnProfile(firstName: 'Поиск');
    final type = await entries.createObjectType(me.id, 'Продукты');
    final yolka = await entries.createObject(
      typeId: type.id,
      title: 'Ёлка новогодняя',
    );
    await entries.createObject(typeId: type.id, title: 'Начало');

    expect(await db.searchObjectIds('елка'), [yolka.id]);
    expect(await db.searchObjectIds('ёлка'), [yolka.id]);
    expect(await db.searchObjectIds('Ёлк'), [yolka.id]);
  });

  test('поиск внутри слова тоже сворачивает «ё»', () async {
    final db = openTestDb();
    addTearDown(db.close);
    final profiles = ProfileRepository(db);
    final entries = EntryRepository(db);

    final me = await profiles.createOwnProfile(firstName: 'Поиск');
    final type = await entries.createObjectType(me.id, 'Продукты');
    final tea = await entries.createObject(
      typeId: type.id,
      title: 'Зелёный чай',
      creator: 'Гринфилд',
    );

    // Слово написано через «ё», а ищут через «е» — самый частый случай.
    expect(await db.searchObjectIds('зелен'), [tea.id]);
  });

  test('правка названия оставляет индекс свёрнутым', () async {
    final db = openTestDb();
    addTearDown(db.close);
    final profiles = ProfileRepository(db);
    final entries = EntryRepository(db);

    final me = await profiles.createOwnProfile(firstName: 'Поиск');
    final type = await entries.createObjectType(me.id, 'Продукты');
    final object = await entries.createObject(typeId: type.id, title: 'Начало');

    // Обновление идёт через триггер `objects_au`: он удаляет прежнюю строку
    // индекса и пишет новую. Если свернуть только вставку, удаление перестанет
    // совпадать и в индексе останется мусор.
    await entries.updateObject(object.id, title: 'Тёплый приём');

    expect(await db.searchObjectIds('теплый'), [object.id]);
    expect(await db.searchObjectIds('приём'), [object.id]);
    expect(await db.searchObjectIds('начало'), isEmpty);
  });

  test('поиск по тексту заметки не различает «ё» и «е»', () async {
    final db = openTestDb();
    addTearDown(db.close);
    final profiles = ProfileRepository(db);
    final entries = EntryRepository(db);

    final me = await profiles.createOwnProfile(firstName: 'Поиск');
    final type = await entries.createObjectType(me.id, 'Продукты');
    final object = await entries.createObject(typeId: type.id, title: 'Мёд');
    final entry = await entries.createEntry(
      profileId: me.id,
      objectId: object.id,
      detailedNote: 'Слишком приторный, берём другой',
    );

    expect(await db.searchEntryIdsByNote('берем'), [entry.id]);
  });
}
