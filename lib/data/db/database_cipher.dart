import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

/// Состояние шифрования базы — то, что известно до её открытия.
///
/// Лежит отдельным файлом рядом с базой, потому что таблица настроек находится
/// внутри самой базы: чтобы узнать оттуда, нужен ли пароль, базу пришлось бы
/// сначала открыть. Соль не секрет, скрывать её незачем.
class CipherState {
  const CipherState({required this.encrypted, this.salt = const []});

  /// База зашифрована и без пароля не открывается.
  final bool encrypted;

  /// Соль для вывода ключа из пароля.
  final List<int> salt;

  static const _version = 1;

  /// Открытая база — состояние по умолчанию.
  static const plain = CipherState(encrypted: false);

  String toJson() => jsonEncode({
    'version': _version,
    'encrypted': encrypted,
    'kdf': 'pbkdf2-sha256',
    'iterations': DatabaseCipher.iterations,
    'salt': base64Encode(salt),
  });

  /// Читает состояние. Всё, чего не понимаем, считаем открытой базой: она
  /// откроется и без пароля, а испорченный файл состояния не должен запирать
  /// доступ к данным.
  static CipherState fromJson(String? raw) {
    if (raw == null || raw.isEmpty) return plain;
    try {
      final map = jsonDecode(raw) as Map<String, Object?>;
      if (map['encrypted'] != true) return plain;
      final salt = map['salt'];
      if (salt is! String || salt.isEmpty) return plain;
      return CipherState(encrypted: true, salt: base64Decode(salt));
    } on Object {
      return plain;
    }
  }
}

/// Шифрование файла базы паролем (SQLite3 Multiple Ciphers).
///
/// Пароль не хранится нигде: из него выводится ключ, и дальше в базу уходит
/// только он. «Помнить на этом устройстве» сохраняет тот же выведенный ключ в
/// хранилище операционной системы — пароль не восстановить и оттуда.
///
/// Все операции работают с закрытой базой: файл переключается на месте
/// (`PRAGMA rekey`), поэтому drift не должен держать его открытым.
class DatabaseCipher {
  const DatabaseCipher(this.directory);

  /// Каталог, в котором лежит база.
  final String directory;

  /// Имя файла базы — то же, что и в [openConnection].
  static const String databaseFileName = 'impressions.sqlite';

  /// Файл состояния рядом с базой.
  static const String stateFileName = 'db_cipher.json';

  /// Число итераций вывода ключа. Столько же у резервных копий.
  static const int iterations = 120000;

  String get databasePath => p.join(directory, databaseFileName);
  String get statePath => p.join(directory, stateFileName);

  // ---- Состояние ----

  Future<CipherState> readState() async {
    final file = File(statePath);
    if (!file.existsSync()) return CipherState.plain;
    return CipherState.fromJson(await file.readAsString());
  }

  Future<void> writeState(CipherState state) async {
    final file = File(statePath);
    if (!state.encrypted) {
      if (file.existsSync()) await file.delete();
      return;
    }
    // Через временный файл: оборванная запись не должна оставить базу с
    // потерянной солью — это равносильно потере данных.
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(state.toJson(), flush: true);
    await tmp.rename(file.path);
  }

  // ---- Ключ ----

  /// Соль в 16 байт из криптографического источника.
  static List<int> newSalt() {
    final random = Random.secure();
    return List<int>.generate(16, (_) => random.nextInt(256));
  }

