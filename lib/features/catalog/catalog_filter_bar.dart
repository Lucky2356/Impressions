import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../core/domain/relation.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/db/database.dart';
import '../../data/models/entry_view.dart';
import '../../data/providers.dart';
import '../../design_system/design_system.dart';
import '../categories/category_providers.dart';
import '../entry/status_field.dart';
import '../home/home_providers.dart';
import 'catalog_providers.dart';
import 'catalog_screen.dart';

class FilterBar extends ConsumerWidget {
  const FilterBar({
    super.key,
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
      state.status != null,
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
    final filterToggle = FilterToggle(
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
      // Стадия отвечает на другой вопрос, чем отношение: «дошли ли вы до
      // этого». Названия у типов свои, а ключи общие — поэтому в отборе стоят
      // три общих стадии, а не объединение всех наборов.
      AppDropdown<String?>(
        label: l10n.catalogStatusLabel,
        icon: Icons.timeline_rounded,
        value: state.status,
        expand: true,
        items: [
          DropdownMenuItem(value: null, child: Text(l10n.catalogAllStatuses)),
          for (final entry in catalogStatusKeys(l10n))
            DropdownMenuItem(value: entry.key, child: Text(entry.label)),
        ],
        onChanged: controller.setStatus,
        active: state.status != null,
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
      // Отбор становится подборкой: «без оценки в Продуктах» собирали заново
      // каждый раз, хотя это те же несколько переключателей. Раньше рядом
      // жили «сохранённые отборы» — свой список в настройках, умевший только
      // применяться к каталогу; теперь сохранённый отбор — это подборка,
      // которую видно, можно назвать, оформить и открыть списком.
      if (hasFilters) const SaveAsCollectionButton(),
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
class FilterToggle extends StatelessWidget {
  const FilterToggle({
    super.key,
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

/// Сохраняет нынешний отбор живой подборкой (§27).
///
/// Живая подборка и есть сохранённый отбор — только у неё есть имя, цвет,
/// обложка и своё место в разделе, а не строчка в выпадающем меню.
class SaveAsCollectionButton extends ConsumerWidget {
  const SaveAsCollectionButton({super.key});

  Future<void> _save(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final profile = ref.read(activeProfileProvider);
    if (profile == null) return;

    final name = await TextInputDialog.show(
      context,
      title: l10n.collectionFromFilter,
      label: l10n.collectionNameLabel,
    );
    if (name == null || name.trim().isEmpty || !context.mounted) return;

    // Запрос в поиске в условие не попадает: он набирается на минуту, а
    // подборка остаётся. `toJson` его и не пишет.
    await ref
        .read(collectionRepositoryProvider)
        .create(
          profile.id,
          name.trim(),
          filterJson: jsonEncode(ref.read(catalogStateProvider).toJson()),
        );
    ref.read(dataRefreshProvider.notifier).bump();
    if (!context.mounted) return;
    showMessage(context, l10n.collectionFromFilterSaved(name.trim()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return TextButton.icon(
      onPressed: () => _save(context, ref),
      icon: const Icon(Icons.auto_awesome_rounded, size: 16),
      label: Text(l10n.collectionFromFilter),
    );
  }
}
