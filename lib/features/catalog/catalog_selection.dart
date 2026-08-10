import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_layout.dart';
import '../../core/theme/theme_context.dart';
import '../../data/providers.dart';
import '../../design_system/design_system.dart';
import '../collections/collection_providers.dart';
import '../quick_add/category_picker.dart';

/// Выделенные в каталоге записи.
///
/// Живёт отдельно от фильтров: выделение не должно переживать перезапуск и не
/// сохраняется в настройках.
class CatalogSelection extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void toggle(String entryId) {
    final next = {...state};
    if (!next.remove(entryId)) next.add(entryId);
    state = next;
  }

  void selectAll(Iterable<String> entryIds) => state = entryIds.toSet();

  void clear() => state = const {};

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

  Future<void> _addToCollection() async {
    final l10n = AppLocalizations.of(context);
    final collections = ref.read(collectionsProvider).value ?? const [];
    if (collections.isEmpty) return;

    final chosen = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l10n.collectionAddTo),
        children: [
          for (final view in collections)
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(view.collection.id),
              child: Row(
                children: [
                  const Icon(Icons.collections_bookmark_rounded, size: 18),
                  const SizedBox(width: AppDimens.space12),
                  Expanded(child: Text(view.collection.name)),
                ],
              ),
            ),
        ],
      ),
    );
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
    final hasCollections =
        (ref.watch(collectionsProvider).value ?? const []).isNotEmpty;

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
            Wrap(
              spacing: AppDimens.space8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _busy ? null : _setCategory,
                  icon: const Icon(Icons.account_tree_rounded, size: 18),
                  label: Text(l10n.bulkSetCategory),
                ),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _addTag,
                  icon: const Icon(Icons.label_outline_rounded, size: 18),
                  label: Text(l10n.bulkAddTag),
                ),
                if (hasCollections)
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _addToCollection,
                    icon: const Icon(Icons.playlist_add_rounded, size: 18),
                    label: Text(l10n.bulkAddToCollection),
                  ),
                FilledButton.icon(
                  onPressed: _busy ? null : _archive,
                  icon: const Icon(Icons.archive_rounded, size: 18),
                  label: Text(l10n.bulkArchive),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
