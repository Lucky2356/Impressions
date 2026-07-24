import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/services/key_service.dart';

/// Соль при выводе ключа из пароля.
///
/// До 1.9.0 соль была захардкожена и одинакова у всех. Число итераций поднимает
/// цену одной попытки подбора, но общая соль позволяет посчитать таблицу один
/// раз и применить её ко всем пакетам всех пользователей — весь смысл соли в
/// том, чтобы этого не давать.
void main() {
  final data = utf8.encode('впечатление о колбасе');

  test('один пароль даёт разные пакеты', () async {
    final a = await KeyService.encryptWithPassword(data, 'пароль');
    final b = await KeyService.encryptWithPassword(data, 'пароль');

    expect(a, isNot(equals(b)), reason: 'соль должна быть случайной');

    final saltA = (jsonDecode(utf8.decode(a)) as Map)['salt'];
    final saltB = (jsonDecode(utf8.decode(b)) as Map)['salt'];
    expect(saltA, isA<String>());
    expect(saltA, isNot(equals(saltB)));
  });

  test('пакет читается своим паролем', () async {
    final packed = await KeyService.encryptWithPassword(data, 'пароль');
    expect(
      await KeyService.decryptWithPassword(packed, 'пароль'),
      equals(data),
    );
  });

  test('чужой пароль не подходит', () async {
    final packed = await KeyService.encryptWithPassword(data, 'пароль');
    expect(await KeyService.decryptWithPassword(packed, 'другой'), isNull);
  });

  test('пакет старого формата, без соли, всё ещё читается', () async {
    final legacy = await _packLegacy(data, 'пароль');
    expect(
      jsonDecode(utf8.decode(legacy)),
      isNot(contains('salt')),
      reason: 'у старого формата поля salt не было',
    );
    expect(
      await KeyService.decryptWithPassword(legacy, 'пароль'),
      equals(data),
      reason: 'уже выгруженные пакеты должны открываться и после обновления',
    );
  });
}

/// Собирает пакет так, как это делал код до 1.9.0: фиксированная соль и
/// отсутствие поля `salt`. Формат воспроизведён здесь, а не взят из боевого
/// кода, чтобы тест ловил его случайное изменение.
Future<Uint8List> _packLegacy(List<int> data, String password) async {
  final kdf = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 120000,
    bits: 256,
  );
  final secret = await kdf.deriveKeyFromPassword(
    password: password,
    nonce: utf8.encode('impressions.package.v1'),
  );
  final box = await AesGcm.with256bits().encrypt(data, secretKey: secret);
  final payload = jsonEncode({
    'nonce': base64Encode(box.nonce),
    'cipher': base64Encode(box.cipherText),
    'mac': base64Encode(box.mac.bytes),
  });
  return Uint8List.fromList(utf8.encode(payload));
}
