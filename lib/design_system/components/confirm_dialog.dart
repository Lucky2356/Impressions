import 'package:flutter/material.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';

/// Подтверждающий диалог (§3.4). Возвращает true при подтверждении.
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    this.message,
    this.confirmLabel,
    this.cancelLabel,
    this.destructive = false,
  });

  final String title;
  final String? message;
  final String? confirmLabel;
  final String? cancelLabel;
  final bool destructive;

  static Future<bool> show(
    BuildContext context, {
    required String title,
    String? message,
    String? confirmLabel,
    String? cancelLabel,
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        destructive: destructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return AlertDialog(
      title: Text(title),
      content: message == null ? null : Text(message!),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppDimens.space16,
        0,
        AppDimens.space16,
        AppDimens.space16,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel ?? l10n.commonCancel),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(backgroundColor: c.coral)
              : null,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel ?? l10n.commonYes),
        ),
      ],
    );
  }
}
