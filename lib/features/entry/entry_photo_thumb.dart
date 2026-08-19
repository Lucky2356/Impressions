import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';

/// Миниатюра снимка в полосе фотографий записи.
///
/// Вынесена из [EntryPhotos]: с подписями и перетаскиванием тот файл перевалил
/// за четыреста строк, а чистку файлов-переростков откатывать нельзя.
class PhotoThumb extends StatelessWidget {
  const PhotoThumb({
    super.key,
    required this.path,
    required this.caption,
    required this.isCover,
    required this.onRemove,
    required this.onOpen,
    required this.onMakeCover,
  });

  final String? path;

  /// Подпись к снимку; показывается значком — целиком её видно в просмотре.
  final String? caption;

  /// Этот снимок показывается в каталоге и на главной.
  final bool isCover;

  final VoidCallback onRemove;
  final VoidCallback onOpen;

  /// null — снимок уже обложка, назначать нечего.
  final VoidCallback? onMakeCover;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context);
    return Stack(
      children: [
        InkWell(
          onTap: onOpen,
          borderRadius: AppDimens.brMd,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: AppDimens.brMd,
              border: isCover
                  ? Border.all(color: c.accentPrimary, width: 2)
                  : null,
            ),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: 108,
              height: 108,
              // Ровная плитка лежит фоном: спрашивать диск о каждом снимке на
              // каждую перерисовку карточки записи незачем.
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: c.surfaceMuted),
                  if (path != null)
                    Image.file(
                      File(path!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                ],
              ),
            ),
          ),
        ),
        // Обложка видна в списках, поэтому выбирать её должен человек, а не
        // порядок добавления снимков.
        Positioned(
          bottom: 2,
          left: 2,
          child: Tooltip(
            message: isCover ? l10n.photoIsCover : l10n.photoMakeCover,
            child: Material(
              color: c.surface.withValues(alpha: 0.85),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onMakeCover,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    isCover ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 14,
                    color: isCover ? c.accentPrimary : c.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Подписанный снимок помечен: иначе подпись видна только тому, кто
        // догадался открыть просмотр.
        if (caption != null)
          Positioned(
            bottom: 2,
            right: 2,
            child: Tooltip(
              message: caption!,
              child: Material(
                color: c.surface.withValues(alpha: 0.85),
                shape: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.subtitles_outlined,
                    size: 14,
                    color: c.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          top: 2,
          right: 2,
          child: Tooltip(
            message: l10n.photoRemove,
            child: Material(
              color: c.surface.withValues(alpha: 0.85),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onRemove,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: c.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
