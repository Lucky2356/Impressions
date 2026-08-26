import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/design_system/design_system.dart';

import 'screens_test.dart' show app;

/// Обложка не разворачивается в памяти крупнее своей ячейки.
///
/// Соседние виджеты с картинкой — строка, полка, аватар — передавали
/// `cacheWidth` всегда, обложка одна не передавала. Обычно там миниатюра в
/// 400 точек, но у записи без миниатюры туда попадает оригинал до 2048.
void main() {
  testWidgets('обложка не разворачивается крупнее своей ячейки', (
    tester,
  ) async {
    // Файла нет — `Image.file` до диска не дойдёт, но параметры разбора уже
    // выбраны, а проверяем именно их.
    final path = File(
      '${Directory.systemTemp.path}/impressions_no_such.jpg',
    ).path;
    await tester.pumpWidget(
      app(
        Center(
          child: SizedBox(
            width: 200,
            child: CoverImage(title: 'Колбасы', imagePath: path),
          ),
        ),
      ),
    );
    await tester.pump();

    final image = tester.widget<Image>(find.byType(Image));
    final provider = image.image as ResizeImage;
    expect(
      provider.width,
      (200 * tester.view.devicePixelRatio).round(),
      reason: 'разбираем ровно под ширину ячейки',
    );
  });
}
