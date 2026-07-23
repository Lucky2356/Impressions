import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../core/domain/app_icons.dart';
import '../../core/domain/relation.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_layout.dart';
import '../../core/theme/theme_context.dart';
import '../../data/db/database.dart';
import '../../data/models/entry_view.dart';
import '../../data/providers.dart';
import '../../design_system/design_system.dart';
import '../entry/entry_detail_sheet.dart';
import '../quick_add/quick_add_sheet.dart';
import 'category_providers.dart';

/// Записи выбранной ветки категорий.
///
/// Живут прямо на экране категорий, а не через фильтр каталога: подстановка
/// фильтра в другой раздел незаметно меняла его состояние, и добавленные потом
/// записи «пропадали» из каталога.
final categoryEntriesProvider = FutureProvider.family<List<EntryView>, String>((
  ref,
  categoryId,
) async {
  ref.watch(dataRefreshProvider);
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return const [];

  final all = await ref.watch(allCategoriesProvider.future);
  final selected = all.where((c) => c.id == categoryId).firstOrNull;
  if (selected == null) return const [];

  final prefix = '${selected.path}/';
  final ids = [
    selected.id,
    ...all.where((c) => c.path.startsWith(prefix)).map((c) => c.id),
  ];

  return ref
      .watch(entryRepositoryProvider)
      .entryViews(profile.id, categoryIds: ids);
});

/// Правая панель экрана категорий: что лежит в выбранной ветке.
class CategoryDetail extends ConsumerWidget {
  const CategoryDetail({
    super.key,
    required this.category,
    required this.onOpenChild,
    required this.onAddChild,
    required this.onRename,
    required this.onIcon,
    required this.onMove,
    required this.onArchive,
    this.onBack,
  });

  final CategoryRow category;
  final ValueChanged<CategoryRow> onOpenChild;
  final VoidCallback onAddChild;
  final VoidCallback onRename;
  final VoidCallback onIcon;
  final VoidCallback onMove;
  final VoidCallback onArchive;

  /// Возврат к списку — только в узкой раскладке.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final layout = context.layout;

    final all = ref.watch(allCategoriesProvider).value ?? const <CategoryRow>[];
    final children = all.where((x) => x.parentId == category.id).toList();
    final entries = ref.watch(categoryEntriesProvider(category.id));
    final direct = ref.watch(categoryDirectCountsProvider).value ?? const {};
    final branch = ref.watch(categoryBranchCountsProvider).value ?? const {};

    final tone = category.color != null
        ? Color(category.color!)
        : c.profileColorFor(category.id);

