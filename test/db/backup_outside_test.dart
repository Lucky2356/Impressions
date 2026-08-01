import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/services/backup_service.dart';
import 'package:impressions/data/services/file_delivery_service.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';

/// Диалога сохранения на Android нет — как в жизни.
class _NoSaveDialog extends FileSelectorPlatform {}

class _FakeShare extends SharePlatform {
  ShareParams? params;

  @override
  Future<ShareResult> share(ShareParams params) async {
    this.params = params;
    return const ShareResult('ok', ShareResultStatus.success);
  }
}

/// Копия должна уметь выйти из приложения и вернуться обратно.
///
/// До 1.11.0 копии лежали только в приватном каталоге приложения: снесли
/// приложение или потеряли телефон — копий не стало. Здесь проверяется вся
/// дорога целиком: копия отдаётся наружу тем же способом, что и на телефоне, а
/// потом из полученного файла восстанавливается чистая база.
void main() {
  late Directory root;
  late Directory outside;
  late FileSelectorPlatform savedSelector;

  setUp(() {
    root = Directory.systemTemp.createTempSync('impressions_backup_outside');
    outside = Directory.systemTemp.createTempSync('impressions_outside');
    savedSelector = FileSelectorPlatform.instance;
  });

  tearDown(() {
    FileSelectorPlatform.instance = savedSelector;
    debugDefaultTargetPlatformOverride = null;
    if (root.existsSync()) root.deleteSync(recursive: true);
    if (outside.existsSync()) outside.deleteSync(recursive: true);
  });

  AppDatabase openFileDb() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    return AppDatabase.forTesting(
      NativeDatabase(File(p.join(root.path, 'impressions.sqlite'))),
    );
  }

  test('копия уходит с телефона и восстанавливается из файла', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    FileSelectorPlatform.instance = _NoSaveDialog();

    var db = openFileDb();
    await ProfileRepository(db).createOwnProfile(firstName: 'Первый');

    final service = BackupService(db, rootOverride: root);
    final snapshot = await service.create(reason: 'manual');

    // Ровно то, что делает кнопка «Сохранить к себе».
    final share = _FakeShare();
    final delivery =
        await FileDeliveryService(
          share: SharePlus.custom(share),
          stagingDirectory: outside,
        ).deliver(
          fileName: snapshot.fileName,
          typeLabel: 'Резервные копии',
          extension: 'zip',
          write: (destination) async =>
              File(snapshot.path).copy(destination.path),
        );
    expect(delivery.status, FileDeliveryStatus.shared);

    // Уносим файл подальше и убираем всё, что было внутри приложения, — так
    // выглядит переустановка.
    final carried = File(p.join(outside.path, 'перенесённая.zip'));
    await File(share.params!.files!.single.path).copy(carried.path);
    await (await service.backupsDir()).delete(recursive: true);

    await ProfileRepository(db).createOwnProfile(firstName: 'Второй');
    expect((await ProfileRepository(db).all()).length, 2);

    expect(await service.verify(carried.path), BackupCheck.ok);
    final result = await service.restore(carried.path, closeDatabase: db.close);
    expect(result.status, RestoreStatus.ok);

    db = openFileDb();
    addTearDown(db.close);
    final profiles = await ProfileRepository(db).all();
    expect(profiles.map((p) => p.firstName), ['Первый']);
  });

  test('вынесенная копия — это тот же файл, а не пересказ', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    FileSelectorPlatform.instance = _NoSaveDialog();

    final db = openFileDb();
    addTearDown(db.close);
    await ProfileRepository(db).createOwnProfile(firstName: 'Первый');

    final snapshot = await BackupService(
      db,
      rootOverride: root,
    ).create(reason: 'manual');

    final share = _FakeShare();
    await FileDeliveryService(
      share: SharePlus.custom(share),
      stagingDirectory: outside,
    ).deliver(
      fileName: snapshot.fileName,
      typeLabel: 'Резервные копии',
      extension: 'zip',
      write: (destination) async => File(snapshot.path).copy(destination.path),
    );

    final delivered = File(share.params!.files!.single.path);
    expect(p.basename(delivered.path), snapshot.fileName);
    expect(delivered.lengthSync(), File(snapshot.path).lengthSync());
    expect(delivered.readAsBytesSync(), File(snapshot.path).readAsBytesSync());
  });
}
