import 'package:flutter/widgets.dart';

/// Дизайн-токены размеров: отступы, радиусы, тени, длительности анимаций.
/// Единый источник — не дублировать значения в виджетах (§3.4).
class AppDimens {
  const AppDimens._();

  // ---- Отступы (сетка 4pt) ----
  static const double space2 = 2;
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;
  static const double space64 = 64;

  // ---- Радиусы скругления (16–24 по §3.1) ----
  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 20;
  static const double radiusXl = 24;
  static const double radiusPill = 999;

  static const Radius rSm = Radius.circular(radiusSm);
  static const Radius rMd = Radius.circular(radiusMd);
  static const Radius rLg = Radius.circular(radiusLg);
  static const Radius rXl = Radius.circular(radiusXl);

  static const BorderRadius brSm = BorderRadius.all(rSm);
  static const BorderRadius brMd = BorderRadius.all(rMd);
  static const BorderRadius brLg = BorderRadius.all(rLg);
  static const BorderRadius brXl = BorderRadius.all(rXl);
  static const BorderRadius brPill = BorderRadius.all(
    Radius.circular(radiusPill),
  );

  // ---- Плавные переходы (150–250 мс) ----
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationMedium = Duration(milliseconds: 200);
  static const Duration durationSlow = Duration(milliseconds: 250);
  static const Curve curveStandard = Curves.easeInOutCubic;

  // ---- Размеры компонентов ----
  static const double minTouchTarget = 48; // доступность (§30)
  static const double avatarSm = 32;
  static const double avatarMd = 44;
  static const double avatarLg = 64;
  static const double coverRadius = radiusMd;

  // ---- Адаптивные брейкпоинты ----
  /// Ниже — компактная (мобильная) раскладка; выше — широкая (десктоп).
  static const double breakpointCompact = 640;
  static const double breakpointMedium = 960;

  /// Порог трёхпанельной раскладки Windows (§4.1).
  static const double breakpointExpanded = 1200;

  // ---- Ширины панелей на широком экране ----
  static const double navRailWidth = 268;
  static const double catalogPaneWidth = 340;
  static const double maxContentWidth = 1160;
}
