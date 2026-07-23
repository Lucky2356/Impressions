import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/core/config/app_config.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/services/backup_service.dart';

import 'test_db.dart';

void main() {
  late Directory root;

  setUp(() {
    root = Directory.systemTemp.createTempSync('impressions_backup_test');
  });

  tearDown(() {
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  test('копия создаётся и проходит проверку целостности (§28)', () async {
    final db = openTestDb();
    addTearDown(db.close);
    await ProfileRepository(db).createOwnProfile(firstName: 'Я');

    final service = BackupService(db, rootOverride: root);
    final info = await service.create(reason: 'manual');

    expect(File(info.path).existsSync(), isTrue);
    expect(info.byteSize, greaterThan(0));
    expect(await service.verify(info.path), isTrue);
  });

  test('повреждённая копия не проходит проверку', () async {
    final db = openTestDb();
    addTearDown(db.close);
    final service = BackupService(db, rootOverride: root);
    final info = await service.create(reason: 'manual');

    // Портим файл.
    await File(info.path).writeAsBytes([1, 2, 3, 4, 5]);
    expect(await service.verify(info.path), isFalse);
  });

  test('хранятся только последние N автоматических копий (§28)', () async {
    final db = openTestDb();
    addTearDown(db.close);
    final service = BackupService(db, rootOverride: root);

    for (var i = 0; i < AppConfig.autoBackupRetention + 3; i++) {
      await service.create(reason: 'beforeImport');
      // Разные метки времени в именах файлов.
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }

    final all = await service.list();
    final auto = all.where((b) => b.reason == 'beforeImport').toList();
    expect(auto.length, AppConfig.autoBackupRetention);
  });

  test('ручные копии не удаляются автоочисткой', () async {
    final db = openTestDb();
    addTearDown(db.close);
    final service = BackupService(db, rootOverride: root);

    final manual = await service.create(reason: 'manual');
    for (var i = 0; i < AppConfig.autoBackupRetention + 2; i++) {
      await service.create(reason: 'beforeImport');
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }

    expect(File(manual.path).existsSync(), isTrue);
  });

  test('несуществующий файл не проходит проверку', () async {
    final db = openTestDb();
    addTearDown(db.close);
    final service = BackupService(db, rootOverride: root);
    expect(await service.verify('${root.path}/нет-такого.zip'), isFalse);
  });
}
