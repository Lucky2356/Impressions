import 'package:flutter/material.dart';

import '../../core/domain/relation.dart';
import '../../core/l10n/gen/app_localizations.dart';
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
    this.heroTag,
    this.visitCount = 1,
  });

  final String title;
  final String? subtitle;
  final List<String> categoryPath;
  final Relation? relation;
  final double? rating;

  /// Стадия записи, при необходимости с прогрессом: «Читаю · 3 серия из 12».
  ///
  /// Стоит рядом с отношением, а не вместо него: это разные вопросы — «дошли
  /// ли вы до этого» и «понравилось ли», — и книга, которую вы читаете и уже
  /// оценили, должна показывать оба ответа. В сетке места в нижней строке нет,
  /// поэтому там стадия лежит поверх обложки.
  final String? statusLabel;
  final String? imagePath;
  final Color? seedColor;

  /// Метка перелёта обложки в карточку записи — см. [CoverImage.heroTag].
  final String? heroTag;

  /// Сколько раз к записи возвращались (§10). Единицу не показываем: «был один
  /// раз» — это про все записи сразу, и пометка сообщала бы ноль сведений.
  final int visitCount;

  /// Как карточка называет себя экранному диктору.
  ///
  /// Одной фразой вместо россыпи отдельных строк: название, где лежит,
  /// отношение и оценка. Отношение и оценка нарисованы значками и числом —
  /// без подписи диктор прочитал бы их бессмысленно.
  String semanticsLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final parts = <String>[
      title,
      if (categoryPath.isNotEmpty) categoryPath.last,
      if (relation != null) relation!.label(l10n),
      if (rating != null) l10n.entryRatingOf(rating!.toStringAsFixed(1)),
      ?statusLabel,
      if (visitCount > 1) l10n.visitCount(visitCount),
    ];
    return parts.join(', ');
  }
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
  double textScale = 1.0,
}) {
  // Под текстом отведено фиксированное число точек, а его размер задаёт
  // система: при «Крупном шрифте» подписи не помещались и карточка
  // переполнялась. Обложка от размера шрифта не зависит, поэтому растёт
  // только текстовая часть.
  final content =
      (contentHeight ??
          (dense ? _cardContentHeightDense : _cardContentHeight)) *
      textScale.clamp(1.0, 3.0);
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
    // Экранный диктор читал карточку как набор несвязанных строк: путь,
    // название, значок отношения и число по отдельности. Здесь она называет
    // себя одной фразой.
    return Semantics(
      button: onTap != null,
      label: data.semanticsLabel(context),
      excludeSemantics: true,
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(_cardPadding),
        borderRadius: AppDimens.brMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Стадия поверх обложки: нижняя строка карточки занята отношением
            // и оценкой, а высота ячейки задана заранее — третий значок в неё
            // не влезает, и вырасти ей некуда.
            Stack(
              children: [
                CoverImage(
                  title: data.title,
                  imagePath: data.imagePath,
                  seedColor: data.seedColor,
                  borderRadius: AppDimens.brSm,
                  heroTag: data.heroTag,
                ),
                if (data.statusLabel != null)
                  Positioned(
                    left: AppDimens.space4,
                    top: AppDimens.space4,
                    right: AppDimens.space4,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: StatusChip(
                        label: data.statusLabel!,
                        compact: true,
                      ),
                    ),
                  ),
                if (data.visitCount > 1)
                  Positioned(
                    right: AppDimens.space4,
                    bottom: AppDimens.space4,
                    child: _VisitBadge(count: data.visitCount),
                  ),
              ],
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
                    child: RelationChip(
                      relation: data.relation!,
                      compact: true,
                    ),
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
      ),
    );
  }
}

/// Высота [EntryCardCompact] в сетке с фиксированной высотой ячейки.
///
/// Складывается из внутренних отступов и самого высокого содержимого — пути
/// категории, названия в две строки и строки метаданных. Экраны должны брать
/// это значение, а не подбирать своё: подобранное вручную оказалось на восемь
/// точек меньше нужного, и карточки с длинным названием переполнялись.
///
/// С 1.17.0 в строке метаданных стоят и отношение, и стадия, и оценка: на
/// узком экране они переносятся на вторую строку, и место под неё заложено
/// здесь.
const double entryCardCompactHeight = 136;

/// Сколько в этой высоте занимает текст: путь, название в две строки и строка
/// метаданных. Миниатюра и отступы от размера шрифта не зависят.
const double _entryCardCompactTextHeight = 88;

/// Высота компактной карточки с поправкой на системный масштаб шрифта.
///
/// По тому же правилу, что и [categoryShelfHeightFor]: высота ячейки задаётся
/// сеткой в точках, а размер текста — системой, и при «Крупном шрифте»
/// содержимое переставало помещаться.
double entryCardCompactHeightFor(double textScale) {
  final extra = (textScale - 1).clamp(0.0, 2.0);
  return entryCardCompactHeight + extra * _entryCardCompactTextHeight;
}

/// Компактная карточка записи (§3.4): строка с миниатюрой слева.
class EntryCardCompact extends StatelessWidget {
  const EntryCardCompact({super.key, required this.data, this.onTap});

  final EntryCardData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: onTap != null,
      label: data.semanticsLabel(context),
      excludeSemantics: true,
      child: AppCard(
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
                heroTag: data.heroTag,
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
                      // Здесь места хватает на всё: строка переносится, а
                      // высота карточки под неё уже заложена.
                      if (data.relation != null)
                        RelationChip(relation: data.relation!, compact: true),
                      if (data.statusLabel != null)
                        StatusChip(label: data.statusLabel!, compact: true),
                      if (data.rating != null)
                        RatingView(value: data.rating, compact: true),
                      if (data.visitCount > 1)
                        _VisitBadge(count: data.visitCount),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// «×3» — сколько раз к записи возвращались (§10).
///
/// Значком со стрелкой, а не словом: в строку метаданных рядом с отношением и
/// оценкой слово не помещается, а вопрос, на который отвечает пометка, —
/// «сюда ходили не один раз?».
class _VisitBadge extends StatelessWidget {
  const _VisitBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tooltip(
      message: AppLocalizations.of(context).visitCount(count),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: c.surfaceMuted,
          borderRadius: AppDimens.brPill,
          border: Border.all(color: c.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.replay_rounded, size: 12, color: c.textMuted),
            const SizedBox(width: 3),
            Text(
              '$count',
              style: context.text.labelSmall?.copyWith(color: c.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
