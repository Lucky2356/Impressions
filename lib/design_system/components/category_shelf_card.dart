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
    this.selected = false,
    this.onTap,
    this.onShowEntries,
    this.showEntriesTooltip,
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

  final bool selected;
  final VoidCallback? onTap;

  /// Показать записи самой полки. Нажатие на карточку с подкатегориями уводит
  /// вглубь, поэтому до собственных записей нужен отдельный ход.
  final VoidCallback? onShowEntries;
  final String? showEntriesTooltip;

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
                  if (onShowEntries != null)
                    IconButton(
                      onPressed: onShowEntries,
                      visualDensity: VisualDensity.compact,
                      tooltip: showEntriesTooltip,
                      icon: Icon(
                        Icons.format_list_bulleted_rounded,
                        size: 18,
                        color: c.textSecondary,
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
