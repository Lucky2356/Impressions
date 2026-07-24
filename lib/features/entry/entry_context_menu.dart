import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/data_refresh.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/models/entry_view.dart';
import '../../data/providers.dart';
import '../../design_system/design_system.dart';
import '../collections/collection_providers.dart';
import '../quick_add/category_picker.dart';
import 'entry_detail_sheet.dart';

/// Контекстное меню записи: открыть, сменить категорию, добавить в подборку,
/// убрать в архив.
///
/// Жило внутри карточки каталога, поэтому правый клик работал только там: на
/// главной те же карточки на него не отзывались вовсе. Здесь меню отделено от
/// выделения — оно есть только в каталоге и передаётся через [onSelect].
class EntryContextMenu {
  const EntryContextMenu._();

  /// Показывает меню в точке [position] (глобальные координаты).
  ///
  /// [onSelect] задаётся там, где есть массовое выделение; без него пункт
  /// «Выделить» не показывается.
  static Future<void> show(
    BuildContext context,
    WidgetRef ref,
    EntryView entry,
    Offset position, {
    VoidCallback? onSelect,
  }) async {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;

    PopupMenuItem<String> item(
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
            Icon(icon, size: 18, color: danger ? c.coral : c.textSecondary),
            const SizedBox(width: AppDimens.space12),
            Text(label, style: danger ? TextStyle(color: c.coral) : null),
          ],
        ),
      );
    }

    final hasCollections =
        (ref.read(collectionsProvider).value ?? const []).isNotEmpty;

    final chosen = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(1, 1),
        Offset.zero & overlay.size,
      ),
      items: [
        item('open', Icons.open_in_full_rounded, l10n.entryOpen),
        if (onSelect != null)
          item(
            'select',
            Icons.check_circle_outline_rounded,
            l10n.bulkSelectOne,
          ),
        const PopupMenuDivider(),
        item('category', Icons.account_tree_rounded, l10n.bulkSetCategory),
        if (hasCollections)
          item('collection', Icons.playlist_add_rounded, l10n.collectionAddTo),
        const PopupMenuDivider(),
        item('archive', Icons.archive_rounded, l10n.entryArchive, danger: true),
      ],
    );
    if (chosen == null || !context.mounted) return;

    switch (chosen) {
      case 'open':
        await EntryDetailSheet.show(context, entry.entryId);
      case 'select':
        onSelect?.call();
      case 'category':
        final picked = await CategoryPicker.show(context);
        final category = picked?.category;
        if (picked == null || picked.cleared || category == null) return;
        await ref
            .read(entryRepositoryProvider)
            .setPrimaryCategory(entry.entryId, category.id);
        ref.read(dataRefreshProvider.notifier).bump();
      case 'collection':
        await _pickCollection(context, ref, entry);
      case 'archive':
        await ref.read(entryRepositoryProvider).archiveEntry(entry.entryId);
        ref.read(dataRefreshProvider.notifier).bump();
        if (!context.mounted) return;
        showUndoSnackBar(
          context,
          message: l10n.entryArchived,
          onUndo: () async {
            await ref.read(entryRepositoryProvider).restoreEntry(entry.entryId);
            ref.read(dataRefreshProvider.notifier).bump();
          },
        );
    }
  }

  static Future<void> _pickCollection(
    BuildContext context,
    WidgetRef ref,
    EntryView entry,
  ) async {
    final l10n = AppLocalizations.of(context);
    final collections = ref.read(collectionsProvider).value ?? const [];
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
    await ref
        .read(collectionRepositoryProvider)
        .addEntry(chosen, entry.entryId);
    ref.read(dataRefreshProvider.notifier).bump();
  }
}

/// Оборачивает карточку записи правым кликом и долгим нажатием на меню.
///
/// Нужен там, где выделения нет: главная, «Хочу попробовать», подборки.
class EntryMenuTarget extends ConsumerWidget {
  const EntryMenuTarget({super.key, required this.entry, required this.child});

  final EntryView entry;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onSecondaryTapUp: (d) =>
          EntryContextMenu.show(context, ref, entry, d.globalPosition),
      onLongPressStart: (d) =>
          EntryContextMenu.show(context, ref, entry, d.globalPosition),
      child: child,
    );
  }
}
