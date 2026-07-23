import 'package:flutter/material.dart';

import '../../core/l10n/gen/app_localizations.dart';

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
  });

  final String title;
  final String? label;
  final String? hint;
  final String? initial;
  final String? confirmLabel;

  /// Возвращает введённую строку или null, если отменено/пусто.
  static Future<String?> show(
    BuildContext context, {
    required String title,
    String? label,
    String? hint,
    String? initial,
    String? confirmLabel,
  }) async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => TextInputDialog(
        title: title,
        label: label,
        hint: hint,
        initial: initial,
        confirmLabel: confirmLabel,
      ),
    );
    final trimmed = result?.trim();
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
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
        ),
        onSubmitted: (_) => _submit(),
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
