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
    final hasImage = path != null && File(path).existsSync();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: hasImage ? null : color.withValues(alpha: 0.14),
        borderRadius: AppDimens.brSm,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.file(File(path), fit: BoxFit.cover)
          : Icon(icon, size: size * 0.5, color: color),
    );
  }
}
