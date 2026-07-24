import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';

import '../../core/utils/hashing.dart';
import '../db/database.dart';
import '../repositories/settings_repository.dart';
import 'secret_storage.dart';

/// Ключи и цифровая подпись профиля (§22).
///
/// Закрытый ключ хранится только локально в зашифрованном виде и не попадает
/// в обычный экспорт. Открытый ключ и отпечаток входят в профиль и экспорт и
/// используются для проверки последующих импортов.
class KeyService {
  KeyService(this.db, {SecretStorage? secrets})
    : _settings = SettingsRepository(db),
      _secrets = secrets ?? const SecretStorage();

  final AppDatabase db;
  final SettingsRepository _settings;
  final SecretStorage _secrets;

  static final _ed25519 = Ed25519();
  static final _aes = AesGcm.with256bits();

  /// Ключ, под которым лежит локальный секрет шифрования закрытых ключей.
  static const String _deviceSecretKey = 'device_secret';

  // ---- Отпечаток ----

  /// Человекочитаемый отпечаток открытого ключа: `7A91-1F42-8B03` (§22).
  static String fingerprintOf(List<int> publicKeyBytes) {
    final hash = Hashing.sha256Hex(publicKeyBytes).toUpperCase();
    final groups = <String>[
      hash.substring(0, 4),
      hash.substring(4, 8),
      hash.substring(8, 12),
    ];
    return groups.join('-');
  }

  // ---- Локальный секрет шифрования ----

  /// Секрет шифрования: сначала хранилище ОС, затем — база.
  ///
  /// Секрет, оставшийся в базе от прежних версий, при первой же возможности
  /// переезжает в хранилище ОС и стирается из базы.
  Future<SecretKey> _deviceSecret() async {
    final fromOs = await _secrets.read(_deviceSecretKey);
    if (fromOs != null) return SecretKey(base64Decode(fromOs));

    // Пустая строка остаётся после переноса — это не секрет.
    final fromDb = await _settings.get(_deviceSecretKey);
    if (fromDb != null && fromDb.isNotEmpty) {
      if (await _secrets.write(_deviceSecretKey, fromDb)) {
        await _settings.set(_deviceSecretKey, '');
      }
      return SecretKey(base64Decode(fromDb));
    }

    final key = await _aes.newSecretKey();
    final encoded = base64Encode(await key.extractBytes());
    if (!await _secrets.write(_deviceSecretKey, encoded)) {
      // Хранилище ОС недоступно — работаем как раньше, но об этом честно
      // сообщается в настройках.
      await _settings.set(_deviceSecretKey, encoded);
    }
    return SecretKey(base64Decode(encoded));
  }

  /// Где сейчас лежит секрет — показывается в настройках.
  ///
  /// Заодно создаёт секрет, если его ещё нет: иначе на свежей установке
  /// настройки сообщали бы «в базе приложения», хотя там пусто, а кнопка
  /// переноса не делала бы ничего.
  Future<SecretLocation> secretLocation() async {
    await _deviceSecret();
    if (await _secrets.read(_deviceSecretKey) != null) {
      return SecretLocation.operatingSystem;
    }
    return SecretLocation.database;
  }

  /// Переносит секрет из базы в хранилище ОС по требованию пользователя.
  /// Возвращает false, если хранилище недоступно и переносить некуда.
  Future<bool> moveSecretToOs() async {
    final fromDb = await _settings.get(_deviceSecretKey);
    if (fromDb == null || fromDb.isEmpty) {
      // Секрета в базе нет — либо он уже перенесён, либо ещё не создан.
      await _deviceSecret();
      return _secrets.read(_deviceSecretKey).then((v) => v != null);
    }
    if (!await _secrets.write(_deviceSecretKey, fromDb)) return false;
    await _settings.set(_deviceSecretKey, '');
    return true;
  }

  Future<String> _encrypt(List<int> data) async {
    final secret = await _deviceSecret();
    final box = await _aes.encrypt(data, secretKey: secret);
    return jsonEncode({
      'nonce': base64Encode(box.nonce),
      'cipher': base64Encode(box.cipherText),
      'mac': base64Encode(box.mac.bytes),
    });
  }

  Future<List<int>> _decrypt(String payload) async {
    final secret = await _deviceSecret();
    final map = jsonDecode(payload) as Map<String, Object?>;
    final box = SecretBox(
      base64Decode(map['cipher']! as String),
      nonce: base64Decode(map['nonce']! as String),
      mac: Mac(base64Decode(map['mac']! as String)),
    );
    return _aes.decrypt(box, secretKey: secret);
  }

  // ---- Ключевая пара профиля ----

  /// Создаёт пару ключей для профиля, если её ещё нет, и записывает открытый
  /// ключ и отпечаток в профиль.
  Future<ProfileKeyRow> ensureKeyPair(String profileId) async {
    final existing = await keyOf(profileId);
    if (existing != null) return existing;

    final keyPair = await _ed25519.newKeyPair();
    final publicKey = await keyPair.extractPublicKey();
    final privateBytes = await keyPair.extractPrivateKeyBytes();

    final publicB64 = base64Encode(publicKey.bytes);
    final fingerprint = fingerprintOf(publicKey.bytes);
    final encryptedPrivate = await _encrypt(privateBytes);

    await db.transaction(() async {
      await db
          .into(db.profileKeys)
          .insert(
            ProfileKeysCompanion.insert(
              profileId: profileId,
              publicKey: publicB64,
              fingerprint: fingerprint,
              encryptedPrivateKey: Value(encryptedPrivate),
              createdAt: DateTime.now(),
            ),
          );
      await (db.update(
        db.profiles,
      )..where((p) => p.id.equals(profileId))).write(
        ProfilesCompanion(
          publicKey: Value(publicB64),
          fingerprint: Value(fingerprint),
        ),
      );
    });

    return (await keyOf(profileId))!;
  }

