import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/data_refresh.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/providers.dart';
import '../../data/services/integrity_service.dart';
import '../../design_system/design_system.dart';

/// Проверка целостности данных.
///
/// Приложение обещает, что ничего не пропадает молча. Расхождения всё равно
/// случаются — прерванный импорт, файл, удалённый мимо приложения, — и заметить
/// их можно было только по симптому: пустая обложка или запись, которую не
/// находит поиск.
class DoctorSection extends ConsumerStatefulWidget {
  const DoctorSection({super.key});

  @override
  ConsumerState<DoctorSection> createState() => _DoctorSectionState();
}

class _DoctorSectionState extends ConsumerState<DoctorSection> {
  IntegrityReport? _report;
  bool _busy = false;

  Future<void> _run(Future<IntegrityReport> Function() action) async {
    setState(() => _busy = true);
    try {
      final report = await action();
      if (!mounted) return;
      setState(() => _report = report);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  IntegrityService get _service =>
      IntegrityService(ref.read(appDatabaseProvider));

  Future<void> _repair() async {
    await _run(_service.repair);
    ref.read(dataRefreshProvider.notifier).bump();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.doctorFixed)));
  }

  /// Человеческое название находки.
  String _label(AppLocalizations l10n, IntegrityFinding finding) {
    return switch (finding.issue) {
      IntegrityIssue.orphanFiles => l10n.doctorOrphanFiles(finding.count),
      IntegrityIssue.missingFiles => l10n.doctorMissingFiles(finding.count),
      IntegrityIssue.entriesWithoutRevision =>
        l10n.doctorEntriesWithoutRevision(finding.count),
      IntegrityIssue.danglingCategories => l10n.doctorDanglingCategories(
        finding.count,
      ),
      IntegrityIssue.danglingCollectionEntries =>
        l10n.doctorDanglingCollectionEntries(finding.count),
      IntegrityIssue.searchOutOfSync => l10n.doctorSearchOutOfSync,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final report = _report;

    return SettingsGroup(
      title: l10n.doctorTitle,
      children: [
        Text(
          l10n.doctorHint,
          style: context.text.bodySmall?.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: AppDimens.space12),
        if (report != null) ...[
          if (report.isClean)
            Row(
              children: [
                Icon(Icons.check_circle_rounded, size: 18, color: c.sage),
                const SizedBox(width: AppDimens.space8),
                Text(l10n.doctorClean, style: context.text.bodyMedium),
              ],
            )
          else
            for (final finding in report.findings)
              Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.space4),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, size: 18, color: c.coral),
                    const SizedBox(width: AppDimens.space8),
                    Expanded(
                      child: Text(
                        _label(l10n, finding),
                        style: context.text.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
          const SizedBox(height: AppDimens.space12),
        ],
        Wrap(
          spacing: AppDimens.space8,
          runSpacing: AppDimens.space8,
          children: [
            OutlinedButton.icon(
              onPressed: _busy ? null : () => _run(_service.check),
              icon: const Icon(Icons.fact_check_outlined, size: 18),
              label: Text(l10n.doctorRun),
            ),
            // Чинить предлагаем только тогда, когда есть что.
            if (report != null && !report.isClean)
              FilledButton.icon(
                onPressed: _busy ? null : _repair,
                icon: const Icon(Icons.healing_rounded, size: 18),
                label: Text(l10n.doctorRepair),
              ),
          ],
        ),
      ],
    );
  }
}
