import 'package:flutter/material.dart';

import '../../core/domain/relation.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import 'app_card.dart';
import 'cover_image.dart';
import 'rating_view.dart';
import 'relation_chip.dart';

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

/// Высота текстового блока карточки: путь категории, название в две строки и
/// строка метаданных. Вынесена в константу, потому что от неё считается
/// соотношение сторон ячейки сетки.
const double _cardContentHeight = 82;
const double _cardContentHeightDense = 68;
const double _cardPadding = AppDimens.space8;

/// Вычисляет соотношение сторон ячейки сетки так, чтобы [EntryCard] помещалась
/// целиком.
///
/// Высота карточки складывается из обложки (3:4 от внутренней ширины) и блока
/// текста. Считать её из фактической ширины ячейки надёжнее, чем подбирать
/// константу: при другом числе колонок карточка переполнялась.
double entryCardAspectRatio({
  required double availableWidth,
  required int columns,
  double outerPadding = AppDimens.space24 * 2,
  double spacing = AppDimens.space12,
  double cardPadding = _cardPadding * 2,
  bool dense = false,
  double? contentHeight,
}) {
  final content =
      contentHeight ?? (dense ? _cardContentHeightDense : _cardContentHeight);
  final usable = availableWidth - outerPadding - spacing * (columns - 1);
  final cellWidth = (usable / columns).clamp(80.0, double.infinity);
  final coverHeight = (cellWidth - cardPadding) * 4 / 3;
  final totalHeight = coverHeight + cardPadding + content;
  return cellWidth / totalHeight;
}

/// Карточка записи в сетке каталога (§3.4): обложка сверху, под ней путь
/// категорий, название и метаданные.
///
/// Карточка намеренно компактная — на экране должно помещаться заметно больше
/// записей, но название, отношение и оценка остаются видимыми без открытия.
class EntryCard extends StatelessWidget {
  const EntryCard({
    super.key,
    required this.data,
    this.onTap,
    this.dense = false,
  });

  final EntryCardData data;
  final VoidCallback? onTap;

  /// Плотный режим: без пути категории и подзаголовка.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final showPath = !dense && data.categoryPath.isNotEmpty;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(_cardPadding),
      borderRadius: AppDimens.brMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CoverImage(
            title: data.title,
            imagePath: data.imagePath,
            seedColor: data.seedColor,
            borderRadius: AppDimens.brSm,
          ),
          const SizedBox(height: AppDimens.space8),
          if (showPath)
            Text(
              data.categoryPath.last,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.labelSmall?.copyWith(
                color: c.textMuted,
                fontSize: 11,
              ),
            ),
          Text(
            data.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.text.titleMedium?.copyWith(
              fontSize: 14,
              height: 1.2,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              if (data.relation != null)
                Flexible(
                  child: RelationChip(relation: data.relation!, compact: true),
                ),
              if (data.rating != null) ...[
                if (data.relation != null)
                  const SizedBox(width: AppDimens.space4),
                RatingView(value: data.rating, compact: true),
              ],
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
