import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/core/utils/normalize.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/features/quick_add/type_for_category.dart';

/// Подстановка типа по категории.
///
/// Форма добавления всегда предлагала первый тип из списка — «Продукты», —
/// даже когда её открывали из ветки «Места › Парки». Тип и категория в базе не
/// связаны намеренно, поэтому связь приходится угадывать, и правило угадывания
/// стоит проверять отдельно от формы.
void main() {
  final now = DateTime(2026, 7, 25);

  ObjectTypeRow type(String name, {int sortOrder = 0}) => ObjectTypeRow(
    id: 't-$name',
    profileId: 'p1',
    name: name,
    normalizedName: Normalize.name(name),
    sortOrder: sortOrder,
    builtIn: true,
    hidden: false,
    createdAt: now,
  );

  CategoryRow category(
    String id,
    String name, {
    String? parentId,
    int level = 0,
    String? path,
  }) => CategoryRow(
    id: id,
    profileId: 'p1',
    parentId: parentId,
    name: name,
    normalizedName: Normalize.name(name),
    sortOrder: 0,
    level: level,
    path: path ?? id,
    createdAt: now,
  );

  final types = [
    type('Продукты'),
    type('Места', sortOrder: 1),
    type('Фильмы', sortOrder: 2),
  ];

  test('тип берётся у одноимённого предка ветки', () {
    final places = category('c1', 'Места');
    final parks = category(
      'c2',
      'Парки',
      parentId: 'c1',
      level: 1,
      path: 'c1/c2',
    );

    final result = typeForCategory(
      category: parks,
      categories: [places, parks],
      types: types,
    );

    expect(result, 't-Места');
  });

  test('имя самой категории важнее имени предка', () {
    final places = category('c1', 'Места');
    final films = category(
      'c2',
      'Фильмы',
      parentId: 'c1',
      level: 1,
      path: 'c1/c2',
    );

    final result = typeForCategory(
      category: films,
      categories: [places, films],
      types: types,
    );

    expect(result, 't-Фильмы');
  });

  test('регистр и ё в названии не мешают совпадению', () {
    final root = category('c1', 'МЕСТА');

    final result = typeForCategory(
      category: root,
      categories: [root],
      types: types,
    );

    expect(result, 't-Места');
  });

  test('без совпадения по имени берётся самый частый тип записей ветки', () {
    final root = category('c1', 'Отпуск');

    final result = typeForCategory(
      category: root,
      categories: [root],
      types: types,
      branchTypeCounts: const {'Места': 2, 'Продукты': 1},
    );

    expect(result, 't-Места');
  });

  test('пустая ветка без совпадения оставляет выбор по умолчанию', () {
    final root = category('c1', 'Отпуск');

    final result = typeForCategory(
      category: root,
      categories: [root],
      types: types,
    );

    expect(result, isNull);
  });

  test('без типов подсказывать нечего', () {
    final root = category('c1', 'Места');

    final result = typeForCategory(
      category: root,
      categories: [root],
      types: const [],
      branchTypeCounts: const {'Места': 1},
    );

    expect(result, isNull);
  });

  test('битая ссылка на предка не зацикливает подъём по дереву', () {
    // Категория ссылается сама на себя: так не бывает при обычной работе, но
    // испорченная копия не должна подвешивать форму добавления.
    final broken = category('c1', 'Отпуск', parentId: 'c1');

    final result = typeForCategory(
      category: broken,
      categories: [broken],
      types: types,
    );

    expect(result, isNull);
  });
}
