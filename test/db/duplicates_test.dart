import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';

import 'test_db.dart';

/// Поиск похожих объектов при добавлении записи (§26).
///
/// Сравнение шло вхождением в обе стороны без ограничения по длине: заводя
/// «Чай», человек получал диалог со списком всех чаёв.
void main() {
  late AppDatabase db;
  late EntryRepository entries;
  late ObjectTypeRow type;

  setUp(() async {
    db = openTestDb();
    entries = EntryRepository(db);
    final me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    type = await entries.createObjectType(me.id, 'Продукты');
  });

  tearDown(() => db.close());

  Future<List<String>> candidates(String title, {String? barcode}) async {
    final rows = await entries.findDuplicateCandidates(
      type.id,
      title,
      barcode: barcode,
    );
    return [for (final o in rows) o.title];
  }

  test('короткое название не тянет за собой всё похожее', () async {
    await entries.createObject(typeId: type.id, title: 'Чай зелёный');
    await entries.createObject(typeId: type.id, title: 'Иван-чай');

    expect(await candidates('Чай'), isEmpty);
  });

  test('точное совпадение находится и у короткого названия', () async {
    await entries.createObject(typeId: type.id, title: 'Чай');
    await entries.createObject(typeId: type.id, title: 'Чай зелёный');

    expect(await candidates('чай'), ['Чай']);
  });

  test('длинное название по-прежнему ищется вхождением', () async {
    await entries.createObject(typeId: type.id, title: 'Папа может');

    expect(await candidates('Папа может варёная'), ['Папа может']);
    expect(await candidates('Папа может, варёная!'), ['Папа может']);
  });

  test('«ё» и «е» совпадению не мешают', () async {
    await entries.createObject(typeId: type.id, title: 'Варёная колбаса');

    expect(await candidates('Вареная колбаса'), ['Варёная колбаса']);
  });

  test('штрихкод совпадает всегда, как бы ни называлось', () async {
    await entries.createObject(
      typeId: type.id,
      title: 'Молоко отборное',
      barcode: '4600000000001',
    );

    expect(await candidates('Совсем другое', barcode: '4600000000001'), [
      'Молоко отборное',
    ]);
  });

  test('чужой тип в кандидаты не попадает', () async {
    final me = await ProfileRepository(db).createOwnProfile(firstName: 'Ещё');
    final other = await entries.createObjectType(me.id, 'Фильмы');
    await entries.createObject(typeId: other.id, title: 'Папа может');

    expect(await candidates('Папа может'), isEmpty);
  });
}
