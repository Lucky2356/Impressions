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
      // Единый переход между экранами на всех платформах: по умолчанию
      // Windows подставляет резкое появление без анимации вовсе, а Android —
      // системный, который в тёмной теме мигает белым.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
        },
      ),
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
      // Все кнопки одной высоты и одного радиуса — различается только заливка.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.accentPrimary,
          foregroundColor: c.accentPrimaryOn,
          disabledBackgroundColor: c.surfaceMuted,
          disabledForegroundColor: c.textMuted,
          textStyle: textTheme.labelLarge,
          minimumSize: const Size(0, AppDimens.controlHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.space20),
          shape: const RoundedRectangleBorder(borderRadius: AppDimens.brMd),
          elevation: 0,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.textPrimary,
          backgroundColor: c.surface,
          // Без этого Material берёт свой серый: отключённая обведённая кнопка
          // выпадала из палитры, а рядом у заполненной цвета заданы.
          disabledForegroundColor: c.textMuted,
          disabledBackgroundColor: c.surfaceMuted,
          textStyle: textTheme.labelLarge,
          minimumSize: const Size(0, AppDimens.controlHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.space20),
          side: BorderSide(color: c.border),
          shape: const RoundedRectangleBorder(borderRadius: AppDimens.brMd),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.accentPrimary,
          textStyle: textTheme.labelLarge,
          minimumSize: const Size(0, AppDimens.controlHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.space12),
          shape: const RoundedRectangleBorder(borderRadius: AppDimens.brMd),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: c.textSecondary,
          shape: const RoundedRectangleBorder(borderRadius: AppDimens.brSm),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      // Поля ввода той же формы, что и таблетки фильтров: светлая поверхность
      // с мягкой границей, акцент при фокусе.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        hintStyle: textTheme.bodyMedium?.copyWith(color: c.textMuted),
        labelStyle: textTheme.bodyMedium?.copyWith(color: c.textSecondary),
        floatingLabelStyle: textTheme.labelMedium?.copyWith(
          color: c.accentPrimary,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space16,
          vertical: AppDimens.space12,
        ),
        border: OutlineInputBorder(
          borderRadius: AppDimens.brMd,
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDimens.brMd,
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDimens.brMd,
          borderSide: BorderSide(color: c.accentPrimary, width: 1.5),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: c.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimens.brMd,
          side: BorderSide(color: c.border),
        ),
        textStyle: textTheme.bodyMedium,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: c.surface,
          selectedBackgroundColor: c.navActiveBg,
          selectedForegroundColor: c.navActiveFg,
          side: BorderSide(color: c.border),
          shape: const RoundedRectangleBorder(borderRadius: AppDimens.brMd),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
