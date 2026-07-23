import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';

/// Показ оценки от 0 до 10 с шагом 0.5 (§10). Оценка необязательна.
/// Компактный числовой вид с иконкой — читаемо и не только цветом (§30).
class RatingView extends StatelessWidget {
  const RatingView({super.key, required this.value, this.compact = false});

  /// Значение 0..10 или null, если оценка не выставлена.
  final double? value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final v = value;
    if (v == null) {
      return Text(
        '—',
        style: context.text.labelMedium?.copyWith(color: c.textMuted),
      );
    }

    final text = v == v.roundToDouble()
        ? v.toStringAsFixed(0)
        : v.toStringAsFixed(1);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppDimens.space8 : AppDimens.space12,
        vertical: compact ? AppDimens.space2 : AppDimens.space4,
      ),
      decoration: BoxDecoration(
        color: c.sand.withValues(alpha: 0.16),
        borderRadius: AppDimens.brPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: compact ? 15 : 17, color: c.sand),
          const SizedBox(width: AppDimens.space4),
          Text(
            text,
            style:
                (compact ? context.text.labelMedium : context.text.titleMedium)
                    ?.copyWith(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
          ),
          if (!compact)
            Text(
              ' / 10',
              style: context.text.labelSmall?.copyWith(color: c.textMuted),
            ),
        ],
      ),
    );
  }
}
