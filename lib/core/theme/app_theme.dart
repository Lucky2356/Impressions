import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_typography.dart';

/// Сборка единой темы Flutter (Material 3 как основа + собственная система).
class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(Brightness.light, AppColors.light);
  static ThemeData dark() => _build(Brightness.dark, AppColors.dark);

  static ThemeData _build(Brightness brightness, AppColors c) {
    final isLight = brightness == Brightness.light;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.accentPrimary,
      onPrimary: c.accentPrimaryOn,
      primaryContainer: c.surfaceHero,
      onPrimaryContainer: c.textPrimary,
      secondary: c.lavender,
      onSecondary: isLight ? Colors.white : const Color(0xFF161522),
      secondaryContainer: c.surfaceMuted,
      onSecondaryContainer: c.textPrimary,
      tertiary: c.sage,
      onTertiary: isLight ? Colors.white : const Color(0xFF10190F),
      error: isLight ? const Color(0xFFB3261E) : const Color(0xFFE49690),
      onError: isLight ? Colors.white : const Color(0xFF2A0F0C),
      surface: c.surface,
      onSurface: c.textPrimary,
      onSurfaceVariant: c.textSecondary,
      outline: c.border,
      outlineVariant: c.divider,
      shadow: c.shadow,
      scrim: const Color(0x66000000),
      surfaceContainerLowest: c.background,
      surfaceContainerLow: c.surface,
      surfaceContainer: c.surfaceMuted,
      surfaceContainerHigh: c.surfaceMuted,
      surfaceContainerHighest: c.surfaceMuted,
      inverseSurface: c.textPrimary,
      onInverseSurface: c.surface,
    );

    final textTheme = AppTypography.build(
      primary: c.textPrimary,
      secondary: c.textSecondary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      extensions: [c],
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineSmall,
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: AppDimens.brLg),
      ),
      dividerTheme: DividerThemeData(color: c.divider, thickness: 1, space: 1),
      chipTheme: ChipThemeData(
        backgroundColor: c.surfaceMuted,
        side: BorderSide.none,
        shape: const RoundedRectangleBorder(borderRadius: AppDimens.brPill),
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space12,
          vertical: AppDimens.space8,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.accentPrimary,
          foregroundColor: c.accentPrimaryOn,
          textStyle: textTheme.labelLarge,
          minimumSize: const Size(0, AppDimens.minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.space20),
          shape: const RoundedRectangleBorder(borderRadius: AppDimens.brMd),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.textPrimary,
          textStyle: textTheme.labelLarge,
          minimumSize: const Size(0, AppDimens.minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.space20),
          side: BorderSide(color: c.border),
          shape: const RoundedRectangleBorder(borderRadius: AppDimens.brMd),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.accentPrimary,
          textStyle: textTheme.labelLarge,
          minimumSize: const Size(0, AppDimens.minTouchTarget),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceMuted,
        hintStyle: textTheme.bodyMedium?.copyWith(color: c.textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space16,
          vertical: AppDimens.space12,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppDimens.brMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppDimens.brMd,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDimens.brMd,
          borderSide: BorderSide(color: c.accentPrimary, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: c.surfaceHero,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.all(textTheme.labelSmall),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: AppDimens.rXl),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppDimens.brXl),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: c.textPrimary,
          borderRadius: AppDimens.brSm,
        ),
        textStyle: textTheme.labelSmall?.copyWith(color: c.surface),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.textPrimary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: c.surface),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppDimens.brMd),
      ),
    );
  }
}
