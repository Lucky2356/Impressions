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
import '../categories/category_palette.dart';
import '../categories/category_providers.dart';
import '../collections/collection_providers.dart';
import '../entry/entry_card_data.dart';
import '../entry/entry_context_menu.dart';
import '../entry/entry_detail_sheet.dart';
import '../quick_add/quick_add_sheet.dart';
import '../wishlist/wishlist_screen.dart';
import 'home_providers.dart';
import 'pinned_store.dart';

/// Главная (§14): визуальная сводка активного профиля на реальных данных.
/// Пустые блоки не показываются.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(recentEntriesProvider);
    final recent = recentAsync.value ?? const <EntryView>[];
    final l10n = AppLocalizations.of(context);

    // Пока запрос идёт, «записей пока нет» — неправда: на большом профиле
    // главная успевала предложить завести первую запись человеку, у которого
    // их тысяча. Пустое состояние показываем, только когда ответ получен.
    if (recentAsync.isLoading && recent.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppDimens.space24),
        child: SkeletonList(),
      );
    }

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
        // Начатое — выше недавнего: «на чём я остановился» спрашивают чаще,
        // чем «что я заводил последним».
        const _ContinueBlock(),
        const _PinnedBlock(),
        const _YearAgoBlock(),
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
              context,
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
                context,
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

  Widget _grid(
    BuildContext context,
    List<Widget> children,
    int cols,
    double aspect,
  ) {
    return GridView.count(
      crossAxisCount: cols,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppDimens.space16,
      crossAxisSpacing: AppDimens.space16,
      // Соотношение делится на масштаб шрифта: подписи внутри плиток растут
      // вместе с ним, а ячейка иначе осталась бы прежней и переполнялась.
      childAspectRatio: aspect / MediaQuery.textScalerOf(context).scale(1),
      children: children,
    );
  }
}

/// Подсказка дня: одна задумка из тех, до чего ещё не дошли руки.
///
/// Список «Хочу попробовать» отвечает на вопрос «что я собирался», а он растёт
/// и перестаёт читаться. Одна строка отвечает на другой вопрос — «чем заняться
/// сегодня», — и на неё хватает взгляда.
class _SuggestionCard extends ConsumerWidget {
  const _SuggestionCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final entry = ref.watch(dailySuggestionProvider).value;
    if (entry == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.space24),
      child: AppCard(
        onTap: () => EntryDetailSheet.show(context, entry.entryId),
        child: Row(
          children: [
            Icon(
              Icons.lightbulb_outline_rounded,
              size: 20,
              color: c.accentPrimary,
            ),
            const SizedBox(width: AppDimens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.homeSuggestion,
                    style: context.text.labelSmall?.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                  Text(
                    entry.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// «Продолжить начатое» — записи на стадии «В процессе».
///
/// Блок пустым не показывается: правило главной — не занимать место рамкой
/// вокруг пустоты.
class _ContinueBlock extends ConsumerWidget {
  const _ContinueBlock();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final started =
        ref.watch(inProgressEntriesProvider).value ?? const <EntryView>[];
    if (started.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppDimens.space24),
        SectionHeader(title: l10n.homeContinue),
        const SizedBox(height: AppDimens.space16),
        for (var i = 0; i < started.length; i++) ...[
          if (i != 0) const SizedBox(height: AppDimens.space8),
          EntryMenuTarget(
            entry: started[i],
            child: EntryCardCompact(
              data: entryCardData(context, started[i]),
              onTap: () => EntryDetailSheet.show(context, started[i].entryId),
            ),
          ),
        ],
      ],
    );
  }
}

/// «Год назад» — что случилось примерно в эти же дни год назад.
class _YearAgoBlock extends ConsumerWidget {
  const _YearAgoBlock();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final then = ref.watch(yearAgoEntriesProvider).value ?? const <EntryView>[];
    if (then.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppDimens.space32),
        SectionHeader(title: l10n.homeYearAgo),
        const SizedBox(height: AppDimens.space16),
        LayoutBuilder(
          builder: (context, cns) {
            final cols = cns.maxWidth >= 900
                ? 4
                : cns.maxWidth >= 560
                ? 3
                : 2;
            return GridView.count(
              crossAxisCount: cols,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppDimens.space16,
              crossAxisSpacing: AppDimens.space16,
              childAspectRatio: 0.62,
              children: [
                for (final e in then.take(cols))
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
            );
          },
        ),
      ],
    );
  }
}

/// Закреплённые ветки и подборки.
///
/// Главная показывала то, что решило приложение: корневые категории и
/// недавнее. Что человек ведёт прямо сейчас, оно знать не могло.
class _PinnedBlock extends ConsumerWidget {
  const _PinnedBlock();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    final categoryIds =
        ref.watch(pinnedCategoryIdsProvider).value ?? const <String>[];
    final collectionIds =
        ref.watch(pinnedCollectionIdsProvider).value ?? const <String>[];
    if (categoryIds.isEmpty && collectionIds.isEmpty) {
      return const SizedBox.shrink();
    }

