import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/models/entry_view.dart';
import 'package:impressions/data/services/readable_export_service.dart';
import 'package:impressions/data/services/stats_export_service.dart';

/// Выгрузка статистики: числа из-под графиков — таблицей и текстом.
void main() {
  const labels = (
    title: 'Статистика',
    scope: 'Срез',
    exported: 'Выгружено',
    metric: 'Показатель',
    value: 'Значение',
    entries: 'Записей',
    total: 'Записей',
    rated: 'С оценкой',
    average: 'Средняя оценка',
    withPhotos: 'С фотографиями',
    withNotes: 'С заметками',
    ratings: 'Распределение оценок',
    rating: 'Оценка',
    relations: 'Отношение',
    categories: 'Самые заполненные категории',
    category: 'Категория',
    months: 'Добавления по месяцам',
    month: 'Месяц',
  );

  String relationLabel(String? name) => switch (name) {
    'love' => 'Люблю',
    'like' => 'Нравится',
    _ => name ?? '',
  };

  ProfileInsights insights({
    int total = 12,
    int rated = 8,
    double? average = 7.25,
    List<int> buckets = const [0, 0, 0, 0, 0, 1, 2, 3, 1, 1],
    Map<String, int> byRelation = const {'love': 5, 'like': 3},
    List<({String id, String name, int count})> categories = const [
      (id: 'c1', name: 'Продукты', count: 7),
    ],
    List<({DateTime month, int count})> byMonth = const [],
  }) => ProfileInsights(
    total: total,
    rated: rated,
    averageRating: average,
    ratingBuckets: buckets,
    byRelation: byRelation,
    topCategories: categories,
    byMonth: byMonth.isEmpty
        ? [
            (month: DateTime(2026, 1), count: 4),
            (month: DateTime(2026, 2), count: 8),
          ]
        : byMonth,
    withPhotos: 3,
    withNotes: 6,
  );

  String csv(
    ProfileInsights data, {
    String scope = 'Все категории · Всё время',
  }) => const StatsExportService().build(
    data: data,
    format: ReadableFormat.csv,
    profileName: 'Александр',
    scope: scope,
    labels: labels,
    relationLabel: relationLabel,
    now: DateTime(2026, 10, 3),
  );

  String markdown(ProfileInsights data) => const StatsExportService().build(
    data: data,
    format: ReadableFormat.markdown,
    profileName: 'Александр',
    scope: 'Все категории · Всё время',
    labels: labels,
    relationLabel: relationLabel,
    now: DateTime(2026, 10, 3),
  );

  group('таблица', () {
    test('начинается меткой кодировки и шапкой про срез', () {
      final text = csv(insights());

      // Без BOM Excel открывает файл в системной кодировке и портит
      // кириллицу.
      expect(text.startsWith('﻿'), isTrue);
      expect(text, contains('Статистика;Александр'));
      expect(text, contains('Срез;Все категории · Всё время'));
      expect(text, contains('Выгружено;03.10.2026'));
    });

    test('показатели совпадают с теми, что над графиками', () {
      final text = csv(insights());

      expect(text, contains('Записей;12'));
      expect(text, contains('С оценкой;8'));
      expect(text, contains('Средняя оценка;7.3'));
      expect(text, contains('С фотографиями;3'));
      expect(text, contains('С заметками;6'));
    });

    test('распределение оценок подписано баллом, а не номером корзины', () {
      final text = csv(insights());

      expect(text, contains('Оценка;Записей'));
      expect(text, contains('\n1;0'));
      // Индекс 9 — это балл 10, а не 9.
      expect(text, contains('\n10;1'));
    });

    test('отношения, категории и месяцы идут своими разделами', () {
      final text = csv(insights());

      expect(text, contains('Люблю;5'));
      expect(text, contains('Нравится;3'));
      expect(text, contains('Категория;Записей'));
      expect(text, contains('Продукты;7'));
      expect(text, contains('Месяц;Записей'));
      expect(text, contains('01.2026;4'));
      expect(text, contains('02.2026;8'));
    });

    test('без оценок средней оценки в файле нет', () {
      // Ноль в этой строке читался бы как «всё плохо», а не как «не оценивал».
      final text = csv(insights(rated: 0, average: null, buckets: const []));

      expect(text, isNot(contains('Средняя оценка')));
      expect(text, isNot(contains('Оценка;Записей')));
      expect(text, contains('С оценкой;0'));
    });

    test('точка с запятой и кавычки в названии не ломают колонки', () {
      final text = csv(
        insights(
          categories: const [
            (id: 'c1', name: 'Кино; и «цитаты»"тут"', count: 2),
          ],
        ),
      );

      expect(text, contains('"Кино; и «цитаты»""тут""";2'));
    });
  });

  group('текст', () {
    test('заголовок, срез и показатели списком', () {
      final text = markdown(insights());

      expect(text, contains('# Статистика — Александр'));
      expect(text, contains('Срез: Все категории · Всё время'));
      expect(text, contains('Выгружено: 03.10.2026'));
      expect(text, contains('- Записей: 12'));
    });

    test('разделы идут таблицами', () {
      final text = markdown(insights());

      expect(text, contains('## Распределение оценок'));
      expect(text, contains('| Оценка | Записей |'));
      expect(text, contains('| 10 | 1 |'));
      expect(text, contains('## Самые заполненные категории'));
      expect(text, contains('| Продукты | 7 |'));
    });

    test('пустые разделы не печатаются', () {
      final text = markdown(
        insights(
          byRelation: const {},
          rated: 0,
          average: null,
          buckets: const [],
        ),
      );

      expect(text, isNot(contains('## Отношение')));
      expect(text, isNot(contains('## Распределение оценок')));
    });

    test('вертикальная черта в названии не разваливает таблицу', () {
      final text = markdown(
        insights(categories: const [(id: 'c1', name: 'Кино | ТВ', count: 2)]),
      );

      expect(text, contains(r'| Кино \| ТВ | 2 |'));
    });
  });
}
