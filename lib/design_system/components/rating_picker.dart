import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';

/// Оценка одним касанием.
///
/// Ползунок от 0 до 10 с двадцатью делениями хорош для половинок, но на
/// телефоне одно деление занимает около двадцати точек, палец перекрывает
/// шкалу, и попасть в целое число с первого раза не получается — а оценка
/// это то, ради чего запись и заводят. Числа сверху ставят целый балл сразу,
/// ползунок остаётся ниже для подстройки.
class RatingPicker extends StatelessWidget {
  const RatingPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  /// Значение 0..10 или null, если оценка не выставлена.
  final double? value;
  final ValueChanged<double> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ряд делит ширину поровну: десять чисел помещаются в строку и на
        // телефоне, и в диалоге, не перенося её и не срывая раскладку.
        Row(
          children: [
            for (var n = 1; n <= 10; n++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _RatingNumber(
                    number: n,
                    // Ровно то же число, а не округление: 7,5 не должно
                    // подсвечивать ни семь, ни восемь.
                    selected: value == n.toDouble(),
                    onTap: enabled ? () => onChanged(n.toDouble()) : null,
                  ),
                ),
              ),
          ],
        ),
        Slider(
          value: value ?? 0,
          min: 0,
          max: 10,
          divisions: 20,
          label: (value ?? 0).toStringAsFixed(1),
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}

class _RatingNumber extends StatelessWidget {
  const _RatingNumber({
    required this.number,
    required this.selected,
    required this.onTap,
  });

  final int number;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: AppDimens.brSm,
      child: Container(
        // Высота — под палец; ширину задаёт ряд, поэтому «10» при системном
        // увеличении шрифта ужимается, а не выпадает из клетки (§30).
        constraints: const BoxConstraints(minHeight: 40),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space2,
          vertical: AppDimens.space4,
        ),
        decoration: BoxDecoration(
          color: selected ? c.accentPrimary : c.surfaceMuted,
          borderRadius: AppDimens.brSm,
          border: Border.all(color: selected ? c.accentPrimary : c.border),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '$number',
            style: context.text.labelLarge?.copyWith(
              color: selected ? c.accentPrimaryOn : c.textPrimary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
