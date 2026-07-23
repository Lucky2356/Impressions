import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Хеширование (§16, §18, §21). SHA-256 для вложений, пакетов и contentHash
/// версий.
class Hashing {
  const Hashing._();

  static String sha256Hex(List<int> bytes) => sha256.convert(bytes).toString();

  static String sha256OfString(String s) =>
      sha256.convert(utf8.encode(s)).toString();

  static String sha256OfBytes(Uint8List bytes) => sha256Hex(bytes);

  /// contentHash полезной нагрузки revision: хеш канонического JSON.
  /// Обеспечивает идемпотентность импорта (§20): одинаковое содержимое — один
  /// и тот же хеш.
  static String contentHash(Map<String, Object?> payload) {
    return sha256OfString(canonicalJson(payload));
  }

  /// Каноническое представление JSON: ключи отсортированы рекурсивно.
  static String canonicalJson(Object? value) {
    final buffer = StringBuffer();
    _write(value, buffer);
    return buffer.toString();
  }

  static void _write(Object? value, StringBuffer out) {
    if (value is Map) {
      final keys = value.keys.map((k) => k.toString()).toList()..sort();
      out.write('{');
      for (var i = 0; i < keys.length; i++) {
        if (i > 0) out.write(',');
        out.write(jsonEncode(keys[i]));
        out.write(':');
        _write(value[keys[i]], out);
      }
      out.write('}');
    } else if (value is List) {
      out.write('[');
      for (var i = 0; i < value.length; i++) {
        if (i > 0) out.write(',');
        _write(value[i], out);
      }
      out.write(']');
    } else {
      out.write(jsonEncode(value));
    }
  }
}
