import 'package:flutter/material.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';

/// Диалог ввода одной строки.
///
/// Контроллером владеет сам диалог и освобождает его в своём `dispose()`.
/// Освобождать контроллер сразу после `showDialog` нельзя: маршрут ещё
/// анимируется, поле остаётся в дереве и Flutter падает на проверке
/// `_dependents.isEmpty`.
class TextInputDialog extends StatefulWidget {
  const TextInputDialog({
    super.key,
    required this.title,
    this.label,
    this.hint,
    this.initial,
    this.confirmLabel,
    this.suggestions = const [],
  });

  final String title;
  final String? label;
  final String? hint;
  final String? initial;
  final String? confirmLabel;

  /// Уже существующие значения — показываются под полем, чтобы одно и то же
  /// не заводилось дважды в разном написании.
  final List<String> suggestions;

  /// Возвращает введённую строку или null, если отменено/пусто.
  static Future<String?> show(
    BuildContext context, {
    required String title,
    String? label,
    String? hint,
    String? initial,
    String? confirmLabel,
    List<String> suggestions = const [],
    bool allowEmpty = false,
  }) async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => TextInputDialog(
        title: title,
        label: label,
        hint: hint,
        initial: initial,
        confirmLabel: confirmLabel,
        suggestions: suggestions,
      ),
    );
    final trimmed = result?.trim();
    // Обычно пустой ввод — это отказ: безымянная категория никому не нужна.
    // Но подпись к снимку стирают именно пустой строкой, и без [allowEmpty]
    // «убрать подпись» было бы нечем выразить.
    if (allowEmpty) return trimmed;
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  @override
  State<TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<TextInputDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial ?? '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_controller.text);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: widget.label,
                hintText: widget.hint,
              ),
              onSubmitted: (_) => _submit(),
            ),
            if (widget.suggestions.isNotEmpty) ...[
              const SizedBox(height: AppDimens.space12),
              Wrap(
                spacing: AppDimens.space8,
                runSpacing: AppDimens.space8,
                children: [
                  for (final s in widget.suggestions.take(12))
                    ActionChip(
                      label: Text(s),
                      onPressed: () => Navigator.of(context).pop(s),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.confirmLabel ?? l10n.commonSave),
        ),
      ],
    );
  }
}
