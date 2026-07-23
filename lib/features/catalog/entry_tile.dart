import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/data_refresh.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/models/entry_view.dart';
import '../../data/providers.dart';
import '../../design_system/design_system.dart';
import '../collections/collection_providers.dart';
import '../entry/entry_detail_sheet.dart';
import '../quick_add/category_picker.dart';
import 'catalog_selection.dart';

/// Карточка каталога вместе со способами ею управлять.
///
/// Сама карточка остаётся чистым отображением из дизайн-системы, а выделение,
/// контекстное меню и обработка клавиш живут здесь: экраны, где выделение не
/// нужно, используют карточку напрямую.
class EntryTile extends ConsumerWidget {
  const EntryTile({
    super.key,
    required this.entry,
    required this.selected,
    required this.selectionActive,
    required this.builder,
  });

  final EntryView entry;
  final bool selected;

  /// Хотя бы одна запись уже выделена: обычное нажатие тоже выделяет.
  final bool selectionActive;

  /// Строит саму карточку. Нажатие приходит извне, чтобы карточка осталась
  /// кнопкой: только так работают обход фокуса стрелками и Enter.
  final Widget Function(VoidCallback onTap) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final selection = ref.read(catalogSelectionProvider.notifier);

    void open() => EntryDetailSheet.show(context, entry.entryId);
    void toggle() => selection.toggle(entry.entryId);

    void onTap() {
      // Ctrl добавляет к выделению, не открывая карточку.
      final ctrl =
          HardwareKeyboard.instance.isControlPressed ||
          HardwareKeyboard.instance.isMetaPressed;
      if (selectionActive || ctrl) {
        toggle();
      } else {
        open();
      }
    }

    return GestureDetector(
      onLongPress: toggle,
      onSecondaryTapUp: (details) =>
          _showContextMenu(context, ref, details.globalPosition),
      child: Stack(
        children: [
          builder(onTap),
          if (selected)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: c.accentPrimary.withValues(alpha: 0.10),
                    borderRadius: AppDimens.brMd,
                    border: Border.all(color: c.accentPrimary, width: 2),
                  ),
                ),
              ),
            ),
          if (selectionActive)
            Positioned(
              top: AppDimens.space8,
              left: AppDimens.space8,
              child: _SelectionMark(selected: selected),
            ),
        ],
      ),
    );
  }

  Future<void> _showContextMenu(
    BuildContext context,
    WidgetRef ref,
    Offset position,
  ) async {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;

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
        item('select', Icons.check_circle_outline_rounded, l10n.bulkSelectOne),
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
        EntryDetailSheet.show(context, entry.entryId);
      case 'select':
        ref.read(catalogSelectionProvider.notifier).toggle(entry.entryId);
      case 'category':
        final picked = await CategoryPicker.show(context);
        final category = picked?.category;
        if (picked == null || picked.cleared || category == null) return;
        await ref
            .read(entryRepositoryProvider)
            .setPrimaryCategory(entry.entryId, category.id);
        ref.read(dataRefreshProvider.notifier).bump();
      case 'collection':
        await _pickCollection(context, ref);
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

  Future<void> _pickCollection(BuildContext context, WidgetRef ref) async {
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

/// Кружок-отметка выделения в углу карточки.
class _SelectionMark extends StatelessWidget {
  const _SelectionMark({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: selected ? c.accentPrimary : c.surface.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? c.accentPrimary : c.border,
          width: 1.5,
        ),
      ),
      child: selected
          ? Icon(Icons.check_rounded, size: 14, color: c.accentPrimaryOn)
          : null,
    );
  }
}
