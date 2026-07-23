import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';

/// Чип статуса (§3.4, §10). Статусы зависят от типа и задаются строкой,
/// поэтому чип универсальный: метка + иконка + приглушённый акцент.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    this.icon = Icons.circle_outlined,
    this.color,
    this.compact = false,
  });

  final String label;
  final IconData icon;
  final Color? color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accent = color ?? c.textSecondary;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppDimens.space8 : AppDimens.space12,
        vertical: compact ? AppDimens.space4 : AppDimens.space8,
      ),
      decoration: BoxDecoration(
        color: c.surfaceMuted,
        borderRadius: AppDimens.brPill,
        border: Border.all(color: c.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 13 : 15, color: accent),
          SizedBox(width: compact ? AppDimens.space4 : AppDimens.space8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.labelMedium?.copyWith(color: c.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
