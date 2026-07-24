import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/services/image_service.dart';

import 'test_db.dart';

/// Обработка фотографии не занимает основной изолят.
///
/// `package:image` целиком на Dart: разбор, поворот и два сжатия снимка с
/// телефона занимают секунду-другую. Пока это делалось в основном изоляте,
/// интерфейс на всё это время замирал — а фотографии как раз чаще всего
/// добавляют с телефона.
void main() {
  late AppDatabase db;
  late Directory media;

  setUp(() async {
    db = openTestDb();
    media = await Directory.systemTemp.createTemp('impressions_img_isolate');
  });

  tearDown(() async {
    await db.close();
    if (media.existsSync()) media.deleteSync(recursive: true);
  });

  /// Крупный снимок с шумом: однотонная картинка сжалась бы мгновенно и
  /// ничего бы не проверила.
  Uint8List bigPhoto() {
    final image = img.Image(width: 2600, height: 1900);
    for (var y = 0; y < image.height; y += 3) {
      for (var x = 0; x < image.width; x += 3) {
        final c = (x * 31 + y * 17) % 255;
        image.setPixelRgb(x, y, c, (c * 3) % 255, (c * 7) % 255);
      }
    }
    return Uint8List.fromList(img.encodeJpg(image, quality: 90));
  }

  test('основной изолят продолжает работать во время обработки', () async {
    final service = ImageService(db, mediaDirectory: media);
    final bytes = bigPhoto();

    // Тикаем каждые 10 мс: если тяжёлая работа идёт в этом же изоляте, таймер
    // не сработает ни разу, пока она не закончится.
    var ticks = 0;
    final ticker = Timer.periodic(
      const Duration(milliseconds: 10),
      (_) => ticks++,
    );

    final started = DateTime.now();
    final result = await service.addFromBytes(bytes);
    final elapsed = DateTime.now().difference(started);
    ticker.cancel();

    expect(result, isA<ImageAdded>());

    // Сколько тиков успело бы пройти, если очередь событий не стояла.
    final expected = elapsed.inMilliseconds ~/ 10;
    expect(
      ticks,
      greaterThan(expected ~/ 2),
      reason:
          'за ${elapsed.inMilliseconds} мс обработки таймер сработал $ticks раз '
          'из ожидаемых ~$expected — значит, основной изолят был занят',
    );
  });

  test(
    'изображение после обработки в изоляте не отличается от прежнего',
    () async {
      final service = ImageService(db, mediaDirectory: media);
      final result = await service.addFromBytes(bigPhoto());

      expect(result, isA<ImageAdded>());
      final added = (result as ImageAdded).attachment;

      // Ограничение стороны, миниатюра и размеры остались теми же, что и когда
      // всё считалось на месте.
      expect(added.width, lessThanOrEqualTo(ImageService.maxSide));
      expect(added.height, lessThanOrEqualTo(ImageService.maxSide));
      expect(added.mimeType, 'image/jpeg');
      expect(added.thumbPath, isNotNull);
      expect(File('${media.path}/${added.storagePath}').existsSync(), isTrue);
      expect(File('${media.path}/${added.thumbPath}').existsSync(), isTrue);
    },
  );
}
