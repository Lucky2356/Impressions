import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Удобный доступ к дизайн-токенам из виджетов.
extension ThemeContextX on BuildContext {
  /// Семантические цвета дизайн-системы.
  AppColors get colors => Theme.of(this).extension<AppColors>()!;

  /// Текстовая тема.
  TextTheme get text => Theme.of(this).textTheme;
}