    // Хлебные крошки строятся из материализованного пути.
    final byId = {for (final x in all) x.id: x};
    final trail = [
      for (final id in category.path.split('/'))
        if (byId[id] case final node?) node.name,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            layout.gutter,
            AppDimens.space20,
            layout.gutter,
            AppDimens.space16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (trail.length > 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.space8),
                  child: Text(
                    trail.take(trail.length - 1).join('  ›  '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.labelSmall?.copyWith(
                      color: c.textMuted,
                    ),
                  ),
                ),
              Row(
                children: [
                  if (onBack != null) ...[
                    AppIconButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: l10n.commonBack,
                      onPressed: onBack!,
                    ),
                    const SizedBox(width: AppDimens.space8),
                  ],
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: tone.withValues(alpha: 0.14),
                      borderRadius: AppDimens.brMd,
                    ),
                    child: Icon(
                      AppIcons.byKey(category.icon),
                      size: 26,
                      color: tone,
                    ),
                  ),
                  const SizedBox(width: AppDimens.space16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          category.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.headlineMedium,
                        ),
                        const SizedBox(height: AppDimens.space2),
                        Text(
                          _summary(l10n, direct, branch, children.length),
                          style: context.text.bodySmall?.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimens.space12),
                  OutlinedButton.icon(
                    onPressed: onAddChild,
                    icon: const Icon(Icons.create_new_folder_rounded, size: 18),
                    label: Text(l10n.categoryAddChild),
                  ),
                  const SizedBox(width: AppDimens.space8),
                  FilledButton.icon(
                    onPressed: () =>
                        QuickAddSheet.show(context, initialCategory: category),
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: Text(l10n.commonAdd),
                  ),
                  const SizedBox(width: AppDimens.space4),
                  PopupMenuButton<String>(
                    tooltip: '',
                    icon: Icon(
                      Icons.more_horiz_rounded,
                      color: c.textSecondary,
                    ),
                    onSelected: (v) => switch (v) {
                      'rename' => onRename(),
                      'icon' => onIcon(),
                      'move' => onMove(),
                      'archive' => onArchive(),
                      _ => null,
                    },
                    itemBuilder: (_) => [
                      _item('rename', Icons.edit_rounded, l10n.categoryRename),
                      _item(
                        'icon',
                        Icons.emoji_symbols_rounded,
                        l10n.categoryIcon,
                      ),
                      _item(
                        'move',
                        Icons.drive_file_move_rounded,
                        l10n.categoryMove,
                      ),
                      const PopupMenuDivider(),
                      _item(
                        'archive',
                        Icons.archive_rounded,
                        l10n.categoryArchive,
                        danger: true,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(height: 1, color: c.border),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              layout.gutter,
              AppDimens.space16,
              layout.gutter,
              AppDimens.space40,
            ),
            children: [
              if (children.isNotEmpty) ...[
                SectionHeader(title: l10n.categorySubcategoriesTitle),
                const SizedBox(height: AppDimens.space12),
                Wrap(
                  spacing: AppDimens.space8,
                  runSpacing: AppDimens.space8,
                  children: [
                    for (final child in children)
                      _SubcategoryTile(
                        category: child,
                        count: branch[child.id] ?? 0,
                        onTap: () => onOpenChild(child),
                      ),
                  ],
                ),
                const SizedBox(height: AppDimens.space32),
              ],
              SectionHeader(title: l10n.categoryEntriesTitle),
              const SizedBox(height: AppDimens.space12),
              entries.when(
                loading: () => const SizedBox.shrink(),
                error: (e, _) => Text('$e'),
                data: (list) {
                  if (list.isEmpty) {
                    return _EmptyBranch(
                      onAdd: () => QuickAddSheet.show(
                        context,
                        initialCategory: category,
                      ),
                    );
                  }
                  // Сеткой, а не колонкой: на широком экране карточка во всю
                  // ширину окна выглядит нелепо, а места пропадает много.
                  return LayoutBuilder(
                    builder: (context, cns) {
                      final columns = (cns.maxWidth / 380).floor().clamp(1, 4);
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: AppDimens.space8,
                          crossAxisSpacing: AppDimens.space8,
                          mainAxisExtent: 104,
                        ),
                        itemCount: list.length,
                        itemBuilder: (context, i) {
                          final e = list[i];
                          return EntryCardCompact(
                            data: EntryCardData(
                              title: e.title,
                              subtitle: e.subtitle,
                              categoryPath: e.categoryPath,
                              relation: _relationOf(e.relation),
                              rating: e.rating,
                              seedColor: c.profileColorFor(e.objectId),
                            ),
                            onTap: () =>
                                EntryDetailSheet.show(context, e.entryId),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _summary(
    AppLocalizations l10n,
    Map<String, int> direct,
    Map<String, int> branch,
    int childCount,
  ) {
    final here = direct[category.id] ?? 0;
    final inBranch = branch[category.id] ?? 0;
    final parts = <String>[
      l10n.categoryBranchCount(inBranch),
      if (childCount > 0) l10n.categorySubcategoriesCount(childCount),
      // «0 прямо здесь» — бесполезный шум, показываем только непустое.
      if (here > 0 && here != inBranch) l10n.categoryDirectCount(here),
    ];
    return parts.join(' · ');
  }

  PopupMenuItem<String> _item(
    String value,
    IconData icon,
    String label, {
    bool danger = false,
  }) {
    return PopupMenuItem(
      value: value,
      height: 40,
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: AppDimens.space12),
          Text(label),
        ],
      ),
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

/// Плитка подкатегории в правой панели.
class _SubcategoryTile extends StatelessWidget {
  const _SubcategoryTile({
    required this.category,
    required this.count,
    required this.onTap,
  });

  final CategoryRow category;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tone = category.color != null
        ? Color(category.color!)
        : c.profileColorFor(category.id);

    return Material(
      color: c.surface,
      borderRadius: AppDimens.brMd,
      child: InkWell(
        borderRadius: AppDimens.brMd,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.space12,
            vertical: AppDimens.space8,
          ),
          decoration: BoxDecoration(
            borderRadius: AppDimens.brMd,
            border: Border.all(color: c.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  AppIcons.byKey(category.icon),
                  size: 16,
                  color: tone,
                ),
              ),
              const SizedBox(width: AppDimens.space8),
              Text(category.name, style: context.text.labelLarge),
              if (count > 0) ...[
                const SizedBox(width: AppDimens.space8),
                Text(
                  '$count',
                  style: context.text.labelSmall?.copyWith(color: c.textMuted),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyBranch extends StatelessWidget {
  const _EmptyBranch({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.space32),
      decoration: BoxDecoration(
        color: c.surfaceMuted,
        borderRadius: AppDimens.brLg,
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded, size: 30, color: c.textMuted),
          const SizedBox(height: AppDimens.space12),
          Text(
            l10n.categoryBranchEmpty,
            style: context.text.bodyMedium?.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: AppDimens.space16),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: Text(l10n.commonAdd),
          ),
        ],
      ),
    );
  }
}
