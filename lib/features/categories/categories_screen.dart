import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../core/domain/app_icons.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_layout.dart';
import '../../core/theme/theme_context.dart';
import '../../core/utils/normalize.dart';
import '../../data/db/database.dart';
import '../../data/providers.dart';
import '../../data/repositories/category_repository.dart';
import '../../design_system/design_system.dart';
import '../quick_add/category_picker.dart';
import 'category_detail.dart';
import 'category_providers.dart';

/// Экран категорий (§7): дерево слева, содержимое выбранной ветки справа.
///
/// Раньше это был плоский список, по которому нельзя было ни понять
/// вложенность, ни посмотреть, что в категории лежит. Нажатие на строку
/// уводило в каталог и незаметно подставляло ему фильтр, из-за чего в каталоге
/// потом «пропадали» новые записи. Теперь ветка раскрывается на месте, а
/// состояние каталога экран категорий не трогает вовсе.
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

/// Как показывать категории: полками или деревом.
enum CategoryViewMode { shelves, tree }

/// Переключатель «полки / дерево». Один виджет на оба режима: он должен быть
/// виден и в полках, и в дереве, иначе из дерева не вернуться.
class CategoryModeToggle extends StatelessWidget {
  const CategoryModeToggle({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  final CategoryViewMode mode;
  final ValueChanged<CategoryViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SegmentedToggle<CategoryViewMode>(
      value: mode,
      onChanged: onChanged,
      segments: [
        SegmentData(
          value: CategoryViewMode.shelves,
          icon: Icons.grid_view_rounded,
          tooltip: l10n.categoryViewShelves,
        ),
        SegmentData(
          value: CategoryViewMode.tree,
          icon: Icons.account_tree_rounded,
          tooltip: l10n.categoryViewTree,
        ),
      ],
    );
  }
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final Set<String> _collapsed = {};
  final _searchController = TextEditingController();
  String _query = '';

  /// Полки или дерево. По умолчанию полки: дерево нужно, когда категорий много
  /// и важна вложенность, а не когда нужно понять, что внутри.
  CategoryViewMode _mode = CategoryViewMode.shelves;

  /// Какая ветка раскрыта в режиме полок; null — корень.
  String? _shelfParentId;

  String? _parentOf(List<CategoryRow> all, String? id) {
    if (id == null) return null;
    return all.where((x) => x.id == id).firstOrNull?.parentId;
  }

  /// Меню полки: те же действия, что и в дереве.
  Future<void> _shelfMenu(CategoryRow cat, Offset position) async {
    final l10n = AppLocalizations.of(context);
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;

    final action = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(1, 1),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(value: 'add', child: Text(l10n.categoryAddChild)),
        PopupMenuItem(value: 'rename', child: Text(l10n.categoryRename)),
        PopupMenuItem(value: 'icon', child: Text(l10n.categoryIcon)),
        PopupMenuItem(value: 'move', child: Text(l10n.categoryMove)),
        // Порядок задавался только полем в базе, которое никто не выставлял.
        PopupMenuItem(value: 'up', child: Text(l10n.categoryMoveUp)),
        PopupMenuItem(value: 'down', child: Text(l10n.categoryMoveDown)),
        PopupMenuItem(value: 'archive', child: Text(l10n.categoryArchive)),
      ],
    );
    if (!mounted) return;
    switch (action) {
      case 'add':
        await _createChild(cat);
      case 'rename':
        await _rename(cat);
      case 'icon':
        await _pickIcon(cat);
      case 'move':
        await _move(cat);
      case 'up':
        await _reorder(cat, up: true);
      case 'down':
        await _reorder(cat, up: false);
      case 'archive':
        await _archive(cat);
    }
  }

  /// Переставить категорию на шаг среди соседей.
  Future<void> _reorder(CategoryRow cat, {required bool up}) async {
    final l10n = AppLocalizations.of(context);
    final moved = await ref
        .read(categoryRepositoryProvider)
        .reorder(cat.id, up: up);
    if (!mounted) return;
    if (!moved) {
      // Молча ничего не делать нельзя: нажатие выглядит как поломка.
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.categoryMoveEdge)));
      return;
    }
    _bump();
  }

  // Выбранная ветка живёт в провайдере: на категорию нажимают и с главной.
  String? get _selectedId => ref.watch(selectedCategoryProvider);
  void _setSelected(String? id) =>
      ref.read(selectedCategoryProvider.notifier).select(id);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _bump() => ref.read(dataRefreshProvider.notifier).bump();

  Future<String?> _askName(String title, {String? initial}) {
    final l10n = AppLocalizations.of(context);
    return TextInputDialog.show(
      context,
      title: title,
      label: l10n.categoryNameLabel,
      initial: initial,
    );
  }

  Future<void> _createRoot() async {
    final l10n = AppLocalizations.of(context);
    final profile = ref.read(activeProfileProvider);
    if (profile == null) return;
    final name = await _askName(l10n.categoryAddRoot);
    if (name == null) return;
    final created = await ref
        .read(categoryRepositoryProvider)
        .createRoot(profile.id, name);
    _setSelected(created.id);
    _bump();
  }

  Future<void> _createChild(CategoryRow parent) async {
    final l10n = AppLocalizations.of(context);
    final name = await _askName(l10n.categoryAddChild);
    if (name == null) return;
    await ref.read(categoryRepositoryProvider).createChild(parent.id, name);
    // Новая подкатегория должна быть видна сразу.
    setState(() => _collapsed.remove(parent.id));
    _bump();
  }

  Future<void> _rename(CategoryRow cat) async {
    final l10n = AppLocalizations.of(context);
    final name = await _askName(l10n.categoryRename, initial: cat.name);
    if (name == null) return;
    await ref.read(categoryRepositoryProvider).rename(cat.id, name);
    _bump();
  }

  Future<void> _pickIcon(CategoryRow cat) async {
    final l10n = AppLocalizations.of(context);
    final chosen = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l10n.categoryIcon),
        contentPadding: const EdgeInsets.fromLTRB(
          AppDimens.space20,
          AppDimens.space16,
          AppDimens.space20,
          AppDimens.space20,
        ),
        children: [
          SizedBox(
            width: 360,
            child: Wrap(
              spacing: AppDimens.space8,
              runSpacing: AppDimens.space8,
              children: [
                for (final key in AppIcons.allKeys)
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(key),
                    icon: Icon(AppIcons.byKey(key)),
                    isSelected: key == cat.icon,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (chosen == null) return;
    await ref
        .read(categoryRepositoryProvider)
        .updateAppearance(cat.id, icon: chosen);
    _bump();
  }

  Future<void> _move(CategoryRow cat) async {
    final picked = await CategoryPicker.show(context);
    if (picked == null) return;
    final targetId = picked.cleared ? null : picked.category?.id;
    if (!picked.cleared && targetId == null) return;
    try {
      await ref.read(categoryRepositoryProvider).move(cat.id, targetId);
      _bump();
    } on CategoryTreeException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  /// Архивирование ветки без вопроса «точно?»: записи не удаляются, а рядом
  /// сразу появляется «Вернуть».
  Future<void> _archive(CategoryRow cat) async {
    final l10n = AppLocalizations.of(context);
    await ref.read(categoryRepositoryProvider).archive(cat.id);
    if (_selectedId == cat.id) _setSelected(null);
    _bump();
    if (!mounted) return;
    showUndoSnackBar(
      context,
      message: l10n.categoryArchived,
      onUndo: () async {
        await ref.read(categoryRepositoryProvider).restore(cat.id);
        _bump();
      },
    );
  }

  /// Раскрывает всех предков, чтобы выбранная категория была видна в дереве.
  void _select(CategoryRow cat) {
    _setSelected(cat.id);
    setState(() {
      for (final id in cat.path.split('/')) {
        _collapsed.remove(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final layout = context.layout;
    final categories = ref.watch(allCategoriesProvider);
    final direct = ref.watch(categoryDirectCountsProvider).value ?? const {};
    final branch = ref.watch(categoryBranchCountsProvider).value ?? const {};

    return categories.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => ErrorState(error: e),
      data: (list) {
        if (list.isEmpty) {
          return EmptyState(
            icon: Icons.account_tree_rounded,
            title: l10n.categoryEmptyTitle,
            message: l10n.categoryEmptyMessage,
            action: FilledButton.icon(
              onPressed: _createRoot,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text(l10n.categoryAddRoot),
            ),
          );
        }

        final selected = list.where((x) => x.id == _selectedId).firstOrNull;
        final tree = _TreePane(
          categories: list,
          branchCounts: branch,
          directCounts: direct,
          collapsed: _collapsed,
          query: _query,
          selectedId: selected?.id,
          searchController: _searchController,
          mode: _mode,
          onModeChanged: (m) => setState(() => _mode = m),
          onQuery: (v) => setState(() => _query = v),
          onToggle: (id) => setState(() {
            if (!_collapsed.remove(id)) _collapsed.add(id);
          }),
          onSelect: _select,
          onAddChild: _createChild,
          onCreateRoot: _createRoot,
          onExpandAll: () => setState(_collapsed.clear),
          onCollapseAll: () => setState(() {
            _collapsed
              ..clear()
              ..addAll(list.map((x) => x.id));
          }),
        );

        Widget detailFor(CategoryRow cat, {VoidCallback? onBack}) =>
            CategoryDetail(
              category: cat,
              onBack: onBack,
              onOpenChild: _select,
              onAddChild: () => _createChild(cat),
              onRename: () => _rename(cat),
              onIcon: () => _pickIcon(cat),
              onMove: () => _move(cat),
              onReorder: ({required up}) => _reorder(cat, up: up),
              onArchive: () => _archive(cat),
            );

        final shelves = _ShelfPane(
          categories: list,
          branchCounts: branch,
          covers: ref.watch(categoryCoversProvider).value ?? const {},
          openedId: _shelfParentId,
          query: _query,
          searchController: _searchController,
          onQuery: (v) => setState(() => _query = v),
          onOpen: (cat) => setState(() => _shelfParentId = cat.id),
          onUp: () =>
              setState(() => _shelfParentId = _parentOf(list, _shelfParentId)),
          onShow: _select,
          onCreateRoot: _createRoot,
          onAddChild: _createChild,
          onMenu: _shelfMenu,
          onModeChanged: (m) => setState(() => _mode = m),
          mode: _mode,
        );

        final browser = _mode == CategoryViewMode.shelves ? shelves : tree;

        // Узкий экран: сначала обзор, выбранная ветка открывается поверх.
        if (!layout.isWide) {
          if (selected == null) return browser;
          return detailFor(selected, onBack: () => _setSelected(null));
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: _mode == CategoryViewMode.shelves
                  ? layout.treePaneWidth * 1.45
                  : layout.treePaneWidth,
              child: browser,
            ),
            VerticalDivider(width: 1, color: c.border),
            Expanded(
              child: selected == null
                  ? EmptyState(
                      icon: Icons.grid_view_rounded,
                      title: l10n.categoryPickTitle,
                      message: l10n.categoryPickMessage,
                    )
                  : detailFor(selected),
            ),
          ],
        );
      },
    );
  }
}

/// Полки: категории карточками с цветом, счётчиком и фотографиями из ветки.
///
/// Прежний плоский список не давал понять, что внутри полки и есть ли там
/// вообще что-нибудь. Здесь видно и то, и другое, а вглубь идут нажатием.
class _ShelfPane extends StatelessWidget {
  const _ShelfPane({
    required this.categories,
    required this.branchCounts,
    required this.covers,
    required this.openedId,
    required this.query,
    required this.searchController,
    required this.onQuery,
    required this.onOpen,
    required this.onUp,
    required this.onShow,
    required this.onCreateRoot,
    required this.onAddChild,
    required this.onMenu,
    required this.mode,
    required this.onModeChanged,
  });

  final List<CategoryRow> categories;
  final Map<String, int> branchCounts;
  final Map<String, List<String>> covers;

  /// Раскрытая ветка; null — показываем корневые полки.
  final String? openedId;

  final String query;
  final TextEditingController searchController;
  final ValueChanged<String> onQuery;
  final ValueChanged<CategoryRow> onOpen;
  final VoidCallback onUp;

  /// Открыть содержимое полки в правой панели.
  final ValueChanged<CategoryRow> onShow;

  final VoidCallback onCreateRoot;
  final ValueChanged<CategoryRow> onAddChild;
  final void Function(CategoryRow, Offset) onMenu;
  final CategoryViewMode mode;
  final ValueChanged<CategoryViewMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final palette = c.profilePalette;
    final byId = {for (final x in categories) x.id: x};
    final opened = openedId == null ? null : byId[openedId];

    // Поиск ищет по всему дереву, а не только внутри открытой полки: искать
    // «Колбасы», стоя в «Местах», — нормальное желание.
    final normalized = Normalize.name(query);
    final shown = normalized.isNotEmpty
        ? categories
              .where((x) => x.normalizedName.contains(normalized))
              .toList()
        : categories.where((x) => x.parentId == openedId).toList();

    return Container(
      color: c.background,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.space16,
              AppDimens.space20,
              AppDimens.space16,
              AppDimens.space12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (opened != null)
                      AppIconButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: l10n.commonBack,
                        onPressed: onUp,
                      ),
                    Expanded(
                      child: Text(
                        opened?.name ?? l10n.categoriesTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.headlineSmall,
                      ),
                    ),
                    CategoryModeToggle(mode: mode, onChanged: onModeChanged),
                    const SizedBox(width: AppDimens.space8),
                    AppIconButton(
                      icon: Icons.add_rounded,
                      tooltip: opened == null
                          ? l10n.categoryAddRoot
                          : l10n.categoryAddChild,
                      onPressed: () =>
                          opened == null ? onCreateRoot() : onAddChild(opened),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.space12),
                AppSearchField(
                  hint: l10n.categorySearchHint,
                  controller: searchController,
                  onChanged: onQuery,
                ),
              ],
            ),
          ),
          Divider(height: 1, color: c.border),
          Expanded(
            child: shown.isEmpty
                ? EmptyState(
                    icon: Icons.grid_view_rounded,
                    title: normalized.isEmpty
                        ? l10n.categoryShelfEmptyTitle
                        : l10n.catalogNothingFoundTitle,
                    message: normalized.isEmpty
                        ? l10n.categoryShelfEmptyMessage
                        : l10n.catalogNothingFoundMessage,
                  )
                : LayoutBuilder(
                    builder: (context, cns) {
                      final cols = (cns.maxWidth / 210).floor().clamp(1, 6);
                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          AppDimens.space16,
                          AppDimens.space16,
                          AppDimens.space16,
                          AppDimens.space40,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          mainAxisSpacing: AppDimens.space12,
                          crossAxisSpacing: AppDimens.space12,
                          // Высота задаётся напрямую: содержимое карточки не
                          // зависит от ширины, а соотношение сторон при
                          // другом числе колонок ломало вёрстку. Поправка на
                          // системный шрифт — чтобы подписи помещались и при
                          // «Крупном шрифте».
                          mainAxisExtent: categoryShelfHeightFor(
                            MediaQuery.textScalerOf(context).scale(1),
                          ),
                        ),
                        itemCount: shown.length,
                        itemBuilder: (context, i) {
                          final cat = shown[i];
                          final children = categories
                              .where((x) => x.parentId == cat.id)
                              .toList();
                          final count = branchCounts[cat.id] ?? 0;
                          final tone = cat.color != null
                              ? Color(cat.color!)
                              : palette[i % palette.length];

                          return Appear(
                            index: i,
                            child: GestureDetector(
                              onSecondaryTapDown: (d) =>
                                  onMenu(cat, d.globalPosition),
                              onLongPressStart: (d) =>
                                  onMenu(cat, d.globalPosition),
                              child: CategoryShelfCard(
                                name: cat.name,
                                icon: AppIcons.byKey(cat.icon),
                                color: tone,
                                count: count,
                                countLabel: l10n.categoryEntriesCount(count),
                                childNames: [
                                  for (final x in children.take(4)) x.name,
                                ],
                                covers: covers[cat.id] ?? const [],
                                // Нажатие открывает содержимое полки; если
                                // внутри есть подкатегории — заходим в них.
                                onTap: () => children.isEmpty
                                    ? onShow(cat)
                                    : onOpen(cat),
                                onShowEntries: () => onShow(cat),
                                showEntriesTooltip: l10n.categoryShowEntries,
                              ),
                            ),
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
}

/// Левая панель: дерево категорий с направляющими линиями.
class _TreePane extends StatelessWidget {
  const _TreePane({
    required this.categories,
    required this.branchCounts,
    required this.directCounts,
    required this.collapsed,
    required this.query,
    required this.selectedId,
    required this.searchController,
    required this.mode,
    required this.onModeChanged,
    required this.onQuery,
    required this.onToggle,
    required this.onSelect,
    required this.onAddChild,
    required this.onCreateRoot,
    required this.onExpandAll,
    required this.onCollapseAll,
  });

  final List<CategoryRow> categories;
  final Map<String, int> branchCounts;
  final Map<String, int> directCounts;
  final Set<String> collapsed;
  final String query;
  final String? selectedId;
  final TextEditingController searchController;
  final CategoryViewMode mode;
  final ValueChanged<CategoryViewMode> onModeChanged;
  final ValueChanged<String> onQuery;
  final ValueChanged<String> onToggle;
  final ValueChanged<CategoryRow> onSelect;
  final ValueChanged<CategoryRow> onAddChild;
  final VoidCallback onCreateRoot;
  final VoidCallback onExpandAll;
  final VoidCallback onCollapseAll;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    // Один проход на всё: кто с детьми, сколько их и кто спрятан свёрнутым
    // предком. Прежде «спрятан ли» решалось разбором материализованного пути
    // на каждую строку — ещё один проход по всему дереву, и так на каждый
    // кадр. Родитель в списке всегда стоит раньше детей, поэтому его
    // видимость к этому моменту уже известна.
    final hasChildren = <String, bool>{};
    final childCount = <String, int>{};
    final hidden = <String, bool>{};
    for (final cat in categories) {
      final parent = cat.parentId;
      if (parent == null) {
        hidden[cat.id] = false;
        continue;
      }
      hasChildren[parent] = true;
      childCount[parent] = (childCount[parent] ?? 0) + 1;
      hidden[cat.id] = collapsed.contains(parent) || (hidden[parent] ?? false);
    }

    // Поиск показывает совпавшие узлы вместе с предками — иначе теряется путь.
    final normalized = Normalize.name(query);
    final visible = <CategoryRow>[];
    if (normalized.isEmpty) {
      visible.addAll(categories.where((cat) => !(hidden[cat.id] ?? false)));
    } else {
      final keep = <String>{};
      for (final cat in categories) {
        if (cat.normalizedName.contains(normalized)) {
          keep.addAll(cat.path.split('/'));
        }
      }
      visible.addAll(categories.where((cat) => keep.contains(cat.id)));
    }

    // Узел последний, только если следующий видимый мельче по уровню: ровня —
    // это ещё один брат, и линия должна идти дальше вниз.
    final isLastChild = <String, bool>{};
    for (var i = 0; i < visible.length; i++) {
      final cat = visible[i];
      final next = i + 1 < visible.length ? visible[i + 1] : null;
      isLastChild[cat.id] = next == null || next.level < cat.level;
    }

    return Container(
      color: c.background,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.space16,
              AppDimens.space20,
              AppDimens.space16,
              AppDimens.space12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.categoriesTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.headlineSmall,
                      ),
                    ),
                    // Переключатель режима есть и здесь: без него, уйдя в дерево,
                    // нельзя было вернуться на полки — сам переключатель исчезал.
                    CategoryModeToggle(mode: mode, onChanged: onModeChanged),
                    const SizedBox(width: AppDimens.space8),
                    AppIconButton(
                      icon: Icons.unfold_more_rounded,
                      tooltip: l10n.categoryExpandAll,
                      onPressed: onExpandAll,
                    ),
                    AppIconButton(
                      icon: Icons.unfold_less_rounded,
                      tooltip: l10n.categoryCollapseAll,
                      onPressed: onCollapseAll,
                    ),
                    AppIconButton(
                      icon: Icons.add_rounded,
                      tooltip: l10n.categoryAddRoot,
                      onPressed: onCreateRoot,
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.space12),
                AppSearchField(
                  hint: l10n.categorySearchHint,
                  controller: searchController,
                  onChanged: onQuery,
                ),
              ],
            ),
          ),
          Divider(height: 1, color: c.border),
          Expanded(
            child: visible.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.space24),
                      child: Text(
                        l10n.catalogNothingFoundTitle,
                        style: context.text.bodyMedium?.copyWith(
                          color: c.textMuted,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.space12,
                      AppDimens.space12,
                      AppDimens.space12,
                      AppDimens.space40,
                    ),
                    itemCount: visible.length,
                    itemBuilder: (context, i) {
                      final cat = visible[i];
                      return CategoryTreeRow(
                        category: cat,
                        branchCount: branchCounts[cat.id] ?? 0,
                        childCount: childCount[cat.id] ?? 0,
                        hasChildren: hasChildren[cat.id] ?? false,
                        collapsed: collapsed.contains(cat.id),
                        selected: cat.id == selectedId,
                        isLast: isLastChild[cat.id] ?? true,
                        onToggle: () => onToggle(cat.id),
                        onSelect: () => onSelect(cat),
                        onAddChild: () => onAddChild(cat),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Строка дерева: направляющие линии, цветной значок, счётчик ветки.
class CategoryTreeRow extends StatefulWidget {
  const CategoryTreeRow({
    super.key,
    required this.category,
    required this.branchCount,
    required this.childCount,
    required this.hasChildren,
    required this.collapsed,
    required this.selected,
    required this.isLast,
    required this.onToggle,
    required this.onSelect,
    required this.onAddChild,
  });

  final CategoryRow category;
  final int branchCount;
  final int childCount;
  final bool hasChildren;
  final bool collapsed;
  final bool selected;
  final bool isLast;
  final VoidCallback onToggle;
  final VoidCallback onSelect;
  final VoidCallback onAddChild;

  @override
  State<CategoryTreeRow> createState() => _CategoryTreeRowState();
}

class _CategoryTreeRowState extends State<CategoryTreeRow> {
  bool _hovered = false;

  static const double _indent = 18;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context);
    final cat = widget.category;
    final tone = cat.color != null
        ? Color(cat.color!)
        : c.profileColorFor(cat.id);
    final isRoot = cat.level == 0;

    final tile = Material(
      color: widget.selected
          ? c.navActiveBg
          : (_hovered ? c.surfaceMuted : Colors.transparent),
      borderRadius: AppDimens.brSm,
      child: InkWell(
        borderRadius: AppDimens.brSm,
        onTap: widget.onSelect,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.space8,
            vertical: AppDimens.space8,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                child: widget.hasChildren
                    ? _Chevron(
                        collapsed: widget.collapsed,
                        onTap: widget.onToggle,
                      )
                    : null,
              ),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: widget.selected ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(AppIcons.byKey(cat.icon), size: 15, color: tone),
              ),
              const SizedBox(width: AppDimens.space8),
              Expanded(
                child: Text(
                  cat.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyMedium?.copyWith(
                    color: widget.selected ? c.navActiveFg : c.textPrimary,
                    fontWeight: widget.selected || isRoot
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ),
                ),
              ),
              if (_hovered)
                AppIconButton(
                  icon: Icons.add_rounded,
                  tooltip: l10n.categoryAddChild,
                  onPressed: widget.onAddChild,
                )
              else if (widget.branchCount > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.space8,
                  ),
                  child: Text(
                    '${widget.branchCount}',
                    style: context.text.labelSmall?.copyWith(
                      color: widget.selected ? c.navActiveFg : c.textMuted,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 1),
        child: isRoot
            ? tile
            : CustomPaint(
                painter: _TreeGuidePainter(
                  level: cat.level,
                  indent: _indent,
                  isLast: widget.isLast,
                  color: c.border,
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: cat.level * _indent),
                  child: tile,
                ),
              ),
      ),
    );
  }
}

/// Направляющие линии дерева: вертикали предков и уголок к самому узлу.
class _TreeGuidePainter extends CustomPainter {
  const _TreeGuidePainter({
    required this.level,
    required this.indent,
    required this.isLast,
    required this.color,
  });

  final int level;
  final double indent;
  final bool isLast;
  final Color color;

  /// Отступ от начала строки до значка: внутренний отступ плюс место
  /// под шеврон.
  static const double _rowIconOffset = AppDimens.space8 + 20;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < level - 1; i++) {
      final x = indent * i + indent / 2;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    final x = indent * (level - 1) + indent / 2;
    final midY = size.height / 2;
    canvas.drawLine(
      Offset(x, 0),
      Offset(x, isLast ? midY : size.height),
      paint,
    );
    canvas.drawLine(
      Offset(x, midY),
      Offset(indent * level + _rowIconOffset - 6, midY),
      paint,
    );
  }

  @override
  bool shouldRepaint(_TreeGuidePainter old) =>
      old.level != level || old.isLast != isLast || old.color != color;
}

class _Chevron extends StatelessWidget {
  const _Chevron({required this.collapsed, required this.onTap});

  final bool collapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: AppDimens.brPill,
      child: SizedBox(
        width: 20,
        height: 20,
        child: AnimatedRotation(
          turns: collapsed ? -0.25 : 0,
          duration: AppDimens.durationFast,
          child: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: c.textSecondary,
          ),
        ),
      ),
    );
  }
}
