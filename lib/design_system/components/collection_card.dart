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

/// Пунктирная карточка «создать подборку».
class NewCollectionCard extends StatelessWidget {
  const NewCollectionCard({super.key, required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return DottedBorderBox(
      color: c.accentPrimary.withValues(alpha: 0.5),
      radius: AppDimens.radiusLg,
      child: Material(
        color: c.accentSoft.withValues(alpha: 0.5),
        borderRadius: AppDimens.brLg,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppDimens.brLg,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: c.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: c.accentPrimary.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Icon(Icons.add_rounded, color: c.accentPrimary),
                ),
                const SizedBox(height: AppDimens.space8),
                Text(
                  label,
                  style: context.text.labelMedium?.copyWith(
                    color: c.accentPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Прямоугольник с пунктирной рамкой (для «создать подборку»).
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({
    super.key,
    required this.child,
    required this.color,
    this.radius = 16,
  });

  final Widget child;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRRectPainter(color: color, radius: radius),
      child: child,
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({required this.color, required this.radius});
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    const dash = 6.0, gap = 5.0;
    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        final len = (dist + dash).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(dist, len), paint);
        dist += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter old) =>
      old.color != color || old.radius != radius;
}
