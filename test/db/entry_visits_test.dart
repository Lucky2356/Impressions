import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';

import 'test_db.dart';

/// Повторные впечатления (§10).
///
/// До схемы 8 у записи была одна дата и одна оценка: сходили в то же кафе
/// второй раз — и первый приходилось затирать.
void main() {
  late AppDatabase db;
  late EntryRepository entries;
  late String entryId;

  setUp(() async {
    db = openTestDb();
    entries = EntryRepository(db);
    final me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    final type = await entries.createObjectType(me.id, 'Места');
    final object = await entries.createObject(typeId: type.id, title: 'Кафе');
    final entry = await entries.createEntry(
      profileId: me.id,
      objectId: object.id,
      rating: 6,
      impressionDate: DateTime(2026, 1, 10),
    );
    entryId = entry.id;
  });

  tearDown(() => db.close());

  Future<ProfileEntryRow> entryRow() => (db.select(
    db.profileEntries,
  )..where((e) => e.id.equals(entryId))).getSingle();

  test('новое посещение становится текущей оценкой записи', () async {
    await entries.addVisit(
      entryId: entryId,
      occurredAt: DateTime(2026, 6, 1),
      rating: 9,
      note: 'Стало заметно лучше',
    );

    final row = await entryRow();
    expect(row.rating, 9);
    expect(row.impressionDate, DateTime(2026, 6, 1));
  });

  test('первый раз попадает в историю сам', () async {
    // У записей, заведённых до обновления, первое посещение создаёт разовый
    // проход схемы 8. У новых его не было бы вовсе, и добавление второго раза
    // выглядело бы так, будто первого не случилось.
    await entries.addVisit(
      entryId: entryId,
      occurredAt: DateTime(2026, 6, 1),
      rating: 9,
    );

    final visits = await entries.visitsOf(entryId);
    expect(visits.length, 2);
    expect(visits.last.rating, 6, reason: 'первым стоит исходное впечатление');
    expect(visits.last.occurredAt, DateTime(2026, 1, 10));
  });

  test('запись без даты и без оценки лишнего повтора не заводит', () async {
    final type = (await entries.objectTypes(
      (await db.select(db.profiles).get()).single.id,
    )).first;
    final object = await entries.createObject(
      typeId: type.id,
      title: 'Ничего не сказано',
    );
    final bare = await entries.createEntry(
      profileId: (await db.select(db.profiles).get()).single.id,
      objectId: object.id,
    );

    await entries.addVisit(entryId: bare.id, occurredAt: DateTime(2026, 6, 1));

    expect(
      (await entries.visitsOf(bare.id)).length,
      1,
      reason: 'придумывать первое впечатление за человека нечего',
    );
  });

  test('история идёт от свежего к старому', () async {
    await entries.addVisit(
      entryId: entryId,
      occurredAt: DateTime(2026, 3, 1),
      rating: 7,
    );
    await entries.addVisit(
      entryId: entryId,
      occurredAt: DateTime(2026, 8, 1),
      rating: 5,
    );

    // Третьим снизу стоит исходное впечатление записи: его заводит сам
    // первый добавленный повтор.
    final visits = await entries.visitsOf(entryId);
    expect(visits.map((v) => v.rating).toList(), [5, 7, 6]);
  });

  test('запись позади самого свежего посещения не отстаёт', () async {
    // Задним числом: посещение старше того, что уже записано.
    await entries.addVisit(
      entryId: entryId,
      occurredAt: DateTime(2026, 7, 1),
      rating: 8,
    );
    await entries.addVisit(
      entryId: entryId,
      occurredAt: DateTime(2026, 2, 1),
      rating: 3,
    );

    final row = await entryRow();
    expect(
      row.rating,
      8,
      reason: 'текущая оценка — самая свежая по дате, а не последняя введённая',
    );
  });

  test('удаление повтора возвращает предыдущий', () async {
    await entries.addVisit(
      entryId: entryId,
      occurredAt: DateTime(2026, 3, 1),
      rating: 7,
    );
    final last = await entries.addVisit(
      entryId: entryId,
      occurredAt: DateTime(2026, 8, 1),
      rating: 5,
    );
    expect((await entryRow()).rating, 5);

    await entries.removeVisit(last.id);

    final row = await entryRow();
    expect(row.rating, 7);
    expect(row.impressionDate, DateTime(2026, 3, 1));
  });

  test('счётчик повторов считается пачкой', () async {
    await entries.addVisit(entryId: entryId, occurredAt: DateTime(2026, 3, 1));
    await entries.addVisit(entryId: entryId, occurredAt: DateTime(2026, 4, 1));

    // Два добавленных повтора плюс исходное впечатление записи.
    expect(await entries.visitCounts([entryId]), {entryId: 3});
    expect(await entries.visitCounts(const []), isEmpty);
  });
}
