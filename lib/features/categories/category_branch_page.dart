import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/app_icons.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_layout.dart';
import '../../core/theme/theme_context.dart';
import '../../data/db/database.dart';
import '../../data/models/category_tree.dart';
import '../../design_system/design_system.dart';
import '../home/pinned_store.dart';
import '../quick_add/quick_add_sheet.dart';
import 'category_actions.dart';
import 'category_branch_entries.dart';
import 'category_palette.dart';
import 'category_providers.dart';

/// С какой ширины шапка ветки помещается в одну строку.
///
/// Считается по содержимому: возврат, значок, название, «Добавить
/// подкатегорию», «Добавить» и меню. Ниже этого кнопки переносятся под
/// название.
const double _wideHeaderWidth = 660;

/// Страница ветки: что она такое и что в ней лежит.
///
/// Раньше это была правая панель, к которой вёл один из двух режимов обзора, и
/// содержимое ветки показывалось списком целиком. Теперь ветка — самостоятельная
/// страница: сверху её лицо и крошки, ниже подкатегории полками, ниже записи с
/// охватом, порядком и подгрузкой.
class CategoryBranchPage extends ConsumerWidget {
  const CategoryBranchPage({
    super.key,
    required this.category,
    this.onBack,
    this.onOpenTree,
  });

  final CategoryRow category;

  /// Возврат на шаг — только в узкой раскладке.
  final VoidCallback? onBack;

  /// Показать дерево целиком — кнопка узкой раскладки, где его не видно.
  final VoidCallback? onOpenTree;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final layout = context.layout;
    final actions = CategoryActions(ref, context);

    final all = ref.watch(allCategoriesProvider).value ?? const <CategoryRow>[];
    final children = CategoryTree.childrenOf(all, category.id);
    final feed = ref.watch(categoryBranchResultsProvider);
    final direct = ref.watch(categoryDirectCountsProvider).value ?? const {};
    final branch = ref.watch(categoryBranchCountsProvider).value ?? const {};

    final tone = CategoryPalette.colorOf(category, all, c);
    final crumbs = CategoryTree.breadcrumbOf(all, category);

