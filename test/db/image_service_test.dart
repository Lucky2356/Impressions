import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:impressions/data/services/image_service.dart';

import 'test_db.dart';

Uint8List _jpeg({int width = 100, int height = 60}) {
  final image = img.Image(width: width, height: height);
  img.fill(image, color: img.ColorRgb8(200, 120, 60));
  return Uint8List.fromList(img.encodeJpg(image));
}

Uint8List _png({int width = 50, int height = 50}) {
  final image = img.Image(width: width, height: height);
  img.fill(image, color: img.ColorRgb8(20, 140, 220));
  return Uint8List.fromList(img.encodePng(image));
}

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('impressions_media_test');
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('MIME определяется по сигнатуре, а не по расширению (§16)', () {
    expect(ImageService.detectMime(_jpeg()), 'image/jpeg');
    expect(ImageService.detectMime(_png()), 'image/png');
    expect(
      ImageService.detectMime(Uint8List.fromList(List.filled(64, 0x41))),
      isNull,
      reason: 'Подозрительный файл не должен опознаваться как изображение',
    );
  });

  test('подозрительный файл отклоняется', () async {
    final db = openTestDb();
    addTearDown(db.close);
    final service = ImageService(db, mediaDirectory: tempDir);

    final result = await service.addFromBytes(
      Uint8List.fromList(List.filled(128, 0x41)),
    );
    expect(result, isA<ImageRejected>());
  });

  test(
    'изображение обрабатывается: файлы, размеры, SHA-256, миниатюра',
    () async {
      final db = openTestDb();
      addTearDown(db.close);
      final service = ImageService(db, mediaDirectory: tempDir);

      final result = await service.addFromBytes(_jpeg(width: 120, height: 80));
      expect(result, isA<ImageAdded>());

      final row = (result as ImageAdded).attachment;
      expect(row.sha256.length, 64);
      expect(row.mimeType, 'image/jpeg');
      expect(row.width, 120);
      expect(row.height, 80);
      expect(row.thumbPath, isNotNull);

      // Файлы действительно записаны.
      final original = File(await service.absolutePath(row.storagePath));
      final thumb = File(await service.absolutePath(row.thumbPath!));
      expect(original.existsSync(), isTrue);
      expect(thumb.existsSync(), isTrue);
      expect(
        File('${original.path}.tmp').existsSync(),
        isFalse,
        reason: 'Временные файлы атомарной записи не должны оставаться',
      );
    },
  );

  test('EXIF очищается при обработке (§16)', () async {
    final db = openTestDb();
    addTearDown(db.close);
    final service = ImageService(db, mediaDirectory: tempDir);

    final result = await service.addFromBytes(_jpeg());
    final row = (result as ImageAdded).attachment;
    final stored = img.decodeImage(
      File(await service.absolutePath(row.storagePath)).readAsBytesSync(),
    )!;
    expect(
      stored.exif.gpsIfd.isEmpty,
      isTrue,
      reason: 'Геолокация EXIF не должна сохраняться',
    );
  });

  test('слишком большое изображение уменьшается до предела', () async {
    final db = openTestDb();
    addTearDown(db.close);
    final service = ImageService(db, mediaDirectory: tempDir);

    final result = await service.addFromBytes(_jpeg(width: 3000, height: 1500));
    final row = (result as ImageAdded).attachment;
    expect(row.width, ImageService.maxSide);
    expect(row.height, lessThanOrEqualTo(ImageService.maxSide));
  });

  test('одинаковый файл не сохраняется повторно (дедупликация)', () async {
    final db = openTestDb();
    addTearDown(db.close);
    final service = ImageService(db, mediaDirectory: tempDir);

    final first = await service.addFromBytes(_jpeg());
    final second = await service.addFromBytes(_jpeg());

    expect(first, isA<ImageAdded>());
    expect(second, isA<ImageDuplicate>());
    expect(
      (second as ImageDuplicate).attachment.sha256,
      (first as ImageAdded).attachment.sha256,
    );

    final all = await db.select(db.attachments).get();
    expect(all.length, 1);
  });
}
