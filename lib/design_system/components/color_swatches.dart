import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';

/// Ряд кружков палитры плюс отдельная плашка «как у родителя».
///
/// «Как у родителя» — это не цвет, а его отсутствие: пустое поле в базе.
/// Поэтому у плашки нет своего оттенка, она показывает унаследованный и
/// возвращает `null`.
class ColorSwatches extends StatelessWidget {
  const ColorSwatches({
    super.key,
    required this.value,
    required this.onChanged,
    required this.inheritLabel,
    this.inheritedColor,
  });

  /// Выбранный цвет; `null` — «как у родителя».
  final Color? value;

  final ValueChanged<Color?> onChanged;

  /// Подпись плашки наследования.
  final String inheritLabel;

  /// Что унаследуется, если своего цвета нет.
  final Color? inheritedColor;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Wrap(
      spacing: AppDimens.space8,
      runSpacing: AppDimens.space8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _Inherit(
          label: inheritLabel,
          tone: inheritedColor ?? c.textMuted,
          selected: value == null,
          onTap: () => onChanged(null),
        ),
        for (final tone in c.profilePalette)
          _Swatch(
            tone: tone,
            selected: value != null && value!.toARGB32() == tone.toARGB32(),
            onTap: () => onChanged(tone),
          ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.tone,
    required this.selected,
    required this.onTap,
  });

  final Color tone;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: tone,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? c.textPrimary : c.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: selected
              ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}

class _Inherit extends StatelessWidget {
  const _Inherit({
    required this.label,
    required this.tone,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color tone;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: selected ? tone.withValues(alpha: 0.14) : c.surfaceMuted,
      borderRadius: AppDimens.brPill,
      child: InkWell(
        borderRadius: AppDimens.brPill,
        onTap: onTap,
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.space12),
          decoration: BoxDecoration(
            borderRadius: AppDimens.brPill,
            border: Border.all(
              color: selected ? tone : c.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(color: tone, shape: BoxShape.circle),
              ),
              const SizedBox(width: AppDimens.space8),
              Text(label, style: context.text.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}
