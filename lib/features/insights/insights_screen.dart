import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../core/domain/relation.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_layout.dart';
import '../../core/theme/theme_context.dart';
import '../../data/models/entry_view.dart';
import '../../data/providers.dart';
import '../../design_system/design_system.dart';

/// Развёрнутая статистика активного профиля.
final profileInsightsProvider = FutureProvider<ProfileInsights>((ref) async {
  ref.watch(dataRefreshProvider);
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) {
    return const ProfileInsights(
      total: 0,
      rated: 0,
      averageRating: null,
      ratingBuckets: [],
      byRelation: {},
      topCategories: [],
      byMonth: [],
      withPhotos: 0,
      withNotes: 0,
    );
  }
  return ref.watch(entryRepositoryProvider).insights(profile.id);
});

/// Экран статистики (§14): каковы ваши вкусы, если посмотреть на всё сразу.
///
/// Главная показывает три числа и недавнее; здесь — распределения, по которым
/// видно, чего в профиле много, а чего нет вовсе.
class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final layout = context.layout;
    final data = ref.watch(profileInsightsProvider).value;

    if (data == null) return const SizedBox.shrink();
    if (data.isEmpty) {
      return EmptyState(
        icon: Icons.insights_rounded,
        title: l10n.insightsEmptyTitle,
        message: l10n.insightsEmptyMessage,
      );
    }

    return ScreenScaffold(
      header: ScreenHeader(
        title: l10n.insightsTitle,
        subtitle: l10n.insightsSubtitle(data.total),
      ),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          layout.gutter,
          AppDimens.space16,
          layout.gutter,
          AppDimens.space40,
        ),
        children: [
          _SummaryRow(data: data),
          const SizedBox(height: AppDimens.space32),
          if (data.rated > 0) ...[
            SectionHeader(title: l10n.insightsRatings),
            const SizedBox(height: AppDimens.space12),
            _RatingHistogram(buckets: data.ratingBuckets),
            const SizedBox(height: AppDimens.space32),
          ],
          if (data.byRelation.isNotEmpty) ...[
            SectionHeader(title: l10n.insightsRelations),
            const SizedBox(height: AppDimens.space12),
            _RelationBars(byRelation: data.byRelation, total: data.total),
            const SizedBox(height: AppDimens.space32),
          ],
          if (data.topCategories.isNotEmpty) ...[
            SectionHeader(title: l10n.insightsCategories),
            const SizedBox(height: AppDimens.space12),
            _TopCategories(items: data.topCategories),
            const SizedBox(height: AppDimens.space32),
          ],
          if (data.byMonth.length > 1) ...[
            SectionHeader(title: l10n.insightsTimeline),
            const SizedBox(height: AppDimens.space12),
            _MonthlyChart(months: data.byMonth),
          ],
        ],
      ),
    );
  }
}

