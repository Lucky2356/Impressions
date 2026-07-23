import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/services/key_service.dart';

import 'test_db.dart';

void main() {
  test(
    'генерация ключей: открытый ключ и отпечаток попадают в профиль (§22)',
    () async {
      final db = openTestDb();
      addTearDown(db.close);
      final keys = KeyService(db);

      final me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
      final row = await keys.ensureKeyPair(me.id);

      expect(row.publicKey, isNotEmpty);
      expect(
        row.encryptedPrivateKey,
        isNotNull,
        reason: 'Закрытый ключ хранится локально в зашифрованном виде',
      );
      // Отпечаток вида 7A91-1F42-8B03.
      expect(
        RegExp(
          r'^[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}$',
        ).hasMatch(row.fingerprint),
        isTrue,
      );

      final profile = await ProfileRepository(db).byId(me.id);
      expect(profile!.publicKey, row.publicKey);
      expect(profile.fingerprint, row.fingerprint);
    },
  );

  test('повторный вызов не создаёт новую пару ключей', () async {
    final db = openTestDb();
    addTearDown(db.close);
    final keys = KeyService(db);
    final me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');

    final first = await keys.ensureKeyPair(me.id);
    final second = await keys.ensureKeyPair(me.id);
    expect(second.publicKey, first.publicKey);
  });

  test('подпись проверяется открытым ключом', () async {
    final db = openTestDb();
    addTearDown(db.close);
    final keys = KeyService(db);
    final me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    final row = await keys.ensureKeyPair(me.id);

    final data = utf8.encode('manifest+checksums');
    final signature = await keys.sign(me.id, data);

    expect(
      await KeyService.verify(
        data: data,
        signatureB64: signature,
        publicKeyB64: row.publicKey,
      ),
      isTrue,
    );
  });

  test('изменённые данные не проходят проверку подписи', () async {
    final db = openTestDb();
    addTearDown(db.close);
    final keys = KeyService(db);
    final me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    final row = await keys.ensureKeyPair(me.id);

    final signature = await keys.sign(me.id, utf8.encode('исходные данные'));

    expect(
      await KeyService.verify(
        data: utf8.encode('подменённые данные'),
        signatureB64: signature,
        publicKeyB64: row.publicKey,
      ),
      isFalse,
    );
  });

  test('подпись чужим ключом не проходит проверку', () async {
    final db = openTestDb();
    addTearDown(db.close);
    final keys = KeyService(db);
    final profiles = ProfileRepository(db);

    final a = await profiles.createOwnProfile(firstName: 'A');
    final b = await profiles.createOwnProfile(firstName: 'B');
    await keys.ensureKeyPair(a.id);
    final keyB = await keys.ensureKeyPair(b.id);

    final data = utf8.encode('пакет');
    final signatureByA = await keys.sign(a.id, data);

    expect(
      await KeyService.verify(
        data: data,
        signatureB64: signatureByA,
        publicKeyB64: keyB.publicKey,
      ),
      isFalse,
    );
  });

  test('повреждённая подпись обрабатывается без исключения', () async {
    final db = openTestDb();
    addTearDown(db.close);
    final keys = KeyService(db);
    final me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    final row = await keys.ensureKeyPair(me.id);

    expect(
      await KeyService.verify(
        data: utf8.encode('данные'),
        signatureB64: 'не base64!!!',
        publicKeyB64: row.publicKey,
      ),
      isFalse,
    );
  });

  test('защищённый паролем пакет: шифрование и расшифровка', () async {
    final data = Uint8List.fromList(utf8.encode('секретный пакет профиля'));

    final encrypted = await KeyService.encryptWithPassword(data, 'пароль123');
    expect(encrypted, isNot(data));

    final decrypted = await KeyService.decryptWithPassword(
      encrypted,
      'пароль123',
    );
    expect(decrypted, isNotNull);
    expect(utf8.decode(decrypted!), 'секретный пакет профиля');

    final wrong = await KeyService.decryptWithPassword(encrypted, 'другой');
    expect(wrong, isNull, reason: 'Неверный пароль не должен расшифровывать');
  });
}
