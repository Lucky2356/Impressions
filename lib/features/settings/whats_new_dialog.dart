import 'package:flutter/material.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/services/changelog_service.dart';

/// «Что нового» — раздел истории изменений текущей версии.
///
/// Обновление приходит само и меняет поведение, а список правок жил только на
/// GitHub: узнать, что изменилось, было неоткуда.
class WhatsNewDialog extends StatelessWidget {
  const WhatsNewDialog({super.key, required this.entry});

  final ChangelogEntry entry;

  static Future<void> show(BuildContext context, ChangelogEntry entry) {
    return showDialog<void>(
      context: context,
      builder: (_) => WhatsNewDialog(entry: entry),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    return AlertDialog(
      title: Text(l10n.whatsNewTitle),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.whatsNewVersion(entry.version),
                style: context.text.labelMedium?.copyWith(color: c.textMuted),
              ),
              const SizedBox(height: AppDimens.space12),
              ..._blocks(context),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonClose),
        ),
      ],
    );
  }

  /// Простая разметка changelog: подзаголовки, пункты списка и абзацы.
  ///
  /// Полноценный markdown здесь не нужен и тянуть ради него зависимость
  /// незачем: файл пишем мы сами и знаем, что в нём бывает.
  List<Widget> _blocks(BuildContext context) {
    final c = context.colors;
    final blocks = <Widget>[];

    for (final raw in entry.body.split('\n')) {
      final line = raw.trim();
      if (line.isEmpty) continue;

      if (line.startsWith('### ')) {
        blocks
          ..add(const SizedBox(height: AppDimens.space12))
          ..add(Text(line.substring(4), style: context.text.titleSmall))
          ..add(const SizedBox(height: AppDimens.space8));
        continue;
      }

      final bullet = line.startsWith('- ');
      final text = _plain(bullet ? line.substring(2) : line);
      blocks.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimens.space8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (bullet) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Icon(Icons.circle, size: 5, color: c.accentPrimary),
                ),
                const SizedBox(width: AppDimens.space8),
              ],
              Expanded(child: Text(text, style: context.text.bodyMedium)),
            ],
          ),
        ),
      );
    }
    return blocks;
  }

  /// Убирает разметку жирного и ссылок, оставляя читаемый текст.
  static String _plain(String input) {
    return input
        .replaceAll('**', '')
        .replaceAllMapped(
          RegExp(r'\[([^\]]+)\]\([^)]+\)'),
          (m) => m.group(1) ?? '',
        )
        .replaceAll('`', '');
  }
}
