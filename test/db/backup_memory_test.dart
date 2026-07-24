import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/services/backup_service.dart';

import 'test_db.dart';

/// Копия собирается потоково, а не целиком в памяти.
///
/// Раньше база и каждая фотография читались в память, складывались в объект
/// архива, а потом он ещё раз кодировался в память — то есть всё содержимое
/// держалось в двух экземплярах сразу. На телефоне с большой медиатекой это
/// заканчивалось нехваткой памяти.
void main() {
  late AppDatabase db;
  late Directory root;

  setUp(() async {
    db = openTestDb();
    root = await Directory.systemTemp.createTemp('impressions_backup_mem');
    // Подставляем файл базы и медиатеку, как их видит служба копий.
    await File(
      '${root.path}/impressions.sqlite',
    ).writeAsBytes(Uint8List(64 * 1024));
    final media = Directory('${root.path}/media');
    await media.create(recursive: true);
    for (var i = 0; i < 40; i++) {
      await File(
        '${media.path}/photo_$i.jpg',
      ).writeAsBytes(Uint8List(128 * 1024));
    }
  });

  tearDown(() async {
    await db.close();
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  test('в копию попадают база, все фотографии и манифест', () async {
    final service = BackupService(db, rootOverride: root);
    final info = await service.create(reason: 'manual');

    final archive = ZipDecoder().decodeBytes(
      await File(info.path).readAsBytes(),
    );
    final names = archive.files.map((f) => f.name).toSet();

    expect(names, contains('backup.json'));
    expect(names, contains('impressions.sqlite'));
    expect(names.where((n) => n.startsWith('media/')).length, 40);
  });

  test('заявленный размер копии совпадает с файлом на диске', () async {
    final service = BackupService(db, rootOverride: root);
    final info = await service.create(reason: 'manual');

    // Размер берётся у готового файла: раньше он считался по буферу в памяти,
    // которого теперь просто нет.
    expect(info.byteSize, await File(info.path).length());
    expect(info.byteSize, greaterThan(0));
  });

  test('копия с большой медиатекой проходит проверку целостности', () async {
    final service = BackupService(db, rootOverride: root);
    final info = await service.create(reason: 'manual');

    // Контрольные суммы считаются потоково — важно, что они по-прежнему верны.
    expect(await service.verify(info.path), BackupCheck.ok);
  });
}
