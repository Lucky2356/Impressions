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
  const ErrorState({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

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
              const SizedBox(height: AppDimens.space12),
              Theme(
                // Разделители внутри раскрывающегося блока не нужны: он и так
                // стоит внутри карточки-заглушки.
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(
                    l10n.errorStateDetails,
                    style: context.text.labelSmall?.copyWith(
                      color: c.textMuted,
                    ),
                  ),
                  children: [
                    SelectableText(
                      '$error',
                      style: context.text.labelSmall?.copyWith(
                        color: c.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
