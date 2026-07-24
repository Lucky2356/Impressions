import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import 'app_card.dart';
import 'sparkline.dart';

/// Одно число в строке сводки.
class SummaryItem {
  const SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.trend = const [],
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  /// Настоящая история значения. Пустая или из одной точки — графика нет.
  final List<double> trend;

  final VoidCallback? onTap;
}

/// Строка сводных чисел на главной.
///
/// Заменила три высокие плитки: на телефоне они занимали весь экран, а внутри
/// показывали одну цифру. Здесь то же самое умещается в одну полосу, и сразу
/// видно главное — записи.
class SummaryStrip extends StatelessWidget {
  const SummaryStrip({super.key, required this.items});

  final List<SummaryItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, cns) {
        // На узком экране числа встают в ряд без графиков, на широком —
        // остаётся место и под историю.
        final compact = cns.maxWidth < 560;
        return Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i != 0) const SizedBox(width: AppDimens.space12),
              Expanded(
                child: _Tile(item: items[i], compact: compact),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.item, required this.compact});

  final SummaryItem item;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // «Записей» и «7» стоят в разных строках и читались диктором порознь,
    // без связи друг с другом.
    return Semantics(
      button: item.onTap != null,
      label: '${item.label}: ${item.value}',
      excludeSemantics: true,
      child: AppCard(
        onTap: item.onTap,
        padding: const EdgeInsets.all(AppDimens.space12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(item.icon, size: 16, color: item.color),
                const SizedBox(width: AppDimens.space8),
                Expanded(
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.labelSmall?.copyWith(
                      color: c.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.space4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.value,
                  style: context.text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (!compact && item.trend.length > 1) ...[
                  const SizedBox(width: AppDimens.space12),
                  Expanded(
                    child: Sparkline(
                      values: item.trend,
                      color: item.color,
                      height: 24,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
