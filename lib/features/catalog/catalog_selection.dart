import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../core/domain/relation.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_layout.dart';
import '../../core/theme/theme_context.dart';
import '../../data/db/database.dart';
import '../../data/providers.dart';
import '../../design_system/design_system.dart';
import '../collections/collection_picker.dart';
import '../quick_add/category_picker.dart';

/// Выделенные в каталоге записи.
///
/// Живёт отдельно от фильтров: выделение не должно переживать перезапуск и не
/// сохраняется в настройках.
class CatalogSelection extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  /// Запись, от которой тянут диапазон Shift+кликом.
  String? _anchor;

  void toggle(String entryId) {
    final next = {...state};
    if (!next.remove(entryId)) next.add(entryId);
    state = next;
    _anchor = entryId;
  }

  /// Выделяет всё между якорем и записью в показанном порядке.
  ///
  /// Убрать в архив тридцать записей подряд означало тридцать нажатий: меню
  /// умело Ctrl+клик и долгое нажатие, а привычного Shift+клика не было.
  /// Якорь не двигаем — от одной точки можно тянуть в обе стороны, как в
  /// проводнике.
  void selectTo(String entryId, List<String> order) {
    final anchor = _anchor;
    final from = anchor == null ? -1 : order.indexOf(anchor);
    final to = order.indexOf(entryId);
    // Якоря нет или он уехал из выборки (сменились фильтры, ушла страница) —
    // тянуть неоткуда, ведём себя как обычный клик с Ctrl.
    if (from < 0 || to < 0) {
      toggle(entryId);
      return;
    }

    final lo = from < to ? from : to;
    final hi = from < to ? to : from;
    state = {...state, ...order.sublist(lo, hi + 1)};
  }

  void selectAll(Iterable<String> entryIds) {
    state = entryIds.toSet();
    _anchor = state.isEmpty ? null : state.last;
  }

  void clear() {
    state = const {};
    _anchor = null;
  }

  bool get isActive => state.isNotEmpty;
}

final catalogSelectionProvider =
    NotifierProvider<CatalogSelection, Set<String>>(CatalogSelection.new);

/// Панель массовых действий над выделенными записями.
///
/// Раньше каждое действие приходилось повторять по одной записи: разложить
/// два десятка товаров по категориям означало два десятка открытий карточки.
class BulkActionsBar extends ConsumerStatefulWidget {
  const BulkActionsBar({super.key, required this.onSelectAll});

  final VoidCallback onSelectAll;

  @override
  ConsumerState<BulkActionsBar> createState() => _BulkActionsBarState();
}

class _BulkActionsBarState extends ConsumerState<BulkActionsBar> {
  bool _busy = false;

  Future<void> _run(Future<void> Function(List<String> ids) action) async {
    final ids = ref.read(catalogSelectionProvider).toList();
    if (ids.isEmpty) return;
    setState(() => _busy = true);
    try {
      await action(ids);
      ref.read(dataRefreshProvider.notifier).bump();
      ref.read(catalogSelectionProvider.notifier).clear();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _setCategory() async {
    final picked = await CategoryPicker.show(context);
    final category = picked?.category;
    if (picked == null || picked.cleared || category == null) return;
    await _run((ids) async {
      final repo = ref.read(entryRepositoryProvider);
      for (final id in ids) {
        await repo.setPrimaryCategory(id, category.id);
      }
    });
  }

  Future<void> _addTag() async {
    final l10n = AppLocalizations.of(context);
    final profile = ref.read(activeProfileProvider);
    if (profile == null) return;
    final name = await TextInputDialog.show(
      context,
      title: l10n.tagAdd,
      label: l10n.tagNameLabel,
    );
    if (name == null) return;
    await _run((ids) async {
      final repo = ref.read(entryRepositoryProvider);
      for (final id in ids) {
        await repo.addTag(profile.id, id, name);
      }
    });
  }

  /// Снимает тег со всех выделенных записей.
  ///
  /// Повесить тег на пачку было можно, а снять — только по одной записи, через
  /// карточку. Выбирать предлагаем из тех тегов, что на выделенном и стоят.
  Future<void> _removeTag() async {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(entryRepositoryProvider);
    final ids = ref.read(catalogSelectionProvider).toList();

    final tags = <String, TagRow>{};
    for (final id in ids) {
      for (final tag in await repo.tagsOfEntry(id)) {
        tags[tag.id] = tag;
      }
    }
    if (!mounted) return;
    if (tags.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.bulkRemoveTagEmpty)));
      return;
    }

