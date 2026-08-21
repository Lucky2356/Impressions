import 'package:flutter/material.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';

/// Заглушка на месте снимка, файла которого нет.
///
/// Ставится там, где под картинкой нет своей подложки: пустая серая плитка
/// неотличима от пустого снимка, и пропажу файла было видно только по
/// проверке целостности. Обложки записей и значки профилей рисуют под собой
/// название и инициалы — им заглушка не нужна.
class MissingImage extends StatelessWidget {
  const MissingImage({super.key, this.withLabel = true});

  /// Подпись рядом со значком: в ячейке меньше сотни точек она не помещается.
  final bool withLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return ColoredBox(
      color: c.surfaceMuted,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image_outlined, size: 20, color: c.textMuted),
            if (withLabel) ...[
              const SizedBox(height: AppDimens.space4),
              Text(
                l10n.imageMissing,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.text.labelSmall?.copyWith(color: c.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
