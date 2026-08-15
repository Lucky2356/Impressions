import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../data/db/database.dart';
import '../../data/models/category_tree.dart';
import '../../data/providers.dart';
import '../../data/repositories/category_repository.dart';
import '../../design_system/design_system.dart';
import '../quick_add/category_picker.dart';
import 'category_drag.dart';
import 'category_editor_sheet.dart';
import 'category_providers.dart';

/// Всё, что можно сделать с веткой, — в одном месте.
///
/// Раньше эти действия жили в `State` экрана и раздавались вниз десятком
/// колбэков: у карточки-полки, у строки дерева и у панели ветки были три
/// разных набора, и они успели разойтись. Здесь набор один, а экран остаётся
/// раскладкой.
class CategoryActions {
  const CategoryActions(this.ref, this.context);

  final WidgetRef ref;
  final BuildContext context;

  CategoryRepository get _repo => ref.read(categoryRepositoryProvider);
  AppLocalizations get _l10n => AppLocalizations.of(context);
  void _bump() => ref.read(dataRefreshProvider.notifier).bump();

  void select(CategoryRow category) {
    ref.read(selectedCategoryProvider.notifier).select(category.id);
    // Выбранная ветка должна быть видна в дереве, даже если её предки свёрнуты.
    ref
        .read(collapsedCategoriesProvider.notifier)
        .expand(CategoryTree.pathIds(category.path));
  }

  Future<String?> _askName(String title, {String? initial}) {
    return TextInputDialog.show(
      context,
      title: title,
      label: _l10n.categoryNameLabel,
      initial: initial,
    );
  }

  Future<void> createRoot() async {
    final profile = ref.read(activeProfileProvider);
    if (profile == null) return;
    final name = await _askName(_l10n.categoryAddRoot);
    if (name == null) return;
    final created = await _repo.createRoot(profile.id, name);
    ref.read(selectedCategoryProvider.notifier).select(created.id);
    _bump();
  }

  Future<void> createChild(CategoryRow parent) async {
    final name = await _askName(_l10n.categoryAddChild);
    if (name == null) return;
    await _repo.createChild(parent.id, name);
    // Новая подкатегория должна быть видна сразу.
    ref.read(collapsedCategoriesProvider.notifier).expand([parent.id]);
    _bump();
  }

  Future<void> rename(CategoryRow category) async {
    final name = await _askName(_l10n.categoryRename, initial: category.name);
    if (name == null) return;
    await _repo.rename(category.id, name);
    _bump();
  }

  /// Оформление ветки: имя, описание, цвет, значок и обложка сразу.
  ///
  /// Отдельного пункта «значок» больше нет: выбирать цвет и значок по одному,
  /// не видя результата, — то же самое, что подбирать одежду по частям.
  Future<void> edit(CategoryRow category) =>
      CategoryEditorSheet.show(context, category);

  Future<void> move(CategoryRow category) async {
    final picked = await CategoryPicker.show(context);
    if (picked == null) return;
    final targetId = picked.cleared ? null : picked.category?.id;
    if (!picked.cleared && targetId == null) return;
    try {
      await _repo.move(category.id, targetId);
      _bump();
    } on CategoryTreeException catch (e) {
      if (!context.mounted) return;
      showMessage(context, e.message);
    }
  }

  /// Принимает брошенный груз: ветку — на место, запись — в ветку.
  ///
  /// Перетаскивание не должно быть единственным путём: то же самое делают
  /// пункты меню и Ctrl+стрелки. Здесь только приём броска.
  Future<void> drop({
    required CategoryDropPayload payload,
    required CategoryRow target,
    required DropEdge edge,
    required List<CategoryRow> siblingsOfTarget,
  }) async {
    switch (payload) {
      case EntryDrag(entryId: final entryId):
        await _moveEntry(entryId, target);
      case CategoryDrag(category: final moved):
        try {
          if (edge == DropEdge.into) {
            await _repo.moveTo(moved.id, newParentId: target.id);
          } else {
            final order = [for (final c in siblingsOfTarget) c.id]
              ..remove(moved.id);
            final at = order.indexOf(target.id);
            await _repo.moveTo(
              moved.id,
              newParentId: target.parentId,
              index: edge == DropEdge.before ? at : at + 1,
            );
          }
          _bump();
        } on CategoryTreeException catch (e) {
          if (!context.mounted) return;
          showMessage(context, e.message);
        }
    }
  }

