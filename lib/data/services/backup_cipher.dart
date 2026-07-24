import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Заголовок зашифрованной копии, прочитанный без расшифровки содержимого.
class BackupHeader {
  const BackupHeader({
    required this.salt,
    required this.iterations,
    required this.nonce,
    required this.wrappedKey,
    required this.byteLength,
  });

  /// Соль вывода ключа из пароля.
  final List<int> salt;

  /// Число итераций PBKDF2, с которым обёрнут ключ этой копии.
  final int iterations;

  /// Одноразовое число шифра содержимого.
  final List<int> nonce;

  /// Ключ копии, зашифрованный паролем: `nonce`, `cipher`, `mac` в base64.
  final Map<String, Object?> wrappedKey;

  /// Длина заголовка вместе с переводом строки — с этого места идёт шифротекст.
  final int byteLength;
}

/// Формат зашифрованной резервной копии `*.zip.enc`.
///
/// Файл устроен так:
///
/// ```
/// <строка JSON-заголовка>\n
/// <шифротекст ChaCha20-Poly1305>
/// <16 байт кода проверки подлинности>
/// ```
///
/// Шифрование и расшифровка идут потоком: копия с фотографиями не поднимается
/// в память ни целиком, ни частями крупнее куска потока. AES-GCM для этого не
/// подошёл — в `cryptography` 2.9 его потоковый вариант на деле копит все куски
/// и шифрует их в конце одним куском, то есть возвращает ровно ту нехватку
/// памяти, ради которой всё и затевалось. У ChaCha20-Poly1305 состояние
/// настоящее потоковое, и в чистом Dart он к тому же быстрее.
///
/// Ключом шифрования служит не пароль, а случайный **ключ копий**: копии
/// создаются в том числе перед импортом и восстановлением, когда спросить
/// пароль негде. Пароль защищает копию ключа, лежащую в заголовке каждого
/// файла, — поэтому копию можно развернуть и на чистой установке, где ключа
/// уже нет.
class BackupCipher {
  const BackupCipher._();

  static final _cipher = Chacha20.poly1305Aead();

  /// Метка формата — по ней зашифрованная копия отличается от чужого файла.
  static const String format = 'impressions.backup.enc';

  /// Число итераций вывода ключа из пароля. Совпадает с защищённым пакетом
  /// обмена, чтобы цена подбора была одинаковой везде.
  static const int iterations = 120000;

  static const int _macLength = 16;
  static const int _saltLength = 16;
  static const int _newline = 0x0a;

  /// Сколько байт от начала файла просматривается в поисках конца заголовка.
  /// Заголовок укладывается в полтысячи байт; запас — на случай новых полей.
  static const int _maxHeaderBytes = 8 * 1024;

  /// Новый случайный ключ копий.
  static Future<SecretKey> newKey() => _cipher.newSecretKey();

  /// Заворачивает ключ копий в пароль. Результат кладётся в заголовок каждой
  /// копии и в настройки.
  static Future<Map<String, Object?>> wrapKey(
    SecretKey key,
    String password,
  ) async {
    final salt = _randomBytes(_saltLength);
    final wrapping = await _keyFromPassword(password, salt, iterations);
    final box = await _cipher.encrypt(
      await key.extractBytes(),
      secretKey: wrapping,
    );
    return {
      'salt': base64Encode(salt),
      'iterations': iterations,
      'nonce': base64Encode(box.nonce),
      'cipher': base64Encode(box.cipherText),
      'mac': base64Encode(box.mac.bytes),
    };
  }

  /// Достаёт ключ копий из заголовка по паролю.
  /// Возвращает null, если пароль неверный.
  static Future<SecretKey?> unwrapKey(
    BackupHeader header,
    String password,
  ) async {
    try {
      final wrapping = await _keyFromPassword(
        password,
        header.salt,
        header.iterations,
      );
      final box = SecretBox(
        base64Decode(header.wrappedKey['cipher']! as String),
        nonce: base64Decode(header.wrappedKey['nonce']! as String),
        mac: Mac(base64Decode(header.wrappedKey['mac']! as String)),
      );
      final bytes = await _cipher.decrypt(box, secretKey: wrapping);
      return SecretKey(bytes);
    } on Object {
      return null;
    }
  }

