import 'package:flutter/widgets.dart';

import 'app_dimens.dart';

/// Класс ширины окна. Один порядок величин — одна раскладка.
enum LayoutSize {
  /// Телефон, узкое окно.
  compact,

  /// Планшет, половина экрана Full HD.
  medium,

  /// Full HD и WQHD в полный экран.
  expanded,

  /// 4K и сверхширокие мониторы.
  ultra,
}

/// Производные величины раскладки, зависящие от разрешения (§3.5).
///
/// Windows масштабирует логические пиксели по DPI, поэтому 4K при 150 %
/// приходит как ~2560 логических точек, а при 100 % — как 3840. Оба случая
/// должны выглядеть соразмерно: на широком окне растёт не размер карточек,
/// а их количество, при этом текст не должен теряться в пустоте.
@immutable
class AppLayout {
  const AppLayout({
    required this.size,
    required this.width,
    required this.gutter,
    required this.contentMaxWidth,
    required this.gridTileWidth,
    required this.sidebarWidth,
    required this.scale,
  });

  final LayoutSize size;
  final double width;

  /// Горизонтальный отступ содержимого экрана.
  final double gutter;

  /// Предельная ширина колонки контента — на 4K текст не растягивается
  /// на весь экран, а остаётся читаемым.
  final double contentMaxWidth;

  /// Целевая ширина ячейки сетки каталога при крупном режиме.
  final double gridTileWidth;

  final double sidebarWidth;

  /// Множитель для размеров, растущих вместе с разрешением.
  final double scale;

  /// Ширина панели дерева категорий на широком экране.
  double get treePaneWidth => switch (size) {
    LayoutSize.ultra => 380,
    _ => 320,
  };

  bool get isCompact => size == LayoutSize.compact;
  bool get isWide => size == LayoutSize.expanded || size == LayoutSize.ultra;
  bool get isUltra => size == LayoutSize.ultra;

  /// Число колонок сетки под целевую ширину ячейки.
  int columnsFor(double available, {required double tileWidth, int min = 2}) {
    final usable = available - gutter * 2;
    if (usable <= 0) return min;
    final raw = ((usable + AppDimens.space16) / (tileWidth + AppDimens.space16))
        .floor();
    return raw.clamp(min, 10);
  }

  static AppLayout resolve(double width) {
    if (width < AppDimens.breakpointCompact) {
      return AppLayout(
        size: LayoutSize.compact,
        width: width,
        gutter: AppDimens.space16,
        contentMaxWidth: double.infinity,
        gridTileWidth: 150,
        sidebarWidth: 0,
        scale: 1,
      );
    }
    if (width < AppDimens.breakpointExpanded) {
      return AppLayout(
        size: LayoutSize.medium,
        width: width,
        gutter: AppDimens.space20,
        contentMaxWidth: double.infinity,
        gridTileWidth: 168,
        sidebarWidth: 0,
        scale: 1,
      );
    }
    if (width < AppDimens.breakpointUltra) {
      return AppLayout(
        size: LayoutSize.expanded,
        width: width,
        gutter: AppDimens.space24,
        contentMaxWidth: AppDimens.maxContentWidth,
        gridTileWidth: 184,
        sidebarWidth: AppDimens.navRailWidth,
        scale: 1,
      );
    }
    // 4K и шире: панель и текст немного крупнее, сетка плотнее по смыслу —
    // ячейки чуть больше, но их всё равно помещается заметно больше.
    return AppLayout(
      size: LayoutSize.ultra,
      width: width,
      gutter: AppDimens.space32,
      contentMaxWidth: AppDimens.maxContentWidthUltra,
      gridTileWidth: 216,
      sidebarWidth: AppDimens.navRailWidthUltra,
      scale: 1.15,
    );
  }

  static AppLayout of(BuildContext context) =>
      resolve(MediaQuery.sizeOf(context).width);

  @override
  bool operator ==(Object other) =>
      other is AppLayout && other.size == size && other.width == width;

  @override
  int get hashCode => Object.hash(size, width);
}

extension AppLayoutContext on BuildContext {
  /// Раскладка для текущего размера окна.
  AppLayout get layout => AppLayout.of(this);
}
