import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/models/category_tree.dart';

/// Тип по умолчанию у ветки (§9).
///
/// До 1.16.0 форма угадывала тип по совпадению названий категории и типа.
/// Правило работало ровно потому, что первый запуск заводит одноимённую пару,
/// но жило в коде: увидеть его было негде, поправить — тоже.
CategoryRow cat(
  String id, {
  String? parentId,
  String? path,
  String? defaultTypeId,
}) => CategoryRow(
  id: id,
  profileId: 'p1',
  parentId: parentId,
  name: id,
  normalizedName: id,
  sortOrder: 0,
  level: path == null ? 0 : path.split('/').length - 1,
  path: path ?? id,
  defaultTypeId: defaultTypeId,
  createdAt: DateTime(2026, 8, 15),
);

void main() {
  test('тип берётся у самой ветки', () {
    final node = cat('places', defaultTypeId: 't-places');
    final found = CategoryTree.defaultTypeFor([node], node);

    expect(found?.typeId, 't-places');
    expect(found?.from.id, 'places');
  });

  test('без своего типа берётся тип предка', () {
    final root = cat('places', defaultTypeId: 't-places');
    final kid = cat('parks', parentId: 'places', path: 'places/parks');

    final found = CategoryTree.defaultTypeFor([root, kid], kid);

    expect(found?.typeId, 't-places');
    // Форма показывает, откуда взяла: «Тип взят из „places“».
    expect(found?.from.id, 'places');
  });

  test('ближний предок важнее дальнего', () {
    final root = cat('root', defaultTypeId: 't-root');
    final mid = cat(
      'mid',
      parentId: 'root',
      path: 'root/mid',
      defaultTypeId: 't-mid',
    );
    final leaf = cat('leaf', parentId: 'mid', path: 'root/mid/leaf');

    final found = CategoryTree.defaultTypeFor([root, mid, leaf], leaf);

    expect(found?.typeId, 't-mid');
    expect(found?.from.id, 'mid');
  });

  test('ветка без типов ничего не подсказывает', () {
    final root = cat('root');
    final kid = cat('kid', parentId: 'root', path: 'root/kid');

    expect(CategoryTree.defaultTypeFor([root, kid], kid), isNull);
  });

  test('совпадение названий больше ни на что не влияет', () {
    // Раньше «Фильмы» получали тип «Фильмы» просто по имени. Теперь связь
    // задаётся полем, и без него подсказки нет — зато она видна и правится.
    final node = cat('Фильмы');
    expect(CategoryTree.defaultTypeFor([node], node), isNull);
  });

  test('пропавший предок не мешает найти тип выше', () {
    // После частичного восстановления копии середина пути может исчезнуть.
    final root = cat('root', defaultTypeId: 't-root');
    final leaf = cat('leaf', parentId: 'mid', path: 'root/mid/leaf');

    expect(CategoryTree.defaultTypeFor([root, leaf], leaf)?.typeId, 't-root');
  });
}
