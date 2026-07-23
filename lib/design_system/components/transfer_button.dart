import 'package:flutter/material.dart';

import '../../core/l10n/gen/app_localizations.dart';

/// Кнопка переноса записи «Добавить в мой профиль» (§3.4, §12).
/// Заметная, но спокойная — основной акцент действия.
class TransferButton extends StatelessWidget {
  const TransferButton({super.key, this.onPressed, this.label});

  final VoidCallback? onPressed;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add_rounded, size: 20),
      label: Text(label ?? l10n.entryAddToMyProfile),
    );
  }
}
