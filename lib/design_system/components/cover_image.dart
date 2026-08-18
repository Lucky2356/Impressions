import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';

/// Обложка объекта. Крупные обложки — важная часть визуального языка (§3).
/// При отсутствии фото рисуется спокойная типографическая заглушка на основе
/// названия (работа без фотографии — §30), а не пустой прямоугольник.
class CoverImage extends StatelessWidget {
  const CoverImage({
    super.key,
    required this.title,
    this.imagePath,
    this.aspectRatio = 3 / 4,
    this.seedColor,
    this.borderRadius = AppDimens.brMd,
    this.heroTag,
  });

  final String title;
  final String? imagePath;
  final double aspectRatio;
  final Color? seedColor;
  final BorderRadius borderRadius;

  /// Метка перелёта в карточку записи. `null` — обложка стоит на месте.
  ///
  /// Метка обязана быть единственной на экране, иначе кадр падает. Поэтому её
  /// задают только там, где запись заведомо встречается один раз: в каталоге,
  /// в ветке, в составе подборки, в «Хочу попробовать». На главной одна и та
  /// же запись попадает и в «Продолжить начатое», и в «Недавнее» — там метки
  /// нет.
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final tag = heroTag;
    // Перелёт при выключенной системной анимации только мешает: там переход
    // и так мгновенный, а Hero оставил бы кадр с летящей картинкой.
    if (tag == null || MediaQuery.disableAnimationsOf(context)) {
      return _content(context);
    }
    return Hero(tag: tag, child: _content(context));
  }

  Widget _content(BuildContext context) {
    final path = imagePath;
    return ClipRRect(
      borderRadius: borderRadius,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Заглушка лежит фоном всегда, снимок кладётся поверх.
            //
            // Раньше наличие файла проверялось прямо здесь, синхронным
            // `existsSync`: сетка каталога на широком мониторе — это сорок
            // карточек, то есть сорок обращений к диску в потоке отрисовки на
            // каждую перерисовку. Пропавший файл теперь просто не закрывает
            // заглушку — и проверять ничего не нужно.
            _Placeholder(title: title, seedColor: seedColor),
            if (path != null)
              Image.file(
                File(path),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
          ],
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.title, this.seedColor});

  final String title;
  final Color? seedColor;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final base = seedColor ?? c.lavender;
    final initial = title.trim().isEmpty
        ? '?'
        : title.characters.first.toUpperCase();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [base.withValues(alpha: 0.22), base.withValues(alpha: 0.10)],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: base.withValues(alpha: 0.85),
          fontSize: 44,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
