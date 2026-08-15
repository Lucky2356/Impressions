import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/domain/app_icons.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../core/utils/normalize.dart';
import '../../data/db/database.dart';
import '../../data/models/category_tree.dart';
import '../../design_system/design_system.dart';
import 'category_drag.dart';
import 'category_palette.dart';

/// Навигатор по дереву категорий: постоянная левая панель.
///
/// Раньше дерево было одним из двух режимов обзора и подменяло собой полки.
/// Из-за этого одно и то же нажатие давало разный результат, а переключатель
/// приходилось дублировать в обеих панелях, чтобы из дерева можно было
/// вернуться. Теперь дерево только водит по веткам, а что внутри — показывает
/// страница ветки.
class TreePane extends StatelessWidget {
  const TreePane({
    super.key,
    required this.categories,
    required this.branchCounts,
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
    this.onDrop,
    this.selection,
    this.onToggleSelected,
    this.onStartSelection,
    this.onCancelSelection,
    this.onMoveSelected,
    this.onArchiveSelected,
  });

  final List<CategoryRow> categories;
  final Map<String, int> branchCounts;
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

  /// Приём брошенного груза. Без него дерево просто не принимает перетаскивание
  /// — например в листе на телефоне, где тащить нечем.
  final void Function(CategoryDropPayload, CategoryRow, DropEdge)? onDrop;

  /// Выделенные ветки; `null` — режим выделения выключен.
  ///
  /// Перетаскивание годится, когда ветку переносят одну. Разложить семь веток
  /// в две другие — это семь бросков, и любой промах приходится отменять
  /// отдельно.
  final Set<String>? selection;
  final ValueChanged<CategoryRow>? onToggleSelected;
  final VoidCallback? onStartSelection;
  final VoidCallback? onCancelSelection;
  final VoidCallback? onMoveSelected;
  final VoidCallback? onArchiveSelected;

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
          keep.addAll(CategoryTree.pathIds(cat.path));
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
                    if (onStartSelection != null)
                      AppIconButton(
                        icon: Icons.checklist_rounded,
                        tooltip: l10n.categorySelectMany,
                        onPressed: selection == null
                            ? onStartSelection
                            : onCancelSelection,
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
                : _TreeList(
                    visible: visible,
                    all: categories,
                    branchCounts: branchCounts,
                    childCount: childCount,
                    hasChildren: hasChildren,
                    isLastChild: isLastChild,
                    collapsed: collapsed,
                    selectedId: selectedId,
                    selection: selection,
                    onToggle: onToggle,
                    onSelect: onSelect,
                    onToggleSelected: onToggleSelected,
                    onAddChild: onAddChild,
                    // В режиме выделения перетаскивания нет: одно движение
                    // мышью не может означать и «выбрать», и «перенести».
                    onDrop: selection == null ? onDrop : null,
                  ),
          ),
          if (selection != null)
            _SelectionBar(
              count: selection!.length,
              onMove: onMoveSelected,
              onArchive: onArchiveSelected,
              onCancel: onCancelSelection,
            ),
        ],
      ),
    );
  }
}

/// Панель действий над выделенными ветками.
class _SelectionBar extends StatelessWidget {
  const _SelectionBar({
    required this.count,
    required this.onMove,
    required this.onArchive,
    required this.onCancel,
  });

  final int count;
  final VoidCallback? onMove;
  final VoidCallback? onArchive;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final enabled = count > 0;

