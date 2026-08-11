import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../core/domain/relation.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_layout.dart';
import '../../core/theme/theme_context.dart';
import '../../data/db/database.dart';
import '../../data/models/entry_view.dart';
import '../../data/providers.dart';
import '../../design_system/design_system.dart';
import '../categories/category_providers.dart';
import '../home/home_providers.dart';
import '../quick_add/quick_add_sheet.dart';
import 'catalog_providers.dart';
import 'catalog_selection.dart';
import 'entry_tile.dart';

/// Теги активного профиля — источник для фильтра.
final profileTagsProvider = FutureProvider<List<TagRow>>((ref) async {
  ref.watch(dataRefreshProvider);
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return const [];
  return ref.watch(entryRepositoryProvider).tagsOfProfile(profile.id);
});

/// Каталог записей (§15): режимы отображения, фильтры, сортировка, поиск.
/// Состояние режима и переключателя подкатегорий сохраняется.
class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  Timer? _debounce;

  /// Развёрнута ли панель фильтров. На широком окне она открыта сразу, на
  /// телефоне прячется — иначе четыре списка занимают экран до первой записи.
  bool? _filtersExpanded;

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(catalogStateProvider).search;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchFocus.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Поиск с задержкой, чтобы не дёргать базу на каждый символ (§29).
  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      ref.read(catalogStateProvider.notifier).setSearch(value);
    });
  }

  /// Добавление записи из каталога.
  ///
  /// Если включены фильтры, новая запись может под них не подойти и создаётся
  /// впечатление, что она не сохранилась. Поэтому предлагаем сбросить фильтры.
  Future<void> _add() async {
    final l10n = AppLocalizations.of(context);
    final added = await QuickAddSheet.show(context);
    if (!added || !mounted) return;

    if (!ref.read(catalogStateProvider).hasFilters) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.catalogAddedHiddenByFilters),
        action: SnackBarAction(
          label: l10n.catalogResetFilters,
          onPressed: () {
            _searchController.clear();
            ref.read(catalogStateProvider.notifier).reset();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(catalogStateProvider);
    final results = ref.watch(catalogResultsProvider);
    // Общее число под фильтрами, а не размер загруженной страницы.
    final count = results.value?.total;

    // На телефоне в каталог приходят по значку поиска: курсор ставим сразу,
    // иначе человек попадает сюда и снова ищет, куда нажать.
    ref.listen(
      catalogSearchFocusProvider,
      (_, _) => _searchFocus.requestFocus(),
    );

    // Строку поиска мог заполнить глобальный поиск в шапке — синхронизируем.
    if (_searchController.text != state.search &&
        (_debounce == null || !_debounce!.isActive)) {
      _searchController.text = state.search;
    }

    // Каталог держится той же колонки, что и остальные разделы: раньше он один
    // растягивался во всю ширину окна, и при переходе с главной содержимое
    // заметно «прыгало» по горизонтали на широком мониторе.
    return ScreenScaffold(
      header: ScreenHeader(
        title: l10n.navCatalog,
        subtitle: count == null ? null : l10n.catalogFound(count),
        actions: [
          FilledButton.icon(
            onPressed: _add,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: Text(l10n.commonAdd),
          ),
        ],
        bottom: _FilterBar(
          searchController: _searchController,
          searchFocus: _searchFocus,
          onSearchChanged: _onSearchChanged,
          expanded: _filtersExpanded ?? context.layout.isWide,
          onToggleFilters: () => setState(
            () =>
                _filtersExpanded = !(_filtersExpanded ?? context.layout.isWide),
          ),
        ),
      ),
      child: results.when(
        loading: () => const SizedBox.shrink(),
        error: (e, _) => ErrorState(error: e),
        data: (found) {
          final list = found.items;
          if (list.isEmpty) {
            final filtered = state.hasFilters;
            return EmptyState(
              icon: filtered
                  ? Icons.search_off_rounded
                  : Icons.auto_stories_rounded,
              title: filtered
                  ? l10n.catalogNothingFoundTitle
                  : l10n.catalogEmptyTitle,
              message: filtered
                  ? l10n.catalogNothingFoundMessage
                  : l10n.catalogEmptyMessage,
              action: filtered
                  ? OutlinedButton(
                      onPressed: () {
                        _searchController.clear();
                        ref.read(catalogStateProvider.notifier).reset();
                      },
                      child: Text(l10n.catalogResetFilters),
                    )
                  : FilledButton.icon(
                      onPressed: () => QuickAddSheet.show(context),
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: Text(l10n.commonAdd),
                    ),
            );
          }
          return _CatalogShortcuts(
            entries: list,
            child: Column(
              children: [
                // Панель появляется по факту выделения, а не по его составу:
                // иначе весь экран перестраивался на каждое нажатие.
                if (ref.watch(
                  catalogSelectionProvider.select((s) => s.isNotEmpty),
                ))
                  BulkActionsBar(
                    onSelectAll: () => ref
                        .read(catalogSelectionProvider.notifier)
                        .selectAll(list.map((e) => e.entryId)),
                  ),
                Expanded(
                  child: _Results(
                    entries: list,
                    view: state.view,
                    hasMore: found.hasMore,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Каталог с клавиатурой и панелью массовых действий.
///
/// Стрелки и Enter работают через обычный обход фокуса Flutter: карточки
/// фокусируемы, поэтому отдельный обработчик нужен только для действий над
/// выделением.
class _CatalogShortcuts extends ConsumerWidget {
  const _CatalogShortcuts({required this.entries, required this.child});

  final List<EntryView> entries;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.read(catalogSelectionProvider.notifier);
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyA, control: true): () =>
            selection.selectAll(entries.map((e) => e.entryId)),
        const SingleActivator(LogicalKeyboardKey.escape): selection.clear,
      },
      child: Focus(child: child),
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({
    required this.entries,
    required this.view,
    required this.hasMore,
  });

  final List<EntryView> entries;
  final CatalogViewMode view;

  /// Есть ли что подгружать дальше.
  final bool hasMore;

  /// Подгружает следующую страницу, когда до конца списка осталось немного.
  bool _onScroll(ScrollNotification n, WidgetRef ref) {
    if (!hasMore) return false;
    final metrics = n.metrics;
    if (metrics.pixels >= metrics.maxScrollExtent - 600) {
      ref.read(catalogPageProvider.notifier).more();
    }
    return false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = context.layout;
    // Списку хватает знать, что выделение вообще есть: сами отметки карточки
    // читают по одной, иначе каждое нажатие перестраивало бы всю страницу.
    final selectionActive = ref.watch(
      catalogSelectionProvider.select((s) => s.isNotEmpty),
    );
    // Порядок, в котором записи показаны: по нему Shift+клик берёт диапазон.
    final order = [for (final e in entries) e.entryId];

    if (view == CatalogViewMode.list) {
      return NotificationListener<ScrollNotification>(
        onNotification: (n) => _onScroll(n, ref),
        child: ListView.separated(
          // Разделы живут в `KeyedSubtree` и при переключении уничтожаются:
          // без своего ключа в хранилище страницы каталог возвращался в
          // начало, и подгруженное приходилось докручивать заново.
          key: const PageStorageKey('catalog-list'),
          padding: EdgeInsets.fromLTRB(
            layout.gutter,
            AppDimens.space16,
            layout.gutter,
            AppDimens.space40,
          ),
          itemCount: entries.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppDimens.space8),
          itemBuilder: (context, i) => Appear(
            index: i,
            child: EntryTile(
              entry: entries[i],
              selectionActive: selectionActive,
              order: order,
              builder: (onTap) => EntryCardCompact(
                data: _toCardData(context, entries[i]),
                onTap: onTap,
              ),
            ),
          ),
        ),
      );
    }

    final dense = view == CatalogViewMode.compact;
    // Ширина ячейки берётся из раскладки: на 4K помещается заметно больше
    // карточек, а не растягиваются те же самые.
    final tile = dense ? layout.gridTileWidth * 0.78 : layout.gridTileWidth;

    return LayoutBuilder(
      builder: (context, cns) {
        final cols = layout.columnsFor(cns.maxWidth, tileWidth: tile);
        return NotificationListener<ScrollNotification>(
          onNotification: (n) => _onScroll(n, ref),
          child: GridView.builder(
            key: const PageStorageKey('catalog-grid'),
            padding: EdgeInsets.fromLTRB(
              layout.gutter,
              AppDimens.space16,
              layout.gutter,
              AppDimens.space40,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              mainAxisSpacing: AppDimens.space12,
              crossAxisSpacing: AppDimens.space12,
              childAspectRatio: entryCardAspectRatio(
                availableWidth: cns.maxWidth,
                columns: cols,
                outerPadding: layout.gutter * 2,
                dense: dense,
                textScale: MediaQuery.textScalerOf(context).scale(1),
              ),
            ),
            itemCount: entries.length,
            itemBuilder: (context, i) => Appear(
              index: i,
              child: EntryTile(
                entry: entries[i],
                selectionActive: selectionActive,
                order: order,
                builder: (onTap) => EntryCard(
                  dense: dense,
                  data: _toCardData(context, entries[i]),
                  onTap: onTap,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  EntryCardData _toCardData(BuildContext context, EntryView e) {
    return EntryCardData(
      title: e.title,
      subtitle: e.subtitle,
      categoryPath: e.categoryPath,
      relation: _relationOf(e.relation),
      rating: e.rating,
      imagePath: e.coverPath,
      seedColor: context.colors.profileColorFor(e.objectId),
    );
  }

  Relation? _relationOf(String? name) {
    if (name == null) return null;
    for (final r in Relation.values) {
      if (r.name == name) return r;
    }
    return null;
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar({
    required this.searchController,
    required this.searchFocus,
    required this.onSearchChanged,
    required this.expanded,
    required this.onToggleFilters,
  });

  final TextEditingController searchController;
  final FocusNode searchFocus;
  final ValueChanged<String> onSearchChanged;

  /// Показаны ли списки фильтров.
  final bool expanded;
  final VoidCallback onToggleFilters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(catalogStateProvider);
    final controller = ref.read(catalogStateProvider.notifier);
    final types = ref.watch(objectTypesProvider).value ?? const [];
    final categories = ref.watch(allCategoriesProvider).value ?? const [];

    final tags = ref.watch(profileTagsProvider).value ?? const <TagRow>[];
    final hasFilters = state.hasFilters;

    // Сколько фильтров включено — число на кнопке, когда панель свёрнута.
    final activeCount = [
      state.typeId != null,
      state.categoryId != null,
      state.relation != null,
      state.tagIds.isNotEmpty,
      state.withoutRating,
      state.withoutCategory,
      state.withoutPhoto,
      state.recommendedOnly,
    ].where((x) => x).length;

    final search = AppSearchField(
      hint: l10n.catalogSearchHint,
      controller: searchController,
      focusNode: searchFocus,
      onChanged: onSearchChanged,
    );
    // Фильтры прячутся за одну кнопку: четыре списка подряд занимали на
    // телефоне пол-экрана ещё до первой записи.
    final filterToggle = _FilterToggle(
      expanded: expanded,
      activeCount: activeCount,
      onPressed: onToggleFilters,
    );
    final viewToggle = SegmentedToggle<CatalogViewMode>(
      value: state.view,
      onChanged: controller.setView,
      segments: [
        SegmentData(
          value: CatalogViewMode.grid,
          icon: Icons.grid_view_rounded,
          tooltip: l10n.catalogViewGrid,
        ),
        SegmentData(
          value: CatalogViewMode.compact,
          icon: Icons.apps_rounded,
          tooltip: l10n.catalogViewCompact,
        ),
        SegmentData(
          value: CatalogViewMode.list,
          icon: Icons.view_list_rounded,
          tooltip: l10n.catalogViewList,
        ),
      ],
    );

    final dropdowns = <Widget>[
      AppDropdown<String?>(
        label: l10n.catalogTypeLabel,
        icon: Icons.category_rounded,
        value: state.typeId,
        expand: true,
        items: [
          DropdownMenuItem(value: null, child: Text(l10n.catalogAllTypes)),
          for (final t in types)
            DropdownMenuItem(value: t.id, child: Text(t.name)),
        ],
        onChanged: controller.setType,
        active: state.typeId != null,
      ),
      AppDropdown<String?>(
        label: l10n.catalogCategoryLabel,
        icon: Icons.account_tree_rounded,
        value: state.categoryId,
        expand: true,
        items: [
          DropdownMenuItem(value: null, child: Text(l10n.catalogAllCategories)),
          for (final cat in categories)
            DropdownMenuItem(
              value: cat.id,
              child: Text('${'   ' * cat.level}${cat.name}'),
            ),
        ],
        onChanged: controller.setCategory,
        active: state.categoryId != null,
      ),
      AppDropdown<String?>(
        label: l10n.catalogRelationLabel,
        icon: Icons.favorite_rounded,
        value: state.relation,
        expand: true,
        items: [
          DropdownMenuItem(value: null, child: Text(l10n.catalogAllRelations)),
          for (final r in Relation.values)
            DropdownMenuItem(value: r.name, child: Text(r.label(l10n))),
        ],
        onChanged: controller.setRelation,
        active: state.relation != null,
      ),
      AppDropdown<EntrySort>(
        label: l10n.catalogSortLabel,
        icon: Icons.sort_rounded,
        value: state.sort,
        expand: true,
        items: [
          DropdownMenuItem(
            value: EntrySort.recent,
            child: Text(l10n.catalogSortRecent),
          ),
          DropdownMenuItem(
            value: EntrySort.title,
            child: Text(l10n.catalogSortTitle),
          ),
          DropdownMenuItem(
            value: EntrySort.rating,
            child: Text(l10n.catalogSortRating),
          ),
          DropdownMenuItem(
            value: EntrySort.impressionDate,
            child: Text(l10n.catalogSortImpression),
          ),
        ],
        onChanged: (v) => controller.setSort(v ?? EntrySort.recent),
        active: state.sort != EntrySort.recent,
      ),
    ];

    // Кнопка направления стоит вплотную к сортировке: порядок был задан
    // жёстко, и «худшие сначала», «Я → А» и «самые старые» не получались никак.
    final sortCell = Row(
      children: [
        Expanded(child: dropdowns.removeLast()),
        const SizedBox(width: AppDimens.space8),
        IconActionButton(
          icon: state.reverseSort
              ? Icons.arrow_upward_rounded
              : Icons.arrow_downward_rounded,
          tooltip: state.reverseSort
              ? l10n.catalogSortReversed
              : l10n.catalogSortNatural,
          onPressed: controller.toggleSortDirection,
          size: AppDimens.controlHeightSm,
        ),
      ],
    );
    dropdowns.add(sortCell);

    // Списки одной ширины: в ряд по два (широкий экран) или столбцом на всю
    // ширину (телефон). Так фильтры выглядят единообразно, а не «короткий —
    // длинный — короткий».
    final filterGrid = LayoutBuilder(
      builder: (context, cns) {
        final cols = cns.maxWidth >= 900 ? 4 : (cns.maxWidth >= 520 ? 2 : 1);
        final gap = AppDimens.space8;
        final cellWidth = cols == 1
            ? cns.maxWidth
            : (cns.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final d in dropdowns) SizedBox(width: cellWidth, child: d),
          ],
        );
      },
    );

    final chips = <Widget>[
      // Запрос мог прийти из шапки — тогда пользователь не набирал его здесь и
      // не понимает, почему список сузился.
      if (state.search.isNotEmpty)
        InputChip(
          label: Text(l10n.catalogSearchChip(state.search)),
          avatar: const Icon(Icons.search_rounded, size: 16),
          deleteIcon: const Icon(Icons.close_rounded, size: 16),
          onDeleted: () {
            searchController.clear();
            controller.setSearch('');
          },
        ),
      if (state.categoryId != null)
        FilterChip(
          selected: state.includeSubcategories,
          onSelected: controller.setIncludeSubcategories,
          label: Text(l10n.categoryShowSubcategories),
          showCheckmark: false,
          avatar: Icon(
            state.includeSubcategories
                ? Icons.check_rounded
                : Icons.subdirectory_arrow_right_rounded,
            size: 16,
          ),
        ),
      // «Что я не доделал». Фильтры отвечали только на «покажи вот такие»:
      // найти записи без оценки или сложенные мимо категорий было нельзя.
      FilterChip(
        selected: state.withoutRating,
        onSelected: controller.setWithoutRating,
        label: Text(l10n.catalogWithoutRating),
        showCheckmark: false,
        avatar: Icon(
          state.withoutRating ? Icons.check_rounded : Icons.star_border_rounded,
          size: 16,
        ),
      ),
      FilterChip(
        selected: state.withoutCategory,
        onSelected: controller.setWithoutCategory,
        label: Text(l10n.catalogWithoutCategory),
        showCheckmark: false,
        avatar: Icon(
          state.withoutCategory
              ? Icons.check_rounded
              : Icons.folder_off_outlined,
          size: 16,
        ),
      ),
      FilterChip(
        selected: state.withoutPhoto,
        onSelected: controller.setWithoutPhoto,
        label: Text(l10n.catalogWithoutPhoto),
        showCheckmark: false,
        avatar: Icon(
          state.withoutPhoto
              ? Icons.check_rounded
              : Icons.image_not_supported_outlined,
          size: 16,
        ),
      ),
      // Кто что посоветовал, приложение помнило и не показывало.
      FilterChip(
        selected: state.recommendedOnly,
        onSelected: controller.setRecommendedOnly,
        label: Text(l10n.catalogRecommended),
        showCheckmark: false,
        avatar: Icon(
          state.recommendedOnly
              ? Icons.check_rounded
              : Icons.person_outline_rounded,
          size: 16,
        ),
      ),
      // Теги — плоские метки, поэтому выбираются чипами, а не списком: их можно
      // выбрать несколько сразу.
      for (final tag in tags)
        FilterChip(
          selected: state.tagIds.contains(tag.id),
          onSelected: (_) => controller.toggleTag(tag.id),
          label: Text(tag.name),
          showCheckmark: false,
          avatar: Icon(
            state.tagIds.contains(tag.id)
                ? Icons.check_rounded
                : Icons.label_outline_rounded,
            size: 16,
          ),
        ),
      if (hasFilters)
        TextButton.icon(
          onPressed: () {
            searchController.clear();
            controller.reset();
          },
          icon: const Icon(Icons.close_rounded, size: 16),
          label: Text(l10n.catalogResetFilters),
        ),
    ];

    // Решаем по месту, а не по ширине окна: каталог может стоять рядом с
    // боковой панелью, и «окно широкое» ещё не значит «строки хватает».
    return LayoutBuilder(
      builder: (context, cns) {
        // Поиск, кнопка фильтров и переключатель вида в одной строке помещаются
        // примерно от 620 точек. Ниже — поиск схлопывался до одного значка.
        final oneRow = cns.maxWidth >= 620;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (oneRow)
              Row(
                children: [
                  // На широком мониторе строка ввода в 1800 точек выглядит
                  // нелепо, поэтому поле ограничено.
                  Flexible(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: search,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: AppDimens.space8),
                  filterToggle,
                  const SizedBox(width: AppDimens.space8),
                  viewToggle,
                ],
              )
            else ...[
              search,
              const SizedBox(height: AppDimens.space8),
              Row(children: [filterToggle, const Spacer(), viewToggle]),
            ],
            if (expanded) ...[
              const SizedBox(height: AppDimens.space12),
              filterGrid,
              if (chips.isNotEmpty) ...[
                const SizedBox(height: AppDimens.space8),
                Wrap(
                  spacing: AppDimens.space8,
                  runSpacing: AppDimens.space8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: chips,
                ),
              ],
            ],
          ],
        );
      },
    );
  }
}

/// Кнопка «Фильтры» со счётчиком включённых.
class _FilterToggle extends StatelessWidget {
  const _FilterToggle({
    required this.expanded,
    required this.activeCount,
    required this.onPressed,
  });

  final bool expanded;
  final int activeCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final on = expanded || activeCount > 0;

    return Material(
      color: on ? c.accentSoft : c.surfaceMuted,
      borderRadius: AppDimens.brPill,
      child: InkWell(
        borderRadius: AppDimens.brPill,
        onTap: onPressed,
        child: Container(
          height: AppDimens.controlHeightSm,
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.space12),
          decoration: BoxDecoration(
            borderRadius: AppDimens.brPill,
            border: Border.all(color: on ? c.accentPrimary : c.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tune_rounded,
                size: 16,
                color: on ? c.accentPrimary : c.textMuted,
              ),
              const SizedBox(width: AppDimens.space8),
              Text(
                l10n.catalogFilters,
                style: context.text.labelMedium?.copyWith(
                  color: on ? c.accentPrimary : c.textSecondary,
                ),
              ),
              if (activeCount > 0) ...[
                const SizedBox(width: AppDimens.space8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: c.accentPrimary,
                    borderRadius: AppDimens.brPill,
                  ),
                  child: Text(
                    '$activeCount',
                    style: context.text.labelSmall?.copyWith(
                      color: c.accentPrimaryOn,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
