import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../app/navigation.dart';
import '../../core/domain/relation.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_layout.dart';
import '../../core/theme/theme_context.dart';
import '../../data/db/database.dart';
import '../../data/models/entry_view.dart';
import '../../data/providers.dart';
import '../../design_system/design_system.dart';
import '../catalog/catalog_providers.dart';
import '../categories/category_providers.dart';
import '../quick_add/category_picker.dart';

/// Срез статистики: за какой срок и по какой ветке считать.
///
/// Экран показывал распределения по всему профилю: вопрос «а что было в этом
/// году» задать было нечем, хотя данные для него есть.
class InsightsScope {
  const InsightsScope({this.yearOnly = false, this.category});

  final bool yearOnly;
  final CategoryRow? category;

  InsightsScope copyWith({
    bool? yearOnly,
    CategoryRow? category,
    bool clear = false,
  }) {
    return InsightsScope(
      yearOnly: yearOnly ?? this.yearOnly,
      category: clear ? null : (category ?? this.category),
    );
  }
}

class InsightsScopeNotifier extends Notifier<InsightsScope> {
  @override
  InsightsScope build() => const InsightsScope();

  void setYearOnly(bool value) => state = state.copyWith(yearOnly: value);
  void setCategory(CategoryRow? category) =>
      state = state.copyWith(category: category, clear: category == null);
}

final insightsScopeProvider =
    NotifierProvider<InsightsScopeNotifier, InsightsScope>(
      InsightsScopeNotifier.new,
    );

/// Развёрнутая статистика активного профиля.
final profileInsightsProvider = FutureProvider<ProfileInsights>((ref) async {
  ref.watch(dataRefreshProvider);
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return ProfileInsights.empty;

  final scope = ref.watch(insightsScopeProvider);
  final category = scope.category;

  // Ветка целиком: подкатегории считаются вместе со своим корнем — иначе
  // «Продукты» выглядели бы пустыми, а всё лежало бы в «Колбасах».
  List<String>? categoryIds;
  if (category != null) {
    final all = await ref.watch(allCategoriesProvider.future);
    final prefix = '${category.path}/';
    categoryIds = [
      category.id,
      ...all.where((c) => c.path.startsWith(prefix)).map((c) => c.id),
    ];
  }

  final now = DateTime.now();
  return ref
      .watch(entryRepositoryProvider)
      .insights(
        profile.id,
        since: scope.yearOnly
            ? DateTime(now.year - 1, now.month, now.day)
            : null,
        categoryIds: categoryIds,
      );
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
    final scope = ref.watch(insightsScopeProvider);

    if (data == null) return const SizedBox.shrink();
    // Пустой профиль и пустой срез — разные вещи: в первом случае заводить
    // нечего, во втором стоит поменять период или ветку.
    if (data.isEmpty) {
      final narrowed = scope.yearOnly || scope.category != null;
      return ScreenScaffold(
        header: ScreenHeader(
          title: l10n.insightsTitle,
          bottom: narrowed ? const _ScopeBar() : null,
        ),
        child: EmptyState(
          icon: Icons.insights_rounded,
          title: narrowed ? l10n.insightsScopeEmpty : l10n.insightsEmptyTitle,
          message: narrowed ? '' : l10n.insightsEmptyMessage,
        ),
      );
    }

    return ScreenScaffold(
      header: ScreenHeader(
        title: l10n.insightsTitle,
        subtitle: l10n.insightsSubtitle(data.total),
        bottom: const _ScopeBar(),
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
            _RelationBars(
              byRelation: data.byRelation,
              total: data.total,
              onTap: (relation) => _openCatalog(ref, relation: relation),
            ),
            const SizedBox(height: AppDimens.space32),
          ],
          if (data.topCategories.isNotEmpty) ...[
            SectionHeader(title: l10n.insightsCategories),
            const SizedBox(height: AppDimens.space12),
            _TopCategories(
              items: data.topCategories,
              onTap: (categoryId) => _openCatalog(ref, categoryId: categoryId),
            ),
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

/// Строка среза: период и ветка категорий.
class _ScopeBar extends ConsumerWidget {
  const _ScopeBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scope = ref.watch(insightsScopeProvider);
    final notifier = ref.read(insightsScopeProvider.notifier);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.layout.gutter),
      child: Wrap(
        spacing: AppDimens.space8,
        runSpacing: AppDimens.space8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SegmentedToggle<bool>(
            value: scope.yearOnly,
            onChanged: notifier.setYearOnly,
            segments: [
              SegmentData(
                value: false,
                icon: Icons.all_inclusive_rounded,
                tooltip: l10n.insightsPeriodAll,
                label: l10n.insightsPeriodAll,
              ),
              SegmentData(
                value: true,
                icon: Icons.event_rounded,
                tooltip: l10n.insightsPeriodYear,
                label: l10n.insightsPeriodYear,
              ),
            ],
          ),
          OutlinedButton.icon(
            onPressed: () async {
              final picked = await CategoryPicker.show(context);
              if (picked == null) return;
              notifier.setCategory(picked.cleared ? null : picked.category);
            },
            icon: const Icon(Icons.account_tree_rounded, size: 18),
            label: Text(scope.category?.name ?? l10n.insightsScopeAll),
          ),
        ],
      ),
    );
  }
}