    // Шапка внутри прокрутки, а не над ней: прибитая к верху, она в альбомной
    // ориентации и при крупном системном шрифте съедала почти всю высоту, и
    // ленте оставалась полоска в пару строк.
    return ListView(
      // Разделы живут в KeyedSubtree и при переключении уничтожаются:
      // без своего ключа страница возвращалась бы в начало.
      key: PageStorageKey('category-branch-${category.id}'),
      padding: EdgeInsets.zero,
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
              if (crumbs.length > 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.space8),
                  child: Breadcrumbs(
                    crumbs: [
                      for (final node in crumbs.take(crumbs.length - 1))
                        Crumb(node.name, onTap: () => actions.select(node)),
                    ],
                  ),
                ),
              _Header(
                category: category,
                tone: tone,
                childCount: children.length,
                here: direct[category.id] ?? 0,
                inBranch: branch[category.id] ?? 0,
                onBack: onBack,
                onOpenTree: onOpenTree,
                actions: actions,
              ),
            ],
          ),
        ),
        // Черта во всю ширину, поэтому отступы по краям несёт не список, а
        // каждая половина отдельно.
        Divider(height: 1, color: c.border),
        Padding(
          padding: EdgeInsets.fromLTRB(
            layout.gutter,
            AppDimens.space16,
            layout.gutter,
            AppDimens.space40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (children.isNotEmpty) ...[
                SectionHeader(title: l10n.categorySubcategoriesTitle),
                const SizedBox(height: AppDimens.space12),
                CategoryShelves(categories: children, allCategories: all),
                const SizedBox(height: AppDimens.space32),
              ],
              SectionHeader(title: l10n.categoryEntriesTitle),
              const SizedBox(height: AppDimens.space12),
              feed.when(
                loading: () => const SkeletonList(),
                error: (e, _) => ErrorState(error: e),
                data: (found) {
                  if (found.items.isEmpty) {
                    return BranchEmpty(
                      onAdd: () => QuickAddSheet.show(
                        context,
                        initialCategory: category,
                      ),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      BranchEntriesBar(total: found.total),
                      const SizedBox(height: AppDimens.space12),
                      BranchEntriesGrid(
                        entries: found.items,
                        branchIds: CategoryTree.branchIds(
                          all,
                          category.id,
                        ).toSet(),
                        // Тащить запись есть куда только там, где рядом видно
                        // дерево: на телефоне для этого есть пункт меню.
                        draggable: layout.isWide,
                      ),
                      if (found.hasMore) const BranchLoadMore(),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Шапка ветки: значок, название, сводка и действия.
class _Header extends ConsumerWidget {
  const _Header({
    required this.category,
    required this.tone,
    required this.childCount,
    required this.here,
    required this.inBranch,
    required this.actions,
    this.onBack,
    this.onOpenTree,
  });

  final CategoryRow category;
  final Color tone;
  final int childCount;
  final int here;
  final int inBranch;
  final CategoryActions actions;
  final VoidCallback? onBack;
  final VoidCallback? onOpenTree;

  String _summary(AppLocalizations l10n) {
    final parts = <String>[
      l10n.categoryBranchCount(inBranch),
      if (childCount > 0) l10n.categorySubcategoriesCount(childCount),
      // «0 прямо здесь» — бесполезный шум, показываем только непустое.
      if (here > 0 && here != inBranch) l10n.categoryDirectCount(here),
    ];
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    // Значок закрепления меняется сразу после нажатия, поэтому смотрим на сам
    // список, а не на его хранителя.
    final pinned = (ref.watch(pinnedCategoryIdsProvider).value ?? const [])
        .contains(category.id);
    final cover =
        (ref.watch(categoryCoverPathsProvider).value ?? const {})[category.id];

    return LayoutBuilder(
      builder: (context, cns) {
        final title = [
          if (onBack != null) ...[
            AppIconButton(
              icon: Icons.arrow_back_rounded,
              tooltip: l10n.commonBack,
              onPressed: onBack!,
            ),
            const SizedBox(width: AppDimens.space8),
          ],
          // Выбранная обложка ветки показывается на её же странице. До сих
          // пор её было видно только на полке в списке — то есть везде, кроме
          // того места, к которому она относится.
          if (cover != null)
            ClipRRect(
              borderRadius: AppDimens.brMd,
              child: SizedBox(
                width: 52,
                height: 52,
                child: Image.file(
                  File(cover),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _IconTile(
                    icon: AppIcons.byKey(category.icon),
                    tone: tone,
                  ),
                ),
              ),
            )
          else
            _IconTile(icon: AppIcons.byKey(category.icon), tone: tone),
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
                  _summary(l10n),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall?.copyWith(
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ];

        final tree = onOpenTree == null
            ? null
            : AppIconButton(
                icon: Icons.account_tree_rounded,
                tooltip: l10n.categoryOpenTree,
                onPressed: onOpenTree!,
              );
        final addChild = OutlinedButton.icon(
          onPressed: () => actions.createChild(category),
          icon: const Icon(Icons.create_new_folder_rounded, size: 18),
          label: Text(
            l10n.categoryAddChild,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
        final addEntry = FilledButton.icon(
          onPressed: () =>
              QuickAddSheet.show(context, initialCategory: category),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: Text(
            l10n.commonAdd,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
        final menu = PopupMenuButton<String>(
          tooltip: '',
          icon: Icon(Icons.more_horiz_rounded, color: c.textSecondary),
          onSelected: (v) => actions.run(v, category),
          itemBuilder: (_) => [
            _item('rename', Icons.edit_rounded, l10n.categoryRename),
            _item('icon', Icons.emoji_symbols_rounded, l10n.categoryIcon),
            _item('move', Icons.drive_file_move_rounded, l10n.categoryMove),
            _item('up', Icons.arrow_upward_rounded, l10n.categoryMoveUp),
            _item('down', Icons.arrow_downward_rounded, l10n.categoryMoveDown),
            const PopupMenuDivider(),
            _item(
              'moveChildren',
              Icons.folder_copy_rounded,
              l10n.categoryMoveChildren,
            ),
            _item(
              'moveEntries',
              Icons.move_down_rounded,
              l10n.categoryMoveEntries,
            ),
            _item('merge', Icons.merge_rounded, l10n.categoryMerge),
            const PopupMenuDivider(),
            _item(
              'pin',
              pinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
              pinned ? l10n.homeUnpin : l10n.homePin,
            ),
            _item('archive', Icons.archive_rounded, l10n.categoryArchive),
          ],
        );

        // На телефоне название, счётчик и обе кнопки в одну строку не
        // помещаются: Expanded сжимался до нуля, и счётчик рисовался по букве
        // в столбик. Кнопки уходят под название.
        if (cns.maxWidth < _wideHeaderWidth) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [...title, ?tree, menu]),
              const SizedBox(height: AppDimens.space12),
              Wrap(
                spacing: AppDimens.space8,
                runSpacing: AppDimens.space8,
                children: [addChild, addEntry],
              ),
            ],
          );
        }

        return Row(
          children: [
            ...title,
            const SizedBox(width: AppDimens.space12),
            addChild,
            const SizedBox(width: AppDimens.space8),
            addEntry,
            const SizedBox(width: AppDimens.space4),
            ?tree,
            menu,
          ],
        );
      },
    );
  }

  PopupMenuItem<String> _item(String value, IconData icon, String label) {
    return PopupMenuItem(
      value: value,
      height: 40,
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: AppDimens.space12),
          // Без Flexible длинная подпись вроде «Перенести подкатегории…»
          // вылезает за край всплывающего меню.
          Flexible(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

/// Ветки полками — с цветом, счётчиком и фотографиями из ветки.
///
/// Раньше полки были отдельным режимом обзора и жили вместо дерева. Здесь они
/// на своём месте: это содержимое, а не другой способ смотреть на дерево.
/// Одним виджетом и для подкатегорий на странице ветки, и для корневых полок
/// на телефоне.
///
/// Полки всегда вкладываются в чужую прокрутку и своей не имеют: до 1.18.0
/// сетка умела прокручиваться сама, но включалось это неиспользованным
/// параметром, а корневые полки на телефоне попадали в ветку без прокрутки —
/// и всё ниже сгиба оказывалось недоступным.
class CategoryShelves extends ConsumerWidget {
  const CategoryShelves({
    super.key,
    required this.categories,
    required this.allCategories,
  });

  /// Что показывать полками.
  final List<CategoryRow> categories;

  /// Всё дерево — из него берутся имена подкатегорий для подписи на карточке.
  final List<CategoryRow> allCategories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final actions = CategoryActions(ref, context);
    final branchCounts =
        ref.watch(categoryBranchCountsProvider).value ?? const {};
    final covers = ref.watch(categoryCoversProvider).value ?? const {};
    final pinned = ref.watch(categoryCoverPathsProvider).value ?? const {};

    if (categories.isEmpty) {
      return EmptyState(
        icon: Icons.grid_view_rounded,
        title: l10n.categoryShelfEmptyTitle,
        message: l10n.categoryShelfEmptyMessage,
      );
    }

    return LayoutBuilder(
      builder: (context, cns) {
        final cols = (cns.maxWidth / 210).floor().clamp(1, 6);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: AppDimens.space12,
            crossAxisSpacing: AppDimens.space12,
            // Высота задаётся напрямую: содержимое карточки не зависит от
            // ширины. Поправка на системный шрифт — чтобы подписи помещались и
            // при «Крупном шрифте».
            mainAxisExtent: categoryShelfHeightFor(
              MediaQuery.textScalerOf(context).scale(1),
            ),
          ),
          itemCount: categories.length,
          itemBuilder: (context, i) {
            final cat = categories[i];
            final grandChildren = [
              for (final x in CategoryTree.childrenOf(allCategories, cat.id))
                x.name,
            ];
            final count = branchCounts[cat.id] ?? 0;
            // Цвет от самой ветки, а не от её места в списке: при поиске один
            // и тот же «Сыр» менял цвет вместе с номером строки.
            final tone = CategoryPalette.colorOf(cat, allCategories, c);

            return Appear(
              index: i,
              child: GestureDetector(
                onSecondaryTapDown: (d) => actions.menu(cat, d.globalPosition),
                onLongPressStart: (d) => actions.menu(cat, d.globalPosition),
                child: CategoryShelfCard(
                  name: cat.name,
                  icon: AppIcons.byKey(cat.icon),
                  color: tone,
                  count: count,
                  countLabel: l10n.categoryEntriesCount(count),
                  childNames: grandChildren.take(4).toList(),
                  covers: covers[cat.id] ?? const [],
                  coverPath: pinned[cat.id],
                  // Одно нажатие — один исход: открыть ветку. Раньше карточка
                  // вела то вглубь, то в панель справа, в зависимости от того,
                  // есть ли внутри подкатегории.
                  onTap: () => actions.select(cat),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Значок ветки на цветной плитке — когда своей обложки у неё нет.
class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon, required this.tone});

  final IconData icon;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.14),
        borderRadius: AppDimens.brMd,
      ),
      child: Icon(icon, size: 26, color: tone),
    );
  }
}
