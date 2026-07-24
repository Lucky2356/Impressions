import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/diagnostics/error_log.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../design_system/design_system.dart';

/// Сколько аварий записано в локальный журнал.
final errorLogCountProvider = FutureProvider<int>((ref) => ErrorLog.count());

/// Журнал аварий в настройках.
///
/// Приложение не отправляет о себе ничего, поэтому единственный способ узнать,
/// что именно сломалось, — показать записи человеку и дать их скопировать.
class ErrorLogSection extends ConsumerWidget {
  const ErrorLogSection({super.key});

  Future<void> _show(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final text = await ErrorLog.read();
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.errorLogTitle),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: SelectableText(
              text.trim().isEmpty ? l10n.errorLogEmpty : text,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.commonClose),
          ),
        ],
      ),
    );
  }

  Future<void> _copy(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final text = await ErrorLog.read();
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.errorLogCopied)));
  }

  Future<void> _clear(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    await ErrorLog.clear();
    ref.invalidate(errorLogCountProvider);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.errorLogCleared)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final count = ref.watch(errorLogCountProvider).value ?? 0;

    return SettingsGroup(
      title: l10n.errorLogTitle,
      children: [
        Text(
          l10n.errorLogHint,
          style: context.text.labelSmall?.copyWith(color: c.textMuted),
        ),
        const SizedBox(height: AppDimens.space16),
        Row(
          children: [
            Icon(
              count == 0
                  ? Icons.check_circle_outline_rounded
                  : Icons.report_gmailerrorred_rounded,
              size: 20,
              color: count == 0 ? c.sage : c.coral,
            ),
            const SizedBox(width: AppDimens.space12),
            Expanded(
              child: Text(
                count == 0 ? l10n.errorLogEmpty : l10n.errorLogCount(count),
                style: context.text.bodyMedium,
              ),
            ),
          ],
        ),
        if (count > 0) ...[
          const SizedBox(height: AppDimens.space8),
          Wrap(
            spacing: AppDimens.space8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _show(context),
                icon: const Icon(Icons.description_outlined, size: 18),
                label: Text(l10n.errorLogShow),
              ),
              TextButton.icon(
                onPressed: () => _copy(context),
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: Text(l10n.errorLogCopy),
              ),
              TextButton.icon(
                onPressed: () => _clear(context, ref),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: Text(l10n.errorLogClear),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
