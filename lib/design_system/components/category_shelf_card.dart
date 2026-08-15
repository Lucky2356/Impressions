import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import 'app_card.dart';

/// Карточка-полка категории.
///
/// Экран категорий долго был строчным списком: по нему нельзя было ни понять,
/// что внутри, ни отличить полную полку от пустой. Здесь категория выглядит
/// как полка — со своим цветом, значком, числом записей и несколькими
/// фотографиями из ветки.
class CategoryShelfCard extends StatelessWidget {
  const CategoryShelfCard({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
    required this.count,
    required this.countLabel,
    this.childNames = const [],
    this.covers = const [],
    this.coverPath,
    this.selected = false,
    this.onTap,
  });

  final String name;
  final IconData icon;
  final Color color;
  final int count;

  /// Готовая подпись со склонением: «12 записей».
  final String countLabel;

  /// Названия подкатегорий — показываются под заголовком.
  final List<String> childNames;

  /// Пути к миниатюрам записей из ветки.
  final List<String> covers;

  /// Закреплённая обложка ветки — в отличие от [covers], её выбрали руками.
  final String? coverPath;

  final bool selected;

  /// Нажатие открывает ветку — и её подкатегории, и её записи сразу. Отдельной
  /// кнопки «показать записи» больше нет: раньше она была нужна потому, что
  /// нажатие на карточку с подкатегориями уводило вглубь мимо них.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Пропавший файл рисуется пустым местом, а не отсеивается проверкой:
    // `existsSync` здесь стоял до трёх раз на карточку, и вся сетка полок
    // ходила на диск при каждой перерисовке.
    final shown = covers.take(3).toList();
    final pixels = (36 * MediaQuery.devicePixelRatioOf(context)).round();

    // Полка называет себя одной фразой: имя и сколько внутри. Иначе диктор
    // читал цвет, значок и число как несвязанные куски.
    return Semantics(
      button: onTap != null,
      label: '$name, $countLabel',
      excludeSemantics: true,
      child: AppCard(
        onTap: onTap,
        selected: selected,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Цветная шапка: полка узнаётся по цвету раньше, чем прочитано
            // название.
            Container(
              height: 72,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.28),
                    color.withValues(alpha: 0.10),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              // Закреплённая обложка — фоном под цветом, а не вместо него:
              // цвет остаётся тем, по чему полка узнаётся издалека.
              foregroundDecoration: coverPath == null
                  ? null
                  : BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(File(coverPath!)),
                        fit: BoxFit.cover,
                        opacity: 0.5,
                        onError: (_, _) {},
                      ),
                    ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space12,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c.surface.withValues(alpha: 0.85),
                      borderRadius: AppDimens.brSm,
                    ),
                    child: Icon(icon, size: 20, color: color),
                  ),
                  const Spacer(),
                  // Фотографии из ветки: сразу видно, что полка не пустая.
                  for (final path in shown)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: ClipRRect(
                        borderRadius: AppDimens.brSm,
                        child: Image.file(
                          File(path),
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          cacheWidth: pixels,
                          errorBuilder: (_, _, _) =>
                              const SizedBox(width: 36, height: 36),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimens.space12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    countLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.labelSmall?.copyWith(
                      color: count == 0 ? c.textMuted : color,
                      fontWeight: count == 0
                          ? FontWeight.w500
                          : FontWeight.w600,
                    ),
                  ),
                  if (childNames.isNotEmpty) ...[
                    const SizedBox(height: AppDimens.space8),
                    Text(
                      childNames.join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.labelSmall?.copyWith(
                        color: c.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Высота карточки-полки: шапка, название, счётчик и строка подкатегорий.
/// Вынесена в константу, потому что от неё считается размер ячейки сетки.
const double categoryShelfHeight = 158;

/// Сколько в этой высоте занимает текст: название, счётчик и подкатегории.
/// Шапка с цветом и фотографиями от размера шрифта не зависит.
const double _categoryShelfTextHeight = 56;

/// Высота карточки-полки с поправкой на системный масштаб шрифта.
///
/// Высота ячейки задаётся сеткой в точках, а размер текста — системой: при
/// «Крупном шрифте» подписи переставали помещаться и карточка переполнялась.
double categoryShelfHeightFor(double textScale) {
  final extra = (textScale - 1).clamp(0.0, 2.0);
  return categoryShelfHeight + extra * _categoryShelfTextHeight;
}
