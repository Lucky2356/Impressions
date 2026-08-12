import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/repositories/category_repository.dart';
import 'package:impressions/data/repositories/collection_repository.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/services/integrity_service.dart';

import 'test_db.dart';

/// Проверка целостности данных.
///
/// Расхождения случаются и там, где приложение всё делает правильно: прерванный
/// импорт, файл, удалённый мимо приложения, упавшая обработка фотографии.
/// Заметить такое можно было только по симптому — пустая обложка или запись,
/// которая не находится поиском.
void main() {
  late AppDatabase db;
  late EntryRepository entries;
  late ProfileRow me;
  late ObjectTypeRow type;
  late Directory media;
  late IntegrityService integrity;

  setUp(() async {
    db = openTestDb();
    media = await Directory.systemTemp.createTemp('impressions-media');
    entries = EntryRepository(db, mediaDirectory: media);
    integrity = IntegrityService(db, mediaDirectory: media);
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    type = await entries.createObjectType(me.id, 'Продукты');
  });

  tearDown(() async {
    await db.close();
    if (media.existsSync()) await media.delete(recursive: true);
  });

  Future<ProfileEntryRow> add(String title, {String? categoryId}) async {
    final object = await entries.createObject(typeId: type.id, title: title);
    return entries.createEntry(
      profileId: me.id,
      objectId: object.id,
      primaryCategoryId: categoryId,
    );
  }

  test('чистая база проверку проходит', () async {
    await add('Папа может');

    expect((await integrity.check()).isClean, isTrue);
  });

  test('файл, на который никто не ссылается, находится и убирается', () async {
    await add('Папа может');
    final orphan = File('${media.path}/ничей.jpg')..writeAsStringSync('x');

    final report = await integrity.check();
    expect(report.countOf(IntegrityIssue.orphanFiles), 1);

    final after = await integrity.repair();
    expect(orphan.existsSync(), isFalse);
    expect(after.isClean, isTrue);
  });

  test('запись о пропавшем файле снимается', () async {
    final entry = await add('Папа может');
    await db
        .into(db.attachments)
        .insert(
          AttachmentsCompanion.insert(
            id: 'a1',
            sha256: 'hash',
            storagePath: 'нет-такого.jpg',
            mimeType: 'image/jpeg',
            byteSize: 1,
            createdAt: DateTime.now(),
          ),
        );
    await db
        .into(db.revisionAttachments)
        .insert(
          RevisionAttachmentsCompanion.insert(
            id: 'ra1',
            revisionId: entry.currentRevisionId!,
            attachmentId: 'a1',
            entityKind: 'entry',
          ),
        );

    expect((await integrity.check()).countOf(IntegrityIssue.missingFiles), 1);

    await integrity.repair();
    expect(await db.select(db.attachments).get(), isEmpty);
    expect(await db.select(db.revisionAttachments).get(), isEmpty);
  });

  test('запись без текущей версии получает её обратно', () async {
    final entry = await add('Папа может');
    await (db.update(db.profileEntries)..where((e) => e.id.equals(entry.id)))
        .write(const ProfileEntriesCompanion(currentRevisionId: Value(null)));

    expect(
      (await integrity.check()).countOf(IntegrityIssue.entriesWithoutRevision),
      1,
    );

    final after = await integrity.repair();
    expect(after.isClean, isTrue);
    final fixed = await (db.select(
      db.profileEntries,
    )..where((e) => e.id.equals(entry.id))).getSingle();
    expect(fixed.currentRevisionId, isNotNull);
  });

  test('связь с исчезнувшей категорией снимается', () async {
    final categories = CategoryRepository(db);
    final food = await categories.createRoot(me.id, 'Еда');
    final entry = await add('Папа может', categoryId: food.id);
    // Категорию убираем мимо приложения: так это и выглядит после сбоя.
    await db.customStatement('PRAGMA foreign_keys = OFF');
    await (db.delete(db.categories)..where((c) => c.id.equals(food.id))).go();
    await db.customStatement('PRAGMA foreign_keys = ON');

    expect(
      (await integrity.check()).countOf(IntegrityIssue.danglingCategories),
      1,
    );

    await integrity.repair();
    final links = await (db.select(
      db.entryCategories,
    )..where((ec) => ec.entryId.equals(entry.id))).get();
    expect(links, isEmpty);
  });

  test('состав подборки без записи снимается', () async {
    final collections = CollectionRepository(db);
    final collection = await collections.create(me.id, 'На выходные');
    // Внешние ключи такую строку не пропускают — и правильно делают. Здесь она
    // заводится мимо них: так выглядит база после сбоя или чужой правки.
    await db.customStatement('PRAGMA foreign_keys = OFF');
    await db
        .into(db.collectionEntries)
        .insert(
          CollectionEntriesCompanion.insert(
            collectionId: collection.id,
            entryId: 'нет-такой-записи',
            addedAt: DateTime.now(),
          ),
        );
    await db.customStatement('PRAGMA foreign_keys = ON');

    expect(
      (await integrity.check()).countOf(
        IntegrityIssue.danglingCollectionEntries,
      ),
      1,
    );

    await integrity.repair();
    expect(await db.select(db.collectionEntries).get(), isEmpty);
  });

  test('отставший поисковый индекс набирается заново', () async {
    await add('Папа может');
    // Так выглядит индекс, отставший от таблиц: запись есть, найти её нечем.
    await db.customStatement(
      "INSERT INTO object_search(object_search) VALUES('delete-all')",
    );

    expect(
      (await integrity.check()).countOf(IntegrityIssue.searchOutOfSync),
      1,
    );

    final after = await integrity.repair();
    expect(after.isClean, isTrue);
    expect(await db.searchObjectIds('Папа'), isNotEmpty);
  });
}
