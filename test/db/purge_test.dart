import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:impressions/data/repositories/category_repository.dart';
import 'package:impressions/data/repositories/collection_repository.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/services/image_service.dart';
import 'package:impressions/data/services/purge_service.dart';

import 'test_db.dart';

Uint8List _jpeg(int shade) {
  final image = img.Image(width: 32, height: 32);
  img.fill(image, color: img.ColorRgb8(shade, 90, 90));
  return Uint8List.fromList(img.encodeJpg(image));
}

void main() {
  late Directory media;

  setUp(() {
    media = Directory.systemTemp.createTempSync('impressions_purge_test');
  });

  tearDown(() {
    if (media.existsSync()) media.deleteSync(recursive: true);
  });

  group('Удаление навсегда (§24)', () {
    test('запись исчезает вместе с версиями, связями и фотографией', () async {
      final db = openTestDb();
      addTearDown(db.close);
      final entries = EntryRepository(db, mediaDirectory: media);
      final images = ImageService(db, mediaDirectory: media);
      final collections = CollectionRepository(db);
      final cats = CategoryRepository(db);

      final me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
      final type = await entries.createObjectType(me.id, 'Продукты');
      final category = await cats.createRoot(me.id, 'Продукты');
      final object = await entries.createObject(
        typeId: type.id,
        title: 'Ошибочная',
      );
      final entry = await entries.createEntry(
        profileId: me.id,
        objectId: object.id,
        primaryCategoryId: category.id,
      );
      await entries.addTag(me.id, entry.id, 'Ошибка');
      final collection = await collections.create(me.id, 'Список');
      await collections.addEntry(collection.id, entry.id);

      final photo = await images.addFromBytes(_jpeg(120)) as ImageAdded;
      await images.attachToEntry(
        entryId: entry.id,
        attachmentId: photo.attachment.id,
        revisionId: entry.currentRevisionId!,
      );
      final file = File(
        await images.absolutePath(photo.attachment.storagePath),
      );
      expect(file.existsSync(), isTrue);

      await PurgeService(db, mediaDirectory: media).purgeEntry(entry.id);

      expect(await entries.entryViews(me.id), isEmpty);
      expect(await entries.tagsOfEntry(entry.id), isEmpty);
      expect(await db.select(db.profileEntryRevisions).get(), isEmpty);
      expect(await db.select(db.revisionAttachments).get(), isEmpty);
      expect(await db.select(db.attachments).get(), isEmpty);
      expect(await db.select(db.collectionEntries).get(), isEmpty);
      expect(await db.select(db.entryCategories).get(), isEmpty);

      // Файлы тоже уходят: иначе «удалить навсегда» оставляло бы фотографии
      // на диске.
      expect(file.existsSync(), isFalse);

      // Категория и подборка сами по себе остаются — удаляли не их.
      expect(await db.select(db.categories).get(), hasLength(1));
      expect(await db.select(db.collections).get(), hasLength(1));
    });

    test('фотография, нужная другой записи, остаётся на месте', () async {
      final db = openTestDb();
      addTearDown(db.close);
      final entries = EntryRepository(db, mediaDirectory: media);
      final images = ImageService(db, mediaDirectory: media);

      final me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
      final type = await entries.createObjectType(me.id, 'Продукты');

      Future<String> makeEntry(String title) async {
        final object = await entries.createObject(
          typeId: type.id,
          title: title,
        );
        final entry = await entries.createEntry(
          profileId: me.id,
          objectId: object.id,
        );
        return entry.id;
      }

      final first = await makeEntry('Первая');
      final second = await makeEntry('Вторая');

      // Одно и то же изображение: дедупликация по SHA-256 даёт одно вложение
      // на две записи.
      final photo = await images.addFromBytes(_jpeg(77)) as ImageAdded;
      for (final id in [first, second]) {
        final row = await (db.select(
          db.profileEntries,
        )..where((e) => e.id.equals(id))).getSingle();
        await images.attachToEntry(
          entryId: id,
          attachmentId: photo.attachment.id,
          revisionId: row.currentRevisionId!,
        );
      }

      final file = File(
        await images.absolutePath(photo.attachment.storagePath),
      );
      await PurgeService(db, mediaDirectory: media).purgeEntry(first);

      expect(await db.select(db.attachments).get(), hasLength(1));
      expect(file.existsSync(), isTrue);
      final left = await entries.entryViews(me.id);
      expect(left.single.title, 'Вторая');
      expect(left.single.coverPath, isNotNull);
    });

    test('категория удаляется, а её записи остаются', () async {
      final db = openTestDb();
      addTearDown(db.close);
      final entries = EntryRepository(db, mediaDirectory: media);
      final cats = CategoryRepository(db);

      final me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
      final type = await entries.createObjectType(me.id, 'Продукты');
      final category = await cats.createRoot(me.id, 'Ненужная');
      final object = await entries.createObject(typeId: type.id, title: 'Сыр');
      await entries.createEntry(
        profileId: me.id,
        objectId: object.id,
        primaryCategoryId: category.id,
      );

      await PurgeService(db, mediaDirectory: media).purgeCategory(category.id);

      expect(await db.select(db.categories).get(), isEmpty);
      final left = await entries.entryViews(me.id);
      expect(left.single.title, 'Сыр');
      expect(left.single.categoryPath, isEmpty);
    });

    test('ветку с подкатегориями удалить нельзя', () async {
      final db = openTestDb();
      addTearDown(db.close);
      final cats = CategoryRepository(db);
      final me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
      final root = await cats.createRoot(me.id, 'Продукты');
      await cats.createChild(root.id, 'Колбасы');

      expect(
        () => PurgeService(db, mediaDirectory: media).purgeCategory(root.id),
        throwsA(
          isA<PurgeException>().having(
            (e) => e.reason,
            'reason',
            PurgeRefusal.categoryHasChildren,
          ),
        ),
      );
    });

    test('подборка удаляется, а её записи остаются', () async {
      final db = openTestDb();
      addTearDown(db.close);
      final entries = EntryRepository(db, mediaDirectory: media);
      final collections = CollectionRepository(db);

      final me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
      final type = await entries.createObjectType(me.id, 'Продукты');
      final object = await entries.createObject(typeId: type.id, title: 'Чай');
      final entry = await entries.createEntry(
        profileId: me.id,
        objectId: object.id,
      );
      final collection = await collections.create(me.id, 'Список');
      await collections.addEntry(collection.id, entry.id);

      await PurgeService(
        db,
        mediaDirectory: media,
      ).purgeCollection(collection.id);

      expect(await db.select(db.collections).get(), isEmpty);
      expect(await db.select(db.collectionEntries).get(), isEmpty);
      expect((await entries.entryViews(me.id)).single.title, 'Чай');
    });
  });
}
