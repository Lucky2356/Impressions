import 'package:flutter/material.dart';

import '../../core/domain/relation.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import 'app_card.dart';
import 'cover_image.dart';
import 'rating_view.dart';
import 'relation_chip.dart';
import 'status_chip.dart';

/// Презентационные данные карточки записи. Слой данных (Drift) отображается
/// в эту модель, чтобы дизайн-компоненты не зависели от БД.
class EntryCardData {
  const EntryCardData({
    required this.title,
    this.subtitle,
    this.categoryPath = const [],
    this.relation,
    this.rating,
    this.statusLabel,
    this.imagePath,
    this.seedColor,
  });

  final String title;
  final String? subtitle;
  final List<String> categoryPath;
  final Relation? relation;
  final double? rating;
  final String? statusLabel;
  final String? imagePath;
  final Color? seedColor;
}

/// Вычисляет соотношение сторон ячейки сетки так, чтобы [EntryCard] помещалась
/// целиком.
///
/// Высота карточки складывается из обложки (3:4 от внутренней ширины) и блока
/// текста с чипами. Считать её из фактической ширины ячейки надёжнее, чем
/// подбирать константу: при другом числе колонок карточка переполнялась.
double entryCardAspectRatio({
  required double availableWidth,
  required int columns,
  double outerPadding = AppDimens.space20 * 2,
  double spacing = AppDimens.space16,
  double cardPadding = AppDimens.space12 * 2,
  double contentHeight = 132,
}) {
  final usable = availableWidth - outerPadding - spacing * (columns - 1);
  final cellWidth = (usable / columns).clamp(80.0, double.infinity);
  final coverHeight = (cellWidth - cardPadding) * 4 / 3;
  final totalHeight = coverHeight + cardPadding + contentHeight;
  return cellWidth / totalHeight;
}

/// Крупная редакционная карточка записи (§3.4). Выразительная обложка сверху,
/// затем путь категорий, название и метаданные.
class EntryCard extends StatelessWidget {
  const EntryCard({super.key, required this.data, this.onTap});

  final EntryCardData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppDimens.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CoverImage(
            title: data.title,
            imagePath: data.imagePath,
            seedColor: data.seedColor,
          ),
          const SizedBox(height: AppDimens.space12),
          if (data.categoryPath.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.space4),
              child: Text(
                data.categoryPath.join(' / '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.labelSmall?.copyWith(color: c.textMuted),
              ),
            ),
          Text(
            data.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.text.titleLarge,
          ),
          if (data.subtitle != null) ...[
            const SizedBox(height: AppDimens.space2),
            Text(
              data.subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ],
          const SizedBox(height: AppDimens.space12),
          Wrap(
            spacing: AppDimens.space8,
            runSpacing: AppDimens.space8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (data.relation != null)
                RelationChip(relation: data.relation!, compact: true),
              if (data.rating != null)
                RatingView(value: data.rating, compact: true),
              if (data.statusLabel != null)
                StatusChip(label: data.statusLabel!, compact: true),
            ],
          ),
        ],
      ),
    );
  }
}

/// Компактная карточка записи (§3.4): строка с миниатюрой слева.
class EntryCardCompact extends StatelessWidget {
  const EntryCardCompact({super.key, required this.data, this.onTap});

  final EntryCardData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppDimens.space12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: CoverImage(
              title: data.title,
              imagePath: data.imagePath,
              seedColor: data.seedColor,
              aspectRatio: 3 / 4,
              borderRadius: AppDimens.brSm,
            ),
          ),
          const SizedBox(width: AppDimens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data.categoryPath.isNotEmpty)
                  Text(
                    data.categoryPath.join(' / '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.labelSmall?.copyWith(
                      color: c.textMuted,
                    ),
                  ),
                Text(
                  data.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleMedium,
                ),
                const SizedBox(height: AppDimens.space8),
                Wrap(
                  spacing: AppDimens.space8,
                  runSpacing: AppDimens.space4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (data.relation != null)
                      RelationChip(relation: data.relation!, compact: true),
                    if (data.rating != null)
                      RatingView(value: data.rating, compact: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
