import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/repositories/collection_repository.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/services/image_service.dart';

import 'test_db.dart';

/// Разные картинки — иначе дедупликация по SHA-256 сведёт их к одному вложению.
Uint8List _jpeg(int shade) {
  final image = img.Image(width: 40, height: 40);
  img.fill(image, color: img.ColorRgb8(shade, 100, 100));
  return Uint8List.fromList(img.encodeJpg(image));
}

/// Удалённое возвращается на прежнее место.
///
/// До 1.21.0 удаление фотографии, повторного впечатления и записи из подборки
/// проходило без возврата: то, что удалили по ошибке, приходилось заводить
/// заново — вместе с порядком, подписью и оценкой.
void main() {
  late Directory media;
  late AppDatabase db;
  late ImageService images;
  late EntryRepository entries;
  late CollectionRepository collections;
  late ProfileRow me;
  late String entryId;
  late String revisionId;

  setUp(() async {
    media = Directory.systemTemp.createTempSync('impressions_undo');
    db = openTestDb();
    images = ImageService(db, mediaDirectory: media);
    entries = EntryRepository(db, mediaDirectory: media);
    collections = CollectionRepository(db);

    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    final type = await entries.createObjectType(me.id, 'Фильмы');
    final object = await entries.createObject(typeId: type.id, title: 'Дюна');
    // Дата у первого впечатления задана явно: из неё разовый проход схемы 8
    // заводит первое посещение, и без даты оно встало бы «сегодня» — позже
    // всех добавленных ниже.
    final entry = await entries.createEntry(
      profileId: me.id,
      objectId: object.id,
      rating: 8,
      impressionDate: DateTime(2026, 1, 1),
    );
    entryId = entry.id;
    revisionId = entry.currentRevisionId!;
  });

  Future<ProfileEntryRow> entryRow() => (db.select(
    db.profileEntries,
  )..where((e) => e.id.equals(entryId))).getSingle();

  tearDown(() async {
    await db.close();
    if (media.existsSync()) media.deleteSync(recursive: true);
  });

  test('вернувшаяся фотография снова обложка и снова с подписью', () async {
    final a = await images.addFromBytes(_jpeg(30)) as ImageAdded;
    final b = await images.addFromBytes(_jpeg(200)) as ImageAdded;
    for (final att in [a.attachment, b.attachment]) {
      await images.attachToEntry(
        entryId: entryId,
        attachmentId: att.id,
        revisionId: revisionId,
      );
    }
    await images.setPrimaryAttachment(
      revisionId: revisionId,
      attachmentId: b.attachment.id,
    );
    await images.setCaption(b.attachment.id, 'Второй кадр');

    final link = await images.detach(revisionId, b.attachment.id);
    expect(link, isNotNull);
    expect((await images.attachmentsOfRevision(revisionId)).length, 1);

    await images.restoreLink(link!);

    final back = await images.attachmentsOfRevision(revisionId);
    expect(back.length, 2);
    expect(
      await images.primaryAttachmentId(revisionId),
      b.attachment.id,
      reason: 'признак обложки лежит в самой связи и возвращается вместе с ней',
    );
    expect(
      back.firstWhere((row) => row.id == b.attachment.id).caption,
      'Второй кадр',
    );
  });

  test('вернувшееся посещение приносит обратно и оценку записи', () async {
    await entries.addVisit(
      entryId: entryId,
      occurredAt: DateTime(2026, 3, 1),
      rating: 9,
    );
    final second = await entries.addVisit(
      entryId: entryId,
      occurredAt: DateTime(2026, 5, 4),
      rating: 6,
      note: 'Во второй раз хуже',
    );
    // Оценка записи следует за самым свежим посещением.
    expect((await entryRow()).rating, 6);

    final removed = await entries.removeVisit(second.id);
    expect(removed, isNotNull);
    expect((await entryRow()).rating, 9);

    await entries.restoreVisit(removed!);

    final restored = (await entries.visitsOf(
      entryId,
    )).firstWhere((v) => v.id == second.id);
    expect(restored.occurredAt, DateTime(2026, 5, 4));
    expect(restored.rating, 6);
    expect(restored.note, 'Во второй раз хуже');
    expect(
      (await entryRow()).rating,
      6,
      reason: 'вернули посещение — вернулась и оценка записи',
    );
  });

  test('запись возвращается в подборку на прежнее место', () async {
    final collection = await collections.create(me.id, 'Пересмотреть');

    final ids = <String>[entryId];
    final type = (await entries.objectTypes(me.id)).first;
    for (var i = 0; i < 2; i++) {
      final object = await entries.createObject(
        typeId: type.id,
        title: 'Ещё $i',
      );
      final entry = await entries.createEntry(
        profileId: me.id,
        objectId: object.id,
      );
      ids.add(entry.id);
    }
    for (final id in ids) {
      await collections.addEntry(collection.id, id);
    }

    Future<List<String>> order() async {
      final rows =
          await (db.select(db.collectionEntries)
                ..where((ce) => ce.collectionId.equals(collection.id))
                ..orderBy([(ce) => OrderingTerm(expression: ce.sortOrder)]))
              .get();
      return [for (final row in rows) row.entryId];
    }

    final link = await collections.removeEntry(collection.id, ids[1]);
    expect(link, isNotNull);
    expect(await order(), [ids[0], ids[2]]);

    await collections.restoreEntry(link!);
    expect(
      await order(),
      ids,
      reason: 'вернулась не в конец, а туда, откуда её убрали',
    );
  });
}