  /// Переносит запись в другую ветку с возможностью вернуть как было.
  Future<void> _moveEntry(String entryId, CategoryRow target) async {
    final l10n = _l10n;
    final entries = ref.read(entryRepositoryProvider);
    // Прежнюю основную категорию запоминаем до переноса — иначе возвращать
    // будет некуда.
    final previous = await entries.primaryCategoryOf(entryId);
    await entries.setPrimaryCategory(entryId, target.id);
    _bump();
    if (!context.mounted) return;
    showUndoSnackBar(
      context,
      message: l10n.categoryMovedTo(target.name),
      onUndo: () async {
        if (previous != null) {
          await entries.setPrimaryCategory(entryId, previous);
        }
        _bump();
      },
    );
  }

  /// Ветка и всё, что под ней, — то, что нельзя предлагать целью переноса.
  Future<Set<String>> _branchOf(CategoryRow category) async {
    final all = await ref.read(allCategoriesProvider.future);
    return CategoryTree.branchIds(all, category.id).toSet();
  }

  /// Спрашивает ветку-цель, не предлагая саму ветку и её потомков.
  Future<CategoryRow?> _pickTarget(CategoryRow source, String title) async {
    // Ветку считаем до показа диалога: иначе между чтением и открытием
    // оказывается ожидание, и контекст успевает устареть.
    final excluded = await _branchOf(source);
    if (!context.mounted) return null;
    final picked = await CategoryPicker.show(
      context,
      title: title,
      allowClear: false,
      excludeIds: excluded,
    );
    return picked?.category;
  }

  /// Сводит ветку в другую (§7.1).
  ///
  /// Спрашиваем до, а не предлагаем «Вернуть» после: разложить сведённое
  /// обратно одним нажатием нельзя, и обещать этого не следует.
  Future<void> merge(CategoryRow source) async {
    final l10n = _l10n;
    final target = await _pickTarget(source, l10n.categoryMergeTitle);
    if (target == null || !context.mounted) return;

    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.categoryMerge,
      message: l10n.categoryMergeMessage(source.name),
      confirmLabel: l10n.categoryMergeAction,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;

    try {
      await _repo.merge(sourceId: source.id, targetId: target.id);
      // Сведённая ветка ушла в архив — оставаться на ней некуда.
      if (ref.read(selectedCategoryProvider) == source.id) {
        ref.read(selectedCategoryProvider.notifier).select(target.id);
      }
      _bump();
      if (!context.mounted) return;
      showMessage(context, l10n.categoryMergeDone);
    } on CategoryTreeException catch (e) {
      if (!context.mounted) return;
      showMessage(context, e.message);
    }
  }

  /// Переносит подкатегории ветки в другую ветку разом.
  ///
  /// Пересобрать дерево, перетаскивая по одной, — долго; а объединение здесь
  /// не годится: саму ветку убирать не хотят.
  Future<void> moveChildren(CategoryRow source) async {
    final l10n = _l10n;
    final children = await _repo.children(source.id, includeArchived: true);
    if (children.isEmpty) {
      if (!context.mounted) return;
      showMessage(context, l10n.categoryShelfEmptyTitle);
      return;
    }
    if (!context.mounted) return;
    final target = await _pickTarget(source, l10n.categoryMoveChildren);
    if (target == null) return;

    final moved = await _repo.moveMany([
      for (final c in children) c.id,
    ], target.id);
    _bump();
    if (!context.mounted) return;
    showMessage(context, l10n.categoryMovedCount(moved));
  }

