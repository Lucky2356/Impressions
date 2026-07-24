import 'package:flutter/material.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';

/// Ввод пароля резервных копий.
///
/// В двух видах: задать пароль (два поля со сверкой) и открыть копию (одно
/// поле). Пароль нигде не сохраняется — он живёт только до закрытия диалога и
/// уходит вызывающей стороне возвращаемым значением.
class BackupPasswordDialog extends StatefulWidget {
  const BackupPasswordDialog({
    super.key,
    required this.title,
    this.message,
    this.note,
    this.confirmPassword = false,
  });

  final String title;
  final String? message;

  /// Дополнительное пояснение под полями — например, о старых копиях.
  final String? note;

  /// Просить ввести пароль дважды и проверять длину.
  final bool confirmPassword;

  static Future<String?> show(
    BuildContext context, {
    required String title,
    String? message,
    String? note,
    bool confirmPassword = false,
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) => BackupPasswordDialog(
        title: title,
        message: message,
        note: note,
        confirmPassword: confirmPassword,
      ),
    );
  }

  @override
  State<BackupPasswordDialog> createState() => _BackupPasswordDialogState();
}

class _BackupPasswordDialogState extends State<BackupPasswordDialog> {
  final _password = TextEditingController();
  final _repeat = TextEditingController();
  String? _error;
  bool _hidden = true;

  /// Короче восьми знаков пароль подбирается перебором быстрее, чем считается
  /// вывод ключа, — тогда сто двадцать тысяч итераций теряют смысл.
  static const int _minLength = 8;

  @override
  void dispose() {
    _password.dispose();
    _repeat.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    final value = _password.text;

    if (widget.confirmPassword) {
      if (value.length < _minLength) {
        setState(() => _error = l10n.backupPasswordShort);
        return;
      }
      if (value != _repeat.text) {
        setState(() => _error = l10n.backupPasswordMismatch);
        return;
      }
    } else if (value.isEmpty) {
      return;
    }

    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.message != null) ...[
              Text(widget.message!, style: context.text.bodySmall),
              const SizedBox(height: AppDimens.space16),
            ],
            TextField(
              controller: _password,
              autofocus: true,
              obscureText: _hidden,
              onSubmitted: (_) => widget.confirmPassword ? null : _submit(),
              decoration: InputDecoration(
                labelText: l10n.backupPasswordField,
                suffixIcon: IconButton(
                  tooltip: '',
                  icon: Icon(
                    _hidden
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 18,
                  ),
                  onPressed: () => setState(() => _hidden = !_hidden),
                ),
              ),
            ),
            if (widget.confirmPassword) ...[
              const SizedBox(height: AppDimens.space12),
              TextField(
                controller: _repeat,
                obscureText: _hidden,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: l10n.backupPasswordRepeat,
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: AppDimens.space12),
              Text(
                _error!,
                style: context.text.labelSmall?.copyWith(color: c.coral),
              ),
            ],
            if (widget.note != null) ...[
              const SizedBox(height: AppDimens.space12),
              Text(
                widget.note!,
                style: context.text.labelSmall?.copyWith(color: c.textMuted),
              ),
            ],
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppDimens.space16,
        0,
        AppDimens.space16,
        AppDimens.space16,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.commonSave)),
      ],
    );
  }
}
