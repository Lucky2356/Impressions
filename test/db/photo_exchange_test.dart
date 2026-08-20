import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/services/export_service.dart';
import 'package:impressions/data/services/image_service.dart';
import 'package:impressions/data/services/import_service.dart';

import 'test_db.dart';

Uint8List _jpeg(int shade) {
  final image = img.Image(width: 40, height: 40);
  img.fill(image, color: img.ColorRgb8(shade, 100, 100));
  return Uint8List.fromList(img.encodeJpg(image));
}

/// Фотографии записей в обмене файлами (§16, §19).
///
/// Файлы снимков в пакет клали всегда, а вот связь «этот снимок принадлежит
/// этой записи» — нет: в чужом профиле фотографии оказывались ничьими.
void main() {
  late Directory sourceMedia;
  late Directory targetMedia;

  setUp(() {
    sourceMedia = Directory.systemTemp.createTempSync('impressions_ex_src');
    targetMedia = Directory.systemTemp.createTempSync('impressions_ex_dst');
  });

  tearDown(() {
    for (final dir in [sourceMedia, targetMedia]) {
      if (dir.existsSync()) dir.deleteSync(recursive: true);
    }
  });

  test('фотографии записи доезжают до чужого профиля', () async {
    final db = openTestDb();
    addTearDown(db.close);
    final entries = EntryRepository(db, mediaDirectory: sourceMedia);
    final images = ImageService(db, mediaDirectory: sourceMedia);

    final me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    final type = await entries.createObjectType(me.id, 'Места');
    final object = await entries.createObject(typeId: type.id, title: 'Кафе');
    final entry = await entries.createEntry(
      profileId: me.id,
      objectId: object.id,
    );

    final first = await images.addFromBytes(_jpeg(60)) as ImageAdded;
    final second = await images.addFromBytes(_jpeg(200)) as ImageAdded;
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
    await images.setCaption(second.attachment.id, 'Терраса вечером');

    final exported = await ExportService(
      db,
      mediaDirectory: sourceMedia,
    ).export(me.id, const ExportOptions());

    final target = openTestDb();
    addTearDown(target.close);
    final importer = ImportService(target, mediaDirectory: targetMedia);
    final preview = await importer.inspect(Uint8List.fromList(exported.bytes));
    await importer.apply(preview);

    final theirProfile = (await ProfileRepository(target).all()).single;
    final theirEntries = await EntryRepository(
      target,
      mediaDirectory: targetMedia,
    ).entryViews(theirProfile.id);

    expect(
      theirEntries.single.coverPath,
      isNotNull,
      reason: 'у записи была обложка — она обязана остаться обложкой',
    );

    final theirImages = ImageService(target, mediaDirectory: targetMedia);
    final theirEntryRow =
        (await target.select(target.profileEntries).get()).single;
    final photos = await theirImages.attachmentsOfRevision(
      theirEntryRow.currentRevisionId!,
    );
    expect(photos.length, 2, reason: 'уехали оба снимка, а не только файлы');
    expect(
      photos.map((p) => p.caption),
      contains('Терраса вечером'),
      reason: 'подпись — свойство снимка и едет вместе с ним',
    );
  });

  test('повторные впечатления доезжают вместе с записью', () async {
    final db = openTestDb();
    addTearDown(db.close);
    final entries = EntryRepository(db, mediaDirectory: sourceMedia);

    final me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    final type = await entries.createObjectType(me.id, 'Места');
    final object = await entries.createObject(typeId: type.id, title: 'Кафе');
    final entry = await entries.createEntry(
      profileId: me.id,
      objectId: object.id,
      rating: 6,
      impressionDate: DateTime(2026, 1, 10),
    );
    await entries.addVisit(
      entryId: entry.id,
      occurredAt: DateTime(2026, 6, 1),
      rating: 9,
      note: 'Стало заметно лучше',
    );

    final exported = await ExportService(
      db,
      mediaDirectory: sourceMedia,
    ).export(me.id, const ExportOptions());

    final target = openTestDb();
    addTearDown(target.close);
    final importer = ImportService(target, mediaDirectory: targetMedia);
    await importer.apply(
      await importer.inspect(Uint8List.fromList(exported.bytes)),
    );

    final theirEntries = EntryRepository(target, mediaDirectory: targetMedia);
    final theirRow = (await target.select(target.profileEntries).get()).single;
    final visits = await theirEntries.visitsOf(theirRow.id);

    // Два: сам повтор и исходное впечатление записи, которое завёл первый
    // добавленный повтор.
    expect(visits.length, 2);
    expect(visits.first.rating, 9);
    expect(visits.first.note, 'Стало заметно лучше');
  });
}