    return Material(
      color: c.accentSoft,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space12,
          vertical: AppDimens.space8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                AppIconButton(
                  icon: Icons.close_rounded,
                  tooltip: l10n.bulkCancel,
                  onPressed: onCancel,
                ),
                const SizedBox(width: AppDimens.space8),
                Expanded(
                  child: Text(
                    l10n.categorySelectedCount(count),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.labelLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.space8),
            // Кнопки под счётчиком, а не рядом: панель живёт в узкой колонке
            // дерева, и в строку они не помещаются.
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: enabled ? onMove : null,
                    icon: const Icon(Icons.drive_file_move_rounded, size: 18),
                    label: Text(
                      l10n.categoryMove,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimens.space8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: enabled ? onArchive : null,
                    icon: const Icon(Icons.archive_rounded, size: 18),
                    label: Text(
                      l10n.bulkArchive,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Список строк дерева с прокруткой у краёв во время перетаскивания.
class _TreeList extends StatefulWidget {
  const _TreeList({
    required this.visible,
    required this.all,
    required this.branchCounts,
    required this.childCount,
    required this.hasChildren,
    required this.isLastChild,
    required this.collapsed,
    required this.selectedId,
    required this.selection,
    required this.onToggle,
    required this.onSelect,
    required this.onToggleSelected,
    required this.onAddChild,
    required this.onDrop,
  });

  final List<CategoryRow> visible;
  final List<CategoryRow> all;
  final Map<String, int> branchCounts;
  final Map<String, int> childCount;
  final Map<String, bool> hasChildren;
  final Map<String, bool> isLastChild;
  final Set<String> collapsed;
  final String? selectedId;
  final Set<String>? selection;
  final ValueChanged<String> onToggle;
  final ValueChanged<CategoryRow> onSelect;
  final ValueChanged<CategoryRow>? onToggleSelected;
  final ValueChanged<CategoryRow> onAddChild;
  final void Function(CategoryDropPayload, CategoryRow, DropEdge)? onDrop;

  @override
  State<_TreeList> createState() => _TreeListState();
}

class _TreeListState extends State<_TreeList> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Полоска у края: пока над ней висит груз, список едет.
  Widget _edge({required bool forward}) {
    return DropZone<CategoryDropPayload>(
      onWillAccept: (_) => true,
      onAccept: (_) {},
      builder: (context, active) => DropAutoScroll(
        active: active,
        controller: _controller,
        forward: forward,
        child: const SizedBox(height: 24, width: double.infinity),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final list = ListView.builder(
      controller: _controller,
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space12,
        AppDimens.space12,
        AppDimens.space12,
        AppDimens.space40,
      ),
      itemCount: widget.visible.length,
      itemBuilder: (context, i) {
        final cat = widget.visible[i];
        return CategoryTreeRow(
          category: cat,
          tone: CategoryPalette.colorOf(cat, widget.all, c),
          branchCount: widget.branchCounts[cat.id] ?? 0,
          childCount: widget.childCount[cat.id] ?? 0,
          hasChildren: widget.hasChildren[cat.id] ?? false,
          collapsed: widget.collapsed.contains(cat.id),
          selected: cat.id == widget.selectedId,
          checked: widget.selection?.contains(cat.id),
          isLast: widget.isLastChild[cat.id] ?? true,
          onToggle: () => widget.onToggle(cat.id),
          // В режиме выделения нажатие на строку выбирает, а не переходит:
          // иначе галочку приходилось бы ловить в 20 точек шириной.
          onSelect: () => widget.selection == null
              ? widget.onSelect(cat)
              : widget.onToggleSelected?.call(cat),
          onAddChild: () => widget.onAddChild(cat),
          onDrop: widget.onDrop == null
              ? null
              : (payload, edge) => widget.onDrop!(payload, cat, edge),
          canDrop: widget.onDrop == null
              ? null
              : (payload, edge) => canDropOn(
                  payload: payload,
                  target: cat,
                  edge: edge,
                  all: widget.all,
                  maxDepth: AppConfig.hardMaxCategoryDepth,
                ),
        );
      },
    );

    if (widget.onDrop == null) return list;
    return Stack(
      children: [
        Positioned.fill(child: list),
        Positioned(top: 0, left: 0, right: 0, child: _edge(forward: false)),
        Positioned(bottom: 0, left: 0, right: 0, child: _edge(forward: true)),
      ],
    );
  }
}

/// Строка дерева: направляющие линии, цветной значок, счётчик ветки.
class CategoryTreeRow extends StatefulWidget {
  const CategoryTreeRow({
    super.key,
    required this.category,
    required this.tone,
    required this.branchCount,
    required this.childCount,
    required this.hasChildren,
    required this.collapsed,
    required this.selected,
    required this.isLast,
    required this.onToggle,
    required this.onSelect,
    required this.onAddChild,
    this.checked,
    this.onDrop,
    this.canDrop,
  });

  final CategoryRow category;

  /// Цвет ветки: считается снаружи по всему дереву — он наследуется.
  final Color tone;

  final int branchCount;
  final int childCount;
  final bool hasChildren;
  final bool collapsed;
  final bool selected;

  /// Стоит ли галочка; `null` — режим выделения выключен и её нет вовсе.
  final bool? checked;

  final bool isLast;
  final VoidCallback onToggle;
  final VoidCallback onSelect;
  final VoidCallback onAddChild;

  /// Приём броска; `null` — строка перетаскивание не поддерживает.
  final void Function(CategoryDropPayload, DropEdge)? onDrop;
  final bool Function(CategoryDropPayload, DropEdge)? canDrop;

  @override
  State<CategoryTreeRow> createState() => CategoryTreeRowState();
}

class CategoryTreeRowState extends State<CategoryTreeRow> {
  bool _hovered = false;

  static const double _indent = 18;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context);
    final cat = widget.category;
    final tone = widget.tone;
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
              if (widget.checked case final checked?) ...[
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: checked,
                    visualDensity: VisualDensity.compact,
                    onChanged: (_) => widget.onSelect(),
                  ),
                ),
                const SizedBox(width: AppDimens.space4),
              ],
              SizedBox(
                width: 20,
                child: widget.hasChildren
                    ? Chevron(
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

    final withGuides = isRoot
        ? tile
        : CustomPaint(
            painter: TreeGuidePainter(
              level: cat.level,
              indent: _indent,
              isLast: widget.isLast,
              color: c.border,
            ),
            child: Padding(
              padding: EdgeInsets.only(left: cat.level * _indent),
              child: tile,
            ),
          );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 1),
        child: widget.onDrop == null
            ? withGuides
            : CategoryDraggable(
                payload: CategoryDrag(cat),
                label: cat.name,
                icon: AppIcons.byKey(cat.icon),
                tone: tone,
                child: _withDropZones(context, withGuides, tone),
              ),
      ),
    );
  }

