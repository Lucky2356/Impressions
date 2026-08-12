import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/repositories/settings_repository.dart';
import 'package:impressions/data/services/backup_service.dart';

import 'test_db.dart';

/// Копия ложится ещё и наружу.
///
/// Копии лежат рядом с базой: потеряли устройство — потеряли и копии. Папка на
/// флешке или в облачном клиенте переживёт само устройство.
void main() {
  late AppDatabase db;
  late Directory root;
  late Directory outside;
  late BackupService backups;
  late SettingsRepository settings;

  setUp(() async {
    db = openTestDb();
    root = await Directory.systemTemp.createTemp('impressions-root');
    outside = await Directory.systemTemp.createTemp('impressions-outside');
    backups = BackupService(db, rootOverride: root);
    settings = SettingsRepository(db);
  });

  tearDown(() async {
    await db.close();
    for (final dir in [root, outside]) {
      if (dir.existsSync()) await dir.delete(recursive: true);
    }
  });

  List<File> outsideFiles() => outside.listSync().whereType<File>().toList();

  test('без выбранной папки наружу ничего не кладётся', () async {
    await backups.create(reason: 'manual');

    expect(outsideFiles(), isEmpty);
  });

  test('копия появляется и в выбранной папке', () async {
    await settings.set(SettingKeys.backupMirrorDir, outside.path);

    final info = await backups.create(reason: 'manual');

    final mirrored = outsideFiles();
    expect(mirrored, hasLength(1));
    expect(
      mirrored.single.path.split(Platform.pathSeparator).last,
      info.path.split(Platform.pathSeparator).last,
    );
    // Рядом с базой копия тоже остаётся: папка наружу — дополнение, а не
    // замена.
    expect(File(info.path).existsSync(), isTrue);
  });

  test('исчезнувшая папка не роняет создание копии', () async {
    await settings.set(SettingKeys.backupMirrorDir, outside.path);
    await outside.delete(recursive: true);

    final info = await backups.create(reason: 'auto');

    expect(File(info.path).existsSync(), isTrue);
  });
}
