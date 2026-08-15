import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/services/csv_import_service.dart';

/// Чтение таблицы: обратная сторона выгрузки.
///
/// Выгрузка в CSV была, а перенести список из Excel или из другого приложения
/// можно было только руками.
void main() {
  const service = CsvImportService();

  Uint8List bytes(String text) => Uint8List.fromList(utf8.encode(text));

  test('свой же файл читается целиком', () {
    // Ровно то, что пишет выгрузка: BOM, точка с запятой, кавычки.
    final preview = service.inspect(
      bytes(
        '﻿Название;Тип;Категория;Отношение;Оценка;Дата впечатления;Добавлено\n'
        'Папа может;Продукты;Продукты / Колбасы;Нравится;7.5;31.12.2026;01.01.2026\n'
        '"Чай ""Ахмад""";Продукты;Продукты;Обожаю;9.0;;\n',
      ),
    );

    expect(preview.rows, hasLength(2));
    expect(preview.rows.first.title, 'Папа может');
    expect(preview.rows.first.category, 'Продукты / Колбасы');
    expect(preview.rows.first.rating, 7.5);
    expect(preview.rows.first.impressionDate, DateTime(2026, 12, 31));
    // Удвоенные кавычки — это одна кавычка внутри поля.
    expect(preview.rows.last.title, 'Чай "Ахмад"');
  });

  test('чужой файл с запятой и другим порядком колонок', () {
    final preview = service.inspect(
      bytes('Rating,Name,Note\n8,Interstellar,Отличный\n'),
    );

    expect(preview.rows.single.title, 'Interstellar');
    expect(preview.rows.single.rating, 8);
    expect(preview.rows.single.note, 'Отличный');
  });

  test('без узнаваемых заголовков названием считается первая колонка', () {
    final preview = service.inspect(bytes('a;b\nМолоко;прочее\n'));

    expect(preview.mapping[CsvField.title], 0);
    expect(preview.rows.single.title, 'Молоко');
  });

  test('строки без названия пропускаются и считаются', () {
    final preview = service.inspect(
      bytes('Название;Оценка\nМолоко;5\n;7\n   ;8\n'),
    );

    expect(preview.rows, hasLength(1));
    expect(preview.skipped, 2);
  });

  test('оценка читается и с запятой, и словами вокруг', () {
    final preview = service.inspect(
      bytes('Название;Оценка\nА;7,5\nБ;8 из 10\nВ;без оценки\nГ;99\n'),
    );

    expect(preview.rows[0].rating, 7.5);
    expect(preview.rows[1].rating, 8);
    expect(preview.rows[2].rating, isNull);
    // Оценка выше десяти — это не оценка: подрезаем до шкалы.
    expect(preview.rows[3].rating, 10);
  });

  test('дата понимается в двух видах', () {
    final preview = service.inspect(
      bytes('Название;Дата\nА;31.12.2026\nБ;2026-12-31\nВ;позавчера\n'),
    );

    expect(preview.rows[0].impressionDate, DateTime(2026, 12, 31));
    expect(preview.rows[1].impressionDate, DateTime(2026, 12, 31));
    expect(preview.rows[2].impressionDate, isNull);
  });

  test('перенос строки внутри поля не разрывает запись', () {
    final preview = service.inspect(
      bytes('Название;Заметка\n"Чай";"Первая строка\nвторая строка"\n'),
    );

    expect(preview.rows, hasLength(1));
    expect(preview.rows.single.note, contains('вторая строка'));
  });

  test('отношение узнаётся по русской метке и по внутреннему имени', () {
    expect(CsvImportService.relationOf('Обожаю'), 'love');
    expect(CsvImportService.relationOf('нравится'), 'like');
    expect(CsvImportService.relationOf('что-то своё'), isNull);
    expect(CsvImportService.relationOf(null), isNull);
  });

  test('«хочу попробовать» из той же колонки читается стадией', () {
    // В чужой таблице «Хочу попробовать» стоит там же, где «Нравится», но
    // значит другое: не мнение о вещи, а что мнения ещё нет.
    expect(CsvImportService.statusOf('Хочу попробовать'), 'planned');
    expect(CsvImportService.statusOf('want'), 'planned');
    expect(CsvImportService.relationOf('Хочу попробовать'), isNull);

    expect(CsvImportService.statusOf('Обожаю'), isNull);
    expect(CsvImportService.statusOf(null), isNull);
  });

  test('пустой файл не роняет разбор', () {
    expect(service.inspect(bytes('')).isEmpty, isTrue);
    expect(service.inspect(bytes('\n\n')).isEmpty, isTrue);
  });
}
