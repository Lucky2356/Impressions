import 'package:flutter/material.dart';

import '../../core/domain/relation.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';

/// Чип отношения (§3.4, §10). Смысл несут и цвет, и иконка, и текст (§30).
class RelationChip extends StatelessWidget {
  const RelationChip({super.key, required this.relation, this.compact = false});

  final Relation relation;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context);
    final accent = relation.accent(c);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppDimens.space8 : AppDimens.space12,
        vertical: compact ? AppDimens.space4 : AppDimens.space8,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: AppDimens.brPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(relation.icon, size: compact ? 13 : 15, color: accent),
          SizedBox(width: compact ? AppDimens.space4 : AppDimens.space8),
          Flexible(
            child: Text(
              relation.label(l10n),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.labelMedium?.copyWith(color: accent),
            ),
          ),
        ],
      ),
    );
  }
}
