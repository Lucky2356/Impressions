import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';

/// Ввод цели на год.
///
/// Отдаёт число впечатлений, ноль — «убрать цель», null — отказ. Ноль и
/// отказ различаются: убрать поставленную цель и закрыть диалог не глядя —
/// это разные решения.
class YearGoalDialog extends StatefulWidget {
  const YearGoalDialog({super.key, required this.year, this.current = 0});

  final int year;

  /// Нынешняя цель; 0 — её ещё нет.
  final int current;

  static Future<int?> show(
    BuildContext context, {
    required int year,
    int current = 0,
  }) {
    return showDialog<int>(
      context: context,
      builder: (_) => YearGoalDialog(year: year, current: current),
    );
  }

  @override
  State<YearGoalDialog> createState() => _YearGoalDialogState();
}

class _YearGoalDialogState extends State<YearGoalDialog> {
  late final TextEditingController _goal = TextEditingController(
    text: widget.current > 0 ? '${widget.current}' : '',
  );

  /// Круглые числа на выбор: цель обычно и задумывают такой.
  static const List<int> _suggestions = [12, 24, 50, 100];

  @override
  void dispose() {
    _goal.dispose();
    super.dispose();
  }

  int get _value => int.tryParse(_goal.text.trim()) ?? 0;

  void _submit() {
    final value = _value;
    if (value <= 0) return;
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.yearGoalDialogTitle('${widget.year}')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _goal,
            autofocus: true,
            keyboardType: TextInputType.number,
            // Только цифры: на телефоне в числовом поле всё равно есть точка
            // и минус, а цель с минусом ничего не значит.
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: l10n.yearGoalDialogLabel,
              hintText: l10n.yearGoalDialogHint,
            ),
          ),
          const SizedBox(height: AppDimens.space12),
          Wrap(
            spacing: AppDimens.space8,
            children: [
              for (final value in _suggestions)
                ActionChip(
                  label: Text('$value'),
                  onPressed: () => setState(() {
                    _goal.text = '$value';
                  }),
                ),
            ],
          ),
        ],
      ),
      actions: [
        if (widget.current > 0)
          TextButton(
            onPressed: () => Navigator.of(context).pop(0),
            child: Text(l10n.yearGoalRemove),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: _value > 0 ? _submit : null,
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
