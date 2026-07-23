import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/core/utils/hashing.dart';

void main() {
  test('SHA-256 строки стабилен и корректен', () {
    // Известный вектор: SHA-256("abc").
    expect(
      Hashing.sha256OfString('abc'),
      'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
    );
  });

  test('contentHash не зависит от порядка ключей (§20 идемпотентность)', () {
    final a = Hashing.contentHash({
      'b': 2,
      'a': 1,
      'c': [1, 2, 3],
    });
    final b = Hashing.contentHash({
      'c': [1, 2, 3],
      'a': 1,
      'b': 2,
    });
    expect(a, b);
  });

  test('contentHash различает разное содержимое', () {
    final a = Hashing.contentHash({'rating': 9.5});
    final b = Hashing.contentHash({'rating': 6.0});
    expect(a, isNot(b));
  });

  test('canonicalJson сортирует вложенные ключи', () {
    expect(
      Hashing.canonicalJson({
        'z': {'y': 1, 'x': 2},
      }),
      '{"z":{"x":2,"y":1}}',
    );
  });
}
