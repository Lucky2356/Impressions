import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';

/// Аватар профиля: фото при наличии, иначе инициалы на индивидуальном цвете
/// профиля (§3.1). Работает и без фотографии (§30).
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.name,
    required this.color,
    this.imagePath,
    this.size = AppDimens.avatarMd,
    this.selected = false,
  });

  final String name;
  final Color color;
  final String? imagePath;
  final double size;
  final bool selected;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    final letters = parts.take(2).map((p) => p.characters.first.toUpperCase());
    return letters.join();
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && File(imagePath!).existsSync();
    final border = selected
        ? Border.all(color: context.colors.accentPrimary, width: 2.5)
        : null;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: hasImage ? 1 : 0.16),
        shape: BoxShape.circle,
        border: border,
        image: hasImage
            ? DecorationImage(
                image: FileImage(File(imagePath!)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      alignment: Alignment.center,
      child: hasImage
          ? null
          : Text(
              _initials,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: size * 0.38,
              ),
            ),
    );
  }
}
