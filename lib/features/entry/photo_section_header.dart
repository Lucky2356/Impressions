import 'package:flutter/material.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/theme_context.dart';
import 'photo_source.dart';

/// Шапка блока фотографий: название и кнопки добавления.
///
/// Одна на два места — форму быстрого добавления и карточку записи. Раньше
/// строка была написана в обеих по отдельности, и переполнялась она тоже
/// по отдельности: «Фотографии», кнопка камеры и «Добавить фото» вместе шире
/// телефона.
class PhotoSectionHeader extends StatelessWidget {
  const PhotoSectionHeader({
    super.key,
    required this.onPick,
    required this.onCapture,
  });

  /// Выбор файла или галереи. `null` — заняты, кнопка недоступна.
  final VoidCallback? onPick;

  /// Съёмка камерой. На компьютере камеры нет — кнопки тоже.
  final VoidCallback? onCapture;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, cns) {
        // Узкой строке подпись кнопки не нужна: значок с подсказкой говорит
        // то же самое, а название блока важнее — по нему понятно, где ты.
        //
        // Порог растёт вместе с системным шрифтом: при «Огромном» подпись
        // «Добавить фото» сама по себе шире строки телефона, и сжать её
        // некуда — кнопка не гнётся.
        final withLabel =
            cns.maxWidth >= 320 * MediaQuery.textScalerOf(context).scale(1);

        return Row(
          children: [
            Flexible(
              child: Text(
                l10n.photoSectionTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.titleMedium,
              ),
            ),
            const Spacer(),
            if (!PhotoSource.isDesktop)
              IconButton(
                tooltip: l10n.photoCapture,
                onPressed: onCapture,
                icon: const Icon(Icons.photo_camera_outlined),
              ),
            if (withLabel)
              TextButton.icon(
                onPressed: onPick,
                icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                label: Text(
                  l10n.photoAdd,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            else
              IconButton(
                tooltip: l10n.photoAdd,
                onPressed: onPick,
                icon: const Icon(Icons.add_photo_alternate_outlined),
              ),
          ],
        );
      },
    );
  }
}
