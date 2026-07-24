import 'package:flutter/material.dart';

import '../../core/l10n/gen/app_localizations.dart';

/// Сообщение о выполненном действии с возможностью его отменить.
///
/// Архивирование обратимо, но узнать об этом можно было только зайдя в раздел
/// «Архив». Кнопка возврата прямо в сообщении избавляет от лишнего шага и
/// снимает страх нажать не туда.
void showUndoSnackBar(
  BuildContext context, {
  required String message,
  required Future<void> Function() onUndo,
}) {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        // Плавающий снек не привязан к геометрии Scaffold: на телефоне с нижней
        // навигацией и кнопкой действия обычный снек мог зависать, пока его
        // анимация появления не завершится, — а она срывалась при подмене тела
        // экрана после архивирования. Плавающий вариант показывается поверх и
        // сам закрывается по таймеру.
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(label: l10n.commonUndo, onPressed: onUndo),
      ),
    );
}
