import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/app_icons.dart';
import '../../core/domain/relation.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/models/entry_view.dart';
import '../../design_system/design_system.dart';
import '../categories/category_providers.dart';
import '../entry/entry_detail_sheet.dart';
import '../quick_add/quick_add_sheet.dart';
import 'home_providers.dart';

/// Главная (§14): визуальная сводка активного профиля на реальных данных.
/// Пустые блоки не показываются.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent =
        ref.watch(recentEntriesProvider).value ?? const <EntryView>[];
    final l10n = AppLocalizations.of(context);

    if (recent.isEmpty) {
      return EmptyState(
        icon: Icons.auto_stories_rounded,
        title: l10n.catalogEmptyTitle,
        message: l10n.catalogEmptyMessage,
        action: FilledButton.icon(
          onPressed: () => QuickAddSheet.show(context),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: Text(l10n.commonAdd),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final showSide = constraints.maxWidth >= 1080;
        final horizontal = constraints.maxWidth >= AppDimens.breakpointExpanded
            ? AppDimens.space32
            : AppDimens.space20;

        return SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1720),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontal,
                  AppDimens.space24,
                  horizontal,
                  AppDimens.space32,
                ),
                child: showSide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Expanded(child: _MainColumn()),
                          SizedBox(width: AppDimens.space24),
                          SizedBox(width: 360, child: _SidePanel()),
                        ],
                      )
                    : const Column(
                        children: [
                          _MainColumn(),
                          SizedBox(height: AppDimens.space24),
                          _SidePanel(),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MainColumn extends ConsumerWidget {
  const _MainColumn();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final stats = ref.watch(profileStatsProvider).value;
    final recent =
        ref.watch(recentEntriesProvider).value ?? const <EntryView>[];
    final roots = ref.watch(rootCategoriesProvider).value ?? const [];
    // Для корневых плиток показываем счётчик по всей ветке (§7.5).
    final counts = ref.watch(categoryBranchCountsProvider).value ?? const {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (stats != null)
          LayoutBuilder(
            builder: (context, cns) {
              final cols = cns.maxWidth >= 900
                  ? 3
                  : cns.maxWidth >= 560
                  ? 2
                  : 1;
              return _grid(
                [
                  StatCard(
                    title: l10n.statEntries,
                    value: '${stats.entries}',
                    unit: l10n.statUnitPieces,
                    trend: _trendFor(stats.entries),
                    trendColor: c.chartGreen,
                  ),
                  StatCard(
                    title: l10n.statCategories,
                    value: '${stats.categories}',
                    unit: l10n.statUnitPieces,
                    trend: _trendFor(stats.categories),
                    trendColor: c.chartBlue,
                  ),
                  StatCard(
                    title: l10n.sectionWantToTry,
                    value: '${stats.wantToTry}',
                    unit: l10n.statUnitPieces,
                    trend: _trendFor(stats.wantToTry),
                    trendColor: c.chartRed,
                  ),
                ],
                cols,
                1.9,
              );
            },
          ),
        const SizedBox(height: AppDimens.space32),
        SectionHeader(title: l10n.sectionRecent),
        const SizedBox(height: AppDimens.space16),
        LayoutBuilder(
          builder: (context, cns) {
            final cols = cns.maxWidth >= 1100
                ? 5
                : cns.maxWidth >= 820
                ? 4
                : cns.maxWidth >= 520
                ? 3
                : 2;
            return _grid(
              [
                for (final e in recent.take(cols * 2))
                  CoverProgress(
                    title: e.title,
                    seedColor: c.profileColorFor(e.objectId),
                    progress: e.rating == null ? null : e.rating! / 10,
                    leftLabel: e.categoryPath.isEmpty
                        ? e.typeName
                        : e.categoryPath.last,
                    rightLabel: e.rating?.toStringAsFixed(1),
                    onTap: () => EntryDetailSheet.show(context, e.entryId),
                  ),
              ],
              cols,
              0.62,
            );
          },
        ),
        if (roots.isNotEmpty) ...[
          const SizedBox(height: AppDimens.space32),
          SectionHeader(title: l10n.categoriesTitle),
          const SizedBox(height: AppDimens.space16),
          LayoutBuilder(
            builder: (context, cns) {
              final cols = cns.maxWidth >= 900
                  ? 4
                  : cns.maxWidth >= 560
                  ? 2
                  : 1;
              final palette = c.profilePalette;
              return _grid(
                [
                  for (var i = 0; i < roots.length && i < cols * 2; i++)
                    _CategoryTile(
                      name: roots[i].name,
                      iconKey: roots[i].icon,
                      color: palette[i % palette.length],
                      count: counts[roots[i].id] ?? 0,
                    ),
                ],
                cols,
                cols == 1 ? 4.2 : 2.4,
              );
            },
          ),
        ],
      ],
    );
  }

  /// Мягкий восходящий тренд по текущему значению — визуальный акцент карточки.
  List<double> _trendFor(int value) {
    final v = value.toDouble();
    return [
      for (var i = 0; i < 10; i++) (v * (0.55 + i * 0.05)).clamp(0, v + 1),
    ];
  }

  Widget _grid(List<Widget> children, int cols, double aspect) {
    return GridView.count(
      crossAxisCount: cols,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppDimens.space16,
      crossAxisSpacing: AppDimens.space16,
      childAspectRatio: aspect,
      children: children,
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.name,
    required this.iconKey,
    required this.color,
    required this.count,
  });

  final String name;
  final String? iconKey;
  final Color color;
  final int count;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context);
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: AppDimens.brSm,
            ),
            child: Icon(AppIcons.byKey(iconKey), size: 20, color: color),
          ),
          const SizedBox(width: AppDimens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleMedium,
                ),
                Text(
                  l10n.categoryEntriesCount(count),
                  style: context.text.labelSmall?.copyWith(color: c.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidePanel extends ConsumerWidget {
  const _SidePanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final want = ref.watch(wantToTryProvider).value ?? const <EntryView>[];

    if (want.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.sectionWantToTry),
        const SizedBox(height: AppDimens.space16),
        AppCard(
          child: Column(
            children: [
              for (var i = 0; i < want.length; i++) ...[
                _WantRow(entry: want[i]),
                if (i != want.length - 1)
                  Divider(height: AppDimens.space24, color: c.divider),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _WantRow extends StatelessWidget {
  const _WantRow({required this.entry});
  final EntryView entry;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = c.profileColorFor(entry.objectId);
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: AppDimens.brSm,
          ),
          child: Icon(Relation.wantToTry.icon, size: 20, color: color),
        ),
        const SizedBox(width: AppDimens.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.titleMedium,
              ),
              Text(
                entry.categoryPath.isEmpty
                    ? entry.typeName
                    : entry.categoryPath.join(' / '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.labelSmall?.copyWith(color: c.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
