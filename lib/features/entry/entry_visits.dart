import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/data_refresh.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../core/utils/dates.dart';
import '../../data/db/database.dart';
import '../../data/providers.dart';
import '../../design_system/design_system.dart';

/// Повторные впечатления записи (§10): «был ещё раз».
///
/// У записи одна оценка и одна дата, и до схемы 8 второй поход в то же кафе
/// затирал первый. Между тем «понравилось тогда» и «понравилось сейчас» —
/// разные сведения, и весь смысл личного архива как раз в том, чтобы видеть,
/// как мнение менялось.
class EntryVisitsBlock extends ConsumerWidget {
  const EntryVisitsBlock({
    super.key,
    required this.entryId,
    required this.visits,
    required this.canEdit,
  });

  final String entryId;
  final List<EntryVisitRow> visits;

  /// Чужую запись дополнять нечем: это её автор ходил ещё раз, не вы.
  final bool canEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    // У чужой записи с единственным посещением показывать нечего: эта дата уже
    // стоит выше. Правило «пустые блоки не показываются» действует и здесь.
    if (visits.length < 2 && !canEdit) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(l10n.visitsTitle, style: context.text.titleMedium),
            ),
            if (canEdit)
              TextButton.icon(
                onPressed: () => _add(context, ref),
                icon: const Icon(Icons.replay_rounded, size: 18),
                label: Text(l10n.visitAdd),
              ),
          ],
        ),
        // Пока повтор один, списка нет: эта дата уже стоит выше, а объяснять
        // кнопку отдельной фразой на каждой записи — лишний шум.
        if (visits.length >= 2)
          for (final visit in visits)
            _VisitRow(
              visit: visit,
              canEdit: canEdit,
              onRemove: () => _remove(context, ref, visit),
            ),
      ],
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final result = await showAdaptiveSheet<NewVisit>(
      context,
      width: 420,
      builder: (_) => const _AddVisitSheet(),
    );
    if (result == null) return;

    await ref
        .read(entryRepositoryProvider)
        .addVisit(
          entryId: entryId,
          occurredAt: result.occurredAt,
          rating: result.rating,
          note: result.note,
        );
    ref.read(dataRefreshProvider.notifier).bump();
  }

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    EntryVisitRow visit,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.visitRemove,
      message: l10n.visitRemoveMessage,
      confirmLabel: l10n.visitRemove,
      destructive: true,
    );
    if (!confirmed) return;

    await ref.read(entryRepositoryProvider).removeVisit(visit.id);
    ref.read(dataRefreshProvider.notifier).bump();
  }
}

/// Один раз: дата, оценка и заметка.
class _VisitRow extends StatelessWidget {
  const _VisitRow({
    required this.visit,
    required this.canEdit,
    required this.onRemove,
  });

  final EntryVisitRow visit;
  final bool canEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.space8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      localeDate(context, 'd MMMM y').format(visit.occurredAt),
                      style: context.text.bodyMedium,
                    ),
                    if (visit.rating != null) ...[
                      const SizedBox(width: AppDimens.space8),
                      RatingView(value: visit.rating, compact: true),
                    ],
                  ],
                ),
                if (visit.note case final note?)
                  Text(
                    note,
                    style: context.text.bodySmall?.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (canEdit)
            AppIconButton(
              icon: Icons.close_rounded,
              tooltip: l10n.visitRemove,
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}

/// Что ввели в форме нового повтора.
typedef NewVisit = ({DateTime occurredAt, double? rating, String? note});

/// Форма «был ещё раз»: дата, оценка, заметка.
class _AddVisitSheet extends StatefulWidget {
  const _AddVisitSheet();

  @override
  State<_AddVisitSheet> createState() => _AddVisitSheetState();
}

class _AddVisitSheetState extends State<_AddVisitSheet> {
  final _note = TextEditingController();
  DateTime _date = DateTime.now();
  double? _rating;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 50),
      lastDate: now,
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.space20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.visitAdd, style: context.text.headlineSmall),
          const SizedBox(height: AppDimens.space16),
          Row(
            children: [
              Expanded(
                child: Text(l10n.visitDate, style: context.text.bodyMedium),
              ),
              TextButton(
                onPressed: _pickDate,
                child: Text(localeDate(context, 'd MMMM y').format(_date)),
              ),
            ],
          ),
          Divider(height: AppDimens.space24, color: c.divider),
          Text(l10n.quickAddRatingLabel, style: context.text.bodyMedium),
          const SizedBox(height: AppDimens.space8),
          RatingPicker(
            value: _rating,
            onChanged: (v) => setState(() => _rating = v),
          ),
          const SizedBox(height: AppDimens.space16),
          TextField(
            controller: _note,
            minLines: 1,
            maxLines: 3,
            decoration: InputDecoration(labelText: l10n.visitNote),
          ),
          const SizedBox(height: AppDimens.space20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.commonCancel),
              ),
              const SizedBox(width: AppDimens.space8),
              FilledButton(
                onPressed: () {
                  final note = _note.text.trim();
                  Navigator.of(context).pop((
                    occurredAt: _date,
                    rating: _rating,
                    note: note.isEmpty ? null : note,
                  ));
                },
                child: Text(l10n.commonSave),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
