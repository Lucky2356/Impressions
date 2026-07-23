import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';

import 'test_db.dart';

void main() {
  test('полнотекстовый поиск объектов (FTS5)', () async {
    final db = openTestDb();
    addTearDown(db.close);
    final profiles = ProfileRepository(db);
    final entries = EntryRepository(db);

    final me = await profiles.createOwnProfile(firstName: 'Поиск');
    final type = await entries.createObjectType(me.id, 'Фильмы');
    await entries.createObject(
      typeId: type.id,
      title: 'Интерстеллар',
      creator: 'Кристофер Нолан',
    );
    await entries.createObject(typeId: type.id, title: 'Начало');

    final byTitle = await db.searchObjectIds('Интер');
    expect(byTitle.length, 1);

    final byCreator = await db.searchObjectIds('Нолан');
    expect(byCreator.length, 1);

    final none = await db.searchObjectIds('Чебурашка');
    expect(none, isEmpty);
  });

  test('уникальность SHA-256 вложений', () async {
    final db = openTestDb();
    addTearDown(db.close);

    Future<void> insertAttachment(String id, String sha) {
      return db
          .into(db.attachments)
          .insert(
            AttachmentsCompanion.insert(
              id: id,
              sha256: sha,
              storagePath: 'a/$id',
              mimeType: 'image/jpeg',
              byteSize: 100,
              createdAt: DateTime.now(),
            ),
          );
    }

    await insertAttachment('a1', 'HASH');
    expect(() => insertAttachment('a2', 'HASH'), throwsA(anything));
  });

  test('транзакция откатывается при ошибке (rollback)', () async {
    final db = openTestDb();
    addTearDown(db.close);
    final profiles = ProfileRepository(db);
    final before = await profiles.all();

    try {
      await db.transaction(() async {
        await profiles.createOwnProfile(firstName: 'Внутри транзакции');
        // Провоцируем ошибку — вставка профиля без обязательных полей.
        await db.customStatement('INSERT INTO profiles (id) VALUES (NULL)');
      });
    } catch (_) {
      // ожидаемо
    }

    final after = await profiles.all();
    expect(
      after.length,
      before.length,
      reason: 'После ошибки транзакция должна откатиться',
    );
  });

  test(
    'внешние ключи RESTRICT запрещают удаление используемого профиля',
    () async {
      final db = openTestDb();
      addTearDown(db.close);
      final profiles = ProfileRepository(db);
      final me = await profiles.createOwnProfile(firstName: 'FK');

      // Локальные настройки ссылаются на профиль → удаление должно быть запрещено.
      expect(
        () => (db.delete(db.profiles)..where((p) => p.id.equals(me.id))).go(),
        throwsA(anything),
      );
    },
  );
}
