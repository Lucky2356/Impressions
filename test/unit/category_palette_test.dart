import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/core/theme/app_colors.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/features/categories/category_palette.dart';

/// Цвет ветки.
///
/// Раньше он считался в четырёх местах по-разному, и на полках брался по
/// номеру строки в показанном списке: при поиске один и тот же «Сыр» менял
/// цвет вместе с позицией.
CategoryRow cat(String id, {String? parentId, String? path, int? color}) =>
    CategoryRow(
      id: id,
      profileId: 'p1',
      parentId: parentId,
      name: id,
      normalizedName: id,
      color: color,
      sortOrder: 0,
      level: path == null ? 0 : path.split('/').length - 1,
      path: path ?? id,
      createdAt: DateTime(2026, 8, 15),
    );

void main() {
  const colors = AppColors.light;

  test('свой цвет важнее всего', () {
    final node = cat('c', color: 0xFF112233);
    expect(
      CategoryPalette.colorOf(node, [node], colors).toARGB32(),
      0xFF112233,
    );
  });

  test('без своего цвета берётся цвет ближайшего предка', () {
    final root = cat('root', color: 0xFF445566);
    final mid = cat('mid', parentId: 'root', path: 'root/mid');
    final leaf = cat('leaf', parentId: 'mid', path: 'root/mid/leaf');
    final all = [root, mid, leaf];

    expect(CategoryPalette.colorOf(leaf, all, colors).toARGB32(), 0xFF445566);
    expect(CategoryPalette.inheritedFrom(leaf, all)?.id, 'root');
  });

  test('ближний предок важнее дальнего', () {
    final root = cat('root', color: 0xFF445566);
    final mid = cat(
      'mid',
      parentId: 'root',
      path: 'root/mid',
      color: 0xFF778899,
    );
    final leaf = cat('leaf', parentId: 'mid', path: 'root/mid/leaf');
    final all = [root, mid, leaf];

    expect(CategoryPalette.colorOf(leaf, all, colors).toARGB32(), 0xFF778899);
    expect(CategoryPalette.inheritedFrom(leaf, all)?.id, 'mid');
  });

  test('вся ветка без заданных цветов — одного цвета', () {
    // Иначе «Продукты», «Колбасы» и «Варёные» получили бы три несвязанных
    // цвета, и дерево стало бы пёстрым шумом.
    final root = cat('root');
    final mid = cat('mid', parentId: 'root', path: 'root/mid');
    final leaf = cat('leaf', parentId: 'mid', path: 'root/mid/leaf');
    final all = [root, mid, leaf];

    final tone = CategoryPalette.colorOf(root, all, colors);
    expect(CategoryPalette.colorOf(mid, all, colors), tone);
    expect(CategoryPalette.colorOf(leaf, all, colors), tone);
  });

  test('цвет выводится из корня ветки, а не из самой категории', () {
    // Иначе подкатегории одной ветки разошлись бы по цветам, а сама ветка
    // перестала бы читаться как целое.
    final root = cat('root');
    final mid = cat('mid', parentId: 'root', path: 'root/mid');
    final loneMid = cat('mid', path: 'mid');

    expect(
      CategoryPalette.colorOf(mid, [root, mid], colors),
      CategoryPalette.colorOf(root, [root, mid], colors),
    );
    // Та же категория вне ветки берёт цвет уже от себя.
    expect(
      CategoryPalette.colorOf(loneMid, [loneMid], colors),
      colors.profileColorFor('mid'),
    );
  });

  test('цвет не зависит от порядка в списке', () {
    final a = cat('a');
    final b = cat('b');
    expect(
      CategoryPalette.colorOf(b, [a, b], colors),
      CategoryPalette.colorOf(b, [b, a], colors),
    );
  });
}
