import 'package:flutter/material.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';

/// Сообщение об ошибке на месте содержимого экрана.
///
/// Раньше экраны выводили `Text('$e')` — пользователь видел текст исключения
/// с именами классов. Теперь наверху понятная фраза, а подробности убраны
/// внутрь: они нужны, только если об ошибке сообщают.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.error,
    this.onRetry,
    this.compact = false,
  });

  final Object error;

  /// Перечитать то, что не прочиталось.
  ///
  /// Без этого из ошибки не было выхода: помогал только уход в другой раздел
  /// и обратно.
  final VoidCallback? onRetry;

  /// Ошибка в блоке экрана, а не на месте всего раздела: без значка и без
  /// вертикальных полей, чтобы соседние блоки не разъехались.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    final details = Theme(
      // Разделители внутри раскрывающегося блока не нужны: он и так
      // стоит внутри карточки-заглушки.
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(
          l10n.errorStateDetails,
          style: context.text.labelSmall?.copyWith(color: c.textMuted),
        ),
        children: [
          SelectableText(
            '$error',
            style: context.text.labelSmall?.copyWith(color: c.textMuted),
          ),
        ],
      ),
    );

    final retry = onRetry == null
        ? null
        : OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(l10n.errorRetry),
          );

    if (compact) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.space12),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, size: 20, color: c.textMuted),
            const SizedBox(width: AppDimens.space12),
            Expanded(
              child: Text(
                l10n.errorStateTitle,
                style: context.text.bodySmall?.copyWith(color: c.textSecondary),
              ),
            ),
            if (retry != null) ...[
              const SizedBox(width: AppDimens.space8),
              retry,
            ],
          ],
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 40, color: c.textMuted),
              const SizedBox(height: AppDimens.space16),
              Text(
                l10n.errorStateTitle,
                textAlign: TextAlign.center,
                style: context.text.titleMedium,
              ),
              const SizedBox(height: AppDimens.space8),
              Text(
                l10n.errorStateMessage,
                textAlign: TextAlign.center,
                style: context.text.bodySmall?.copyWith(color: c.textSecondary),
              ),
              if (retry != null) ...[
                const SizedBox(height: AppDimens.space16),
                retry,
              ],
              const SizedBox(height: AppDimens.space12),
              details,
            ],
          ),
        ),
      ),
    );
  }
}
