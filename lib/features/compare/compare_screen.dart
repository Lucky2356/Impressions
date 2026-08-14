import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../core/domain/relation.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/models/entry_view.dart';
import '../../data/providers.dart';
import '../../data/services/compare_service.dart';
import '../../data/services/transfer_service.dart';
import '../../design_system/design_system.dart';

/// Параметры сравнения.
class CompareParams {
  const CompareParams({
    required this.firstId,
    required this.secondId,
    required this.mode,
  });

  final String firstId;
  final String secondId;
  final CompareMode mode;

  @override
  bool operator ==(Object other) =>
      other is CompareParams &&
      other.firstId == firstId &&
      other.secondId == secondId &&
      other.mode == mode;

  @override
  int get hashCode => Object.hash(firstId, secondId, mode);
}

/// Пара сравниваемых профилей — без режима.
class _ComparePair {
  const _ComparePair(this.firstId, this.secondId);

  final String firstId;
  final String secondId;

  @override
  bool operator ==(Object other) =>
      other is _ComparePair &&
      other.firstId == firstId &&
      other.secondId == secondId;

  @override
  int get hashCode => Object.hash(firstId, secondId);
}

/// Строки сравнения пары профилей — собираются один раз на пару.
final _comparePairProvider =
    FutureProvider.family<List<CompareRow>, _ComparePair>((ref, pair) async {
      ref.watch(dataRefreshProvider);
      return CompareService(
        ref.watch(appDatabaseProvider),
      ).rows(firstProfileId: pair.firstId, secondProfileId: pair.secondId);
    });

/// Строки под выбранный режим.
///
/// Режим отбирает уже собранное: раньше каждое переключение «только у меня /
/// у обоих» заново поднимало оба профиля целиком.
final compareResultsProvider =
    FutureProvider.family<List<CompareRow>, CompareParams>((ref, params) async {
      final rows = await ref.watch(
        _comparePairProvider(
          _ComparePair(params.firstId, params.secondId),
        ).future,
      );
      return CompareService.filter(rows, params.mode);
    });

/// Сравнение двух профилей (§13): режимы, две колонки на широком экране,
/// множественный выбор и массовый перенос записей себе.
class CompareScreen extends ConsumerStatefulWidget {
  const CompareScreen({super.key});