  /// Ключ из пароля: PBKDF2-HMAC-SHA256, 256 бит.
  static Future<List<int>> deriveKey(String password, List<int> salt) async {
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

  /// Ключ в том виде, в каком его понимает SQLite: `x'…'` — это сырые байты,
  /// без ещё одного вывода ключа внутри библиотеки.
  static String keyLiteral(List<int> key) {
    final hex = key.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return "x'$hex'";
  }

  /// SQL, открывающий базу этим ключом. Должен идти первым запросом.
  static String openStatement(List<int> key) =>
      'PRAGMA key = ${_quote(keyLiteral(key))}';

  static String _quote(String literal) => '"$literal"';

  // ---- Операции над файлом ----

  /// Подходит ли пароль к нынешней базе.
  Future<bool> unlocks(String password) async {
    final state = await readState();
    if (!state.encrypted) return true;
    final key = await deriveKey(password, state.salt);
    return _opens(key);
  }

  bool _opens(List<int> key) {
    Database? db;
    try {
      db = sqlite3.open(databasePath);
      db.execute(openStatement(key));
      // Чтение заголовка — единственный способ убедиться в ключе: сам по себе
      // `PRAGMA key` не жалуется на неверный.
      db.select('SELECT count(*) FROM sqlite_master');
      return true;
    } on Object {
      return false;
    } finally {
      db?.close();
    }
  }

  /// Зашифровывает открытую базу и возвращает ключ, которым она теперь закрыта.
  ///
  /// Файл переписывается на месте. Вызывать только при закрытой базе.
  Future<List<int>> encrypt(String password) async {
    final salt = newSalt();
    final key = await deriveKey(password, salt);

    final db = sqlite3.open(databasePath);
    try {
      db.execute('PRAGMA rekey = ${_quote(keyLiteral(key))}');
    } finally {
      db.close();
    }

    await writeState(CipherState(encrypted: true, salt: salt));
    return key;
  }

  /// Снимает шифрование. Неверный пароль возвращает false и ничего не меняет.
  Future<bool> decrypt(String password) async {
    final state = await readState();
    if (!state.encrypted) return true;

    final key = await deriveKey(password, state.salt);
    if (!_opens(key)) return false;

    final db = sqlite3.open(databasePath);
    try {
      db.execute(openStatement(key));
      db.execute("PRAGMA rekey = ''");
    } finally {
      db.close();
    }

    await writeState(CipherState.plain);
    return true;
  }

  /// Меняет пароль. Неверный старый возвращает null и ничего не меняет.
  Future<List<int>?> changePassword(
    String oldPassword,
    String newPassword,
  ) async {
    final state = await readState();
    if (!state.encrypted) return null;

    final oldKey = await deriveKey(oldPassword, state.salt);
    if (!_opens(oldKey)) return null;

    // Новая соль на новый пароль: одинаковая соль позволила бы сказать, что
    // пароль сменили, но не сменили на другой.
    final salt = newSalt();
    final newKey = await deriveKey(newPassword, salt);

    final db = sqlite3.open(databasePath);
    try {
      db.execute(openStatement(oldKey));
      db.execute('PRAGMA rekey = ${_quote(keyLiteral(newKey))}');
    } finally {
      db.close();
    }

    await writeState(CipherState(encrypted: true, salt: salt));
    return newKey;
  }

  /// Открывается ли база вообще — проверка после миграции.
  ///
  /// Читает не только заголовок, но и одну настоящую таблицу: повреждённый
  /// файл может отдать список таблиц и не отдать их содержимое.
  Future<bool> verify(List<int>? key) async {
    Database? db;
    try {
      db = sqlite3.open(databasePath);
      if (key != null) db.execute(openStatement(key));
      final tables = db.select(
        "SELECT name FROM sqlite_master WHERE type = 'table' LIMIT 1",
      );
      if (tables.isEmpty) return false;
      db.select('PRAGMA integrity_check');
      return true;
    } on Object {
      return false;
    } finally {
      db?.close();
    }
  }

  /// Уносит следы журнала: после смены ключа старый `-wal` уже не к этой базе.
  Future<void> dropSideFiles() async {
    for (final suffix in ['-wal', '-shm']) {
      final file = File('$databasePath$suffix');
      if (file.existsSync()) await file.delete();
    }
  }

  /// Ключ в виде, пригодном для хранения, и обратно.
  static String encodeKey(List<int> key) => base64Encode(key);

  static List<int>? decodeKey(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final bytes = base64Decode(raw);
      return bytes.length == 32 ? Uint8List.fromList(bytes) : null;
    } on Object {
      return null;
    }
  }
}
