import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:impressions/data/services/barcode_decoder.dart';
import 'package:impressions/data/services/product_lookup_service.dart';

/// Эталонные кодировки EAN-13 — используются только в тесте, чтобы построить
/// заведомо правильный штрихкод и проверить на нём декодер.
const _lCodes = [
  '0001101',
  '0011001',
  '0010011',
  '0111101',
  '0100011',
  '0110001',
  '0101111',
  '0111011',
  '0110111',
  '0001011',
];
const _gCodes = [
  '0100111',
  '0110011',
  '0011011',
  '0100001',
  '0011101',
  '0111001',
  '0000101',
  '0010001',
  '0001001',
  '0010111',
];
const _rCodes = [
  '1110010',
  '1100110',
  '1101100',
  '1000010',
  '1011100',
  '1001110',
  '1010000',
  '1000100',
  '1001000',
  '1110100',
];
const _parity = [
  'LLLLLL',
  'LLGLGG',
  'LLGGLG',
  'LLGGGL',
  'LGLLGG',
  'LGGLLG',
  'LGGGLL',
  'LGLGLG',
  'LGLGGL',
  'LGGLGL',
];

/// Собирает модульную строку EAN-13 («1» — чёрный штрих).
String _encodeEan13(String code) {
  expect(code.length, 13);
  final d = code.split('').map(int.parse).toList();
  final pattern = _parity[d[0]];
  final buffer = StringBuffer('101');
  for (var i = 0; i < 6; i++) {
    final digit = d[i + 1];
    buffer.write(pattern[i] == 'L' ? _lCodes[digit] : _gCodes[digit]);
  }
  buffer.write('01010');
  for (var i = 7; i < 13; i++) {
    buffer.write(_rCodes[d[i]]);
  }
  buffer.write('101');
  return buffer.toString();
}

/// Рисует штрихкод в PNG с заданным масштабом и белыми полями.
Uint8List _renderBarcode(String code, {int scale = 3, int quiet = 12}) {
  final modules = _encodeEan13(code);
  final width = modules.length * scale + quiet * 2 * scale;
  const height = 90;
  final image = img.Image(width: width, height: height);
  img.fill(image, color: img.ColorRgb8(255, 255, 255));

  for (var i = 0; i < modules.length; i++) {
    if (modules[i] != '1') continue;
    final x0 = (quiet + i) * scale;
    for (var x = x0; x < x0 + scale; x++) {
      for (var y = 0; y < height; y++) {
        image.setPixelRgb(x, y, 0, 0, 0);
      }
    }
  }
  return Uint8List.fromList(img.encodePng(image));
}

void main() {
  const decoder = BarcodeDecoder();

  group('Декодирование линейных штрихкодов', () {
    test('распознаёт российский код 4600682000594', () {
      final result = decoder.decodeImage(_renderBarcode('4600682000594'));
      expect(result, isNotNull);
      expect(result!.value, '4600682000594');
      expect(result.format, 'EAN-13');
      expect(result.isProductCode, isTrue);
    });

    test('распознаёт код на изображении низкого разрешения', () {
      final result = decoder.decodeImage(
        _renderBarcode('4607034170028', scale: 2),
      );
      expect(result?.value, '4607034170028');
    });

    test('распознаёт код, повёрнутый на 90 градусов', () {
      final source = img.decodePng(_renderBarcode('4680115880016'))!;
      final rotated = img.copyRotate(source, angle: 90);
      final result = decoder.decodeImage(
        Uint8List.fromList(img.encodePng(rotated)),
      );
      expect(result?.value, '4680115880016');
    });

    test('распознаёт зеркально снятый код', () {
      final source = img.decodePng(_renderBarcode('4650001110015'))!;
      final flipped = img.flipHorizontal(source);
      final result = decoder.decodeImage(
        Uint8List.fromList(img.encodePng(flipped)),
      );
      expect(result?.value, '4650001110015');
    });

    test('на изображении без кода ничего не находит', () {
      final blank = img.Image(width: 300, height: 200);
      img.fill(blank, color: img.ColorRgb8(220, 220, 220));
      final result = decoder.decodeImage(
        Uint8List.fromList(img.encodePng(blank)),
      );
      expect(result, isNull);
    });
  });

  group('Проверка товарных кодов', () {
    test('принимает корректные GTIN', () {
      expect(ProductLookupService.isGtin('4600682000594'), isTrue);
      expect(ProductLookupService.isGtin('4607034170028'), isTrue);
    });

    test('отвергает код с испорченной контрольной суммой', () {
      expect(ProductLookupService.isGtin('4600682000595'), isFalse);
      expect(ProductLookupService.isGtin('не код'), isFalse);
    });

    test('узнаёт российский префикс GS1', () {
      expect(ProductLookupService.isRussianGtin('4600682000594'), isTrue);
      expect(ProductLookupService.isRussianGtin('3017620422003'), isFalse);
    });
  });
}
