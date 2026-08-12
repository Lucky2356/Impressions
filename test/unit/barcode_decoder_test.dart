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

/// Эталонные ширины ITF: 1 — узкий элемент, 2 — широкий.
const _itfWidths = [
  [1, 1, 2, 2, 1],
  [2, 1, 1, 1, 2],
  [1, 2, 1, 1, 2],
  [2, 2, 1, 1, 1],
  [1, 1, 2, 1, 2],
  [2, 1, 2, 1, 1],
  [1, 2, 2, 1, 1],
  [1, 1, 1, 2, 2],
  [2, 1, 1, 2, 1],
  [1, 2, 1, 2, 1],
];

/// Собирает модульную строку ITF: цифры идут парами, первая — штрихами,
/// вторая — пробелами между ними.
String _encodeItf(String code) {
  final buffer = StringBuffer('1010');
  for (var i = 0; i < code.length; i += 2) {
    final bars = _itfWidths[int.parse(code[i])];
    final spaces = _itfWidths[int.parse(code[i + 1])];
    for (var j = 0; j < 5; j++) {
      buffer
        ..write('1' * bars[j])
        ..write('0' * spaces[j]);
    }
  }
  return '${buffer}11010';
}

/// Эталонные шаблоны Code 128 — те же, что и в декодере, но здесь они нужны
/// для сборки заведомо правильного кода.
const _code128 = [
  [2, 1, 2, 2, 2, 2],
  [2, 2, 2, 1, 2, 2],
  [2, 2, 2, 2, 2, 1],
  [1, 2, 1, 2, 2, 3],
  [1, 2, 1, 3, 2, 2],
  [1, 3, 1, 2, 2, 2],
  [1, 2, 2, 2, 1, 3],
  [1, 2, 2, 3, 1, 2],
  [1, 3, 2, 2, 1, 2],
  [2, 2, 1, 2, 1, 3],
  [2, 2, 1, 3, 1, 2],
  [2, 3, 1, 2, 1, 2],
  [1, 1, 2, 2, 3, 2],
  [1, 2, 2, 1, 3, 2],
  [1, 2, 2, 2, 3, 1],
  [1, 1, 3, 2, 2, 2],
  [1, 2, 3, 1, 2, 2],
  [1, 2, 3, 2, 2, 1],
  [2, 2, 3, 2, 1, 1],
  [2, 2, 1, 1, 3, 2],
  [2, 2, 1, 2, 3, 1],
  [2, 1, 3, 2, 1, 2],
  [2, 2, 3, 1, 1, 2],
  [3, 1, 2, 1, 3, 1],
  [3, 1, 1, 2, 2, 2],
  [3, 2, 1, 1, 2, 2],
  [3, 2, 1, 2, 2, 1],
  [3, 1, 2, 2, 1, 2],
  [3, 2, 2, 1, 1, 2],
  [3, 2, 2, 2, 1, 1],
  [2, 1, 2, 1, 2, 3],
  [2, 1, 2, 3, 2, 1],
  [2, 3, 2, 1, 2, 1],
  [1, 1, 1, 3, 2, 3],
  [1, 3, 1, 1, 2, 3],
  [1, 3, 1, 3, 2, 1],
  [1, 1, 2, 3, 1, 3],
  [1, 3, 2, 1, 1, 3],
  [1, 3, 2, 3, 1, 1],
  [2, 1, 1, 3, 1, 3],
  [2, 3, 1, 1, 1, 3],
  [2, 3, 1, 3, 1, 1],
  [1, 1, 2, 1, 3, 3],
  [1, 1, 2, 3, 3, 1],
  [1, 3, 2, 1, 3, 1],
  [1, 1, 3, 1, 2, 3],
  [1, 1, 3, 3, 2, 1],
  [1, 3, 3, 1, 2, 1],
  [3, 1, 3, 1, 2, 1],
  [2, 1, 1, 3, 3, 1],
  [2, 3, 1, 1, 3, 1],
  [2, 1, 3, 1, 1, 3],
  [2, 1, 3, 3, 1, 1],
  [2, 1, 3, 1, 3, 1],
  [3, 1, 1, 1, 2, 3],
  [3, 1, 1, 3, 2, 1],
  [3, 3, 1, 1, 2, 1],
  [3, 1, 2, 1, 1, 3],
  [3, 1, 2, 3, 1, 1],
  [3, 3, 2, 1, 1, 1],
  [3, 1, 4, 1, 1, 1],
  [2, 2, 1, 4, 1, 1],
  [4, 3, 1, 1, 1, 1],
  [1, 1, 1, 2, 2, 4],
  [1, 1, 1, 4, 2, 2],
  [1, 2, 1, 1, 2, 4],
  [1, 2, 1, 4, 2, 1],
  [1, 4, 1, 1, 2, 2],
  [1, 4, 1, 2, 2, 1],
  [1, 1, 2, 2, 1, 4],
  [1, 1, 2, 4, 1, 2],
  [1, 2, 2, 1, 1, 4],
  [1, 2, 2, 4, 1, 1],
  [1, 4, 2, 1, 1, 2],
  [1, 4, 2, 2, 1, 1],
  [2, 4, 1, 2, 1, 1],
  [2, 2, 1, 1, 1, 4],
  [4, 1, 3, 1, 1, 1],
  [2, 4, 1, 1, 1, 2],
  [1, 3, 4, 1, 1, 1],
  [1, 1, 1, 2, 4, 2],
  [1, 2, 1, 1, 4, 2],
  [1, 2, 1, 2, 4, 1],
  [1, 1, 4, 2, 1, 2],
  [1, 2, 4, 1, 1, 2],
  [1, 2, 4, 2, 1, 1],
  [4, 1, 1, 2, 1, 2],
  [4, 2, 1, 1, 1, 2],
  [4, 2, 1, 2, 1, 1],
  [2, 1, 2, 1, 4, 1],
  [2, 1, 4, 1, 2, 1],
  [4, 1, 2, 1, 2, 1],
  [1, 1, 1, 1, 4, 3],
  [1, 1, 1, 3, 4, 1],
  [1, 3, 1, 1, 4, 1],
  [1, 1, 4, 1, 1, 3],
  [1, 3, 4, 1, 1, 1],
  [4, 1, 1, 1, 1, 3],
  [4, 1, 1, 3, 1, 1],
  [1, 1, 3, 1, 4, 1],
  [1, 1, 4, 1, 3, 1],
  [3, 1, 1, 1, 4, 1],
  [4, 1, 1, 1, 3, 1],
  [2, 1, 1, 4, 1, 2],
  [2, 1, 1, 2, 1, 4],
  [2, 1, 1, 2, 3, 2],
  [2, 3, 3, 1, 1, 1],
];

