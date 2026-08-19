import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';

import 'test_db.dart';

/// Разовый проход схемы 8: у записей появляется первое посещение.
///
/// Без него история повторов начиналась бы со второго раза, а первый выглядел
/// бы забытым: запись есть, дата есть, а в истории пусто.
void main() {
  late AppDatabase db;
  late EntryRepository entries;
  late ProfileRow me;
  late String typeId;

  setUp(() async {
    db = openTestDb();
    entries = EntryRepository(db);
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    typeId = (await entries.createObjectType(me.id, 'Места')).id;
  });

  tearDown(() => db.close());

  Future<String> entryWith({double? rating, DateTime? date}) async {
    final object = await entries.createObject(
      typeId: typeId,
      title: 'Кафе ${DateTime.now().microsecondsSinceEpoch}',
    );
    final entry = await entries.createEntry(
      profileId: me.id,
      objectId: object.id,
      rating: rating,
      impressionDate: date,
    );
    return entry.id;
  }

  test('посещение заводится там, где есть дата или оценка', () async {
    final rated = await entryWith(rating: 8);
    final dated = await entryWith(date: DateTime(2026, 5, 4));
    final empty = await entryWith();

    expect(await db.seedFirstVisits(), 2);

    expect((await entries.visitsOf(rated)).single.rating, 8);
    expect(
      (await entries.visitsOf(dated)).single.occurredAt,
      DateTime(2026, 5, 4),
    );
    expect(
      await entries.visitsOf(empty),
      isEmpty,
      reason: 'запись без даты и без оценки — не повод придумывать посещение',
    );
  });

  test('у записи без даты посещение берёт день заведения', () async {
    final id = await entryWith(rating: 5);
    await db.seedFirstVisits();

    final entry = await (db.select(
      db.profileEntries,
    )..where((e) => e.id.equals(id))).getSingle();
    expect((await entries.visitsOf(id)).single.occurredAt, entry.createdAt);
  });
}
