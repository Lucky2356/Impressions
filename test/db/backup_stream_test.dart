import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/services/backup_cipher.dart';

/// Шифрование копии не занимает поток целиком.
///
/// Копия с медиатекой — это десятки мегабайт, и ChaCha20 в чистом Dart считает
/// их заметное время. Если бы шифрование шло одним куском, интерфейс замирал
/// бы на всё это время: ни прогресса, ни отклика на нажатия. Поток отдаёт
/// управление между кусками, и проверяется здесь именно это.
///
/// Способ проверки: рядом тикает таймер. Если поток занят одним длинным
/// вычислением, тиков будет считанные единицы вместо ожидаемых десятков.
void main() {
  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('impressions_backup_stream');
  });

  tearDown(() {
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  test('во время шифрования копии таймер продолжает тикать', () async {
    // Столько же, сколько занимает копия небольшой медиатеки.
    final source = File('${root.path}/backup.zip');
    await source.writeAsBytes(Uint8List(24 * 1024 * 1024));

    final key = await BackupCipher.newKey();
    final wrapped = await BackupCipher.wrapKey(key, 'пароль-подлиннее');

    var ticks = 0;
    const period = Duration(milliseconds: 10);
    final timer = Timer.periodic(period, (_) => ticks++);

    final started = DateTime.now();
    await BackupCipher.encryptFile(
      source,
      File('${root.path}/backup.zip.enc'),
      key: key,
      wrappedKey: wrapped,
    );
    final elapsed = DateTime.now().difference(started);
    timer.cancel();

    final expected = elapsed.inMilliseconds ~/ period.inMilliseconds;
    // Половины ожидаемого хватает: таймер не обязан быть точным, а вот
    // единичные тики означали бы, что поток стоял.
    expect(
      ticks,
      greaterThan(expected ~/ 2),
      reason:
          'за ${elapsed.inMilliseconds} мс шифрования таймер сработал $ticks '
          'раз из ожидаемых ~$expected',
    );
  });
}
