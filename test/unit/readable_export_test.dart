import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/models/entry_view.dart';
import 'package:impressions/data/services/readable_export_service.dart';

EntryView _entry({
  required String title,
  List<String> path = const [],
  String? relation,
  double? rating,
}) => EntryView(
  entryId: 'e-$title',
  objectId: 'o-$title',
  title: title,
  typeName: 'Продукты',
  categoryPath: path,
  relation: relation,
  rating: rating,
  createdAt: DateTime(2026, 3, 14),
);

String _label(String? relation) => switch (relation) {
  'love' => 'Обожаю',
  'dislike' => 'Не нравится',
  _ => '',
};

void main() {
  const service = ReadableExportService();

  String build(List<EntryView> entries, ReadableFormat format) => service.build(
    entries: entries,
    format: format,
    profileName: 'Лариса',
    relationLabel: _label,
  );

  group('Выгрузка в CSV', () {
    test('начинается с BOM и заголовков', () {
      final csv = build([_entry(title: 'Хлеб')], ReadableFormat.csv);
      // Без BOM Excel открывает файл в системной кодировке и портит кириллицу.
      expect(csv.codeUnitAt(0), 0xFEFF);
      expect(csv, contains('Название;Тип;Категория'));
    });

    test('экранирует разделитель, кавычки и переносы строк', () {
      final csv = build([
        _entry(title: 'Сыр; выдержанный'),
        _entry(title: 'Печенье "Юбилейное"'),
        _entry(title: 'Первая\nвторая'),
      ], ReadableFormat.csv);

      expect(csv, contains('"Сыр; выдержанный"'));
      expect(csv, contains('"Печенье ""Юбилейное"""'));
      expect(csv, contains('"Первая\nвторая"'));
    });

    test('содержит путь категории, отношение и оценку', () {
      final csv = build([
        _entry(
          title: 'Папа может',
          path: ['Продукты', 'Колбасы'],
          relation: 'love',
          rating: 8.5,
        ),
      ], ReadableFormat.csv);

      expect(csv, contains('Папа может'));
      expect(csv, contains('Продукты / Колбасы'));
      expect(csv, contains('Обожаю'));
      expect(csv, contains('8.5'));
    });

    test('строк ровно столько, сколько записей, плюс заголовок', () {
      final csv = build([
        _entry(title: 'Раз'),
        _entry(title: 'Два'),
      ], ReadableFormat.csv);
      final lines = csv.trim().split('\n').where((l) => l.isNotEmpty);
      expect(lines, hasLength(3));
    });
  });

  group('Выгрузка в Markdown', () {
    test('группирует по категориям и озаглавлена именем профиля', () {
      final md = build([
        _entry(title: 'Колбаса', path: ['Продукты']),
        _entry(title: 'Сыр', path: ['Продукты']),
        _entry(title: 'Кафе у дома', path: ['Места']),
        _entry(title: 'Без полки'),
      ], ReadableFormat.markdown);

      expect(md, startsWith('# Лариса'));
      expect(md, contains('## Продукты'));
      expect(md, contains('## Места'));
      expect(md, contains('## Без категории'));
      expect(md, contains('- Колбаса'));
    });

    test('показывает отношение и оценку рядом с названием', () {
      final md = build([
        _entry(title: 'Кино', relation: 'dislike', rating: 3),
      ], ReadableFormat.markdown);
      expect(md, contains('- Кино — Не нравится, 3.0 из 10'));
    });

    test('экранирует разметку в названии', () {
      final md = build([
        _entry(title: 'Звёздочка * и _подчёркивание_'),
      ], ReadableFormat.markdown);
      expect(md, contains(r'Звёздочка \* и \_подчёркивание\_'));
    });
  });

  test('расширение файла соответствует формату', () {
    expect(service.extensionFor(ReadableFormat.csv), 'csv');
    expect(service.extensionFor(ReadableFormat.markdown), 'md');
  });
}