  /// Переносит все записи ветки в другую ветку.
  Future<void> moveEntries(CategoryRow source) async {
    final l10n = _l10n;
    final profile = ref.read(activeProfileProvider);
    if (profile == null) return;

    final entries = ref.read(entryRepositoryProvider);
    final ids = await entries.matchingEntryIds(
      profile.id,
      categoryIds: await _branchOf(source).then((s) => s.toList()),
    );
    if (ids.isEmpty) {
      if (!context.mounted) return;
      showMessage(context, l10n.categoryBranchEmpty);
      return;
    }
    if (!context.mounted) return;
    final target = await _pickTarget(source, l10n.categoryMoveEntries);
    if (target == null) return;

    await entries.setPrimaryCategories(ids, target.id);
    _bump();
    if (!context.mounted) return;
    showMessage(context, l10n.categoryMovedEntries(ids.length));
  }

  Future<void> reorder(CategoryRow category, {required bool up}) async {
    final moved = await _repo.reorder(category.id, up: up);
    if (!context.mounted) return;
    if (!moved) {
      // Молча ничего не делать нельзя: нажатие выглядит как поломка.
      showMessage(context, _l10n.categoryMoveEdge);
      return;
    }
    _bump();
  }

  /// Архивирование без вопроса «точно?»: записи не удаляются, а рядом сразу
  /// появляется «Вернуть».
  Future<void> archive(CategoryRow category) async {
    final l10n = _l10n;
    await _repo.archive(category.id);
    if (ref.read(selectedCategoryProvider) == category.id) {
      ref.read(selectedCategoryProvider.notifier).back();
    }
    _bump();
    if (!context.mounted) return;
    showUndoSnackBar(
      context,
      message: l10n.categoryArchived,
      onUndo: () async {
        await _repo.restore(category.id);
        _bump();
      },
    );
  }

  /// Контекстное меню ветки — тот же набор, что и в карточке, и в дереве.
  Future<void> menu(CategoryRow category, Offset position) async {
    final l10n = _l10n;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;

    final action = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(1, 1),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(value: 'add', child: Text(l10n.categoryAddChild)),
        PopupMenuItem(value: 'rename', child: Text(l10n.categoryRename)),
        PopupMenuItem(value: 'edit', child: Text(l10n.categoryAppearance)),
        PopupMenuItem(value: 'move', child: Text(l10n.categoryMove)),
        // Порядок задавался только полем в базе, которое никто не выставлял.
        PopupMenuItem(value: 'up', child: Text(l10n.categoryMoveUp)),
        PopupMenuItem(value: 'down', child: Text(l10n.categoryMoveDown)),
        PopupMenuItem(
          value: 'moveChildren',
          child: Text(l10n.categoryMoveChildren),
        ),
        PopupMenuItem(
          value: 'moveEntries',
          child: Text(l10n.categoryMoveEntries),
        ),
        PopupMenuItem(value: 'merge', child: Text(l10n.categoryMerge)),
        PopupMenuItem(value: 'archive', child: Text(l10n.categoryArchive)),
      ],
    );
    if (!context.mounted) return;
    await run(action, category);
  }

  /// Выполняет действие по его ключу — общий разбор для меню и для «…».
  Future<void> run(String? action, CategoryRow category) async {
    switch (action) {
      case 'add':
        await createChild(category);
      case 'rename':
        await rename(category);
      case 'edit':
        await edit(category);
      case 'move':
        await move(category);
      case 'up':
        await reorder(category, up: true);
      case 'down':
        await reorder(category, up: false);
      case 'moveChildren':
        await moveChildren(category);
      case 'moveEntries':
        await moveEntries(category);
      case 'merge':
        await merge(category);
      case 'archive':
        await archive(category);
    }
  }
}
