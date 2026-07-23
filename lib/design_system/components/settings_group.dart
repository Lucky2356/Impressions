import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import 'app_card.dart';

/// Раздел настроек: заголовок, необязательное действие справа и карточка
/// с содержимым.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    super.key,
    required this.title,
    required this.children,
    this.trailing,
  });

  final String title;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: context.text.titleLarge)),
            ?trailing,
          ],
        ),
        const SizedBox(height: AppDimens.space12),
        // Содержимое прижато к левому краю: по умолчанию Column центрирует
        // детей по горизонтали, из-за чего одиночные подписи и пустые
        // состояния оказывались посреди карточки и выглядели как ошибка.
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ],
    );
  }
}
