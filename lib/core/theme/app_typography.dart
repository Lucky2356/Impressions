import 'package:flutter/material.dart';

/// Типографическая шкала (§3.3).
///
/// Основной шрифт — локальный Inter с полной кириллицей: он лежит в assets и
/// ничего не грузит из сети. Файл вариативный, поэтому начертание задаётся
/// осью `wght`; [FontWeight] оставлен для запасных системных шрифтов.
class AppTypography {
  const AppTypography._();

  static const String _primaryFamily = 'Inter';
  static const List<String> _fallback = ['Segoe UI', 'Roboto'];

  /// Строит [TextTheme] с заданными цветами основного и вторичного текста.
  static TextTheme build({required Color primary, required Color secondary}) {
    TextStyle s(
      double size,
      FontWeight weight,
      Color color, {
      double height = 1.3,
      double spacing = 0,
    }) {
      return TextStyle(
        fontFamily: _primaryFamily,
        fontFamilyFallback: _fallback,
        fontSize: size,
        fontWeight: weight,
        fontVariations: [FontVariation('wght', weight.value.toDouble())],
        height: height,
        letterSpacing: spacing,
        color: color,
      );
    }

    return TextTheme(
      // Крупный экранный заголовок.
      displayLarge: s(
        36,
        FontWeight.w700,
        primary,
        height: 1.12,
        spacing: -0.5,
      ),
      displayMedium: s(
        30,
        FontWeight.w700,
        primary,
        height: 1.15,
        spacing: -0.3,
      ),
      // Заголовок раздела.
      headlineMedium: s(
        24,
        FontWeight.w600,
        primary,
        height: 1.2,
        spacing: -0.2,
      ),
      headlineSmall: s(20, FontWeight.w600, primary, height: 1.25),
      // Заголовок карточки.
      titleLarge: s(18, FontWeight.w600, primary, height: 1.3),
      titleMedium: s(16, FontWeight.w600, primary, height: 1.3),
      // Основной текст.
      bodyLarge: s(16, FontWeight.w400, primary, height: 1.45),
      // Вторичный текст.
      bodyMedium: s(14, FontWeight.w400, secondary, height: 1.45),
      // Подпись.
      bodySmall: s(13, FontWeight.w400, secondary, height: 1.4),
      // Текст кнопок.
      labelLarge: s(15, FontWeight.w600, primary, height: 1.2, spacing: 0.1),
      // Компактные чипы.
      labelMedium: s(13, FontWeight.w600, primary, height: 1.1, spacing: 0.1),
      // Метаданные.
      labelSmall: s(12, FontWeight.w500, secondary, height: 1.2, spacing: 0.2),
    );
  }
}