    final sorted = tags.values.toList()
      ..sort((a, b) => a.normalizedName.compareTo(b.normalizedName));
    final chosen = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l10n.bulkRemoveTag),
        children: [
          for (final tag in sorted)
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(tag.id),
              child: Row(
                children: [
                  const Icon(Icons.label_outline_rounded, size: 18),
                  const SizedBox(width: AppDimens.space12),
                  Expanded(child: Text(tag.name)),
                ],
              ),
            ),
        ],
      ),
    );
    if (chosen == null) return;

    await _run((selected) async {
      for (final id in selected) {
        await repo.removeTag(id, chosen);
      }
    });
  }

  /// Ставит отношение всей пачке.
  ///
  /// «Понравилось / не понравилось» — самое частое действие вообще, а в панели
  /// выделения его не было: разбирая полсотни записей, отношение проставляли
  /// по одной через меню карточки.
  Future<void> _setRelation(Relation relation) async {
    final l10n = AppLocalizations.of(context);
    final count = ref.read(catalogSelectionProvider).length;

    await _run((ids) async {
      final repo = ref.read(entryRepositoryProvider);
      for (final id in ids) {
        await repo.updateEntry(id, relation: relation.name);
      }
    });

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.bulkDone(count))));
  }

  /// Ставит оценку всей пачке — тем же выбором, что и в карточке.
  Future<void> _setRating() async {
    final l10n = AppLocalizations.of(context);
    final count = ref.read(catalogSelectionProvider).length;

    final rating = await RatingDialog.show(
      context,
      title: l10n.bulkSelected(count),
    );
    if (rating == null) return;

    await _run((ids) async {
      final repo = ref.read(entryRepositoryProvider);
      for (final id in ids) {
        await repo.updateEntry(id, rating: rating);
      }
    });

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.bulkDone(count))));
  }

  /// Кладёт выделенное в подборку.
  ///
  /// Пустой список подборок больше не тупик: завести первую можно прямо
  /// отсюда — раньше кнопка нажималась и не происходило ничего.
  Future<void> _addToCollection() async {
    final chosen = await CollectionPicker.show(context, ref);
    if (chosen == null) return;
    await _run((ids) async {
      final repo = ref.read(collectionRepositoryProvider);
      for (final id in ids) {
        await repo.addEntry(chosen, id);
      }
    });
  }

  /// Архивирование пачки без вопроса «точно?»: следом появляется «Вернуть»,
  /// которое возвращает ровно те же записи.
  Future<void> _archive() async {
    final l10n = AppLocalizations.of(context);
    final ids = ref.read(catalogSelectionProvider).toList();

    await _run((selected) async {
      final repo = ref.read(entryRepositoryProvider);
      for (final id in selected) {
        await repo.archiveEntry(id);
      }
    });

    if (!mounted) return;
    showUndoSnackBar(
      context,
      message: l10n.bulkArchived(ids.length),
      onUndo: () async {
        final repo = ref.read(entryRepositoryProvider);
        for (final id in ids) {
          await repo.restoreEntry(id);
        }
        ref.read(dataRefreshProvider.notifier).bump();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final selected = ref.watch(catalogSelectionProvider);

    return Material(
      color: c.accentSoft,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.layout.gutter,
          vertical: AppDimens.space8,
        ),
        child: Row(
          children: [
            AppIconButton(
              icon: Icons.close_rounded,
              tooltip: l10n.bulkCancel,
              onPressed: ref.read(catalogSelectionProvider.notifier).clear,
            ),
            const SizedBox(width: AppDimens.space8),
            Text(
              l10n.bulkSelected(selected.length),
              style: context.text.labelLarge,
            ),
            const SizedBox(width: AppDimens.space12),
            TextButton(
              onPressed: widget.onSelectAll,
              child: Text(l10n.bulkSelectAll),
            ),
            const Spacer(),
            if (_busy)
              const Padding(
                padding: EdgeInsets.only(right: AppDimens.space12),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            // Кнопками — то, что делают чаще всего; остальное в меню, иначе
            // панель растёт в две строки. На узком окне ряд переносится, а не
            // выезжает за край.
            Flexible(
              child: Wrap(
                spacing: AppDimens.space8,
                runSpacing: AppDimens.space8,
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _RelationButton(enabled: !_busy, onSelected: _setRelation),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _setRating,
                    icon: const Icon(Icons.star_border_rounded, size: 18),
                    label: Text(l10n.bulkRating),
                  ),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _setCategory,
                    icon: const Icon(Icons.account_tree_rounded, size: 18),
                    label: Text(l10n.bulkSetCategory),
                  ),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _addToCollection,
                    icon: const Icon(Icons.playlist_add_rounded, size: 18),
                    label: Text(l10n.bulkAddToCollection),
                  ),
                  // Теги — под «Ещё»: их вешают реже, чем ставят отношение и
                  // оценку, а панель не должна расти в три строки.
                  PopupMenuButton<String>(
                    enabled: !_busy,
                    tooltip: l10n.bulkMore,
                    icon: const Icon(Icons.more_horiz_rounded, size: 20),
                    onSelected: (value) =>
                        value == 'addTag' ? _addTag() : _removeTag(),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'addTag',
                        child: Text(l10n.bulkAddTag),
                      ),
                      PopupMenuItem(
                        value: 'removeTag',
                        child: Text(l10n.bulkRemoveTag),
                      ),
                    ],
                  ),
                  FilledButton.icon(
                    onPressed: _busy ? null : _archive,
                    icon: const Icon(Icons.archive_rounded, size: 18),
                    label: Text(l10n.bulkArchive),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Кнопка «Отношение» со списком из шести значений.
class _RelationButton extends StatelessWidget {
  const _RelationButton({required this.enabled, required this.onSelected});

  final bool enabled;
  final ValueChanged<Relation> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    return PopupMenuButton<Relation>(
      enabled: enabled,
      tooltip: l10n.bulkRelation,
      onSelected: onSelected,
      itemBuilder: (_) => [
        for (final r in Relation.values)
          PopupMenuItem(
            value: r,
            height: 40,
            // Меню Material шире 280 точек не бывает, а «Хочу попробовать»
            // со значком в эту ширину не помещается.
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(r.icon, size: 18, color: r.accent(c)),
                const SizedBox(width: AppDimens.space12),
                Flexible(
                  child: Text(
                    r.label(l10n),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
      // Нажатие ловит меню снаружи, поэтому кнопка пропускает его сквозь себя:
      // с собственным обработчиком она бы его съедала, а с `onPressed: null`
      // выглядела бы отключённой.
      child: IgnorePointer(
        child: OutlinedButton.icon(
          onPressed: enabled ? () {} : null,
          icon: const Icon(Icons.favorite_border_rounded, size: 18),
          label: Text(l10n.bulkRelation),
        ),
      ),
    );
  }
}
