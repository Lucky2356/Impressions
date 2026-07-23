import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';

/// Пустое состояние (§14): красивая локальная композиция из встроенных форм и
/// иконок, без загрузки из интернета. Мягкий круг с иконкой + текст + действие.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Мягкая композиция из вложенных кругов.
            Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                color: c.surfaceHero,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: c.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: c.shadow,
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(icon, size: 32, color: c.lavender),
              ),
            ),
            const SizedBox(height: AppDimens.space24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.text.titleLarge,
            ),
            if (message != null) ...[
              const SizedBox(height: AppDimens.space8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(
                  color: c.textSecondary,
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppDimens.space24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
