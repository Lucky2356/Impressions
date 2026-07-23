import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart';

/// Что удалось распознать в изображении.
class DecodedCode {
  const DecodedCode({required this.value, required this.format});

  final String value;

  /// `EAN-13`, `EAN-8`, `UPC-A` или `QR`.
  final String format;

  /// Товарный ли это код (в отличие от произвольного текста в QR).
  bool get isProductCode => format != 'QR';
}

/// Распознавание штрихкодов и QR-кодов из изображения без камеры.
///
/// На Windows камеры-сканера нет: пользователь либо вводит код с USB-сканера
/// (он работает как клавиатура), либо подсовывает фотографию или снимок экрана.
/// QR разбирает zxing2; линейные коды EAN-13/EAN-8/UPC-A разбираются здесь —
/// готовой чистой реализации для Dart нет, а без них сканирование товаров с
/// фотографии не работает.
class BarcodeDecoder {
  const BarcodeDecoder();

  /// Пробует распознать код в изображении: сначала линейный, затем QR.
  DecodedCode? decodeImage(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;

    // Слишком большие снимки сначала уменьшаем: полосы остаются различимыми,
    // а проходов по строкам становится в разы меньше.
    final image = decoded.width > 1600
        ? img.copyResize(decoded, width: 1600)
        : decoded;

    final linear = _decodeLinear(image);
    if (linear != null) return linear;

    return _decodeQr(image);
  }

  // ---- QR ----

  DecodedCode? _decodeQr(img.Image image) {
    try {
      final rgba = image.convert(numChannels: 4);
      final pixels = rgba.getBytes(order: img.ChannelOrder.abgr);
      final source = RGBLuminanceSource(
        image.width,
        image.height,
        pixels.buffer.asInt32List(),
      );
      final bitmap = BinaryBitmap(HybridBinarizer(source));
      final result = QRCodeReader().decode(bitmap);
      final text = result.text;
      if (text.trim().isEmpty) return null;
      return DecodedCode(value: text.trim(), format: 'QR');
    } catch (_) {
      return null;
    }
  }

  // ---- Линейные коды ----

  /// Проходит по горизонтальным строкам изображения, затем по вертикальным
  /// (штрихкод мог быть снят повёрнутым на 90°).
  DecodedCode? _decodeLinear(img.Image image) {
    final direct = _scanRows(image, image.width, image.height, (x, y) {
      final p = image.getPixel(x, y);
      return (p.r * 299 + p.g * 587 + p.b * 114) ~/ 1000;
    });
    if (direct != null) return direct;

    return _scanRows(image, image.height, image.width, (x, y) {
      final p = image.getPixel(y, x);
      return (p.r * 299 + p.g * 587 + p.b * 114) ~/ 1000;
    });
  }

  DecodedCode? _scanRows(
    img.Image image,
    int width,
    int height,
    int Function(int x, int y) luminance,
  ) {
    if (width < 60) return null;
    // Пробуем строки от середины к краям: код обычно в центре кадра.
    const attempts = 24;
    for (var i = 0; i < attempts; i++) {
      final offset = ((i + 1) ~/ 2) * (height ~/ (attempts + 2));
      final y = i.isEven ? height ~/ 2 + offset : height ~/ 2 - offset;
      if (y < 0 || y >= height) continue;

      final row = Uint8List(width);
      var min = 255;
      var max = 0;
      for (var x = 0; x < width; x++) {
        final v = luminance(x, y).clamp(0, 255);
        row[x] = v;
        if (v < min) min = v;
        if (v > max) max = v;
      }
      // Строка без контраста — точно не штрихкод.
      if (max - min < 40) continue;

      final threshold = (min + max) ~/ 2;
      final bits = List<bool>.generate(width, (x) => row[x] < threshold);

      final result = _decodeRow(bits) ?? _decodeRow(bits.reversed.toList());
      if (result != null) return result;
    }
    return null;
  }

  /// Ширины модулей каждой цифры для левой половины с чётной (L) чётностью.
  static const List<List<int>> _lPatterns = [
    [3, 2, 1, 1],
    [2, 2, 2, 1],
    [2, 1, 2, 2],
    [1, 4, 1, 1],
    [1, 1, 3, 2],
    [1, 2, 3, 1],
    [1, 1, 1, 4],
    [1, 3, 1, 2],
    [1, 2, 1, 3],
    [3, 1, 1, 2],
  ];

  /// Разряды первой цифры EAN-13, закодированные чётностью первых шести цифр.
  static const List<int> _firstDigitEncodings = [
    0x00,
    0x0B,
    0x0D,
    0x0E,
    0x13,
    0x19,
    0x1C,
    0x15,
    0x16,
    0x1A,
  ];

  static const List<int> _startGuard = [1, 1, 1];
  static const List<int> _middleGuard = [1, 1, 1, 1, 1];

