import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/db/database_cipher.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/services/backup_service.dart';
import 'package:path/path.dart' as p;

import 'test_db.dart';

/// Резервные копии и шифрование базы.
///
/// Копия зашифрованной базы без файла состояния бесполезна: в нём лежит соль,
/// без которой из пароля не вывести ключ. А копия обычной базы, развёрнутая
/// поверх зашифрованной, наоборот, должна убрать оставшееся состояние — иначе
/// приложение запрётся на правильных данных, спрашивая пароль, которого у этих
/// данных нет.
void main() {
  late Directory root;

  /// Имена файлов внутри архива копии.
  Set<String> entriesOf(String zipPath) {
    final input = InputFileStream(zipPath);
    try {
      return ZipDecoder()
          .decodeStream(input)
          .files
          .where((f) => f.isFile)
          .map((f) => f.name)
          .toSet();
    } finally {
      input.closeSync();
    }
  }

  File stateFile() => File(p.join(root.path, DatabaseCipher.stateFileName));

  setUp(() {
    root = Directory.systemTemp.createTempSync('impressions_backup_cipher');
  });

  tearDown(() {
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  test('состояние шифрования попадает в копию', () async {
    final db = openTestDb();
    addTearDown(db.close);
    await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    await DatabaseCipher(
      root.path,
    ).writeState(const CipherState(encrypted: true, salt: [1, 2, 3]));

    final info = await BackupService(
      db,
      rootOverride: root,
    ).create(reason: 'manual');

    expect(entriesOf(info.path), contains(DatabaseCipher.stateFileName));
  });

  test('копии обычной базы состояние не нужно', () async {
    final db = openTestDb();
    addTearDown(db.close);
    await ProfileRepository(db).createOwnProfile(firstName: 'Я');

    final info = await BackupService(
      db,
      rootOverride: root,
    ).create(reason: 'manual');

    expect(entriesOf(info.path), isNot(contains(DatabaseCipher.stateFileName)));
  });

  test('копия обычной базы снимает оставшееся состояние', () async {
    final db = openTestDb();
    addTearDown(db.close);
    await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    final service = BackupService(db, rootOverride: root);

    // Копия снята с незашифрованной базы.
    final info = await service.create(reason: 'manual');

    // А потом базу зашифровали — и разворачивают ту, старую копию.
    await DatabaseCipher(
      root.path,
    ).writeState(const CipherState(encrypted: true, salt: [1, 2, 3]));
    expect(stateFile().existsSync(), isTrue);

    final result = await service.restore(info.path, closeDatabase: db.close);

    expect(result.isOk, isTrue);
    expect(
      stateFile().existsSync(),
      isFalse,
      reason: 'состояние от прежней базы осталось и запрёт данные',
    );
  });

  test('копия зашифрованной базы приносит своё состояние', () async {
    final db = openTestDb();
    addTearDown(db.close);
    await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    final service = BackupService(db, rootOverride: root);

    await DatabaseCipher(
      root.path,
    ).writeState(const CipherState(encrypted: true, salt: [7, 7, 7]));
    final info = await service.create(reason: 'manual');

    // Состояние потеряли — например, переустановили приложение.
    await stateFile().delete();

    final result = await service.restore(info.path, closeDatabase: db.close);

    expect(result.isOk, isTrue);
    final restored = await DatabaseCipher(root.path).readState();
    expect(restored.encrypted, isTrue);
    expect(restored.salt, [7, 7, 7]);
  });
}
