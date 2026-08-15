import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/navigation.dart';
import '../../core/domain/app_icons.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_layout.dart';
import '../../core/theme/theme_context.dart';
import '../../data/models/entry_view.dart';
import '../../design_system/design_system.dart';
import '../categories/category_providers.dart';
import '../entry/entry_context_menu.dart';
import '../entry/entry_detail_sheet.dart';
import '../quick_add/quick_add_sheet.dart';
import '../wishlist/wishlist_screen.dart';
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

    // Боковая колонка занимала свои 360 точек даже пустой: справа оставалась
    // мёртвая полоса, и содержимое главной стояло не по центру окна.
    final hasWishlist =
        (ref.watch(plannedEntriesProvider).value ?? const <EntryView>[])
            .isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = AppLayout.resolve(constraints.maxWidth);
        final showSide = hasWishlist && constraints.maxWidth >= 1080;
        final horizontal = layout.gutter;

        return SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              // Та же колонка, что и у остальных разделов. Своя, более широкая
              // мерка делала главную единственным экраном с другим краем: на
              // 2K содержимое начиналось и заканчивалось не там, где в каталоге.
              constraints: BoxConstraints(maxWidth: layout.contentMaxWidth),
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
    final byMonth = ref.watch(entriesByMonthProvider).value ?? const <double>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Три числа в одной невысокой строке. Раньше это были три плитки в
        // половину экрана каждая — на телефоне ради трёх цифр приходилось
        // прокручивать всю главную, и выглядели они как пустые блоки.
        if (stats != null)
          SummaryStrip(
            items: [
              SummaryItem(
                label: l10n.statEntries,
                value: '${stats.entries}',
                icon: Icons.article_rounded,
                color: c.chartGreen,
                trend: byMonth,
                onTap: () => ref.read(navProvider.notifier).go(NavIds.catalog),
              ),
              SummaryItem(
                label: l10n.statCategories,
                value: '${stats.categories}',
                icon: Icons.account_tree_rounded,
                color: c.chartBlue,
                onTap: () =>
                    ref.read(navProvider.notifier).go(NavIds.categories),
              ),
              SummaryItem(
                label: l10n.sectionWantToTry,
                value: '${stats.planned}',
                icon: Icons.bookmark_add_rounded,
                color: c.chartRed,
                onTap: () => ref.read(navProvider.notifier).go(NavIds.wishlist),
              ),
            ],
          ),
        const SizedBox(height: AppDimens.space24),
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
                // Правый клик и долгое нажатие открывают то же меню, что и в
                // каталоге: раньше на этих карточках они не делали ничего.
                for (final e in recent.take(cols * 2))
                  EntryMenuTarget(
                    entry: e,
                    child: CoverProgress(
                      title: e.title,
                      imagePath: e.coverPath,
                      seedColor: c.profileColorFor(e.objectId),
                      progress: e.rating == null ? null : e.rating! / 10,
                      leftLabel: e.categoryPath.isEmpty
                          ? e.typeName
                          : e.categoryPath.last,
                      rightLabel: e.rating?.toStringAsFixed(1),
                      onTap: () => EntryDetailSheet.show(context, e.entryId),
                    ),
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
                      // Плитки долго были просто картинкой: нажатие ничего не
                      // делало. Открываем ветку на её экране, фильтр каталога
                      // не трогаем.
                      onTap: () {
                        ref
                            .read(selectedCategoryProvider.notifier)
                            .select(roots[i].id);
                        ref.read(navProvider.notifier).go(NavIds.categories);
                      },
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
    required this.onTap,
  });

  final String name;
  final String? iconKey;
  final Color color;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context);
    return AppCard(
      onTap: onTap,
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
    final want = ref.watch(plannedEntriesProvider).value ?? const <EntryView>[];

    if (want.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.sectionWantToTry),
        const SizedBox(height: AppDimens.space16),
        // Та же строка, что и на своём экране: открывается по нажатию и даёт
        // отметить попробованное. Прежняя копия здесь не делала ни того, ни
        // другого.
        for (var i = 0; i < want.length; i++) ...[
          if (i != 0) const SizedBox(height: AppDimens.space8),
          WishlistTile(entry: want[i]),
        ],
      ],
    );
  }
}
