import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/providers.dart';
import '../../data/services/backup_service.dart';
import '../../data/services/csv_import_service.dart';
import '../../design_system/design_system.dart';

/// Перенос списка из таблицы.
///
/// Выгрузка в CSV была с самого начала, обратного пути не было: список из
/// Excel или из другого приложения переносили руками, по записи за раз.
class CsvImportCard extends ConsumerStatefulWidget {
  const CsvImportCard({super.key});

  @override
  ConsumerState<CsvImportCard> createState() => _CsvImportCardState();
}

class _CsvImportCardState extends ConsumerState<CsvImportCard> {
  CsvPreview? _preview;
  bool _busy = false;

  static const _service = CsvImportService();

  Future<void> _pick() async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'CSV', extensions: ['csv', 'tsv', 'txt']),
      ],
    );
    if (file == null) return;

    setState(() => _busy = true);
    try {
      final preview = _service.inspect(await file.readAsBytes());
      if (!mounted) return;
      setState(() => _preview = preview);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _apply() async {
    final preview = _preview;
    final profile = ref.read(activeProfileProvider);
    if (preview == null || profile == null) return;
    final l10n = AppLocalizations.of(context);

    setState(() => _busy = true);
    try {
      final db = ref.read(appDatabaseProvider);
      // Копия до переноса — как и перед импортом профиля: чужая таблица может
      // оказаться не тем, чем выглядела.
      await BackupService(db).create(reason: 'beforeImport');
      final result = await _service.apply(
        profileId: profile.id,
        rows: preview.rows,
        entries: ref.read(entryRepositoryProvider),
        categories: ref.read(categoryRepositoryProvider),
      );
      ref.read(dataRefreshProvider.notifier).bump();
      if (!mounted) return;
      setState(() => _preview = null);
      showMessage(context, l10n.csvImportDone(result.created));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Что приложение угадало: «Название → Название, Оценка → Оценка».
  String _columns(CsvPreview preview, AppLocalizations l10n) {
    final names = <String>[];
    for (final entry in preview.mapping.entries) {
      if (entry.value >= preview.headers.length) continue;
      names.add(preview.headers[entry.value]);
    }
    return names.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final preview = _preview;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.csvImportTitle, style: context.text.titleMedium),
          const SizedBox(height: AppDimens.space4),
          Text(
            l10n.csvImportHint,
            style: context.text.bodySmall?.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: AppDimens.space12),
          if (preview != null) ...[
            if (preview.isEmpty)
              Text(
                l10n.csvImportNothing,
                style: context.text.bodyMedium?.copyWith(color: c.coral),
              )
            else ...[
              Text(
                l10n.csvImportFound(preview.rows.length),
                style: context.text.bodyMedium,
              ),
              if (preview.skipped > 0)
                Text(
                  l10n.csvImportSkipped(preview.skipped),
                  style: context.text.labelSmall?.copyWith(color: c.textMuted),
                ),
              Text(
                l10n.csvImportColumns(_columns(preview, l10n)),
                style: context.text.labelSmall?.copyWith(color: c.textMuted),
              ),
            ],
            const SizedBox(height: AppDimens.space12),
          ],
          Wrap(
            spacing: AppDimens.space8,
            runSpacing: AppDimens.space8,
            children: [
              OutlinedButton.icon(
                onPressed: _busy ? null : _pick,
                icon: const Icon(Icons.table_chart_outlined, size: 18),
                label: Text(l10n.csvImportPick),
              ),
              // Перенос начинается только по отдельному нажатию: файл сначала
              // показывается, а решает человек.
              if (preview != null && !preview.isEmpty)
                FilledButton.icon(
                  onPressed: _busy ? null : _apply,
                  icon: const Icon(Icons.playlist_add_check_rounded, size: 18),
                  label: Text(l10n.csvImportApply),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
