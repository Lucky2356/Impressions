import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/relation.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/models/entry_view.dart';
import '../../design_system/design_system.dart';
import '../categories/category_providers.dart';
import '../entry/entry_detail_sheet.dart';
import '../home/home_providers.dart';
import '../quick_add/quick_add_sheet.dart';
import 'catalog_providers.dart';

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
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(catalogStateProvider.notifier).setSearch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final state = ref.watch(catalogStateProvider);
    final results = ref.watch(catalogResultsProvider);

    return Column(
      children: [
        _FilterBar(
          searchController: _searchController,
          onSearchChanged: _onSearchChanged,
        ),
        Divider(height: 1, color: c.border),
        Expanded(
          child: results.when(
            loading: () => const SizedBox.shrink(),
            error: (e, _) => Center(child: Text('$e')),
            data: (list) {
              if (list.isEmpty) {
                final filtered =
                    state.search.isNotEmpty ||
                    state.typeId != null ||
                    state.relation != null ||
                    state.categoryId != null;
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
        ),
      ],
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.entries, required this.view});

  final List<EntryView> entries;
  final CatalogViewMode view;

  @override
  Widget build(BuildContext context) {
    if (view == CatalogViewMode.list) {
      return ListView.separated(
        padding: const EdgeInsets.all(AppDimens.space20),
        itemCount: entries.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppDimens.space12),
        itemBuilder: (context, i) => EntryCardCompact(
          data: _toCardData(context, entries[i]),
          onTap: () => EntryDetailSheet.show(context, entries[i].entryId),
        ),
      );
    }

    final compact = view == CatalogViewMode.compact;
    return LayoutBuilder(
      builder: (context, cns) {
        final target = compact ? 180.0 : 240.0;
        final cols = (cns.maxWidth / target).floor().clamp(2, 8);
        return GridView.builder(
          padding: const EdgeInsets.all(AppDimens.space20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: AppDimens.space16,
            crossAxisSpacing: AppDimens.space16,
            childAspectRatio: entryCardAspectRatio(
              availableWidth: cns.maxWidth,
              columns: cols,
            ),
          ),
          itemCount: entries.length,
          itemBuilder: (context, i) => EntryCard(
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
    final c = context.colors;
    final state = ref.watch(catalogStateProvider);
    final controller = ref.read(catalogStateProvider.notifier);
    final types = ref.watch(objectTypesProvider).value ?? const [];
    final categories = ref.watch(allCategoriesProvider).value ?? const [];
    final count = ref.watch(catalogResultsProvider).value?.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space20,
        AppDimens.space16,
        AppDimens.space20,
        AppDimens.space12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: TextField(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    decoration: InputDecoration(
                      hintText: l10n.catalogSearchHint,
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      isDense: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.space12),
              _ViewToggle(view: state.view, onChanged: controller.setView),
            ],
          ),
          const SizedBox(height: AppDimens.space12),
          Wrap(
            spacing: AppDimens.space8,
            runSpacing: AppDimens.space8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _Dropdown<String?>(
                label: l10n.catalogAllTypes,
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
              _Dropdown<String?>(
                label: l10n.catalogAllCategories,
                value: state.categoryId,
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(l10n.catalogAllCategories),
                  ),
                  for (final cat in categories)
                    DropdownMenuItem(
                      value: cat.id,
                      child: Text('${'  ' * cat.level}${cat.name}'),
                    ),
                ],
                onChanged: controller.setCategory,
              ),
              _Dropdown<String?>(
                label: l10n.catalogAllRelations,
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
              _Dropdown<EntrySort>(
                label: l10n.catalogSortLabel,
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
                ),
              if (count != null)
                Text(
                  l10n.catalogFound(count),
                  style: context.text.labelSmall?.copyWith(color: c.textMuted),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.space12),
      decoration: BoxDecoration(
        color: c.surfaceMuted,
        borderRadius: AppDimens.brPill,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          isDense: true,
          borderRadius: AppDimens.brMd,
          style: context.text.labelMedium,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: c.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.view, required this.onChanged});

  final CatalogViewMode view;
  final ValueChanged<CatalogViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    Widget seg(CatalogViewMode mode, IconData icon, String tip) {
      final active = view == mode;
      return Tooltip(
        message: tip,
        child: Material(
          color: active ? c.navActiveBg : Colors.transparent,
          borderRadius: AppDimens.brSm,
          child: InkWell(
            borderRadius: AppDimens.brSm,
            onTap: () => onChanged(mode),
            child: SizedBox(
              width: 40,
              height: 36,
              child: Icon(
                icon,
                size: 18,
                color: active ? c.navActiveFg : c.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: c.surfaceMuted,
        borderRadius: AppDimens.brMd,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          seg(
            CatalogViewMode.grid,
            Icons.grid_view_rounded,
            l10n.catalogViewGrid,
          ),
          seg(
            CatalogViewMode.compact,
            Icons.apps_rounded,
            l10n.catalogViewCompact,
          ),
          seg(
            CatalogViewMode.list,
            Icons.view_list_rounded,
            l10n.catalogViewList,
          ),
        ],
      ),
    );
  }
}
