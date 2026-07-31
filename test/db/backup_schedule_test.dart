import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/core/config/app_config.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/repositories/settings_repository.dart';
import 'package:impressions/data/services/backup_service.dart';

import 'test_db.dart';

/// Копия по расписанию (§28).
///
/// Раньше копия появлялась только перед импортом, перед восстановлением или по
/// кнопке. У человека, который ничего из этого не делает, копий не было вовсе.
void main() {
  late Directory root;

  setUp(() {
    root = Directory.systemTemp.createTempSync('impressions_schedule_test');
  });

  tearDown(() {
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  test('первый запуск делает копию, второй в тот же день — нет', () async {
    final db = openTestDb();
    addTearDown(db.close);
    await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    final service = BackupService(db, rootOverride: root);

    final first = await service.createScheduled();
    expect(first, isNotNull);
    expect(first!.reason, 'auto');
    expect(File(first.path).existsSync(), isTrue);

    expect(await service.createScheduled(), isNull);
    expect((await service.list()).length, 1);
  });

  test('через неделю копия делается снова', () async {
    final db = openTestDb();
    addTearDown(db.close);
    await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    final service = BackupService(db, rootOverride: root);

    final start = DateTime(2026, 7, 1);
    expect(await service.createScheduled(now: start), isNotNull);

    // За день до срока — рано.
    final almost = start.add(
      const Duration(days: AppConfig.autoBackupIntervalDays - 1),
    );
    expect(await service.createScheduled(now: almost), isNull);

    final due = start.add(
      const Duration(days: AppConfig.autoBackupIntervalDays),
    );
    expect(await service.createScheduled(now: due), isNotNull);
    expect((await service.list()).length, 2);
  });

  test('выключенное расписание не делает ничего', () async {
    final db = openTestDb();
    addTearDown(db.close);
    await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    await SettingsRepository(db).setBool(SettingKeys.autoBackupEnabled, false);

    final service = BackupService(db, rootOverride: root);
    expect(await service.createScheduled(), isNull);
    expect(await service.list(), isEmpty);
  });

  test('копия по расписанию проходит проверку целостности', () async {
    final db = openTestDb();
    addTearDown(db.close);
    await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    final service = BackupService(db, rootOverride: root);

    final info = await service.createScheduled();
    expect(await service.verify(info!.path), BackupCheck.ok);
  });
}
