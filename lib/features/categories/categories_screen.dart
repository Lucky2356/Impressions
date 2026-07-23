import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../app/navigation.dart';
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
import '../catalog/catalog_providers.dart';
import '../quick_add/category_picker.dart';
import 'category_providers.dart';

/// Экран дерева категорий (§7).
///
/// Дерево рисуется направляющими линиями и цветными плитками уровней, а не
/// плоским списком с отступами: по такому списку невозможно понять вложенность.
/// Корневые категории показываются крупными карточками-разделами, потомки —
/// компактными строками внутри ветки.
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final Set<String> _collapsed = {};
  final _searchController = TextEditingController();
  String _query = '';

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
    await ref.read(categoryRepositoryProvider).createRoot(profile.id, name);
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
    _bump();
  }

  /// Открывает каталог, отфильтрованный по этой ветке.
  void _openInCatalog(CategoryRow cat) {
    ref.read(catalogStateProvider.notifier)
      ..setCategory(cat.id)
      ..setIncludeSubcategories(true);
    ref.read(navProvider.notifier).go(NavIds.catalog);
  }

  bool _hiddenByCollapse(CategoryRow cat) {
    final ids = cat.path.split('/');
    for (var i = 0; i < ids.length - 1; i++) {
      if (_collapsed.contains(ids[i])) return true;
    }
    return false;
  }

  void _expandAll() => setState(_collapsed.clear);

  void _collapseAll(List<CategoryRow> all) {
    setState(() {
      _collapsed
        ..clear()
        ..addAll(all.map((c) => c.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = ref.watch(allCategoriesProvider);
    final direct = ref.watch(categoryDirectCountsProvider).value ?? const {};
    final branch = ref.watch(categoryBranchCountsProvider).value ?? const {};

    return categories.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => Center(child: Text('$e')),
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

        final hasChildren = <String, bool>{};
        final childCount = <String, int>{};
        for (final cat in list) {
          final parent = cat.parentId;
          if (parent != null) {
            hasChildren[parent] = true;
            childCount[parent] = (childCount[parent] ?? 0) + 1;
          }
        }

        // Поиск по дереву: показываем совпавшие узлы вместе со всеми предками,
        // чтобы путь оставался понятным.
        final query = Normalize.name(_query);
        final visible = <CategoryRow>[];
        if (query.isEmpty) {
          visible.addAll(list.where((cat) => !_hiddenByCollapse(cat)));
        } else {
          final keep = <String>{};
          for (final cat in list) {
            if (cat.normalizedName.contains(query)) {
              keep.addAll(cat.path.split('/'));
            }
          }
          visible.addAll(list.where((cat) => keep.contains(cat.id)));
        }

        // Последний потомок в своей ветке рисует уголок, а не «тройник».
        // Узел последний, только если следующий видимый узел мельче по уровню:
        // ровня — это ещё один брат, и линия должна идти дальше вниз.
        final isLastChild = <String, bool>{};
        for (var i = 0; i < visible.length; i++) {
          final cat = visible[i];
          final next = i + 1 < visible.length ? visible[i + 1] : null;
          isLastChild[cat.id] = next == null || next.level < cat.level;
        }

        final total = list.length;
        return ScreenScaffold(
          header: ScreenHeader(
            title: l10n.categoriesTitle,
            subtitle: l10n.categoriesSubtitle(total),
            actions: [
              IconActionButton(
                icon: Icons.unfold_more_rounded,
                tooltip: l10n.categoryExpandAll,
                onPressed: _expandAll,
                size: AppDimens.controlHeight,
              ),
              IconActionButton(
                icon: Icons.unfold_less_rounded,
                tooltip: l10n.categoryCollapseAll,
                onPressed: () => _collapseAll(list),
                size: AppDimens.controlHeight,
              ),
              FilledButton.icon(
                onPressed: _createRoot,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(l10n.categoryAddRoot),
              ),
            ],
            bottom: SizedBox(
              width: 360,
              child: AppSearchField(
                hint: l10n.categorySearchHint,
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
          ),
          child: visible.isEmpty
              ? EmptyState(
                  icon: Icons.search_off_rounded,
                  title: l10n.catalogNothingFoundTitle,
                  message: l10n.catalogNothingFoundMessage,
                )
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    context.layout.gutter,
                    AppDimens.space16,
                    context.layout.gutter,
                    AppDimens.space40,
                  ),
                  itemCount: visible.length,
                  itemBuilder: (context, i) {
                    final cat = visible[i];
                    return _CategoryNode(
                      category: cat,
                      directCount: direct[cat.id] ?? 0,
                      branchCount: branch[cat.id] ?? 0,
                      childCount: childCount[cat.id] ?? 0,
                      hasChildren: hasChildren[cat.id] ?? false,
                      collapsed: _collapsed.contains(cat.id),
                      isLast: isLastChild[cat.id] ?? true,
                      onToggle: () => setState(() {
                        if (!_collapsed.remove(cat.id)) _collapsed.add(cat.id);
                      }),
                      onOpen: () => _openInCatalog(cat),
                      onAddChild: () => _createChild(cat),
                      onRename: () => _rename(cat),
                      onIcon: () => _pickIcon(cat),
                      onMove: () => _move(cat),
                      onArchive: () => _archive(cat),
                    );
                  },
                ),
        );
      },
    );
  }
}

/// Узел дерева. Корень — карточка-раздел, потомки — строки с направляющими.
class _CategoryNode extends StatefulWidget {
  const _CategoryNode({
    required this.category,
    required this.directCount,
    required this.branchCount,
    required this.childCount,
    required this.hasChildren,
    required this.collapsed,
    required this.isLast,
    required this.onToggle,
    required this.onOpen,
    required this.onAddChild,
    required this.onRename,
    required this.onIcon,
    required this.onMove,
    required this.onArchive,
  });

  final CategoryRow category;
  final int directCount;
  final int branchCount;
  final int childCount;
  final bool hasChildren;
  final bool collapsed;
  final bool isLast;
  final VoidCallback onToggle;
  final VoidCallback onOpen;
  final VoidCallback onAddChild;
  final VoidCallback onRename;
  final VoidCallback onIcon;
  final VoidCallback onMove;
  final VoidCallback onArchive;

  @override
  State<_CategoryNode> createState() => _CategoryNodeState();
}

class _CategoryNodeState extends State<_CategoryNode> {
  bool _hovered = false;

  static const double _indent = 26;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context);
    final cat = widget.category;
    final isRoot = cat.level == 0;
    final tone = cat.color != null
        ? Color(cat.color!)
        : c.profileColorFor(cat.id);

    final tile = Container(
      decoration: BoxDecoration(
        color: isRoot
            ? c.surface
            : (_hovered ? c.surfaceMuted : Colors.transparent),
        borderRadius: isRoot ? AppDimens.brLg : AppDimens.brMd,
        border: isRoot ? Border.all(color: c.border) : null,
        boxShadow: isRoot
            ? [BoxShadow(color: c.shadow, blurRadius: 14, offset: Offset(0, 4))]
            : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: isRoot ? AppDimens.brLg : AppDimens.brMd,
          onTap: widget.branchCount > 0 ? widget.onOpen : widget.onAddChild,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimens.space12,
              vertical: isRoot ? AppDimens.space12 : AppDimens.space8,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: widget.hasChildren
                      ? _Chevron(
                          collapsed: widget.collapsed,
                          onTap: widget.onToggle,
                        )
                      : null,
                ),
                _IconTile(
                  icon: AppIcons.byKey(cat.icon),
                  tone: tone,
                  big: isRoot,
                ),
                const SizedBox(width: AppDimens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        cat.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: isRoot
                            ? context.text.titleLarge
                            : context.text.titleMedium,
                      ),
                      if (widget.hasChildren || widget.branchCount > 0)
                        Text(
                          _meta(l10n),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.labelSmall?.copyWith(
                            color: c.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
                if (widget.branchCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(right: AppDimens.space8),
                    child: _CountBadge(count: widget.branchCount, tone: tone),
                  ),
                // Действия проявляются при наведении, чтобы дерево не рябило
                // от иконок; на сенсорном экране показываем всегда.
                AnimatedOpacity(
                  duration: AppDimens.durationFast,
                  opacity: _hovered || context.layout.isCompact ? 1 : 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIconButton(
                        icon: Icons.add_rounded,
                        tooltip: l10n.categoryAddChild,
                        onPressed: widget.onAddChild,
                      ),
                      PopupMenuButton<String>(
                        tooltip: '',
                        icon: Icon(
                          Icons.more_horiz_rounded,
                          size: 18,
                          color: c.textSecondary,
                        ),
                        onSelected: (v) => switch (v) {
                          'rename' => widget.onRename(),
                          'icon' => widget.onIcon(),
                          'move' => widget.onMove(),
                          'open' => widget.onOpen(),
                          'archive' => widget.onArchive(),
                          _ => null,
                        },
                        itemBuilder: (_) => [
                          _menuItem(
                            'open',
                            Icons.grid_view_rounded,
                            l10n.categoryOpenInCatalog,
                          ),
                          _menuItem(
                            'rename',
                            Icons.edit_rounded,
                            l10n.categoryRename,
                          ),
                          _menuItem(
                            'icon',
                            Icons.emoji_symbols_rounded,
                            l10n.categoryIcon,
                          ),
                          _menuItem(
                            'move',
                            Icons.drive_file_move_rounded,
                            l10n.categoryMove,
                          ),
                          const PopupMenuDivider(),
                          _menuItem(
                            'archive',
                            Icons.archive_rounded,
                            l10n.categoryArchive,
                            danger: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Padding(
        padding: EdgeInsets.only(bottom: isRoot ? AppDimens.space8 : 2),
        child: cat.level == 0
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

  PopupMenuItem<String> _menuItem(
    String value,
    IconData icon,
    String label, {
    bool danger = false,
  }) {
    final c = context.colors;
    return PopupMenuItem(
      value: value,
      height: 40,
      child: Row(
        children: [
          Icon(icon, size: 18, color: danger ? c.coral : c.textSecondary),
          const SizedBox(width: AppDimens.space12),
          Text(label, style: danger ? TextStyle(color: c.coral) : null),
        ],
      ),
    );
  }

  String _meta(AppLocalizations l10n) {
    final parts = <String>[];
    if (widget.childCount > 0) {
      parts.add(l10n.categorySubcategoriesCount(widget.childCount));
    }
    if (widget.directCount > 0 && widget.directCount != widget.branchCount) {
      parts.add(l10n.categoryDirectCount(widget.directCount));
    }
    return parts.join(' · ');
  }
}

/// Направляющие линии дерева: вертикали для каждого уровня предков и уголок
/// к самому узлу.
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

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Вертикали предков — от верха до низа строки.
    for (var i = 0; i < level - 1; i++) {
      final x = indent * i + indent / 2;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Ветка к текущему узлу: вертикаль до середины и горизонталь до плитки
    // значка, иначе линия обрывается в пустоте и связь не читается.
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

  /// Отступ от начала строки до плитки значка: внутренний отступ карточки
  /// плюс место под шеврон.
  static const double _rowIconOffset = AppDimens.space12 + 24;

  @override
  bool shouldRepaint(_TreeGuidePainter old) =>
      old.level != level || old.isLast != isLast || old.color != color;
}

/// Цветная плитка иконки категории.
class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon, required this.tone, required this.big});

  final IconData icon;
  final Color tone;
  final bool big;

  @override
  Widget build(BuildContext context) {
    final side = big ? 40.0 : 30.0;
    return Container(
      width: side,
      height: side,
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(big ? 12 : 9),
      ),
      child: Icon(icon, size: big ? 21 : 17, color: tone),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, required this.tone});

  final int count;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.space8),
      height: 22,
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: AppDimens.brPill,
      ),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: context.text.labelSmall?.copyWith(
          color: tone,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
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
        width: 24,
        height: 24,
        child: AnimatedRotation(
          turns: collapsed ? -0.25 : 0,
          duration: AppDimens.durationFast,
          child: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: c.textSecondary,
          ),
        ),
      ),
    );
  }
}
