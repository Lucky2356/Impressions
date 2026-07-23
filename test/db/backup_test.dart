import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/core/config/app_config.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/services/backup_service.dart';
import 'package:path/path.dart' as p;

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

  group('Восстановление (§28)', () {
    /// Копия и восстановление работают с файлом базы, поэтому здесь база не
    /// in-memory, а настоящая — и лежит там же, куда смотрит служба.
    AppDatabase openFileDb() {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      return AppDatabase.forTesting(
        NativeDatabase(File(p.join(root.path, 'impressions.sqlite'))),
      );
    }

    test('возвращает состояние на момент копии', () async {
      var db = openFileDb();
      await ProfileRepository(db).createOwnProfile(firstName: 'Первый');

      final service = BackupService(db, rootOverride: root);
      final snapshot = await service.create(reason: 'manual');

      // Изменение, которого в копии нет.
      await ProfileRepository(db).createOwnProfile(firstName: 'Второй');
      expect((await ProfileRepository(db).all()).length, 2);

      final result = await service.restore(
        snapshot.path,
        closeDatabase: db.close,
      );
      expect(result.status, RestoreStatus.ok);

      db = openFileDb();
      addTearDown(db.close);
      final profiles = await ProfileRepository(db).all();
      expect(profiles.map((p) => p.firstName), ['Первый']);
    });

    test('перед заменой сохраняет нынешнее состояние', () async {
      var db = openFileDb();
      await ProfileRepository(db).createOwnProfile(firstName: 'Первый');
      final service = BackupService(db, rootOverride: root);
      final snapshot = await service.create(reason: 'manual');

      final result = await service.restore(
        snapshot.path,
        closeDatabase: db.close,
      );

      // Без этой копии откатить неудачное восстановление было бы нечем.
      expect(result.backupOfPrevious, isNotNull);
      expect(result.backupOfPrevious!.reason, 'beforeRestore');
      expect(File(result.backupOfPrevious!.path).existsSync(), isTrue);

      db = openFileDb();
      addTearDown(db.close);
    });

    test('битую копию не разворачивает и базу не трогает', () async {
      final db = openFileDb();
      addTearDown(db.close);
      await ProfileRepository(db).createOwnProfile(firstName: 'Первый');

      final service = BackupService(db, rootOverride: root);
      final snapshot = await service.create(reason: 'manual');
      await File(snapshot.path).writeAsBytes([1, 2, 3, 4, 5]);

      var closed = false;
      final result = await service.restore(
        snapshot.path,
        closeDatabase: () async => closed = true,
      );

      expect(result.status, RestoreStatus.corrupted);
      // База не должна закрываться, раз разворачивать нечего.
      expect(closed, isFalse);
      expect((await ProfileRepository(db).all()).length, 1);
    });

    test('копию из будущей версии не разворачивает', () async {
      final db = openFileDb();
      addTearDown(db.close);
      final service = BackupService(db, rootOverride: root);

      // Копия, снятая приложением с более новой схемой: её таблицы текущая
      // версия прочитать не сможет, миграции идут только вперёд.
      final manifest = utf8.encode(
        jsonEncode({
          'createdAt': DateTime.now().toUtc().toIso8601String(),
          'reason': 'manual',
          'schemaVersion': db.schemaVersion + 5,
          'files': <String, String>{},
        }),
      );
      final archive = Archive()
        ..add(ArchiveFile('backup.json', manifest.length, manifest));
      final path = p.join(root.path, 'backup_manual_future.zip');
      await File(path).writeAsBytes(ZipEncoder().encode(archive));

      var closed = false;
      final result = await service.restore(
        path,
        closeDatabase: () async => closed = true,
      );

      expect(result.status, RestoreStatus.tooNew);
      expect(closed, isFalse);
    });

    test('отсутствующий файл сообщает об этом отдельно', () async {
      final db = openFileDb();
      addTearDown(db.close);
      final service = BackupService(db, rootOverride: root);

      final result = await service.restore(
        p.join(root.path, 'нет-такого.zip'),
        closeDatabase: () async {},
      );
      expect(result.status, RestoreStatus.notFound);
    });
  });
}
