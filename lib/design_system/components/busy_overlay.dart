import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';

/// Выполняет длительное действие, показывая, что приложение занято.
///
/// Резервное копирование сотен мегабайт, проверка целостности и перешифровка
/// базы шли без единого признака работы: нажал — и ничего не произошло, а
/// второе нажатие запускало ту же работу второй раз. Перекрывающий слой и
/// сообщает о работе, и не даёт нажать снова.
///
/// Полоса неопределённая: сервисы отчитываются по завершении, а придумывать
/// проценты, которых никто не считает, — врать.
Future<T> runBusy<T>(
  BuildContext context,
  Future<T> Function() action, {
  required String label,
}) async {
  final navigator = Navigator.of(context, rootNavigator: true);

  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => PopScope(canPop: false, child: _BusyDialog(label: label)),
    ),
  );

  try {
    return await action();
  } finally {
    // Слой снимается и при сбое: иначе неудача выглядела бы как вечная работа.
    if (navigator.mounted) navigator.pop();
  }
}

class _BusyDialog extends StatelessWidget {
  const _BusyDialog({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space24),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: AppDimens.space16),
            Flexible(child: Text(label, style: context.text.bodyMedium)),
          ],
        ),
      ),
    );
  }
}
