import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/models/entry_view.dart';
import '../../design_system/design_system.dart';
import '../entry/entry_card_data.dart';
import '../entry/entry_detail_sheet.dart';
import 'category_drag.dart';
import 'category_providers.dart';

/// Панель над списком записей ветки: охват и порядок.
///
/// Переключатель «только здесь / вся ветка» стоит рядом со списком, а не в
/// настройках: вопрос «а это всё или только верхняя полка» возникает прямо в
/// момент чтения списка.
class BranchEntriesBar extends ConsumerWidget {
  const BranchEntriesBar({super.key, required this.total});

  /// Сколько записей всего под нынешним охватом.
  final int total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final view = ref.watch(categoryBranchStateProvider);
    final notifier = ref.read(categoryBranchStateProvider.notifier);

    return Wrap(
      spacing: AppDimens.space8,
      runSpacing: AppDimens.space8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SegmentedToggle<bool>(
          value: view.subtree,
          onChanged: notifier.setSubtree,
          segments: [
            SegmentData(
              value: false,
              icon: Icons.folder_open_rounded,
              tooltip: l10n.categoryScopeHere,
            ),
            SegmentData(
              value: true,
              icon: Icons.account_tree_rounded,
              tooltip: l10n.categoryScopeBranch,
            ),
          ],
        ),
        AppDropdown<EntrySort>(
          label: l10n.catalogSortLabel,
          value: view.sort,
          showLabel: false,
          icon: Icons.swap_vert_rounded,
          onChanged: (v) => v == null ? null : notifier.setSort(v),
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
        ),
        AppIconButton(
          icon: view.reverseSort
              ? Icons.arrow_upward_rounded
              : Icons.arrow_downward_rounded,
          tooltip: view.reverseSort
              ? l10n.catalogSortReversed
              : l10n.catalogSortNatural,
          onPressed: () => notifier.setReverse(!view.reverseSort),
        ),
        Text(
          l10n.categoryEntriesCount(total),
          style: context.text.labelSmall?.copyWith(color: c.textMuted),
        ),
      ],
    );
  }
}

/// Записи ветки сеткой компактных карточек.
///
/// Сеткой, а не колонкой: на широком экране карточка во всю ширину окна
/// выглядит нелепо, а места пропадает много.
class BranchEntriesGrid extends StatelessWidget {
  const BranchEntriesGrid({
    super.key,
    required this.entries,
    required this.branchIds,
    this.draggable = true,
  });

  final List<EntryView> entries;

  /// Ветка, содержимое которой показано. По ней видно, кто попал сюда
  /// дополнительной категорией: у такой записи путь ведёт совсем в другое
  /// место, и без пометки это выглядит как ошибка.
  final Set<String> branchIds;

  /// Можно ли утащить запись в другую ветку. На телефоне дерева на экране нет,
  /// и тащить некуда — там перенос делается через меню записи.
  final bool draggable;

  @override
  Widget build(BuildContext context) {
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
            // Высота берётся у самой карточки, а не подбирается здесь: с
            // 1.17.0 в строке метаданных стоят и отношение, и стадия, и
            // оценка, подобранных 104 точек им перестало хватать.
            mainAxisExtent: entryCardCompactHeightFor(
              MediaQuery.textScalerOf(context).scale(1),
            ),
          ),
          itemCount: entries.length,
          itemBuilder: (context, i) {
            final e = entries[i];
            final card = _maybeBadged(
              context,
              entry: e,
              child: EntryCardCompact(
                data: entryCardData(context, e, hero: true),
                onTap: () => EntryDetailSheet.show(context, e.entryId),
              ),
            );
            if (!draggable) return card;
            return CategoryDraggable(
              payload: EntryDrag(entryId: e.entryId, title: e.title),
              label: e.title,
              icon: Icons.description_rounded,
              tone: context.colors.accentPrimary,
              child: card,
            );
          },
        );
      },
    );
  }

  /// Помечает запись, которая лежит здесь дополнительной категорией.
  ///
  /// Основная категория задаёт путь на карточке. Если он ведёт в другую ветку,
  /// запись в этом списке выглядит попавшей по ошибке — пометка объясняет, что
  /// она тут нарочно.
  Widget _maybeBadged(
    BuildContext context, {
    required EntryView entry,
    required Widget child,
  }) {
    // Путь пуст — основной категории нет вовсе, и сравнивать не с чем.
    if (entry.categoryPath.isEmpty) return child;
    if (entry.primaryCategoryId case final id? when branchIds.contains(id)) {
      return child;
    }

    final l10n = AppLocalizations.of(context);
    return Stack(
      children: [
        child,
        Positioned(
          top: AppDimens.space4,
          right: AppDimens.space4,
          child: Tooltip(
            message: l10n.categoryExtraBadge,
            child: Icon(
              Icons.link_rounded,
              size: 14,
              color: context.colors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

/// Заглушка пустой ветки: единственный видимый выход отсюда — завести запись.
class BranchEmpty extends StatelessWidget {
  const BranchEmpty({super.key, required this.onAdd});
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

/// Кнопка «показать ещё» под неполным списком.
///
/// Ленты внутри прокручиваемой страницы не хватает: подгрузка по прокрутке
/// требует своего скролла, а он здесь один на всю страницу ветки.
class BranchLoadMore extends ConsumerWidget {
  const BranchLoadMore({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.space16),
      child: Center(
        child: OutlinedButton(
          onPressed: () => ref.read(categoryFeedProvider.notifier).more(),
          child: Text(l10n.categoryShowMore),
        ),
      ),
    );
  }
}
