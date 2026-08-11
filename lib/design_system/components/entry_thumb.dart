import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';

/// Квадратная миниатюра записи в плотных списках.
///
/// Показывает фотографию, если она есть, и цветной значок, если её нет.
/// Отличается от [CoverImage] соотношением сторон и размером: в строке списка
/// нужен квадрат в 38 точек, а не обложка 3:4.
class EntryThumb extends StatelessWidget {
  const EntryThumb({
    super.key,
    required this.icon,
    required this.color,
    this.imagePath,
    this.size = 38,
  });

  final IconData icon;
  final Color color;
  final String? imagePath;
  final double size;

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    // Снимок кладётся поверх значка, а не вместо него: так не нужно спрашивать
    // у диска, есть ли файл, — а спрашивалось это на каждую перерисовку строки.
    final pixels = (size * MediaQuery.devicePixelRatioOf(context)).round();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: AppDimens.brSm,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Icon(icon, size: size * 0.5, color: color),
          if (path != null)
            Image.file(
              File(path),
              fit: BoxFit.cover,
              // Миниатюра на диске — 400 точек, в строке нужна сороковая часть
              // экрана: декодировать её целиком незачем.
              cacheWidth: pixels,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}
