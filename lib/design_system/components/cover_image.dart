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
  });

  final String title;
  final String? imagePath;
  final double aspectRatio;
  final Color? seedColor;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && File(imagePath!).existsSync();
    return ClipRRect(
      borderRadius: borderRadius,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: hasImage
            ? Image.file(File(imagePath!), fit: BoxFit.cover)
            : _Placeholder(title: title, seedColor: seedColor),
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
