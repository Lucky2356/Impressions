import 'package:flutter/material.dart';

/// Семантические цвета дизайн-системы сверх стандартного [ColorScheme].
///
/// Визуальный ориентир — макет YowBooks (см. DESIGN_SYSTEM.md): светлый
/// прохладный фон, белые карточки, оранжевый акцент, мягкие границы.
/// Значения не хардкодятся в виджетах — только здесь (§3.1, §3.4).
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.surfaceHero,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.divider,
    required this.accentPrimary,
    required this.accentPrimaryOn,
    required this.accentSoft,
    required this.navActiveBg,
    required this.navActiveFg,
    required this.lavender,
    required this.sage,
    required this.sand,
    required this.coral,
    required this.chartGreen,
    required this.chartRed,
    required this.chartBlue,
    required this.shadow,
    required this.profilePalette,
  });

  /// Прохладный светлый фон рабочей области.
  final Color background;

  /// Основная поверхность карточек и панелей (белый в светлой теме).
  final Color surface;

  /// Мягкая дополнительная поверхность (чипы, вложенные блоки, поля поиска).
  final Color surfaceMuted;

  /// Спокойная «геройская»/акцентная мягкая поверхность.
  final Color surfaceHero;

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  /// Очень мягкая граница карточек (минимум рамок — §3).
  final Color border;
  final Color divider;

  /// Основной интерактивный акцент (оранжевый).
  final Color accentPrimary;
  final Color accentPrimaryOn;

  /// Мягкая персиковая заливка акцента (фон акцентных чипов/кнопок-призраков).
  final Color accentSoft;

  /// Фон и текст активного пункта навигации (персиковый + оранжевый).
  final Color navActiveBg;
  final Color navActiveFg;

  // Палитра спокойных вторичных акцентов.
  final Color lavender;
  final Color sage;
  final Color sand;
  final Color coral;

  // Цвета мини-графиков (sparkline) и индикаторов.
  final Color chartGreen;
  final Color chartRed;
  final Color chartBlue;

  /// Цвет очень мягкой тени.
  final Color shadow;

  /// Набор индивидуальных цветов профилей (§3.1).
  final List<Color> profilePalette;

  static const AppColors light = AppColors(
    background: Color(0xFFF3F4F6),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF5F6F8),
    surfaceHero: Color(0xFFFFF3E9),
    textPrimary: Color(0xFF191C21),
    textSecondary: Color(0xFF6C7178),
    textMuted: Color(0xFF9CA3AD),
    border: Color(0xFFEBEDF0),
    divider: Color(0xFFF0F1F4),
    accentPrimary: Color(0xFFF5822B),
    accentPrimaryOn: Color(0xFFFFFFFF),
    accentSoft: Color(0xFFFFF1E4),
    navActiveBg: Color(0xFFFFF3E9),
    navActiveFg: Color(0xFFF5822B),
    lavender: Color(0xFF7A72E3),
    sage: Color(0xFF35B37E),
    sand: Color(0xFFE0A63C),
    coral: Color(0xFFF06A5D),
    chartGreen: Color(0xFF35C759),
    chartRed: Color(0xFFF2555A),
    chartBlue: Color(0xFF4F9CF9),
    shadow: Color(0x12101828),
    profilePalette: _profilePaletteLight,
  );

  static const AppColors dark = AppColors(
    background: Color(0xFF141517),
    surface: Color(0xFF1D1F23),
    surfaceMuted: Color(0xFF26282D),
    surfaceHero: Color(0xFF2B2118),
    textPrimary: Color(0xFFECEDEF),
    textSecondary: Color(0xFFA2A7AE),
    textMuted: Color(0xFF767B83),
    border: Color(0xFF2C2F35),
    divider: Color(0xFF26292E),
    accentPrimary: Color(0xFFF98E33),
    accentPrimaryOn: Color(0xFF1E1206),
    accentSoft: Color(0xFF3A2A18),
    navActiveBg: Color(0xFF352518),
    navActiveFg: Color(0xFFF9A253),
    lavender: Color(0xFF9C95F0),
    sage: Color(0xFF56C795),
    sand: Color(0xFFE7BB63),
    coral: Color(0xFFF3897E),
    chartGreen: Color(0xFF4BD26B),
    chartRed: Color(0xFFF56E72),
    chartBlue: Color(0xFF6BADF9),
    shadow: Color(0x33000000),
    profilePalette: _profilePaletteDark,
  );

  static const List<Color> _profilePaletteLight = [
    Color(0xFFF5822B), // оранжевый
    Color(0xFF4F9CF9), // синий
    Color(0xFF35B37E), // зелёный
    Color(0xFF7A72E3), // фиолетовый
    Color(0xFFF06A5D), // коралл
    Color(0xFF2FB3C4), // бирюза
    Color(0xFFE0A63C), // янтарь
    Color(0xFFE06CA7), // розовый
    Color(0xFF6C7BE0), // индиго
    Color(0xFF7F9A3C), // оливковый
  ];

  static const List<Color> _profilePaletteDark = [
    Color(0xFFF98E33),
    Color(0xFF6BADF9),
    Color(0xFF56C795),
    Color(0xFF9C95F0),
    Color(0xFFF3897E),
    Color(0xFF57C7D6),
    Color(0xFFE7BB63),
    Color(0xFFEA85BA),
    Color(0xFF8A98EC),
    Color(0xFF9DB85B),
  ];

  /// Детерминированно выбирает цвет профиля по его id.
  Color profileColorFor(String seed) {
    if (profilePalette.isEmpty) return accentPrimary;
    final hash = seed.codeUnits.fold<int>(
      0,
      (a, b) => (a * 31 + b) & 0x7fffffff,
    );
    return profilePalette[hash % profilePalette.length];
  }

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? surfaceHero,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? border,
    Color? divider,
    Color? accentPrimary,
    Color? accentPrimaryOn,
    Color? accentSoft,
    Color? navActiveBg,
    Color? navActiveFg,
    Color? lavender,
    Color? sage,
    Color? sand,
    Color? coral,
    Color? chartGreen,
    Color? chartRed,
    Color? chartBlue,
    Color? shadow,
    List<Color>? profilePalette,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      surfaceHero: surfaceHero ?? this.surfaceHero,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      accentPrimary: accentPrimary ?? this.accentPrimary,
      accentPrimaryOn: accentPrimaryOn ?? this.accentPrimaryOn,
      accentSoft: accentSoft ?? this.accentSoft,
      navActiveBg: navActiveBg ?? this.navActiveBg,
      navActiveFg: navActiveFg ?? this.navActiveFg,
      lavender: lavender ?? this.lavender,
      sage: sage ?? this.sage,
      sand: sand ?? this.sand,
      coral: coral ?? this.coral,
      chartGreen: chartGreen ?? this.chartGreen,
      chartRed: chartRed ?? this.chartRed,
      chartBlue: chartBlue ?? this.chartBlue,
      shadow: shadow ?? this.shadow,
      profilePalette: profilePalette ?? this.profilePalette,
    );
  }

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      surfaceHero: Color.lerp(surfaceHero, other.surfaceHero, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      accentPrimary: Color.lerp(accentPrimary, other.accentPrimary, t)!,
      accentPrimaryOn: Color.lerp(accentPrimaryOn, other.accentPrimaryOn, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      navActiveBg: Color.lerp(navActiveBg, other.navActiveBg, t)!,
      navActiveFg: Color.lerp(navActiveFg, other.navActiveFg, t)!,
      lavender: Color.lerp(lavender, other.lavender, t)!,
      sage: Color.lerp(sage, other.sage, t)!,
      sand: Color.lerp(sand, other.sand, t)!,
      coral: Color.lerp(coral, other.coral, t)!,
      chartGreen: Color.lerp(chartGreen, other.chartGreen, t)!,
      chartRed: Color.lerp(chartRed, other.chartRed, t)!,
      chartBlue: Color.lerp(chartBlue, other.chartBlue, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      profilePalette: t < 0.5 ? profilePalette : other.profilePalette,
    );
  }
}
