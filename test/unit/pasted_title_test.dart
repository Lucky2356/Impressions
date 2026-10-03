import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/core/utils/pasted_title.dart';

void main() {
  group('предлагается', () {
    test('обычное название', () {
      expect(pastedTitle('Дюна'), 'Дюна');
    });

    test('обрезаются пробелы и перевод строки', () {
      expect(pastedTitle('  Дюна \n'), 'Дюна');
    });

    test('берётся первая строка, а не весь скопированный блок', () {
      // Так копируют со страницы магазина: под названием автор и год.
      expect(pastedTitle('Дюна\nФрэнк Герберт\n1965'), 'Дюна');
    });

    test('пустые строки сверху пропускаются', () {
      expect(pastedTitle('\n\n  \nДюна\nФрэнк Герберт'), 'Дюна');
    });

    test('внутренние пробелы схлопываются', () {
      expect(pastedTitle('Звёздные   войны\tV'), 'Звёздные войны V');
    });

    test('неразрывный пробел считается пробелом', () {
      expect(pastedTitle('Дюна II'), 'Дюна II');
    });

    test('невидимые знаки со страницы убираются', () {
      expect(pastedTitle('﻿Дюна​'), 'Дюна');
    });

    test('кавычки снимаются', () {
      expect(pastedTitle('«Дюна»'), 'Дюна');
      expect(pastedTitle('"Дюна"'), 'Дюна');
      expect(pastedTitle('„Дюна“'), 'Дюна');
    });

    test('снимается вся надетая обёртка, а не один слой', () {
      expect(pastedTitle('(«Дюна»)'), 'Дюна');
    });

    test('кавычки внутри названия остаются', () {
      expect(
        pastedTitle('Фильм «Дюна» и его музыка'),
        'Фильм «Дюна» и его музыка',
      );
    });

    test('название из одних цифр — тоже название', () {
      expect(pastedTitle('1984'), '1984');
    });

    test('название длиной ровно в предел', () {
      final title = 'Д' * 120;
      expect(pastedTitle(title), title);
    });
  });

  group('не предлагается', () {
    test('пустой буфер', () {
      expect(pastedTitle(null), isNull);
      expect(pastedTitle(''), isNull);
      expect(pastedTitle('   \n\t '), isNull);
    });

    test('ссылка', () {
      expect(pastedTitle('https://openlibrary.org/works/OL893415W'), isNull);
      expect(pastedTitle('http://example.org'), isNull);
      expect(pastedTitle('www.example.org'), isNull);
    });

    test('абзац текста', () {
      expect(pastedTitle('Д' * 121), isNull);
    });

    test('строка без букв и цифр', () {
      expect(pastedTitle('--- * ---'), isNull);
    });

    test('одни кавычки', () {
      expect(pastedTitle('«»'), isNull);
    });
  });
}