/// Собирает Code 128 набора B: печатные знаки, контрольная сумма по модулю 103.
String _encodeCode128(String text) {
  final values = <int>[104];
  for (final char in text.codeUnits) {
    values.add(char - 32);
  }
  var checksum = 104;
  for (var i = 1; i < values.length; i++) {
    checksum += values[i] * i;
  }
  values
    ..add(checksum % 103)
    ..add(106);

  final buffer = StringBuffer();
  for (final value in values) {
    final widths = _code128[value];
    for (var i = 0; i < widths.length; i++) {
      buffer.write((i.isEven ? '1' : '0') * widths[i]);
    }
  }
  // Хвостовой штрих стоп-метки.
  buffer.write('11');
  return buffer.toString();
}

/// Рисует набор модулей в PNG с белыми полями.
Uint8List _renderModules(String modules, {int scale = 3, int quiet = 12}) {
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

    test('распознаёт ITF-14 с коробки', () {
      // Код транспортной упаковки: им помечены коробки и блоки, которые и
      // фотографируют чаще всего.
      final result = decoder.decodeImage(
        _renderModules(_encodeItf('14600682000591'), scale: 4),
      );

      expect(result?.value, '14600682000591');
      expect(result?.format, 'ITF-14');
      expect(result?.isProductCode, isTrue);
    });

    test('распознаёт Code 128 со складской наклейки', () {
      final result = decoder.decodeImage(
        _renderModules(_encodeCode128('ABC-1234'), scale: 4),
      );

      expect(result?.value, 'ABC-1234');
      expect(result?.format, 'Code 128');
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
