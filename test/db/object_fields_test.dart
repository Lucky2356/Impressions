import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';

import 'test_db.dart';

/// Оригинальное название и краткое описание объекта.
///
/// Обе колонки были в базе с самого начала: описание даже подставлялось
/// подзаголовком в списках, когда у объекта нет бренда. Ввести их было негде,
/// а `updateObject` не умел стирать поля — `null` там значил «не трогать».
void main() {
  test('поля правятся, а пустое значение стирает прежнее', () async {
    final db = openTestDb();
    addTearDown(db.close);
    final entries = EntryRepository(db);
    final me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    final type = await entries.createObjectType(me.id, 'Сериалы');
    final object = await entries.createObject(
      typeId: type.id,
      title: 'Твин Пикс',
    );

    await entries.updateObject(
      object.id,
      altTitle: 'Twin Peaks',
      summary: 'Странный городок и вишнёвый пирог',
      creator: 'Дэвид Линч',
      year: 1990,
    );

    Future<ObjectRow> read() async => (await (db.select(
      db.objects,
    )..where((o) => o.id.equals(object.id))).getSingle());

    var saved = await read();
    expect(saved.altTitle, 'Twin Peaks');
    expect(saved.summary, 'Странный городок и вишнёвый пирог');
    expect(saved.normalizedAltTitle, isNotNull);

    // Не переданное поле остаётся прежним.
    await entries.updateObject(object.id, title: 'Твин Пикс');
    saved = await read();
    expect(saved.altTitle, 'Twin Peaks');
    expect(saved.creator, 'Дэвид Линч');

    // Явный null стирает.
    await entries.updateObject(object.id, altTitle: null, creator: null);
    saved = await read();
    expect(saved.altTitle, isNull);
    expect(
      saved.normalizedAltTitle,
      isNull,
      reason: 'нормализованное написание уходит вместе с самим названием',
    );
    expect(saved.creator, isNull);
    expect(saved.summary, 'Странный городок и вишнёвый пирог');
  });
}
