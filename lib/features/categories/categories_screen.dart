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

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final Set<String> _collapsed = {};
  final _searchController = TextEditingController();
  String _query = '';

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

  Future<void> _archive(CategoryRow cat) async {
    final l10n = AppLocalizations.of(context);
    final ok = await ConfirmDialog.show(
      context,
      title: l10n.categoryArchive,
      message: l10n.categoryArchiveConfirm,
      confirmLabel: l10n.categoryArchive,
      destructive: true,
    );
    if (!ok) return;
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

  bool _hiddenByCollapse(CategoryRow cat) {
    final ids = cat.path.split('/');
    for (var i = 0; i < ids.length - 1; i++) {
      if (_collapsed.contains(ids[i])) return true;
    }
    return false;
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
          hiddenByCollapse: _hiddenByCollapse,
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
              onArchive: () => _archive(cat),
            );

        // Узкий экран: сначала дерево, выбранная ветка открывается поверх.
        if (!layout.isWide) {
          if (selected == null) return tree;
          return detailFor(selected, onBack: () => _setSelected(null));
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: layout.treePaneWidth, child: tree),
            VerticalDivider(width: 1, color: c.border),
            Expanded(
              child: selected == null
                  ? EmptyState(
                      icon: Icons.account_tree_rounded,
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
    required this.onQuery,
    required this.onToggle,
    required this.onSelect,
    required this.onAddChild,
    required this.onCreateRoot,
    required this.onExpandAll,
    required this.onCollapseAll,
    required this.hiddenByCollapse,
  });

  final List<CategoryRow> categories;
  final Map<String, int> branchCounts;
  final Map<String, int> directCounts;
  final Set<String> collapsed;
  final String query;
  final String? selectedId;
  final TextEditingController searchController;
  final ValueChanged<String> onQuery;
  final ValueChanged<String> onToggle;
  final ValueChanged<CategoryRow> onSelect;
  final ValueChanged<CategoryRow> onAddChild;
  final VoidCallback onCreateRoot;
  final VoidCallback onExpandAll;
  final VoidCallback onCollapseAll;
  final bool Function(CategoryRow) hiddenByCollapse;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    final hasChildren = <String, bool>{};
    final childCount = <String, int>{};
    for (final cat in categories) {
      final parent = cat.parentId;
      if (parent != null) {
        hasChildren[parent] = true;
        childCount[parent] = (childCount[parent] ?? 0) + 1;
      }
    }

    // Поиск показывает совпавшие узлы вместе с предками — иначе теряется путь.
    final normalized = Normalize.name(query);
    final visible = <CategoryRow>[];
    if (normalized.isEmpty) {
      visible.addAll(categories.where((cat) => !hiddenByCollapse(cat)));
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
                        style: context.text.headlineSmall,
                      ),
                    ),
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
                  height: AppDimens.controlHeightSm,
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
