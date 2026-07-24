import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/services/backup_cipher.dart';
import 'package:impressions/data/services/backup_service.dart';
import 'package:impressions/data/services/secret_storage.dart';
import 'package:path/path.dart' as p;

/// Защита резервных копий паролем (§28).
///
/// Разбирается главное свойство схемы: копия шифруется без вопросов, потому
/// что ключ лежит в хранилище ОС, но остаётся читаемой на чужом устройстве —
/// по паролю из заголовка самой копии.
void main() {
  late Directory root;
  late SecretStorage secrets;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('impressions_backup_enc');
    secrets = SecretStorage(directoryOverride: root.path);
  });

  tearDown(() {
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  AppDatabase openFileDb() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    return AppDatabase.forTesting(
      NativeDatabase(File(p.join(root.path, 'impressions.sqlite'))),
    );
  }

  BackupService serviceFor(AppDatabase db) =>
      BackupService(db, rootOverride: root, secrets: secrets);

  /// Стирает ключ копий — то же самое, что открыть копию на другом устройстве
  /// или после переустановки.
  Future<void> forgetDeviceKey() => secrets.delete('backup_key');

  test('включённая защита даёт зашифрованный файл', () async {
    final db = openFileDb();
    addTearDown(db.close);
    final service = serviceFor(db);

    expect(await service.enableEncryption('пароль-подлиннее'), isTrue);
    final info = await service.create(reason: 'manual');

    expect(info.encrypted, isTrue);
    expect(info.path.endsWith('.zip.enc'), isTrue);
    expect(await BackupCipher.isEncrypted(File(info.path)), isTrue);

    // Список копий узнаёт защищённые, не заглядывая внутрь.
    final listed = await service.list();
    expect(listed.single.encrypted, isTrue);
  });

  test('своя копия проверяется и разворачивается без пароля', () async {
    var db = openFileDb();
    await ProfileRepository(db).createOwnProfile(firstName: 'Первый');

    final service = serviceFor(db);
    await service.enableEncryption('пароль-подлиннее');
    final snapshot = await service.create(reason: 'manual');

    expect(await service.verify(snapshot.path), BackupCheck.ok);

    await ProfileRepository(db).createOwnProfile(firstName: 'Второй');
    final result = await service.restore(
      snapshot.path,
      closeDatabase: db.close,
    );
    expect(result.status, RestoreStatus.ok);

    db = openFileDb();
    addTearDown(db.close);
    expect((await ProfileRepository(db).all()).map((p) => p.firstName), [
      'Первый',
    ]);
  });

  test('копия с другого устройства просит пароль', () async {
    final db = openFileDb();
    addTearDown(db.close);
    final service = serviceFor(db);

    await service.enableEncryption('пароль-подлиннее');
    final info = await service.create(reason: 'manual');

    await forgetDeviceKey();

    expect(await service.verify(info.path), BackupCheck.passwordRequired);
    expect(
      await service.verify(info.path, password: 'не-тот-пароль'),
      BackupCheck.wrongPassword,
    );
    expect(
      await service.verify(info.path, password: 'пароль-подлиннее'),
      BackupCheck.ok,
    );
  });

  test('чужая копия разворачивается по паролю', () async {
    var db = openFileDb();
    await ProfileRepository(db).createOwnProfile(firstName: 'Первый');

    final service = serviceFor(db);
    await service.enableEncryption('пароль-подлиннее');
    final snapshot = await service.create(reason: 'manual');

    await ProfileRepository(db).createOwnProfile(firstName: 'Второй');
    await forgetDeviceKey();

    // Без пароля восстановление не начинается и базу не трогает.
    expect(
      (await service.restore(snapshot.path, closeDatabase: db.close)).status,
      RestoreStatus.passwordRequired,
    );
    expect((await ProfileRepository(db).all()).length, 2);

    expect(
      (await service.restore(
        snapshot.path,
        closeDatabase: db.close,
        password: 'не-тот',
      )).status,
      RestoreStatus.wrongPassword,
    );

    final result = await service.restore(
      snapshot.path,
      closeDatabase: db.close,
      password: 'пароль-подлиннее',
    );
    expect(result.status, RestoreStatus.ok);

    db = openFileDb();
    addTearDown(db.close);
    expect((await ProfileRepository(db).all()).map((p) => p.firstName), [
      'Первый',
    ]);
  });

  test('смена пароля не портит уже сделанные копии', () async {
    final db = openFileDb();
    addTearDown(db.close);
    final service = serviceFor(db);

    await service.enableEncryption('первый-пароль');
    final old = await service.create(reason: 'manual');

    await service.enableEncryption('второй-пароль');
    final fresh = await service.create(reason: 'manual');

    await forgetDeviceKey();

    // Обёртка ключа лежит в каждом файле и задним числом не меняется.
    expect(
      await service.verify(old.path, password: 'первый-пароль'),
      BackupCheck.ok,
    );
    expect(
      await service.verify(old.path, password: 'второй-пароль'),
      BackupCheck.wrongPassword,
    );
    expect(
      await service.verify(fresh.path, password: 'второй-пароль'),
      BackupCheck.ok,
    );
  });

  test('без ключа копия всё равно делается, а защита выключается', () async {
    final db = openFileDb();
    addTearDown(db.close);
    final service = serviceFor(db);

    await service.enableEncryption('пароль-подлиннее');
    // Настройки говорят «шифровать», ключа нет: так выглядит устройство после
    // восстановления копии с чужими настройками.
    await forgetDeviceKey();

    final info = await service.create(reason: 'beforeImport');

    // Копия сделана — несделанная была бы хуже незашифрованной.
    expect(File(info.path).existsSync(), isTrue);
    expect(info.encrypted, isFalse);
    // И об этом сказано вслух: переключатель в настройках больше не горит.
    expect(await service.encryptionEnabled(), isFalse);
  });

  test('копии, сделанные до включения защиты, читаются как раньше', () async {
    final db = openFileDb();
    addTearDown(db.close);
    final service = serviceFor(db);

    final plain = await service.create(reason: 'manual');
    expect(plain.encrypted, isFalse);

    await service.enableEncryption('пароль-подлиннее');
    expect(await service.verify(plain.path), BackupCheck.ok);
  });

  test('выключение защиты возвращает обычные копии, старые остаются', () async {
    final db = openFileDb();
    addTearDown(db.close);
    final service = serviceFor(db);

    await service.enableEncryption('пароль-подлиннее');
    final sealed = await service.create(reason: 'manual');

    await service.disableEncryption();
    final open = await service.create(reason: 'manual');

    expect(open.encrypted, isFalse);
    expect(await service.verify(sealed.path), BackupCheck.ok);
  });
}
