import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/services/revision_service.dart';

import 'test_db.dart';

void main() {
  test(
    'изменение записи создаёт новую версию, старая сохраняется (§18)',
    () async {
      final db = openTestDb();
      addTearDown(db.close);
      final entries = EntryRepository(db);
      final revisions = RevisionService(db);

      final me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
      final type = await entries.createObjectType(me.id, 'Фильмы');
      final obj = await entries.createObject(
        typeId: type.id,
        title: 'Интерстеллар',
      );
      final entry = await entries.createEntry(
        profileId: me.id,
        objectId: obj.id,
        relation: 'like',
        rating: 7.0,
      );

      expect(entry.currentRevisionId, isNotNull);
      var history = await revisions.entryHistory(entry.id);
      expect(history.length, 1);

      await entries.updateEntry(entry.id, relation: 'love', rating: 9.5);

      history = await revisions.entryHistory(entry.id);
      expect(history.length, 2, reason: 'Старая версия должна сохраниться');

      final updated = await (db.select(
        db.profileEntries,
      )..where((e) => e.id.equals(entry.id))).getSingle();
      expect(updated.relation, 'love');
      expect(updated.rating, 9.5);
      expect(updated.currentRevisionId, isNot(entry.currentRevisionId));
    },
  );

  test('повторное сохранение того же содержимого не плодит версии', () async {
    final db = openTestDb();
    addTearDown(db.close);
    final entries = EntryRepository(db);
    final revisions = RevisionService(db);

    final me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    final type = await entries.createObjectType(me.id, 'Книги');
    final obj = await entries.createObject(typeId: type.id, title: 'Книга');
    final entry = await entries.createEntry(
      profileId: me.id,
      objectId: obj.id,
      relation: 'like',
    );

    await revisions.commitEntry(entry.id);
    await revisions.commitEntry(entry.id);

    final history = await revisions.entryHistory(entry.id);
    expect(history.length, 1);
  });

  test('восстановление версии создаёт новую версию на основе старой', () async {
    final db = openTestDb();
    addTearDown(db.close);
    final entries = EntryRepository(db);
    final revisions = RevisionService(db);

    final me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    final type = await entries.createObjectType(me.id, 'Игры');
    final obj = await entries.createObject(typeId: type.id, title: 'Игра');
    final entry = await entries.createEntry(
      profileId: me.id,
      objectId: obj.id,
      relation: 'like',
      rating: 6.0,
    );
    final firstRevision = entry.currentRevisionId!;

    await entries.updateEntry(entry.id, relation: 'avoid', rating: 2.0);
    await revisions.restoreEntryRevision(entry.id, firstRevision);

    final restored = await (db.select(
      db.profileEntries,
    )..where((e) => e.id.equals(entry.id))).getSingle();
    expect(restored.relation, 'like');
    expect(restored.rating, 6.0);

    // §18: восстановление создаёт НОВУЮ версию на основе старой,
    // а не переиспользует существующую.
    final history = await revisions.entryHistory(entry.id);
    expect(history.length, 3);
    expect(restored.currentRevisionId, isNot(firstRevision));
    expect(history.first.parentRevisionId, isNotNull);
  });

  test('мнение одного профиля не меняет запись другого (§6.2)', () async {
    final db = openTestDb();
    addTearDown(db.close);
    final entries = EntryRepository(db);
    final profiles = ProfileRepository(db);

    final me = await profiles.createOwnProfile(firstName: 'Александр');
    final other = await profiles.createOwnProfile(firstName: 'Лариса');
    final type = await entries.createObjectType(me.id, 'Фильмы');
    final obj = await entries.createObject(
      typeId: type.id,
      title: 'Интерстеллар',
    );

    final mine = await entries.createEntry(
      profileId: me.id,
      objectId: obj.id,
      relation: 'love',
      rating: 9.5,
    );
    final theirs = await entries.createEntry(
      profileId: other.id,
      objectId: obj.id,
      relation: 'neutral',
      rating: 6.0,
    );

    await entries.updateEntry(mine.id, rating: 10.0);

    final theirsAfter = await (db.select(
      db.profileEntries,
    )..where((e) => e.id.equals(theirs.id))).getSingle();
    expect(theirsAfter.rating, 6.0);
    expect(theirsAfter.relation, 'neutral');
  });
}