/// Четыре числа сверху: сколько всего, средняя оценка, с фото, с заметками.
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.data});
  final ProfileInsights data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    final tiles = <({String label, String value, Color color})>[
      (
        label: l10n.insightsTotal,
        value: '${data.total}',
        color: c.accentPrimary,
      ),
      (
        label: l10n.insightsAverage,
        value: data.averageRating == null
            ? '—'
            : data.averageRating!.toStringAsFixed(1),
        color: c.sand,
      ),
      (
        label: l10n.insightsWithPhotos,
        value: '${data.withPhotos}',
        color: c.chartBlue,
      ),
      (
        label: l10n.insightsWithNotes,
        value: '${data.withNotes}',
        color: c.sage,
      ),
    ];

    return LayoutBuilder(
      builder: (context, cns) {
        final columns = cns.maxWidth >= 720 ? 4 : 2;
        // Высота задана явно, а не соотношением сторон: при двух колонках на
        // узком экране ячейка получалась ниже содержимого, и плитки
        // переполнялись.
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: AppDimens.space12,
            crossAxisSpacing: AppDimens.space12,
            mainAxisExtent: 112,
          ),
          itemCount: tiles.length,
          itemBuilder: (context, i) => AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  tiles[i].value,
                  maxLines: 1,
                  style: context.text.displayMedium?.copyWith(
                    color: tiles[i].color,
                  ),
                ),
                const SizedBox(height: AppDimens.space4),
                Text(
                  tiles[i].label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall?.copyWith(
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Распределение оценок столбиками по целым баллам.
class _RatingHistogram extends StatelessWidget {
  const _RatingHistogram({required this.buckets});
  final List<int> buckets;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final max = buckets.fold<int>(0, (a, b) => a > b ? a : b);
    if (max == 0) return const SizedBox.shrink();

    return AppCard(
      child: SizedBox(
        height: 160,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < buckets.length; i++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        buckets[i] == 0 ? '' : '${buckets[i]}',
                        style: context.text.labelSmall?.copyWith(
                          color: c.textMuted,
                        ),
                      ),
                      const SizedBox(height: AppDimens.space4),
                      // Пустой столбик остаётся видимой чертой: так понятно,
                      // что оценка возможна, но её никто не ставил.
                      Container(
                        height: (buckets[i] / max * 96).clamp(2.0, 96.0),
                        decoration: BoxDecoration(
                          color: buckets[i] == 0
                              ? c.border
                              : c.accentPrimary.withValues(
                                  alpha: 0.35 + 0.65 * (i / buckets.length),
                                ),
                          borderRadius: AppDimens.brSm,
                        ),
                      ),
                      const SizedBox(height: AppDimens.space8),
                      Text(
                        '${i + 1}',
                        style: context.text.labelSmall?.copyWith(
                          color: c.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Доли отношений полосами.
class _RelationBars extends StatelessWidget {
  const _RelationBars({required this.byRelation, required this.total});

  final Map<String, int> byRelation;
  final int total;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    final rows =
        Relation.values
            .map((r) => (relation: r, count: byRelation[r.name] ?? 0))
            .where((e) => e.count > 0)
            .toList()
          ..sort((a, b) => b.count.compareTo(a.count));

    return AppCard(
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: AppDimens.space12),
            Row(
              children: [
                Icon(
                  rows[i].relation.icon,
                  size: 16,
                  color: rows[i].relation.accent(c),
                ),
                const SizedBox(width: AppDimens.space8),
                SizedBox(
                  width: 130,
                  child: Text(
                    rows[i].relation.label(l10n),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall,
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: AppDimens.brPill,
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : rows[i].count / total,
                      minHeight: 10,
                      backgroundColor: c.surfaceMuted,
                      valueColor: AlwaysStoppedAnimation(
                        rows[i].relation.accent(c),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimens.space12),
                SizedBox(
                  width: 36,
                  child: Text(
                    '${rows[i].count}',
                    textAlign: TextAlign.right,
                    style: context.text.labelMedium,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TopCategories extends StatelessWidget {
  const _TopCategories({required this.items});
  final List<({String name, int count})> items;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final max = items.isEmpty ? 1 : items.first.count;

    return AppCard(
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: AppDimens.space12),
            Row(
              children: [
                SizedBox(
                  width: 180,
                  child: Text(
                    items[i].name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall,
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: AppDimens.brPill,
                    child: LinearProgressIndicator(
                      value: items[i].count / max,
                      minHeight: 10,
                      backgroundColor: c.surfaceMuted,
                      valueColor: AlwaysStoppedAnimation(
                        c.profileColorFor(items[i].name),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimens.space12),
                SizedBox(
                  width: 36,
                  child: Text(
                    '${items[i].count}',
                    textAlign: TextAlign.right,
                    style: context.text.labelMedium,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Сколько записей добавлялось помесячно.
class _MonthlyChart extends StatelessWidget {
  const _MonthlyChart({required this.months});
  final List<({DateTime month, int count})> months;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Последние два года — дальше столбики становятся неразличимыми.
    final shown = months.length > 24
        ? months.sublist(months.length - 24)
        : months;
    final max = shown.fold<int>(0, (a, b) => a > b.count ? a : b.count);
    final format = DateFormat('LLL', 'ru');

    return AppCard(
      child: SizedBox(
        height: 170,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final point in shown)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${point.count}',
                        style: context.text.labelSmall?.copyWith(
                          color: c.textMuted,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: AppDimens.space4),
                      Container(
                        height: (point.count / max * 100).clamp(2.0, 100.0),
                        decoration: BoxDecoration(
                          color: c.chartBlue,
                          borderRadius: AppDimens.brSm,
                        ),
                      ),
                      const SizedBox(height: AppDimens.space8),
                      Text(
                        format.format(point.month),
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: context.text.labelSmall?.copyWith(
                          color: c.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
