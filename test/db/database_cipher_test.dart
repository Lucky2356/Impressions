import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/db/database_cipher.dart';
import 'package:sqlite3/sqlite3.dart';

/// Шифрование файла базы паролем.
///
/// Тесты работают с настоящими файлами и настоящей библиотекой SQLite: здесь
/// проверяется не разметка вызовов, а то, что данные действительно не читаются
/// без пароля и не теряются при переходе туда и обратно.
void main() {
  late Directory dir;
  late DatabaseCipher cipher;

  /// Заводит базу с одной записью — по ней видно, пережили ли данные переход.
  void seed() {
    final db = sqlite3.open(cipher.databasePath);
    db.execute('CREATE TABLE entries(title TEXT)');
    db.execute("INSERT INTO entries VALUES ('Докторская')");
    db.close();
  }

  /// Читает запись ключом (или без него) — null, если прочитать не вышло.
  String? read(List<int>? key) {
    Database? db;
    try {
      db = sqlite3.open(cipher.databasePath);
      if (key != null) db.execute(DatabaseCipher.openStatement(key));
      return db.select('SELECT title FROM entries').single['title'] as String;
    } on Object {
      return null;
    } finally {
      db?.close();
    }
  }

  setUp(() {
    dir = Directory.systemTemp.createTempSync('impressions_cipher');
    cipher = DatabaseCipher(dir.path);
    seed();
  });

  tearDown(() => dir.deleteSync(recursive: true));

  test('до включения база открыта и состояния нет', () async {
    expect((await cipher.readState()).encrypted, isFalse);
    expect(File(cipher.statePath).existsSync(), isFalse);
    expect(read(null), 'Докторская');
  });

  test('после шифрования без пароля не читается, с паролем читается', () async {
    final key = await cipher.encrypt('очень длинный пароль');

    expect(read(null), isNull, reason: 'база открылась без ключа');
    expect(read(key), 'Докторская');
    expect((await cipher.readState()).encrypted, isTrue);
  });

  test('чужой пароль не подходит', () async {
    await cipher.encrypt('очень длинный пароль');

    expect(await cipher.unlocks('другой пароль'), isFalse);
    expect(await cipher.unlocks('очень длинный пароль'), isTrue);
  });

  test('расшифровка возвращает базу в прежний вид', () async {
    await cipher.encrypt('очень длинный пароль');

    expect(await cipher.decrypt('очень длинный пароль'), isTrue);
    expect(read(null), 'Докторская');
    expect(File(cipher.statePath).existsSync(), isFalse);
  });

  test('расшифровка чужим паролем ничего не ломает', () async {
    final key = await cipher.encrypt('очень длинный пароль');

    expect(await cipher.decrypt('другой пароль'), isFalse);
    expect(read(key), 'Докторская', reason: 'база осталась зашифрованной');
    expect((await cipher.readState()).encrypted, isTrue);
  });

  test('смена пароля: старый перестаёт подходить, данные на месте', () async {
    await cipher.encrypt('старый пароль такой');

    final newKey = await cipher.changePassword(
      'старый пароль такой',
      'новый пароль другой',
    );

    expect(newKey, isNotNull);
    expect(read(newKey), 'Докторская');
    expect(await cipher.unlocks('старый пароль такой'), isFalse);
    expect(await cipher.unlocks('новый пароль другой'), isTrue);
  });

  test('смена пароля с неверным старым ничего не меняет', () async {
    final key = await cipher.encrypt('старый пароль такой');

    expect(await cipher.changePassword('не тот', 'новый'), isNull);
    expect(read(key), 'Докторская');
    expect(await cipher.unlocks('старый пароль такой'), isTrue);
  });

  test('проверка после миграции видит рабочую базу', () async {
    final key = await cipher.encrypt('очень длинный пароль');

    expect(await cipher.verify(key), isTrue);
    expect(await cipher.verify(null), isFalse);
  });

  group('быстрая проверка ключа', () {
    // Она выполняется при каждом запуске, до первого кадра, поэтому не должна
    // читать файл целиком — этим занимается verify после перешифровки.
    test('отличает верный ключ от неверного', () async {
      final key = await cipher.encrypt('очень длинный пароль');
      final wrong = await DatabaseCipher.deriveKey(
        'другой пароль',
        DatabaseCipher.newSalt(),
      );

      expect(await cipher.opens(key), isTrue);
      expect(await cipher.opens(wrong), isFalse);
      expect(await cipher.opens(null), isFalse);
    });

    test('на незашифрованной базе открывает без ключа', () async {
      expect(await cipher.opens(null), isTrue);
    });

    test('не читает файл целиком', () async {
      // База, у которой оглавление цело, а страница с данными испорчена.
      // Быстрая проверка такую откроет — она смотрит только оглавление; полная
      // должна её отвергнуть. Так видно, что это два разных действия, а не
      // одно под двумя именами.
      final db = sqlite3.open(cipher.databasePath);
      db.execute('BEGIN');
      for (var i = 0; i < 2000; i++) {
        db.execute("INSERT INTO entries VALUES ('запись номер $i')");
      }
      db.execute('COMMIT');
      db.close();

      final file = File(cipher.databasePath);
      final bytes = await file.readAsBytes();
      // Первая страница — оглавление, её не трогаем; портим четвёртую.
      const pageSize = 4096;
      expect(bytes.length, greaterThan(pageSize * 5));
      bytes.fillRange(pageSize * 3, pageSize * 4, 0x7f);
      await file.writeAsBytes(bytes, flush: true);

      expect(await cipher.opens(null), isTrue);
      expect(await cipher.verify(null), isFalse);
    });
  });

  group('состояние', () {
    test('переживает запись и чтение', () async {
      await cipher.writeState(
        const CipherState(encrypted: true, salt: [1, 2, 3, 4]),
      );

      final restored = await cipher.readState();

      expect(restored.encrypted, isTrue);
      expect(restored.salt, [1, 2, 3, 4]);
    });

    test('испорченный файл читается как открытая база', () {
      // База без шифрования откроется и так, а вот запертая наглухо из-за
      // сломанного json — это потеря данных на ровном месте.
      expect(CipherState.fromJson('не json').encrypted, isFalse);
      expect(CipherState.fromJson('{"encrypted":true}').encrypted, isFalse);
      expect(CipherState.fromJson(null).encrypted, isFalse);
    });
  });

  group('ключ', () {
    test('один пароль и одна соль дают один ключ', () async {
      final salt = DatabaseCipher.newSalt();

      final first = await DatabaseCipher.deriveKey('пароль', salt);
      final second = await DatabaseCipher.deriveKey('пароль', salt);

      expect(first, second);
      expect(first, hasLength(32));
    });

    test('одинаковый пароль на разной соли даёт разные ключи', () async {
      final first = await DatabaseCipher.deriveKey(
        'пароль',
        DatabaseCipher.newSalt(),
      );
      final second = await DatabaseCipher.deriveKey(
        'пароль',
        DatabaseCipher.newSalt(),
      );

      expect(first, isNot(second));
    });

    test('ключ переживает сохранение и чтение', () async {
      final key = await DatabaseCipher.deriveKey('пароль', [1, 2, 3]);

      expect(DatabaseCipher.decodeKey(DatabaseCipher.encodeKey(key)), key);
      expect(DatabaseCipher.decodeKey('мусор'), isNull);
      expect(DatabaseCipher.decodeKey(null), isNull);
    });
  });
}