    final categories = ref.watch(allCategoriesProvider).value ?? const [];
    final counts = ref.watch(categoryBranchCountsProvider).value ?? const {};
    final collections = ref.watch(collectionsProvider).value ?? const [];

    // Закреплённое могли убрать в архив или удалить: пропускаем молча, а не
    // рисуем плитку в никуда.
    final pinnedCategories = [
      for (final id in categoryIds)
        ?categories.where((cat) => cat.id == id).firstOrNull,
    ];
    final pinnedCollections = [
      for (final id in collectionIds)
        ?collections.where((v) => v.collection.id == id).firstOrNull,
    ];
    if (pinnedCategories.isEmpty && pinnedCollections.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppDimens.space32),
        SectionHeader(title: l10n.homePinned),
        const SizedBox(height: AppDimens.space16),
        LayoutBuilder(
          builder: (context, cns) {
            final cols = cns.maxWidth >= 900
                ? 4
                : cns.maxWidth >= 560
                ? 2
                : 1;
            return GridView.count(
              crossAxisCount: cols,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppDimens.space16,
              crossAxisSpacing: AppDimens.space16,
              // Соотношение делится на масштаб шрифта — по тому же правилу,
              // что и в [_grid].
              childAspectRatio:
                  (cols == 1 ? 4.2 : 2.4) /
                  MediaQuery.textScalerOf(context).scale(1),
              children: [
                for (final category in pinnedCategories)
                  _CategoryTile(
                    name: category.name,
                    iconKey: category.icon,
                    color: CategoryPalette.colorOf(category, categories, c),
                    count: counts[category.id] ?? 0,
                    onTap: () {
                      ref
                          .read(selectedCategoryProvider.notifier)
                          .select(category.id);
                      ref.read(navProvider.notifier).go(NavIds.categories);
                    },
                  ),
                for (final view in pinnedCollections)
                  _CategoryTile(
                    name: view.collection.name,
                    iconKey: null,
                    icon: view.isSmart
                        ? Icons.auto_awesome_rounded
                        : Icons.collections_bookmark_rounded,
                    color: view.collection.color == null
                        ? c.profileColorFor(view.collection.id)
                        : Color(view.collection.color!),
                    count: view.entryCount,
                    onTap: () =>
                        ref.read(navProvider.notifier).go(NavIds.collections),
                  ),
              ],
            );
          },
        ),
      ],
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
    this.icon,
  });

  final String name;
  final String? iconKey;

  /// Готовый значок вместо ключа — у подборки своего значка в базе нет.
  final IconData? icon;

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
            child: Icon(
              icon ?? AppIcons.byKey(iconKey),
              size: 20,
              color: color,
            ),
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
        const _SuggestionCard(),
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
