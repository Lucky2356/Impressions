import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_layout.dart';
import '../../core/theme/theme_context.dart';
import '../../data/db/database.dart';
import '../../data/models/category_tree.dart';
import '../../design_system/design_system.dart';
import 'category_actions.dart';
import 'category_branch_page.dart';
import 'category_providers.dart';
import 'category_tree_pane.dart';

/// Экран категорий (§7): навигатор по дереву слева, страница ветки справа.
///
/// До 1.16.0 здесь было два режима обзора — «полками» и «деревом», — и они
/// спорили друг с другом. Полки ходили вглубь как папки, дерево раскрывало
/// узлы, а нажатие на карточку давало разный результат в зависимости от того,
/// есть ли внутри подкатегории. Отсюда и брался вопрос «что вообще такое эти
/// категории». Теперь способ один: дерево водит, страница ветки показывает.
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Дерево на телефоне: там постоянной панели нет, и добраться до дальней
  /// ветки одними полками — это спуск по всем уровням подряд.
  Future<void> _showTree(List<CategoryRow> categories) async {
    await showAdaptiveSheet<void>(
      context,
      heightFactor: 0.9,
      builder: (sheetContext) =>
          _tree(categories, onSelected: () => Navigator.of(sheetContext).pop()),
    );
  }

  Widget _tree(List<CategoryRow> categories, {VoidCallback? onSelected}) {
    final actions = CategoryActions(ref, context);
    final branch = ref.watch(categoryBranchCountsProvider).value ?? const {};
    final collapsed = ref.watch(collapsedCategoriesProvider);

    return TreePane(
      categories: categories,
      branchCounts: branch,
      collapsed: collapsed,
      query: _query,
      selectedId: ref.watch(selectedCategoryProvider),
      searchController: _searchController,
      onQuery: (v) => setState(() => _query = v),
      onToggle: ref.read(collapsedCategoriesProvider.notifier).toggle,
      onSelect: (cat) {
        actions.select(cat);
        onSelected?.call();
      },
      onAddChild: actions.createChild,
      onCreateRoot: actions.createRoot,
      onExpandAll: ref.read(collapsedCategoriesProvider.notifier).expandAll,
      onCollapseAll: () => ref
          .read(collapsedCategoriesProvider.notifier)
          .collapseAll([for (final c in categories) c.id]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final layout = context.layout;
    final categories = ref.watch(allCategoriesProvider);
    final selectedId = ref.watch(selectedCategoryProvider);

    return categories.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => ErrorState(error: e),
      data: (list) {
        final actions = CategoryActions(ref, context);
        if (list.isEmpty) {
          return EmptyState(
            icon: Icons.account_tree_rounded,
            title: l10n.categoryEmptyTitle,
            message: l10n.categoryEmptyMessage,
            action: FilledButton.icon(
              onPressed: actions.createRoot,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text(l10n.categoryAddRoot),
            ),
          );
        }

        final selected = list.where((x) => x.id == selectedId).firstOrNull;

        // Узкий экран: без выбранной ветки показываем корневые полками, чтобы
        // первое, что видно, было содержимым, а не навигацией.
        if (!layout.isWide) {
          if (selected == null) {
            return _RootShelves(
              categories: list,
              onOpenTree: () => _showTree(list),
            );
          }
          return CategoryBranchPage(
            category: selected,
            onBack: () => ref.read(selectedCategoryProvider.notifier).back(),
            onOpenTree: () => _showTree(list),
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: layout.treePaneWidth, child: _tree(list)),
            VerticalDivider(width: 1, color: c.border),
            Expanded(
              child: selected == null
                  ? EmptyState(
                      icon: Icons.account_tree_rounded,
                      title: l10n.categoryPickTitle,
                      message: l10n.categoryPickMessage,
                    )
                  : CategoryBranchPage(category: selected),
            ),
          ],
        );
      },
    );
  }
}

/// Корневые ветки полками — то, с чего начинается экран на телефоне.
///
/// Отдельно от страницы ветки: у корня нет ни своего названия, ни своих
/// записей, и притворяться веткой ему нечем.
class _RootShelves extends ConsumerWidget {
  const _RootShelves({required this.categories, required this.onOpenTree});

  final List<CategoryRow> categories;
  final VoidCallback onOpenTree;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final actions = CategoryActions(ref, context);
    final roots = CategoryTree.childrenOf(categories, null);

    return ScreenScaffold(
      constrain: false,
      header: ScreenHeader(
        constrain: false,
        title: l10n.categoriesTitle,
        actions: [
          AppIconButton(
            icon: Icons.account_tree_rounded,
            tooltip: l10n.categoryOpenTree,
            onPressed: onOpenTree,
          ),
          FilledButton.icon(
            onPressed: actions.createRoot,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: Text(l10n.commonAdd),
          ),
        ],
      ),
      child: CategoryShelves(categories: roots, allCategories: categories),
    );
  }
}
