import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/services/backup_cipher.dart';

/// Формат зашифрованной копии `*.zip.enc`.
///
/// Проверяется то, ради чего он и заводился: содержимое не читается без ключа,
/// открывается ключом копий и паролем, чужой пароль отвергается, а порча даже
/// одного байта ловится кодом проверки подлинности.
void main() {
  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('impressions_cipher');
  });

  tearDown(() {
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  File at(String name) => File('${root.path}/$name');

  /// Содержимое заметно крупнее куска потока, чтобы шифрование прошло не одним
  /// вызовом, а несколькими — иначе потоковость ничем не проверяется.
  Uint8List payload(int bytes) {
    final random = Random(42);
    return Uint8List.fromList(
      List<int>.generate(bytes, (_) => random.nextInt(256)),
    );
  }

  test('копия расшифровывается тем же ключом байт в байт', () async {
    final source = at('backup.zip');
    final data = payload(3 * 1024 * 1024);
    await source.writeAsBytes(data);

    final key = await BackupCipher.newKey();
    final wrapped = await BackupCipher.wrapKey(key, 'пароль от копий');

    final encrypted = at('backup.zip.enc');
    await BackupCipher.encryptFile(
      source,
      encrypted,
      key: key,
      wrappedKey: wrapped,
    );

    final restored = at('restored.zip');
    expect(
      await BackupCipher.decryptFile(encrypted, restored, key: key),
      isTrue,
    );
    expect(await restored.readAsBytes(), data);
  });

  test('исходное содержимое в зашифрованном файле не встречается', () async {
    final source = at('backup.zip');
    // Узнаваемая строка: если бы шифрование где-то пропускало кусок, она бы
    // осталась в файле как есть.
    await source.writeAsBytes(
      List<int>.filled(200 * 1024, 0x41), // 'A'
    );

    final key = await BackupCipher.newKey();
    final encrypted = at('backup.zip.enc');
    await BackupCipher.encryptFile(
      source,
      encrypted,
      key: key,
      wrappedKey: await BackupCipher.wrapKey(key, 'п'),
    );

    final bytes = await encrypted.readAsBytes();
    final runOfA = List<int>.filled(1024, 0x41);
    expect(_contains(bytes, runOfA), isFalse);
  });

  test('ключ копий достаётся из заголовка по паролю', () async {
    final source = at('backup.zip');
    await source.writeAsBytes(payload(64 * 1024));

    final key = await BackupCipher.newKey();
    final encrypted = at('backup.zip.enc');
    await BackupCipher.encryptFile(
      source,
      encrypted,
      key: key,
      wrappedKey: await BackupCipher.wrapKey(key, 'верный'),
    );

    final header = await BackupCipher.readHeader(encrypted);
    expect(header, isNotNull);

    // На чужом устройстве ключа копий нет — есть только пароль.
    final unwrapped = await BackupCipher.unwrapKey(header!, 'верный');
    expect(unwrapped, isNotNull);
    expect(await unwrapped!.extractBytes(), await key.extractBytes());

    expect(await BackupCipher.unwrapKey(header, 'неверный'), isNull);
  });

  test('порча одного байта делает копию нечитаемой', () async {
    final source = at('backup.zip');
    await source.writeAsBytes(payload(256 * 1024));

    final key = await BackupCipher.newKey();
    final encrypted = at('backup.zip.enc');
    await BackupCipher.encryptFile(
      source,
      encrypted,
      key: key,
      wrappedKey: await BackupCipher.wrapKey(key, 'п'),
    );

    final bytes = await encrypted.readAsBytes();
    final middle = bytes.length ~/ 2;
    bytes[middle] = bytes[middle] ^ 0x01;
    await encrypted.writeAsBytes(bytes);

    final restored = at('restored.zip');
    expect(
      await BackupCipher.decryptFile(encrypted, restored, key: key),
      isFalse,
    );
    // Непроверенному содержимому доверять нельзя, поэтому его не оставляют.
    expect(restored.existsSync(), isFalse);
  });

  test('обычный зип за зашифрованную копию не принимается', () async {
    final plain = at('plain.zip');
    await plain.writeAsBytes(payload(4096));

    expect(await BackupCipher.readHeader(plain), isNull);
    expect(await BackupCipher.isEncrypted(plain), isFalse);
  });
}

bool _contains(List<int> haystack, List<int> needle) {
  outer:
  for (var i = 0; i + needle.length <= haystack.length; i++) {
    for (var j = 0; j < needle.length; j++) {
      if (haystack[i + j] != needle[j]) continue outer;
    }
    return true;
  }
  return false;
}
