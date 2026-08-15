import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/services/transfer_service.dart';
import 'package:sqlite3/sqlite3.dart';

import 'test_db.dart';

/// «Кто мне это посоветовал» приложение писало с самого начала и никогда не
/// показывало. Теперь такие записи можно отобрать.
void main() {
  test('фильтр отбирает только то, что посоветовали', () async {
    final db = openTestDb();
    addTearDown(db.close);
    final profiles = ProfileRepository(db);
    final entries = EntryRepository(db);

    final other = await profiles.createOwnProfile(firstName: 'Максим');
    final me = await profiles.createOwnProfile(firstName: 'Александр');
    final type = await entries.createObjectType(other.id, 'Фильмы');

    final film = await entries.createObject(
      typeId: type.id,
      title: 'Интерстеллар',
    );
    final theirs = await entries.createEntry(
      profileId: other.id,
      objectId: film.id,
      relation: 'love',
    );
    await TransferService(
      db,
    ).transfer(sourceEntryId: theirs.id, targetProfileId: me.id);

    final myType = await entries.createObjectType(me.id, 'Книги');
    final book = await entries.createObject(
      typeId: myType.id,
      title: 'Война и мир',
    );
    await entries.createEntry(profileId: me.id, objectId: book.id);

    final all = await entries.entryViews(me.id);
    expect(all.map((v) => v.title).toSet(), {'Интерстеллар', 'Война и мир'});

    final advised = await entries.entryViews(me.id, recommendedOnly: true);
    expect(advised.map((v) => v.title), ['Интерстеллар']);
  });

  test('имя советчика видно рядом с записью', () async {
    final db = openTestDb();
    addTearDown(db.close);
    final profiles = ProfileRepository(db);
    final entries = EntryRepository(db);

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
    );

    final result = await TransferService(
      db,
    ).transfer(sourceEntryId: theirs.id, targetProfileId: me.id);

    final mine = await (db.select(
      db.profileEntries,
    )..where((e) => e.id.equals(result.entryId))).getSingle();
    final source = await (db.select(
      db.profiles,
    )..where((p) => p.id.equals(mine.recommendedByProfileId!))).getSingle();

    expect(source.firstName, 'Максим');
  });

  test('миграция 3 → 4 убирает мёртвую таблицу и не трогает данные', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

    // База, как её оставила версия 3: с таблицей profile_relationships и с
    // записанной строкой в ней.
    final raw = sqlite3.openInMemory();
    // closeUnderlyingOnClose: соединение переживает закрытие базы — иначе
    // повторно открыть ту же базу и проверить миграцию было бы нечем.
    var db = AppDatabase.forTesting(
      NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
    );
    await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    raw.execute('''
      CREATE TABLE IF NOT EXISTS profile_relationships (
        id TEXT NOT NULL PRIMARY KEY,
        from_profile_id TEXT NOT NULL,
        to_profile_id TEXT NOT NULL,
        relation TEXT,
        note TEXT,
        created_at INTEGER NOT NULL
      )
    ''');
    raw.execute(
      "INSERT INTO profile_relationships VALUES ('r1', 'a', 'b', null, null, 0)",
    );
    await pretendSchemaVersion(db, 3);
    await db.close();

    // Открытие поднимает схему до 4.
    db = AppDatabase.forTesting(
      NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
    );
    addTearDown(db.close);
    final profiles = await ProfileRepository(db).all();

    expect(profiles.map((p) => p.firstName), ['Я'], reason: 'данные на месте');
    final tables = raw
        .select("SELECT name FROM sqlite_master WHERE type = 'table'")
        .map((r) => r['name'] as String);
    expect(tables, isNot(contains('profile_relationships')));
  });

  test('миграция 4 → 5 убирает таблицу recommendations', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

    // База, как её оставила версия 4: с таблицей recommendations и строкой в
    // ней. Она дублировала «кто посоветовал» из самой записи и не читалась.
    final raw = sqlite3.openInMemory();
    var db = AppDatabase.forTesting(
      NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
    );
    await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    raw.execute('''
      CREATE TABLE IF NOT EXISTS recommendations (
        id TEXT NOT NULL PRIMARY KEY,
        profile_id TEXT NOT NULL,
        object_id TEXT NOT NULL,
        from_profile_id TEXT,
        note TEXT,
        created_at INTEGER NOT NULL
      )
    ''');
    raw.execute(
      "INSERT INTO recommendations VALUES ('r1', 'p1', 'o1', 'p2', null, 0)",
    );
    await pretendSchemaVersion(db, 4);
    await db.close();

    db = AppDatabase.forTesting(
      NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
    );
    addTearDown(db.close);
    final profiles = await ProfileRepository(db).all();

    expect(profiles.map((p) => p.firstName), ['Я'], reason: 'данные на месте');
    final tables = raw
        .select("SELECT name FROM sqlite_master WHERE type = 'table'")
        .map((r) => r['name'] as String);
    expect(tables, isNot(contains('recommendations')));
  });
}
