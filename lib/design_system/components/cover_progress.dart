import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import 'cover_image.dart';

/// Высота подписей под обложкой, из которой считается соотношение сторон
/// ячейки — см. [coverProgressAspectRatio].
///
/// Складывается из отступа и полосы прогресса (8 + 5), отступа и названия
/// в одну строку (8 + 14 × 1.2), отступа и строки метаданных (4 + 12 × 1.2) —
/// это 56 точек. Округлено вверх: метрики шрифта дают доли точки, а
/// переполнение сетки стоит дороже нескольких точек пустоты.
const double _contentHeight = 62;

/// Соотношение сторон ячейки сетки, при котором [CoverProgress] помещается
/// целиком.
///
/// По тому же правилу, что и `entryCardAspectRatio` у карточки записи: высота
/// обложки растёт вместе с шириной ячейки, а подписи под ней занимают
/// фиксированное число точек. Одна константа поэтому не годится — на узкой
/// ячейке текст занимает пропорционально больше, и карточка переполняется.
///
/// Поправку на системный масштаб шрифта делает сетка: она делит полученное
/// соотношение на масштаб.
double coverProgressAspectRatio({
  required double availableWidth,
  required int columns,
  double spacing = AppDimens.space16,
}) {
  final usable = availableWidth - spacing * (columns - 1);
  final cellWidth = (usable / columns).clamp(80.0, double.infinity);
  final coverHeight = cellWidth * 4 / 3;
  return cellWidth / (coverHeight + _contentHeight);
}

/// Обложка с прогресс-баром и подписью снизу (ориентир YowBooks — ряд обложек
/// «сейчас читаю»). В нашем приложении — например, недавние записи с индикатором.
///
/// Название стоит под обложкой отдельной строкой. Раньше [title] уходил только
/// в заглушку [CoverImage] — на букве вместо картинки, — а подписью снизу были
/// категория и оценка. У записи без обложки главная отвечала на вопрос «в какой
/// категории», а не «что это».
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
          const SizedBox(height: AppDimens.space8),
          // Одна строка, а не две как в каталоге: полоса недавнего
          // просматривается взглядом, и высота ячейки заложена под неё.
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.titleMedium?.copyWith(
              fontSize: 14,
              height: 1.2,
            ),
          ),
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
