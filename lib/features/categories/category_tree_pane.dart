import 'package:flutter/material.dart';

import '../../core/domain/app_icons.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../core/utils/normalize.dart';
import '../../data/db/database.dart';
import '../../design_system/design_system.dart';
import 'categories_screen.dart';

/// Левая панель: дерево категорий с направляющими линиями.
class TreePane extends StatelessWidget {
  const TreePane({
    super.key,
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

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 1),
        child: isRoot
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
              ),
      ),
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
