import 'package:flutter/material.dart';

import '../../core/theme/theme_context.dart';

/// Заголовок секции с необязательным действием справа («Показать все»).
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.trailing,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: context.text.headlineSmall)),
        ?trailing,
        if (actionLabel != null && trailing == null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: context.colors.textSecondary,
              textStyle: context.text.labelMedium,
              minimumSize: const Size(0, 0),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}