  Future<ProfileKeyRow?> keyOf(String profileId) {
    return (db.select(
      db.profileKeys,
    )..where((k) => k.profileId.equals(profileId))).getSingleOrNull();
  }

  /// Сохраняет открытый ключ внешнего профиля (закрытого у нас нет).
  Future<void> storePublicKey({
    required String profileId,
    required String publicKeyB64,
  }) async {
    final fingerprint = fingerprintOf(base64Decode(publicKeyB64));
    await db
        .into(db.profileKeys)
        .insertOnConflictUpdate(
          ProfileKeysCompanion.insert(
            profileId: profileId,
            publicKey: publicKeyB64,
            fingerprint: fingerprint,
            createdAt: DateTime.now(),
          ),
        );
    await (db.update(db.profiles)..where((p) => p.id.equals(profileId))).write(
      ProfilesCompanion(
        publicKey: Value(publicKeyB64),
        fingerprint: Value(fingerprint),
      ),
    );
  }

  // ---- Подпись и проверка ----

  /// Подписывает данные закрытым ключом профиля.
  Future<String> sign(String profileId, List<int> data) async {
    final row = await keyOf(profileId);
    if (row == null || row.encryptedPrivateKey == null) {
      throw StateError('У профиля нет закрытого ключа для подписи');
    }
    final privateBytes = await _decrypt(row.encryptedPrivateKey!);
    final keyPair = await _ed25519.newKeyPairFromSeed(privateBytes);
    final signature = await _ed25519.sign(data, keyPair: keyPair);
    return base64Encode(signature.bytes);
  }

  /// Проверяет подпись открытым ключом.
  static Future<bool> verify({
    required List<int> data,
    required String signatureB64,
    required String publicKeyB64,
  }) async {
    try {
      final publicKey = SimplePublicKey(
        base64Decode(publicKeyB64),
        type: KeyPairType.ed25519,
      );
      final signature = Signature(
        base64Decode(signatureB64),
        publicKey: publicKey,
      );
      return await _ed25519.verify(data, signature: signature);
    } on Object {
      // Повреждённая подпись или ключ — считаем проверку непройденной.
      return false;
    }
  }

  /// Шифрование произвольных данных паролем (защищённый пакет, §19, §22).
  static Future<Uint8List> encryptWithPassword(
    List<int> data,
    String password,
  ) async {
    final salt = _newSalt();
    final secret = await _keyFromPassword(password, salt);
    final box = await _aes.encrypt(data, secretKey: secret);
    final payload = jsonEncode({
      'salt': base64Encode(salt),
      'nonce': base64Encode(box.nonce),
      'cipher': base64Encode(box.cipherText),
      'mac': base64Encode(box.mac.bytes),
    });
    return Uint8List.fromList(utf8.encode(payload));
  }

  /// Расшифровка пакета паролем. Возвращает null при неверном пароле.
  static Future<Uint8List?> decryptWithPassword(
    Uint8List data,
    String password,
  ) async {
    try {
      final map = jsonDecode(utf8.decode(data)) as Map<String, Object?>;
      final box = SecretBox(
        base64Decode(map['cipher']! as String),
        nonce: base64Decode(map['nonce']! as String),
        mac: Mac(base64Decode(map['mac']! as String)),
      );
      // Пакеты, выгруженные до появления соли в формате, читаются по-старому.
      final rawSalt = map['salt'];
      final salt = rawSalt is String ? base64Decode(rawSalt) : _legacySalt;
      final secret = await _keyFromPassword(password, salt);
      final clear = await _aes.decrypt(box, secretKey: secret);
      return Uint8List.fromList(clear);
    } on Object {
      return null;
    }
  }

  /// Соль пакетов, выгруженных до версии 1.9.0.
  ///
  /// Она была одна на всех, и это ошибка: число итераций поднимает цену одной
  /// попытки подбора, но общая соль позволяет посчитать таблицу один раз и
  /// применить её сразу ко всем пакетам всех пользователей. Оставлена только
  /// для чтения старых файлов — новые получают случайную.
  static final List<int> _legacySalt = utf8.encode('impressions.package.v1');

  /// Случайная соль пакета: 16 байт из криптографического источника.
  static List<int> _newSalt() {
    final random = Random.secure();
    return List<int>.generate(16, (_) => random.nextInt(256));
  }

  /// Производный ключ из пароля (PBKDF2-HMAC-SHA256) на заданной соли.
  static Future<SecretKey> _keyFromPassword(
    String password,
    List<int> salt,
  ) async {
    final kdf = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 120000,
      bits: 256,
    );
    return kdf.deriveKeyFromPassword(password: password, nonce: salt);
  }
}