  /// Читает заголовок. Возвращает null, если это не зашифрованная копия.
  static Future<BackupHeader?> readHeader(File file) async {
    if (!file.existsSync()) return null;
    RandomAccessFile? raf;
    try {
      raf = await file.open();
      final probe = await raf.read(_maxHeaderBytes);
      final end = probe.indexOf(_newline);
      if (end < 0) return null;

      final map =
          jsonDecode(utf8.decode(probe.sublist(0, end)))
              as Map<String, Object?>;
      if (map['format'] != format) return null;

      final wrapped = map['wrappedKey']! as Map<String, Object?>;
      return BackupHeader(
        salt: base64Decode(wrapped['salt']! as String),
        iterations: wrapped['iterations']! as int,
        nonce: base64Decode(map['nonce']! as String),
        wrappedKey: wrapped,
        byteLength: end + 1,
      );
    } on Object {
      return null;
    } finally {
      await raf?.close();
    }
  }

  /// Зашифрован ли файл — по заголовку, а не по имени.
  static Future<bool> isEncrypted(File file) async =>
      await readHeader(file) != null;

  /// Шифрует [source] в [target] потоком.
  static Future<void> encryptFile(
    File source,
    File target, {
    required SecretKey key,
    required Map<String, Object?> wrappedKey,
  }) async {
    final nonce = _cipher.newNonce();
    final header = jsonEncode({
      'format': format,
      'v': 1,
      'cipher': 'chacha20-poly1305',
      'kdf': 'pbkdf2-hmac-sha256',
      'nonce': base64Encode(nonce),
      'wrappedKey': wrappedKey,
    });

    final sink = target.openWrite();
    try {
      sink.add(utf8.encode(header));
      sink.add(const [_newline]);

      // Код проверки подлинности известен только после того, как через шифр
      // прошёл последний байт, поэтому он дописывается в хвост файла.
      Mac? mac;
      await sink.addStream(
        _cipher.encryptStream(
          source.openRead(),
          secretKey: key,
          nonce: nonce,
          onMac: (value) => mac = value,
        ),
      );
      sink.add(mac!.bytes);
    } finally {
      await sink.close();
    }
  }

  /// Расшифровывает [source] в [target] потоком.
  ///
  /// Возвращает false, если файл повреждён или ключ не тот: [target] в этом
  /// случае удаляется — расшифрованное без проверки подлинности содержимое
  /// оставлять на диске нельзя, ему нельзя доверять.
  static Future<bool> decryptFile(
    File source,
    File target, {
    required SecretKey key,
  }) async {
    final header = await readHeader(source);
    if (header == null) return false;

    final total = await source.length();
    final macStart = total - _macLength;
    if (macStart <= header.byteLength) return false;

    final mac = Mac(await _readRange(source, macStart, total));

    final sink = target.openWrite();
    var ok = true;
    try {
      await sink.addStream(
        _cipher.decryptStream(
          source.openRead(header.byteLength, macStart),
          secretKey: key,
          nonce: header.nonce,
          mac: mac,
        ),
      );
      await sink.close();
    } on Object {
      // Ошибка проверки подлинности приходит после последнего куска и сама
      // закрывает приёмник, поэтому второе закрытие тоже бросает исключение.
      ok = false;
      try {
        await sink.close();
      } on Object {
        // Уже закрыт — закрывать нечего.
      }
    }

    if (!ok && target.existsSync()) await target.delete();
    return ok;
  }

  static Future<Uint8List> _readRange(File file, int start, int end) async {
    final raf = await file.open();
    try {
      await raf.setPosition(start);
      // Именно `await`, а не возврат незавершённого будущего: иначе `finally`
      // закроет файл прямо посреди чтения.
      return await raf.read(end - start);
    } finally {
      await raf.close();
    }
  }

  /// Вывод ключа из пароля вне основного потока.
  ///
  /// PBKDF2 на сто двадцать тысяч итераций в чистом Dart считается секундами —
  /// на телефоне это заметное подвисание интерфейса.
  static Future<SecretKey> _keyFromPassword(
    String password,
    List<int> salt,
    int iterations,
  ) async {
    final bytes = await Isolate.run(() => _derive(password, salt, iterations));
    return SecretKey(bytes);
  }

  static Future<List<int>> _derive(
    String password,
    List<int> salt,
    int iterations,
  ) async {
    final kdf = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    );
    final key = await kdf.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );
    return key.extractBytes();
  }

  static List<int> _randomBytes(int count) {
    final random = Random.secure();
    return List<int>.generate(count, (_) => random.nextInt(256));
  }
}
