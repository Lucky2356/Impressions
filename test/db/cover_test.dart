import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/services/image_service.dart';
import 'package:path/path.dart' as p;

import 'test_db.dart';

/// Разные картинки — иначе дедупликация по SHA-256 сведёт их к одному вложению.
Uint8List _jpeg(int shade) {
  final image = img.Image(width: 40, height: 40);
  img.fill(image, color: img.ColorRgb8(shade, 100, 100));
  return Uint8List.fromList(img.encodeJpg(image));
}

void main() {
  late Directory media;

  setUp(() {
    media = Directory.systemTemp.createTempSync('impressions_cover_test');
  });

  tearDown(() {
    if (media.existsSync()) media.deleteSync(recursive: true);
  });

  group('Обложки записей', () {
    test('без фотографии обложки нет', () async {
      final db = openTestDb();
      addTearDown(db.close);
      final entries = EntryRepository(db, mediaDirectory: media);
      final me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
      final type = await entries.createObjectType(me.id, 'Продукты');
      final object = await entries.createObject(
        typeId: type.id,
        title: 'Без фото',
      );
      await entries.createEntry(profileId: me.id, objectId: object.id);

      final views = await entries.entryViews(me.id);
      expect(views.single.coverPath, isNull);
    });

    test('берётся миниатюра прикреплённой фотографии', () async {
      final db = openTestDb();
      addTearDown(db.close);
      final entries = EntryRepository(db, mediaDirectory: media);
      final images = ImageService(db, mediaDirectory: media);

      final me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
      final type = await entries.createObjectType(me.id, 'Продукты');
      final object = await entries.createObject(
        typeId: type.id,
        title: 'С фото',
      );
      final entry = await entries.createEntry(
        profileId: me.id,
        objectId: object.id,
      );

      final added = await images.addFromBytes(_jpeg(200)) as ImageAdded;
      await images.attachToEntry(
        entryId: entry.id,
        attachmentId: added.attachment.id,
        revisionId: entry.currentRevisionId!,
      );

      final views = await entries.entryViews(me.id);
      final cover = views.single.coverPath;
      expect(cover, isNotNull);
      // Путь абсолютный: карточка отдаёт его прямо в Image.file.
      expect(p.isAbsolute(cover!), isTrue);
      expect(File(cover).existsSync(), isTrue);
      expect(cover, endsWith(added.attachment.thumbPath!));
    });

    test('обложкой становится снимок с пометкой «главный»', () async {
      final db = openTestDb();
      addTearDown(db.close);
      final entries = EntryRepository(db, mediaDirectory: media);
      final images = ImageService(db, mediaDirectory: media);

      final me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
      final type = await entries.createObjectType(me.id, 'Продукты');
      final object = await entries.createObject(
        typeId: type.id,
        title: 'Две фотографии',
      );
      final entry = await entries.createEntry(
        profileId: me.id,
        objectId: object.id,
      );

      final first = await images.addFromBytes(_jpeg(50)) as ImageAdded;
      final second = await images.addFromBytes(_jpeg(220)) as ImageAdded;
      await images.attachToEntry(
        entryId: entry.id,
        attachmentId: first.attachment.id,
        revisionId: entry.currentRevisionId!,
      );
      await images.attachToEntry(
        entryId: entry.id,
        attachmentId: second.attachment.id,
        revisionId: entry.currentRevisionId!,
        isPrimary: true,
      );

      final views = await entries.entryViews(me.id);
      // Вторая фотография помечена главной, хотя добавлена позже.
      expect(views.single.coverPath, endsWith(second.attachment.thumbPath!));
    });

    test('фотография одной записи не попадает в обложку другой', () async {
      final db = openTestDb();
      addTearDown(db.close);
      final entries = EntryRepository(db, mediaDirectory: media);
      final images = ImageService(db, mediaDirectory: media);

      final me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
      final type = await entries.createObjectType(me.id, 'Продукты');

      final withPhoto = await entries.createEntry(
        profileId: me.id,
        objectId: (await entries.createObject(
          typeId: type.id,
          title: 'С фото',
        )).id,
      );
      await entries.createEntry(
        profileId: me.id,
        objectId: (await entries.createObject(
          typeId: type.id,
          title: 'Без фото',
        )).id,
      );

      final added = await images.addFromBytes(_jpeg(180)) as ImageAdded;
      await images.attachToEntry(
        entryId: withPhoto.id,
        attachmentId: added.attachment.id,
        revisionId: withPhoto.currentRevisionId!,
      );

      final views = await entries.entryViews(me.id);
      final byTitle = {for (final v in views) v.title: v.coverPath};
      expect(byTitle['С фото'], isNotNull);
      expect(byTitle['Без фото'], isNull);
    });
  });
}