  DecodedCode? _decodeRow(List<bool> bits) {
    final start = _findGuard(bits, 0, _startGuard, whiteFirst: false);
    if (start == null) return null;

    final digits = StringBuffer();
    var parityBits = 0;
    var pos = start.end;

    // Левая половина: шесть цифр, чётность каждой запоминается.
    for (var i = 0; i < 6; i++) {
      final d = _decodeDigit(bits, pos, allowParity: true);
      if (d == null) return null;
      digits.write(d.value % 10);
      if (d.value >= 10) parityBits |= 1 << (5 - i);
      pos = d.end;
    }

    final middle = _findGuard(bits, pos, _middleGuard, whiteFirst: true);
    if (middle == null) return null;
    pos = middle.end;

    // Правая половина: шесть цифр, всегда прямая (R) кодировка.
    for (var i = 0; i < 6; i++) {
      final d = _decodeDigit(bits, pos, allowParity: false);
      if (d == null) return null;
      digits.write(d.value);
      pos = d.end;
    }

    final body = digits.toString();
    if (body.length != 12) return null;

    // Чётность первых шести цифр даёт первую цифру EAN-13. Если все шесть
    // цифр с L-кодировкой (parityBits == 0), это UPC-A.
    final firstDigit = _firstDigitEncodings.indexOf(parityBits);
    if (firstDigit < 0) return null;

    if (firstDigit == 0) {
      // UPC-A: 12 цифр. EAN-13 с ведущим нулём — та же последовательность.
      if (!_checksumOk(body)) return null;
      return DecodedCode(value: body, format: 'UPC-A');
    }

    final full = '$firstDigit$body';
    if (!_checksumOk(full)) return null;
    return DecodedCode(value: full, format: 'EAN-13');
  }

  /// Ищет служебный шаблон (стартовый или центральный), начиная с [from].
  _Span? _findGuard(
    List<bool> bits,
    int from,
    List<int> pattern, {
    required bool whiteFirst,
  }) {
    var index = from;
    // Пропускаем ведущее поле нужного цвета.
    while (index < bits.length && bits[index] == whiteFirst) {
      index++;
    }

    while (index < bits.length) {
      final counters = _recordPattern(bits, index, pattern.length);
      if (counters == null) return null;
      if (_variance(counters, pattern) < _maxVariance) {
        return _Span(index, index + counters.reduce((a, b) => a + b));
      }
      // Сдвигаемся на два интервала — чередование цветов должно сохраниться.
      index += counters[0] + counters[1];
      while (index < bits.length && bits[index] == whiteFirst) {
        index++;
      }
      if (counters[0] + counters[1] == 0) return null;
    }
    return null;
  }

  /// Читает [count] соседних одноцветных участков начиная с [start].
  List<int>? _recordPattern(List<bool> bits, int start, int count) {
    if (start >= bits.length) return null;
    final counters = List<int>.filled(count, 0);
    var current = 0;
    var colour = bits[start];
    for (var i = start; i < bits.length; i++) {
      if (bits[i] == colour) {
        counters[current]++;
      } else {
        current++;
        if (current == count) return counters;
        counters[current] = 1;
        colour = !colour;
      }
    }
    return current == count - 1 && counters[current] > 0 ? counters : null;
  }

  static const double _maxVariance = 0.48;

  /// Насколько измеренные ширины отличаются от эталонного шаблона.
  /// Ширина модуля неизвестна заранее, поэтому сравниваем пропорции.
  double _variance(List<int> counters, List<int> pattern) {
    final total = counters.fold<int>(0, (a, b) => a + b);
    final patternTotal = pattern.fold<int>(0, (a, b) => a + b);
    if (total < patternTotal) return double.infinity;

    final unit = total / patternTotal;
    final maxIndividual = unit * 0.7;
    var totalVariance = 0.0;
    for (var i = 0; i < counters.length; i++) {
      final expected = pattern[i] * unit;
      final diff = (counters[i] - expected).abs();
      if (diff > maxIndividual) return double.infinity;
      totalVariance += diff;
    }
    return totalVariance / total;
  }

  /// Декодирует одну цифру. Возвращает 0–9 для прямой кодировки и 10–19 для
  /// зеркальной (G), по которой определяется первая цифра EAN-13.
  _Digit? _decodeDigit(
    List<bool> bits,
    int start, {
    required bool allowParity,
  }) {
    final counters = _recordPattern(bits, start, 4);
    if (counters == null) return null;

    var best = double.infinity;
    var bestValue = -1;
    for (var d = 0; d < _lPatterns.length; d++) {
      final v = _variance(counters, _lPatterns[d]);
      if (v < best) {
        best = v;
        bestValue = d;
      }
      if (allowParity) {
        // G-кодировка — тот же шаблон, прочитанный справа налево.
        final reversed = _lPatterns[d].reversed.toList();
        final vr = _variance(counters, reversed);
        if (vr < best) {
          best = vr;
          bestValue = d + 10;
        }
      }
    }
    if (bestValue < 0 || best >= _maxVariance) return null;
    return _Digit(bestValue, start + counters.reduce((a, b) => a + b));
  }

  /// Контрольная сумма GTIN.
  bool _checksumOk(String digits) {
    final d = digits.split('').map(int.parse).toList();
    var sum = 0;
    for (var i = 0; i < d.length - 1; i++) {
      final fromRight = d.length - 2 - i;
      sum += d[i] * (fromRight.isEven ? 3 : 1);
    }
    return (10 - (sum % 10)) % 10 == d.last;
  }
}

class _Span {
  const _Span(this.start, this.end);
  final int start;
  final int end;
}

class _Digit {
  const _Digit(this.value, this.end);
  final int value;
  final int end;
}
