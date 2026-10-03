import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/db/connection.dart';
import 'package:impressions/data/db/database_cipher.dart';
import 'package:impressions/data/services/database_lock_service.dart';
import 'package:impressions/data/services/secret_storage.dart';
import 'package:sqlite3/sqlite3.dart';

/// Хранилище секретов в памяти.
///
/// Настоящее `SecretStorage` на Windows шифрует содержимое DPAPI, а на Linux
/// нет: проверки отпирания зависели бы от платформы прогона, хотя проверяют
/// они не хранилище, а решения самого сервиса. Само хранилище живьём
/// проверяется в `backup_encryption_test.dart`.
class _MemorySecrets extends SecretStorage {
  _MemorySecrets();

  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<bool> write(String key, String value) async {
    values[key] = value;
    return true;
  }

  @override
  Future<void> delete(String key) async => values.remove(key);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late _MemorySecrets secrets;
  late DatabaseLockService lock;
  late DatabaseCipher cipher;

  /// Ключ, который заведомо не от этой базы. Выводить его паролем незачем:
  /// 120 000 итераций ради заранее неподходящего ключа — только время.
  final alienKey = List<int>.filled(32, 7);

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('impressions-lock');
    // path_provider на тестовой платформе не отвечает — подменяем каталог.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => dir.path,
        );

    secrets = _MemorySecrets();
    lock = DatabaseLockService(secrets: secrets);
    cipher = DatabaseCipher(dir.path);

    // Без единой таблицы `opens` считает базу нечитаемой, и проверка
    // упиралась бы в пустой файл вместо ключа.
    final db = sqlite3.open(cipher.databasePath);
    db.execute('CREATE TABLE entries(title TEXT)');
    db.close();

    databaseKey = null;
  });

  tearDown(() async {
    databaseKey = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  group('запуск', () {
    test('без шифрования база открывается сама', () async {
      databaseKey = alienKey; // остался от прошлого сеанса

      expect(await lock.prepare(), LockStatus.open);
      expect(
        databaseKey,
        isNull,
        reason: 'ключ от прошлого сеанса нечего тащить в незашифрованную базу',
      );
    });

    test('без запомненного ключа спрашивается пароль', () async {
      await cipher.encrypt('верный');

      expect(await lock.prepare(), LockStatus.needsPassword);
      expect(databaseKey, isNull);
    });

    test('запомненный ключ открывает базу молча', () async {
      final key = await cipher.encrypt('верный');
      secrets.values[DatabaseLockService.secretName] = DatabaseCipher.encodeKey(
        key,
      );

      expect(await lock.prepare(), LockStatus.unlocked);
      expect(databaseKey, key);
    });

    test(
      'чужой запомненный ключ выбрасывается, а не спрашивается молча',
      () async {
        // Так выглядит восстановление копии, сделанной под другим паролем.
        await cipher.encrypt('верный');
        secrets.values[DatabaseLockService.secretName] =
            DatabaseCipher.encodeKey(alienKey);

        expect(await lock.prepare(), LockStatus.staleKey);
        expect(
          secrets.values,
          isEmpty,
          reason: 'ключ не от этой базы держать незачем',
        );
        expect(
          databaseKey,
          isNull,
          reason: 'база не отперта — подставлять нечего',
        );
      },
    );
  });

  group('пароль', () {
    test('верный пароль отпирает', () async {
      final key = await cipher.encrypt('верный');

      expect(await lock.unlock('верный'), isTrue);
      expect(databaseKey, key);
    });

    test('неверный пароль не отпирает и ничего не портит', () async {
      await cipher.encrypt('верный');

      expect(await lock.unlock('неверный'), isFalse);
      expect(databaseKey, isNull);
      expect(secrets.values, isEmpty);
    });

    test('«помнить» кладёт ключ в хранилище', () async {
      final key = await cipher.encrypt('верный');

      expect(await lock.unlock('верный', remember: true), isTrue);
      expect(
        DatabaseCipher.decodeKey(
          secrets.values[DatabaseLockService.secretName],
        ),
        key,
      );
    });

    test('без «помнить» в хранилище не остаётся ничего', () async {
      await cipher.encrypt('верный');

      expect(await lock.unlock('верный'), isTrue);
      expect(secrets.values, isEmpty);
    });

    test('незашифрованная база отпирается любым паролем', () async {
      expect(await lock.unlock(''), isTrue);
    });
  });

  group('сверка пароля', () {
    test('пароль нынешнего сеанса подходит', () async {
      databaseKey = await cipher.encrypt('верный');

      expect(await lock.matches('верный'), isTrue);
    });

    test('чужой пароль не подходит', () async {
      databaseKey = await cipher.encrypt('верный');

      expect(await lock.matches('неверный'), isFalse);
    });

    test('сверяется с ключом сеанса, а не с файлом базы', () async {
      // База зашифрована «верным», а сеанс идёт с ключом от другой базы: так
      // выглядит подменённый под работающим приложением файл. Пароль к файлу
      // к этому сеансу не подходит.
      await cipher.encrypt('верный');
      databaseKey = alienKey;

      expect(await lock.matches('верный'), isFalse);
    });

    test('без шифрования сверять нечего', () async {
      databaseKey = null;

      expect(await lock.matches('что угодно'), isTrue);
    });
  });

  group('запомнить и забыть', () {
    test('запомненный ключ читается обратно', () async {
      expect(await lock.isRemembered(), isFalse);

      await lock.remember(alienKey);
      expect(await lock.isRemembered(), isTrue);

      await lock.forget();
      expect(await lock.isRemembered(), isFalse);
    });
  });
}
