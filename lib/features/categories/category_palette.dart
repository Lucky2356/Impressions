import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/db/database.dart';
import '../../data/models/category_tree.dart';

/// Цвет ветки — одно правило на всё приложение.
///
/// Раньше цвет считался в четырёх местах по-разному, и в полках он брался по
/// номеру строки в показанном списке: при поиске один и тот же «Сыр» менял
/// цвет вместе с позицией. Здесь цвет зависит только от самой ветки.
///
/// Порядок такой:
/// 1. свой цвет, если его задали;
/// 2. цвет ближайшего предка, у которого он задан, — «как у родителя»;
/// 3. цвет, выведенный из корня ветки.
///
/// Наследование, а не свой случайный цвет каждому узлу: иначе «Продукты»,
/// «Колбасы» и «Варёные» получили бы три несвязанных цвета, и дерево стало бы
/// пёстрым шумом. При наследовании ветка читается как одна семья, а пустое
/// поле цвета получает внятный смысл.
class CategoryPalette {
  const CategoryPalette._();

  static Color colorOf(
    CategoryRow category,
    Iterable<CategoryRow> all,
    AppColors colors,
  ) {
    final own = category.color;
    if (own != null) return Color(own);

    final source = inheritedFrom(category, all);
    if (source != null) return Color(source.color!);

    // Корень ветки, а не сама категория: у соседних веток цвета разные, у
    // соседних подкатегорий — одинаковые.
    return colors.profileColorFor(CategoryTree.pathIds(category.path).first);
  }

  /// Ближайший предок с явно заданным цветом — от кого унаследован цвет.
  ///
  /// Нужен редактору: он показывает, откуда взялся нынешний цвет, если своего
  /// у ветки нет.
  static CategoryRow? inheritedFrom(
    CategoryRow category,
    Iterable<CategoryRow> all,
  ) {
    for (final node in CategoryTree.ancestorsOf(all, category).reversed) {
      if (node.color != null) return node;
    }
    return null;
  }
}
