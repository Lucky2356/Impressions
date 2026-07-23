import 'dart:async';

import 'package:flutter/material.dart';
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
import '../entry/entry_detail_sheet.dart';
import '../home/home_providers.dart';
import '../quick_add/quick_add_sheet.dart';
import 'catalog_providers.dart';

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
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(catalogStateProvider).search;
  }

  @override
  void dispose() {
    _debounce?.cancel();
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

    final state = ref.read(catalogStateProvider);
    final filtered =
        state.search.isNotEmpty ||
        state.typeId != null ||
        state.relation != null ||
        state.categoryId != null ||
        state.tagIds.isNotEmpty;
    if (!filtered) return;

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
    final count = results.value?.length;

    // Строку поиска мог заполнить глобальный поиск в шапке — синхронизируем.
    if (_searchController.text != state.search &&
        (_debounce == null || !_debounce!.isActive)) {
      _searchController.text = state.search;
    }

    return ScreenScaffold(
      constrain: false,
      header: ScreenHeader(
        constrain: false,
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
          onSearchChanged: _onSearchChanged,
        ),
      ),
      child: results.when(
        loading: () => const SizedBox.shrink(),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) {
          if (list.isEmpty) {
            final filtered =
                state.search.isNotEmpty ||
                state.typeId != null ||
                state.relation != null ||
                state.categoryId != null ||
                state.tagIds.isNotEmpty;
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
          return _Results(entries: list, view: state.view);
        },
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.entries, required this.view});

  final List<EntryView> entries;
  final CatalogViewMode view;

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;

    if (view == CatalogViewMode.list) {
      return ListView.separated(
        padding: EdgeInsets.fromLTRB(
          layout.gutter,
          AppDimens.space16,
          layout.gutter,
          AppDimens.space40,
        ),
        itemCount: entries.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppDimens.space8),
        itemBuilder: (context, i) => EntryCardCompact(
          data: _toCardData(context, entries[i]),
          onTap: () => EntryDetailSheet.show(context, entries[i].entryId),
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
        return GridView.builder(
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
            ),
          ),
          itemCount: entries.length,
          itemBuilder: (context, i) => EntryCard(
            dense: dense,
            data: _toCardData(context, entries[i]),
            onTap: () => EntryDetailSheet.show(context, entries[i].entryId),
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
    required this.onSearchChanged,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(catalogStateProvider);
    final controller = ref.read(catalogStateProvider.notifier);
    final types = ref.watch(objectTypesProvider).value ?? const [];
    final categories = ref.watch(allCategoriesProvider).value ?? const [];

    final tags = ref.watch(profileTagsProvider).value ?? const <TagRow>[];
    final hasFilters =
        state.search.isNotEmpty ||
        state.typeId != null ||
        state.relation != null ||
        state.categoryId != null ||
        state.tagIds.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Поле поиска не растягивается на всю ширину окна: на широком
            // мониторе строка ввода в 1800 точек выглядит нелепо.
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SizedBox(
                width: 420,
                child: AppSearchField(
                  hint: l10n.catalogSearchHint,
                  controller: searchController,
                  onChanged: onSearchChanged,
                ),
              ),
            ),
            const Spacer(),
            const SizedBox(width: AppDimens.space12),
            SegmentedToggle<CatalogViewMode>(
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
            ),
          ],
        ),
        const SizedBox(height: AppDimens.space12),
        Wrap(
          spacing: AppDimens.space8,
          runSpacing: AppDimens.space8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            AppDropdown<String?>(
              label: l10n.catalogTypeLabel,
              icon: Icons.category_rounded,
              value: state.typeId,
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(l10n.catalogAllTypes),
                ),
                for (final t in types)
                  DropdownMenuItem(value: t.id, child: Text(t.name)),
              ],
              onChanged: controller.setType,
            ),
            AppDropdown<String?>(
              label: l10n.catalogCategoryLabel,
              icon: Icons.account_tree_rounded,
              value: state.categoryId,
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(l10n.catalogAllCategories),
                ),
                for (final cat in categories)
                  DropdownMenuItem(
                    value: cat.id,
                    child: Text('${'   ' * cat.level}${cat.name}'),
                  ),
              ],
              onChanged: controller.setCategory,
            ),
            AppDropdown<String?>(
              label: l10n.catalogRelationLabel,
              icon: Icons.favorite_rounded,
              value: state.relation,
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(l10n.catalogAllRelations),
                ),
                for (final r in Relation.values)
                  DropdownMenuItem(value: r.name, child: Text(r.label(l10n))),
              ],
              onChanged: controller.setRelation,
            ),
            AppDropdown<EntrySort>(
              label: l10n.catalogSortLabel,
              icon: Icons.sort_rounded,
              value: state.sort,
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
            // Теги — плоские метки, поэтому выбираются чипами, а не списком:
            // их можно выбрать несколько сразу.
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
          ],
        ),
      ],
    );
  }
}
