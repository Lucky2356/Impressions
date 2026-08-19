import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:impressions/data/db/database.dart';
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

/// Порядок снимков и подписи к ним (§16).
///
/// Оба свойства были в базе с самого начала: `sortOrder` выставлялся при
/// добавлении и учитывался при выборе обложки, `caption` можно было передать
/// один раз при загрузке файла. Изменить потом было нельзя ни то, ни другое.
void main() {
  late Directory media;
  late AppDatabase db;
  late ImageService images;
  late EntryRepository entries;
  late String revisionId;

  setUp(() async {
    media = Directory.systemTemp.createTempSync('impressions_photo_order');
    db = openTestDb();
    images = ImageService(db, mediaDirectory: media);
    entries = EntryRepository(db, mediaDirectory: media);

    final me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    final type = await entries.createObjectType(me.id, 'Места');
    final object = await entries.createObject(typeId: type.id, title: 'Кафе');
    final entry = await entries.createEntry(
      profileId: me.id,
      objectId: object.id,
    );
    revisionId = entry.currentRevisionId!;
  });

  tearDown(() {
    db.close();
    if (media.existsSync()) media.deleteSync(recursive: true);
  });

  /// Три снимка в порядке добавления.
  Future<List<String>> addThree() async {
    final ids = <String>[];
    for (final shade in [40, 120, 220]) {
      final added = await images.addFromBytes(_jpeg(shade)) as ImageAdded;
      await images.attachToEntry(
        entryId: 'ignored',
        attachmentId: added.attachment.id,
        revisionId: revisionId,
      );
      ids.add(added.attachment.id);
    }
    return ids;
  }

  test('порядок задаётся списком целиком', () async {
    final ids = await addThree();
    expect([
      for (final a in await images.attachmentsOfRevision(revisionId)) a.id,
    ], ids);

    await images.reorderAttachments(
      revisionId: revisionId,
      orderedAttachmentIds: [ids[2], ids[0], ids[1]],
    );

    expect(
      [for (final a in await images.attachmentsOfRevision(revisionId)) a.id],
      [ids[2], ids[0], ids[1]],
    );
  });

  test('перестановка не трогает обложку', () async {
    final ids = await addThree();
    // Обложка — второй снимок, а не первый по порядку.
    await images.setPrimaryAttachment(
      revisionId: revisionId,
      attachmentId: ids[1],
    );

    await images.reorderAttachments(
      revisionId: revisionId,
      orderedAttachmentIds: [ids[2], ids[1], ids[0]],
    );

    expect(await images.primaryAttachmentId(revisionId), ids[1]);
  });

  test('подпись сохраняется и стирается пустой строкой', () async {
    final ids = await addThree();

    await images.setCaption(ids[0], '  Терраса вечером  ');
    var rows = await images.attachmentsOfRevision(revisionId);
    // Подпись обрезается по краям: пробелы в конце — не часть подписи.
    expect(rows.first.caption, 'Терраса вечером');

    await images.setCaption(ids[0], '   ');
    rows = await images.attachmentsOfRevision(revisionId);
    expect(
      rows.first.caption,
      isNull,
      reason: 'подпись из одних пробелов — это отсутствие подписи',
    );
  });
}
