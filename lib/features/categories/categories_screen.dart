import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../core/domain/app_icons.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/db/database.dart';
import '../../data/providers.dart';
import '../../data/repositories/category_repository.dart';
import '../../design_system/design_system.dart';
import '../quick_add/category_picker.dart';
import 'category_providers.dart';

/// Экран дерева категорий (§7): создание корневых и вложенных категорий,
/// переименование, перемещение с защитой от циклов, архивирование.
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final Set<String> _collapsed = {};

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
    _bump();
  }

  Future<void> _rename(CategoryRow cat) async {
    final l10n = AppLocalizations.of(context);
    final name = await _askName(l10n.categoryRename, initial: cat.name);
    if (name == null) return;
    await ref.read(categoryRepositoryProvider).rename(cat.id, name);
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

  bool _hiddenByCollapse(CategoryRow cat) {
    final ids = cat.path.split('/');
    // Пропускаем собственный id — скрываем только потомков свёрнутых узлов.
    for (var i = 0; i < ids.length - 1; i++) {
      if (_collapsed.contains(ids[i])) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final categories = ref.watch(allCategoriesProvider);
    final counts = ref.watch(categoryDirectCountsProvider).value ?? const {};

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
        for (final cat in list) {
          if (cat.parentId != null) hasChildren[cat.parentId!] = true;
        }
        final visible = list.where((cat) => !_hiddenByCollapse(cat)).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.space24,
                AppDimens.space20,
                AppDimens.space24,
                AppDimens.space12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.categoriesTitle,
                      style: context.text.headlineSmall,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: _createRoot,
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: Text(l10n.categoryAddRoot),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: c.border),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.space16,
                  vertical: AppDimens.space8,
                ),
                itemCount: visible.length,
                itemBuilder: (context, i) {
                  final cat = visible[i];
                  return _CategoryRow(
                    category: cat,
                    count: counts[cat.id] ?? 0,
                    hasChildren: hasChildren[cat.id] ?? false,
                    collapsed: _collapsed.contains(cat.id),
                    onToggle: () => setState(() {
                      if (!_collapsed.remove(cat.id)) _collapsed.add(cat.id);
                    }),
                    onAddChild: () => _createChild(cat),
                    onRename: () => _rename(cat),
                    onMove: () => _move(cat),
                    onArchive: () => _archive(cat),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.count,
    required this.hasChildren,
    required this.collapsed,
    required this.onToggle,
    required this.onAddChild,
    required this.onRename,
    required this.onMove,
    required this.onArchive,
  });

  final CategoryRow category;
  final int count;
  final bool hasChildren;
  final bool collapsed;
  final VoidCallback onToggle;
  final VoidCallback onAddChild;
  final VoidCallback onRename;
  final VoidCallback onMove;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: category.level * 20.0,
        bottom: AppDimens.space4,
      ),
      child: AppCard(
        elevated: false,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space12,
          vertical: AppDimens.space8,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: hasChildren
                  ? IconButton(
                      onPressed: onToggle,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        collapsed
                            ? Icons.chevron_right_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: c.textSecondary,
                      ),
                    )
                  : null,
            ),
            Icon(
              AppIcons.byKey(category.icon),
              size: 20,
              color: c.textSecondary,
            ),
            const SizedBox(width: AppDimens.space12),
            Expanded(
              child: Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.titleMedium,
              ),
            ),
            if (count > 0)
              Padding(
                padding: const EdgeInsets.only(right: AppDimens.space8),
                child: Text(
                  l10n.categoryEntriesCount(count),
                  style: context.text.labelSmall?.copyWith(color: c.textMuted),
                ),
              ),
            PopupMenuButton<String>(
              tooltip: '',
              icon: Icon(
                Icons.more_horiz_rounded,
                size: 20,
                color: c.textSecondary,
              ),
              onSelected: (v) => switch (v) {
                'child' => onAddChild(),
                'rename' => onRename(),
                'move' => onMove(),
                'archive' => onArchive(),
                _ => null,
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'child',
                  child: Text(l10n.categoryAddChild),
                ),
                PopupMenuItem(
                  value: 'rename',
                  child: Text(l10n.categoryRename),
                ),
                PopupMenuItem(value: 'move', child: Text(l10n.categoryMove)),
                PopupMenuItem(
                  value: 'archive',
                  child: Text(l10n.categoryArchive),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
