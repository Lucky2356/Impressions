import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';

/// Базовая мягкая карточка дизайн-системы: скруглённые углы, очень мягкая тень,
/// минимум рамок (§3). Все карточки строятся поверх неё, чтобы не дублировать
/// стили вручную.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppDimens.space16),
    this.borderRadius = AppDimens.brLg,
    this.color,
    this.selected = false,
    this.elevated = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Color? color;
  final bool selected;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final surface = color ?? c.surface;

    return AnimatedContainer(
      duration: AppDimens.durationFast,
      curve: AppDimens.curveStandard,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: borderRadius,
        border: Border.all(
          color: selected ? c.accentPrimary : c.border,
          width: selected ? 1.5 : 1,
        ),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: c.shadow,
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
