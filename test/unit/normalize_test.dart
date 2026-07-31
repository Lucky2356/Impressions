import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/core/utils/normalize.dart';

void main() {
  group('Normalize.name', () {
    test('обрезает, приводит к нижнему регистру, схлопывает пробелы', () {
      expect(Normalize.name('  Папа   Может  '), 'папа может');
      expect(Normalize.name('The Lord OF the Rings'), 'the lord of the rings');
    });
  });

  group('«ё» и «е» — одна буква', () {
    test('название с «ё» нормализуется как без неё', () {
      expect(Normalize.name('Ёлка'), Normalize.name('Елка'));
      expect(Normalize.name('Зелёный чай'), 'зеленый чай');
    });

    test('дубли с «ё» и без совпадают', () {
      expect(Normalize.forMatch('Пельмени «Ёлочка»'), 'пельмени елочка');
      expect(
        Normalize.forMatch('Варёная колбаса'),
        Normalize.forMatch('Вареная колбаса'),
      );
    });
  });

  group('Normalize.forMatch', () {
    test('убирает пунктуацию для поиска дублей', () {
      expect(Normalize.forMatch('Папа Может, варёная!'), 'папа может вареная');
      expect(Normalize.forMatch('ПАПА МОЖЕТ'), 'папа может');
    });

    test('одинаковые названия в разном оформлении совпадают', () {
      expect(
        Normalize.forMatch('The Lord of the Rings'),
        Normalize.forMatch('the lord of the rings'),
      );
    });
  });
}
