import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';

import 'test_db.dart';

void main() {
  test('база седьмой схемы получает посещения при открытии', () async {
    final dir = await Directory.systemTemp.createTemp('probe-7to8');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/impressions.sqlite');

    // Настоящая база 1.22: записи есть, таблицы посещений нет.
    final old = AppDatabase.forTesting(NativeDatabase(file));
    final entries = EntryRepository(old);
    final me = await ProfileRepository(old).createOwnProfile(firstName: 'Я');
    final typeId = (await entries.createObjectType(me.id, 'Места')).id;
    final object = await entries.createObject(typeId: typeId, title: 'Кафе');
    final entry = await entries.createEntry(
      profileId: me.id,
      objectId: object.id,
      rating: 8,
      impressionDate: DateTime(2026, 5, 4),
    );
    await old.customStatement('DROP TABLE entry_visits');
    await pretendSchemaVersion(old, 7);
    await old.close();

    // Обновление приложения: та же база открывается новой версией.
    final fresh = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(fresh.close);

    final visits = await EntryRepository(fresh).visitsOf(entry.id);
    expect(visits, hasLength(1), reason: 'первый раз должен попасть в историю');
    expect(visits.single.rating, 8);
    expect(visits.single.occurredAt, DateTime(2026, 5, 4));
  });
}