  @override
  ConsumerState<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends ConsumerState<CompareScreen> {
  String? _firstId;
  String? _secondId;
  CompareMode _mode = CompareMode.onlySecond;
  final Set<String> _selected = {};
  bool _busy = false;

  String _modeLabel(CompareMode mode, AppLocalizations l10n) => switch (mode) {
    CompareMode.onlyFirst => l10n.compareModeOnlyFirst,
    CompareMode.onlySecond => l10n.compareModeOnlySecond,
    CompareMode.both => l10n.compareModeBoth,
    CompareMode.bothLike => l10n.compareModeBothLike,
    CompareMode.ratingDiffers => l10n.compareModeRatingDiffers,
    CompareMode.recommendedNotAdded => l10n.compareModeRecommended,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final profiles = ref.watch(profilesProvider).value ?? const [];
    final active = ref.watch(activeProfileProvider);

    if (profiles.length < 2) {
      return EmptyState(
        icon: Icons.compare_arrows_rounded,
        title: l10n.compareNeedTwo,
        message: l10n.compareNeedTwoMessage,
      );
    }

    _firstId ??= active?.id ?? profiles.first.id;
    _secondId ??= profiles
        .firstWhere((p) => p.id != _firstId, orElse: () => profiles.first)
        .id;

    final params = CompareParams(
      firstId: _firstId!,
      secondId: _secondId!,
      mode: _mode,
    );
    final results = ref.watch(compareResultsProvider(params));

    return ScreenScaffold(
      constrain: false,
      header: ScreenHeader(
        constrain: false,
        title: l10n.compareTitle,
        bottom: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppDimens.space12,
              runSpacing: AppDimens.space12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _ProfileDropdown(
                  label: l10n.compareFirst,
                  value: _firstId!,
                  onChanged: (v) => setState(() {
                    _firstId = v;
                    _selected.clear();
                  }),
                ),
                Icon(Icons.compare_arrows_rounded, color: c.textMuted),
                _ProfileDropdown(
                  label: l10n.compareSecond,
                  value: _secondId!,
                  onChanged: (v) => setState(() {
                    _secondId = v;
                    _selected.clear();
                  }),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.space12),
            Wrap(
              spacing: AppDimens.space8,
              runSpacing: AppDimens.space8,
              children: [
                for (final mode in CompareMode.values)
                  ChoiceChip(
                    selected: _mode == mode,
                    onSelected: (_) => setState(() {
                      _mode = mode;
                      _selected.clear();
                    }),
                    label: Text(_modeLabel(mode, l10n)),
                  ),
              ],
            ),
          ],
        ),
      ),
      child: Column(
        children: [
          if (_selected.isNotEmpty)
            Container(
              width: double.infinity,
              color: c.accentSoft,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space20,
                vertical: AppDimens.space8,
              ),
              child: Row(
                children: [
                  Text(
                    l10n.compareSelected(_selected.length),
                    style: context.text.labelMedium,
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _busy ? null : () => _transferSelected(params),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(l10n.compareTransferSelected),
                  ),
                ],
              ),
            ),
          Expanded(
            child: results.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => ErrorState(error: e),
              data: (rows) {
                if (rows.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off_rounded,
                    title: l10n.compareEmpty,
                    message: l10n.compareEmptyMessage,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(AppDimens.space20),
                  itemCount: rows.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppDimens.space12),
                  itemBuilder: (context, i) {
                    final row = rows[i];
                    // Переносить можно только то, чего нет у активного профиля.
                    final transferable = _transferableEntryId(row) != null;
                    return _CompareRowCard(
                      row: row,
                      selected: _selected.contains(row.objectId),
                      selectable: transferable,
                      onToggle: () => setState(() {
                        if (!_selected.remove(row.objectId)) {
                          _selected.add(row.objectId);
                        }
                      }),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Запись-источник для переноса: та, что принадлежит НЕ активному профилю,
  /// при условии что у активного записи нет.
  String? _transferableEntryId(CompareRow row) {
    final active = ref.read(activeProfileProvider);
    if (active == null) return null;
    final mine = row.left?.entryId != null && _firstId == active.id
        ? row.left
        : (_secondId == active.id ? row.right : null);
    if (mine != null) return null;

    final source = _firstId == active.id ? row.right : row.left;
    return source?.entryId;
  }

  Future<void> _transferSelected(CompareParams params) async {
    final l10n = AppLocalizations.of(context);
    final active = ref.read(activeProfileProvider);
    if (active == null) return;

    setState(() => _busy = true);
    var moved = 0;
    try {
      final rows = ref.read(compareResultsProvider(params)).value ?? const [];
      final service = TransferService(ref.read(appDatabaseProvider));
      for (final row in rows) {
        if (!_selected.contains(row.objectId)) continue;
        final sourceEntryId = _transferableEntryId(row);
        if (sourceEntryId == null) continue;
        await service.transfer(
          sourceEntryId: sourceEntryId,
          targetProfileId: active.id,
          mode: TransferCategoryMode.autoCreate,
        );
        moved++;
      }
      ref.read(dataRefreshProvider.notifier).bump();
      setState(() => _selected.clear());
    } finally {
      if (mounted) setState(() => _busy = false);
    }

    if (!mounted) return;
    showMessage(context, l10n.compareTransferred(moved));
  }
}

class _ProfileDropdown extends ConsumerWidget {
  const _ProfileDropdown({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final profiles = ref.watch(profilesProvider).value ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: context.text.labelSmall?.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: AppDimens.space4),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.space12),
          decoration: BoxDecoration(
            color: c.surfaceMuted,
            borderRadius: AppDimens.brPill,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              onChanged: (v) => v == null ? null : onChanged(v),
              isDense: true,
              borderRadius: AppDimens.brMd,
              style: context.text.labelMedium,
              items: [
                for (final p in profiles)
                  DropdownMenuItem(value: p.id, child: Text(p.firstName)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CompareRowCard extends StatelessWidget {
  const _CompareRowCard({
    required this.row,
    required this.selected,
    required this.selectable,
    required this.onToggle,
  });

  final CompareRow row;
  final bool selected;
  final bool selectable;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      selected: selected,
      onTap: selectable ? onToggle : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectable)
            Padding(
              padding: const EdgeInsets.only(right: AppDimens.space8),
              child: Checkbox(value: selected, onChanged: (_) => onToggle()),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleMedium,
                ),
                Text(
                  row.typeName,
                  style: context.text.labelSmall?.copyWith(color: c.textMuted),
                ),
                const SizedBox(height: AppDimens.space12),
                LayoutBuilder(
                  builder: (context, cns) {
                    final side = _OpinionSide(entry: row.left);
                    final other = _OpinionSide(entry: row.right);
                    // На широком экране — две параллельные колонки (§13).
                    if (cns.maxWidth >= 520) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: side),
                          const SizedBox(width: AppDimens.space16),
                          Expanded(child: other),
                        ],
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        side,
                        const SizedBox(height: AppDimens.space8),
                        other,
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OpinionSide extends StatelessWidget {
  const _OpinionSide({required this.entry});
  final EntryView? entry;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context);
    final e = entry;
    if (e == null) {
      return Text(
        l10n.compareNoEntry,
        style: context.text.bodySmall?.copyWith(color: c.textMuted),
      );
    }
    final relation = Relation.byName(e.relation);
    return Wrap(
      spacing: AppDimens.space8,
      runSpacing: AppDimens.space4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (relation != null) RelationChip(relation: relation, compact: true),
        if (e.rating != null) RatingView(value: e.rating, compact: true),
        if (relation == null && e.rating == null)
          Text(
            '—',
            style: context.text.bodySmall?.copyWith(color: c.textMuted),
          ),
      ],
    );
  }
}
