import 'package:flutter/material.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../design_system/design_system.dart';
import 'entry_card_data.dart';
import 'entry_providers.dart';

/// Лицо записи: обложка, название и короткая строка фактов.
///
/// До 1.20.0 карточка начиналась с крошек и служебного заголовка «Запись», а
/// обложка лежала где-то в середине, среди миниатюр. Между тем открывают
/// карточку ради вот этого — что это такое и как оно выглядит.
class EntryHero extends StatelessWidget {
  const EntryHero({
    super.key,
    required this.detail,
    required this.coverPath,
    required this.editable,
    this.onPickCategory,
  });

  final EntryDetail detail;

  /// Главная фотография записи; null — фотографий нет.
  final String? coverPath;

  final bool editable;
  final VoidCallback? onPickCategory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final object = detail.object;

    final facts = [
      detail.typeName,
      if (object.creator != null) object.creator!,
      if (object.year != null) '${object.year}',
    ].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Обложка во всю ширину и без заглушки: типографический прямоугольник
        // в половину экрана — это много пустоты, а перелёту из списка нужно
        // куда прилетать только тогда, когда лететь есть чему.
        if (coverPath case final path?) ...[
          CoverImage(
            title: object.title,
            imagePath: path,
            aspectRatio: 16 / 9,
            borderRadius: AppDimens.brLg,
            heroTag: entryHeroTag(detail.entry.id),
          ),
          const SizedBox(height: AppDimens.space16),
        ],

        // Крошки ведут туда, где запись лежит, и меняют категорию нажатием:
        // раньше переложить её можно было только правой кнопкой в каталоге.
        InkWell(
          onTap: editable ? onPickCategory : null,
          borderRadius: AppDimens.brSm,
          child: Row(
            children: [
              Expanded(
                child: Breadcrumbs(
                  crumbs: [
                    for (final name in detail.categoryPath) Crumb(name),
                    if (detail.categoryPath.isEmpty)
                      Crumb(l10n.quickAddNoCategory),
                  ],
                ),
              ),
              if (editable)
                Icon(
                  Icons.drive_file_move_outline,
                  size: 16,
                  color: c.textMuted,
                ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.space8),

        Text(object.title, style: context.text.displayMedium),

        // Оригинальное название под основным: «Twin Peaks» под «Твин Пикс».
        if (object.altTitle case final alt?) ...[
          const SizedBox(height: AppDimens.space2),
          Text(
            alt,
            style: context.text.titleMedium?.copyWith(color: c.textSecondary),
          ),
        ],

        const SizedBox(height: AppDimens.space4),
        Text(
          facts,
          style: context.text.bodyMedium?.copyWith(color: c.textSecondary),
        ),

        if (object.summary case final summary?) ...[
          const SizedBox(height: AppDimens.space12),
          Text(summary, style: context.text.bodyMedium),
        ],

        // Откуда запись взялась. Приложение помечало перенесённые записи с
        // самого начала и нигде этого не показывало.
        if (detail.recommendedBy case final who?) ...[
          const SizedBox(height: AppDimens.space12),
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 16,
                color: c.accentPrimary,
              ),
              const SizedBox(width: AppDimens.space8),
              Flexible(
                child: Text(
                  l10n.entryRecommendedBy(who),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall?.copyWith(
                    color: c.accentPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