/// Переход из статистики в каталог с подставленным фильтром.
///
/// Экран показывал числа и никуда не вёл: увидев «Продукты — 42», к этим сорока
/// двум записям перейти было нельзя. Прежний отбор сбрасывается — иначе строка
/// «Продукты» показала бы продукты, оставшиеся от прошлого фильтра.
void _openCatalog(WidgetRef ref, {String? categoryId, String? relation}) {
  final catalog = ref.read(catalogStateProvider.notifier)..reset();
  if (categoryId != null) catalog.setCategory(categoryId);
  if (relation != null) catalog.setRelation(relation);
  ref.read(navProvider.notifier).go(NavIds.catalog);
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
  const _RelationBars({
    required this.byRelation,
    required this.total,
    required this.onTap,
  });

  final Map<String, int> byRelation;
  final int total;
  final ValueChanged<String> onTap;

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
            _StatBar(
              label: rows[i].relation.label(l10n),
              icon: rows[i].relation.icon,
              color: rows[i].relation.accent(c),
              value: total == 0 ? 0 : rows[i].count / total,
              count: rows[i].count,
              onTap: () => onTap(rows[i].relation.name),
            ),
          ],
        ],
      ),
    );
  }
}

class _TopCategories extends StatelessWidget {
  const _TopCategories({required this.items, required this.onTap});

  final List<({String id, String name, int count})> items;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final max = items.isEmpty ? 1 : items.first.count;

    return AppCard(
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: AppDimens.space12),
            _StatBar(
              label: items[i].name,
              color: c.profileColorFor(items[i].name),
              value: items[i].count / max,
              count: items[i].count,
              labelWidth: 180,
              onTap: () => onTap(items[i].id),
            ),
          ],
        ],
      ),
    );
  }
}

/// Строка статистики: подпись, полоса и число. Нажатие открывает каталог с
/// подставленным отбором.
class _StatBar extends StatelessWidget {
  const _StatBar({
    required this.label,
    required this.color,
    required this.value,
    required this.count,
    required this.onTap,
    this.icon,
    this.labelWidth = 130,
  });

  final String label;
  final Color color;
  final double value;
  final int count;
  final VoidCallback onTap;
  final IconData? icon;
  final double labelWidth;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: AppDimens.brSm,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.space4),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: color),
              const SizedBox(width: AppDimens.space8),
            ],
            SizedBox(
              width: labelWidth,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodySmall,
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: AppDimens.brPill,
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  backgroundColor: c.surfaceMuted,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ),
            const SizedBox(width: AppDimens.space12),
            SizedBox(
              width: 36,
              child: Text(
                '$count',
                textAlign: TextAlign.right,
                style: context.text.labelMedium,
              ),
            ),
          ],
        ),
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
