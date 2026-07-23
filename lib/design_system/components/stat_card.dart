import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import 'app_card.dart';
import 'sparkline.dart';

/// Карточка статистики (ориентир YowBooks): заголовок, крупное число с
/// единицей, мини-график и подпись. Используется на главной.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.trend,
    required this.trendColor,
    this.unit,
    this.subtitle,
  });

  final String title;
  final String value;
  final String? unit;
  final String? subtitle;
  final List<double> trend;
  final Color trendColor;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      padding: const EdgeInsets.all(AppDimens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: context.text.bodySmall?.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: AppDimens.space12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(value, style: context.text.displayMedium),
                    if (unit != null) ...[
                      const SizedBox(width: AppDimens.space4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          unit!,
                          style: context.text.bodySmall?.copyWith(
                            color: c.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(
                width: 88,
                child: Sparkline(values: trend, color: trendColor, height: 40),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppDimens.space8),
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.labelSmall?.copyWith(color: c.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}
