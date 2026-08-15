import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/models/category_tree.dart';

/// Категория без базы: помощнику нужен только путь и родитель.
CategoryRow cat(String id, {String? parentId, String? path, int level = 0}) =>
    CategoryRow(
      id: id,
      profileId: 'p1',
      parentId: parentId,
      name: id,
      normalizedName: id,
      sortOrder: 0,
      level: level,
      path: path ?? id,
      createdAt: DateTime(2026, 8, 15),
    );

void main() {
  // Продукты / Колбасы / Варёные, рядом отдельная ветка Места.
  final products = cat('products');
  final sausages = cat(
    'sausages',
    parentId: 'products',
    path: 'products/sausages',
    level: 1,
  );
  final boiled = cat(
    'boiled',
    parentId: 'sausages',
    path: 'products/sausages/boiled',
    level: 2,
  );
  final places = cat('places');
  final all = [products, sausages, boiled, places];

  test('ветка — это сама категория и всё, что под ней', () {
    expect(CategoryTree.branchIds(all, 'products'), [
      'products',
      'sausages',
      'boiled',
    ]);
    expect(CategoryTree.branchIds(all, 'sausages'), ['sausages', 'boiled']);
    expect(CategoryTree.branchIds(all, 'boiled'), ['boiled']);
  });

  test('соседняя ветка в отбор не попадает', () {
    expect(CategoryTree.branchIds(all, 'places'), ['places']);
  });

  test('ветка несуществующей категории пуста, а не «весь профиль»', () {
    // Иначе снятая категория молча превратила бы отбор в его отсутствие.
    expect(CategoryTree.branchOf(all, 'нет такой'), isEmpty);
  });

  test('префикс пути не путает похожие идентификаторы', () {
    // Без разделителя «products» поймал бы «products2» — тот же префикс строки,
    // но соседний корень.
    final other = cat('products2');
    expect(
      CategoryTree.branchIds([...all, other], 'products'),
      isNot(contains('products2')),
    );
  });

  test('предки идут от корня к родителю, без самой категории', () {
    expect(
      [for (final c in CategoryTree.ancestorsOf(all, boiled)) c.id],
      ['products', 'sausages'],
    );
    expect(CategoryTree.ancestorsOf(all, products), isEmpty);
  });

  test('крошки заканчиваются самой категорией', () {
    expect(
      [for (final c in CategoryTree.breadcrumbOf(all, boiled)) c.id],
      ['products', 'sausages', 'boiled'],
    );
  });

  test('пропавший предок не ломает путь', () {
    // После частичного восстановления копии середина пути может исчезнуть:
    // крошки должны показать, что осталось, а не упасть.
    expect(
      [
        for (final c in CategoryTree.ancestorsOf([products, boiled], boiled))
          c.id,
      ],
      ['products'],
    );
  });

  test('дети берутся по родителю, null — корневые', () {
    expect(
      [for (final c in CategoryTree.childrenOf(all, 'products')) c.id],
      ['sausages'],
    );
    expect(
      [for (final c in CategoryTree.childrenOf(all, null)) c.id],
      ['products', 'places'],
    );
  });

  test('сегменты пути включают саму категорию', () {
    expect(CategoryTree.pathIds(boiled.path), [
      'products',
      'sausages',
      'boiled',
    ]);
  });
}