  /// Три зоны на строке: сверху «поставить перед», снизу «после», посередине
  /// «положить внутрь».
  ///
  /// Три зоны, а не вычисление координат в одном таргете: их видно в дереве
  /// виджетов, по ним можно попасть в тесте, и каждая сама решает, принимает
  /// ли она груз.
  Widget _withDropZones(BuildContext context, Widget row, Color tone) {
    Widget line(DropEdge edge, {required bool top}) =>
        DropZone<CategoryDropPayload>(
          onWillAccept: (payload) => widget.canDrop!(payload, edge),
          onAccept: (payload) => widget.onDrop!(payload, edge),
          builder: (context, active) => Container(
            height: dropEdgeHeight,
            decoration: active
                ? BoxDecoration(
                    border: Border(
                      top: top
                          ? BorderSide(color: tone, width: 2)
                          : BorderSide.none,
                      bottom: top
                          ? BorderSide.none
                          : BorderSide(color: tone, width: 2),
                    ),
                  )
                : null,
          ),
        );

    return Stack(
      children: [
        DropZone<CategoryDropPayload>(
          onWillAccept: (payload) => widget.canDrop!(payload, DropEdge.into),
          onAccept: (payload) => widget.onDrop!(payload, DropEdge.into),
          builder: (context, active) => DropHoverExpand(
            // Свёрнутая ветка раскрывается сама, если над ней подержать груз:
            // иначе положить внутрь неё нечего, не бросив груз сначала.
            active: active && widget.collapsed && widget.hasChildren,
            onExpand: widget.onToggle,
            child: Container(
              decoration: active
                  ? BoxDecoration(
                      color: tone.withValues(alpha: 0.14),
                      borderRadius: AppDimens.brSm,
                      border: Border.all(color: tone, width: 1.5),
                    )
                  : null,
              child: row,
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: line(DropEdge.before, top: true),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: line(DropEdge.after, top: false),
        ),
      ],
    );
  }
}

/// Направляющие линии дерева: вертикали предков и уголок к самому узлу.
class TreeGuidePainter extends CustomPainter {
  const TreeGuidePainter({
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
  bool shouldRepaint(TreeGuidePainter old) =>
      old.level != level || old.isLast != isLast || old.color != color;
}

class Chevron extends StatelessWidget {
  const Chevron({super.key, required this.collapsed, required this.onTap});

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
