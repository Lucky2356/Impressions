import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:impressions/app/app_state.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/services/image_service.dart';
import 'package:impressions/features/entry/entry_photos.dart';

import '../db/test_db.dart';
import 'screens_test.dart' show app;

/// Удаление фотографии предлагает вернуть её.
///
/// Крестик в 14 точек в углу миниатюры удалял снимок молча и насовсем: ни
/// подтверждения, ни сообщения, ни возврата.
void main() {
  late Directory media;
  late AppDatabase db;
  late ImageService images;
  late ProfileRow me;
  late String entryId;
  late String revisionId;

  setUp(() async {
    media = Directory.systemTemp.createTempSync('impressions_undo_ui');
    db = openTestDb();
    images = ImageService(db, mediaDirectory: media);
    final entries = EntryRepository(db, mediaDirectory: media);

    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    final type = await entries.createObjectType(me.id, 'Места');
    final object = await entries.createObject(typeId: type.id, title: 'Кафе');
    final entry = await entries.createEntry(
      profileId: me.id,
      objectId: object.id,
    );
    entryId = entry.id;
    revisionId = entry.currentRevisionId!;

    final added = await images.addFromBytes(_jpeg()) as ImageAdded;
    await images.attachToEntry(
      entryId: entryId,
      attachmentId: added.attachment.id,
      revisionId: revisionId,
    );
  });

  tearDown(() async {
    await db.close();
    if (media.existsSync()) media.deleteSync(recursive: true);
  });

  testWidgets('удалённую фотографию можно вернуть из сообщения', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activeProfileProvider.overrideWithValue(me),
          imageServiceProvider.overrideWithValue(images),
        ],
        child: app(EntryPhotos(entryId: entryId, revisionId: revisionId)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('Фотография удалена'), findsOneWidget);
    expect(await images.attachmentsOfRevision(revisionId), isEmpty);

    await tester.tap(find.text('Вернуть'));
    await tester.pumpAndSettle();

    expect(
      (await images.attachmentsOfRevision(revisionId)).length,
      1,
      reason: 'снимок вернулся к записи',
    );
  });
}

Uint8List _jpeg() {
  final image = img.Image(width: 40, height: 40);
  img.fill(image, color: img.ColorRgb8(120, 100, 100));
  return Uint8List.fromList(img.encodeJpg(image));
}
