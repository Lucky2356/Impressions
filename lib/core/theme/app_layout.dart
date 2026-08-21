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

/// Как раздел занимает ширину окна.
enum ContentWidth {
  /// Читают строками: колонка постоянной ширины по центру. Настройки, карточка
  /// записи, итоги года, сводка.
  reading,

  /// Смотрят сетками: раздел занимает всё окно, и на широком экране растёт
  /// число ячеек, а не их размер. Каталог, категории, подборки, архив.
  full,
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
    required this.gridTileWidth,
    required this.sidebarWidth,
    required this.scale,
  });

  final LayoutSize size;
  final double width;

  /// Горизонтальный отступ содержимого экрана.
  final double gutter;

  /// Целевая ширина ячейки сетки каталога при крупном режиме.
  final double gridTileWidth;

  final double sidebarWidth;

  /// Множитель для размеров, растущих вместе с разрешением.
  final double scale;

  /// Ширина панели дерева категорий на широком экране.
  ///
  /// В шапке панели теперь стоит и переключатель «полки/дерево», поэтому
  /// прежних 320 точек не хватало: заголовок «Категории» переносился по слогам.
  double get treePaneWidth => switch (size) {
    LayoutSize.ultra => 420,
    _ => 366,
  };

  bool get isWide => size == LayoutSize.expanded || size == LayoutSize.ultra;

  /// Ширина колонки, которую читают строками.
  ///
  /// Умножается на [scale], а не на ширину окна: колонка должна расти вместе
  /// с кеглем, иначе крупный шрифт помещает в строку меньше слов, чем мелкий.
  double get readingWidth => AppDimens.readingWidth * scale;

  /// Предел ширины для раздела с таким способом занимать окно.
  double maxWidthFor(ContentWidth width) =>
      width == ContentWidth.full ? double.infinity : readingWidth;

  /// Число колонок сетки под целевую ширину ячейки.
  ///
  /// [available] — ширина, доставшаяся самой сетке: боковые отступы вычитает
  /// вызывающая сторона, потому что у одних сеток они есть, а у других нет.
  /// [spacing] — промежуток между ячейками, тот же, что передан делегату:
  /// раньше здесь всегда стояло 16, а каталог рисовал 12, и колонок выходило
  /// на одну меньше, чем помещалось.
  ///
  /// Потолок [max] нужен сеткам с заведомо коротким списком: раскладывать
  /// восемь плиток статистики на шестнадцать колонок незачем. Общего потолка
  /// нет намеренно — на широком окне должно расти число ячеек, а не их размер,
  /// а прежний `clamp(min, 10)` на 4K растягивал десять карточек вдвое.
  int columnsFor(
    double available, {
    required double tileWidth,
    int min = 2,
    int max = 99,
    double spacing = AppDimens.space16,
  }) {
    if (available <= 0) return min;
    final raw = ((available + spacing) / (tileWidth + spacing)).floor();
    return raw.clamp(min, max);
  }

  static AppLayout resolve(double width) {
    if (width < AppDimens.breakpointCompact) {
      return AppLayout(
        size: LayoutSize.compact,
        width: width,
        gutter: AppDimens.space16,
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
