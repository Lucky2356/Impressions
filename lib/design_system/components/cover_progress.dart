import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import 'cover_image.dart';

/// Обложка с прогресс-баром и подписью снизу (ориентир YowBooks — ряд обложек
/// «сейчас читаю»). В нашем приложении — например, недавние записи с индикатором.
class CoverProgress extends StatelessWidget {
  const CoverProgress({
    super.key,
    required this.title,
    this.imagePath,
    this.seedColor,
    this.progress,
    this.leftLabel,
    this.rightLabel,
    this.onTap,
  });

  final String title;
  final String? imagePath;
  final Color? seedColor;

  /// 0..1 или null, если прогресс не показывается.
  final double? progress;
  final String? leftLabel;
  final String? rightLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accent = seedColor ?? c.accentPrimary;
    return InkWell(
      onTap: onTap,
      borderRadius: AppDimens.brMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CoverImage(title: title, imagePath: imagePath, seedColor: seedColor),
          if (progress != null) ...[
            const SizedBox(height: AppDimens.space8),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radiusPill),
              child: LinearProgressIndicator(
                value: progress!.clamp(0, 1),
                minHeight: 5,
                backgroundColor: c.surfaceMuted,
                valueColor: AlwaysStoppedAnimation(accent),
              ),
            ),
          ],
          if (leftLabel != null || rightLabel != null) ...[
            const SizedBox(height: AppDimens.space4),
            Row(
              children: [
                if (leftLabel != null)
                  Expanded(
                    child: Text(
                      leftLabel!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.labelSmall?.copyWith(
                        color: c.textMuted,
                      ),
                    ),
                  ),
                if (rightLabel != null)
                  Text(
                    rightLabel!,
                    style: context.text.labelSmall?.copyWith(
                      color: c.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
