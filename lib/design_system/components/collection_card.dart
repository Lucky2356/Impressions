import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import 'app_card.dart';

/// Карточка подборки (ориентир YowBooks «Folder»): цветной тег, название,
/// прогресс-бар. Отдельный вариант «создать подборку» с пунктирной рамкой.
class CollectionCard extends StatelessWidget {
  const CollectionCard({
    super.key,
    required this.title,
    required this.tagLabel,
    required this.tagColor,
    required this.tagIcon,
    required this.progress,
    required this.progressLabel,
    this.selected = false,
    this.onTap,
  });

  final String title;
  final String tagLabel;
  final Color tagColor;
  final IconData tagIcon;

  /// 0..1.
  final double progress;
  final String progressLabel;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      onTap: onTap,
      selected: selected,
      padding: const EdgeInsets.all(AppDimens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(tagIcon, size: 15, color: tagColor),
              const SizedBox(width: AppDimens.space4),
              Flexible(
                child: Text(
                  tagLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.labelSmall?.copyWith(color: tagColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.titleMedium,
          ),
          const SizedBox(height: AppDimens.space16),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusPill),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 6,
              backgroundColor: c.surfaceMuted,
              valueColor: AlwaysStoppedAnimation(tagColor),
            ),
          ),
          const SizedBox(height: AppDimens.space8),
          Text(
            progressLabel,
            style: context.text.labelSmall?.copyWith(color: c.textMuted),
          ),
        ],
      ),
    );
  }
}
