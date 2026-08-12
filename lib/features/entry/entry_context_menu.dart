import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/data_refresh.dart';
import '../../core/domain/relation.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/models/entry_view.dart';
import '../../data/providers.dart';
import '../../design_system/design_system.dart';
import '../collections/collection_picker.dart';
import '../quick_add/category_picker.dart';
import '../quick_add/quick_add_sheet.dart';
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: danger ? c.coral : c.textSecondary),
            const SizedBox(width: AppDimens.space12),
            // Меню Material не бывает шире 280 точек: длинные названия должны
            // ужиматься, а не вылезать за край.
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: danger ? TextStyle(color: c.coral) : null,
              ),
            ),
          ],
        ),
      );
    }

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
        // Самое частое действие — «понравилось / не понравилось» и оценка.
        // Раньше ради них приходилось открывать карточку записи.
        for (final r in Relation.values)
          PopupMenuItem(
            value: 'relation:${r.name}',
            height: 40,
            // Ширину меню задаёт самый широкий пункт, поэтому строки здесь
            // такие же по устройству, как у `item`: `Expanded` лишает пункт
            // собственной ширины, и меню становится уже соседних строк.
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  r.icon,
                  size: 18,
                  color: entry.relation == r.name
                      ? r.accent(c)
                      : c.textSecondary,
                ),
                const SizedBox(width: AppDimens.space12),
                // Меню Material шире 280 точек не бывает, а «Хочу попробовать»
                // с галочкой в эту ширину не помещается.
                Flexible(
                  child: Text(
                    r.label(l10n),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (entry.relation == r.name) ...[
                  const SizedBox(width: AppDimens.space8),
                  Icon(Icons.check_rounded, size: 16, color: c.accentPrimary),
                ],
              ],
            ),
          ),
        item('rating', Icons.star_border_rounded, l10n.entryRateAction),
        const PopupMenuDivider(),
        item('category', Icons.account_tree_rounded, l10n.bulkSetCategory),
        // «То же самое, но другой бренд» и «тот же фильм, второй просмотр»
        // заводились с нуля.
        item('duplicate', Icons.copy_rounded, l10n.entryDuplicate),
        // Пункт есть всегда: подборку можно завести прямо из него, а раньше
        // при пустом списке он просто исчезал из меню.
        item('collection', Icons.playlist_add_rounded, l10n.collectionAddTo),
        const PopupMenuDivider(),
        item('archive', Icons.archive_rounded, l10n.entryArchive, danger: true),
      ],
    );
    if (chosen == null || !context.mounted) return;

    if (chosen.startsWith('relation:')) {
      final name = chosen.substring('relation:'.length);
      await ref
          .read(entryRepositoryProvider)
          .updateEntry(
            entry.entryId,
            // Повторный выбор того же отношения снимает его — как у чипов в
            // карточке записи.
            relation: entry.relation == name ? null : name,
          );
      ref.read(dataRefreshProvider.notifier).bump();
      return;
    }

    switch (chosen) {
      case 'open':
        await EntryDetailSheet.show(context, entry.entryId);
      case 'select':
        onSelect?.call();
      case 'rating':
        final rating = await RatingDialog.show(
          context,
          title: entry.title,
          initial: entry.rating ?? 7,
        );
        if (rating == null) return;
        await ref
            .read(entryRepositoryProvider)
            .updateEntry(entry.entryId, rating: rating);
        ref.read(dataRefreshProvider.notifier).bump();
      case 'category':
        final picked = await CategoryPicker.show(context);
        final category = picked?.category;
        if (picked == null || picked.cleared || category == null) return;
        await ref
            .read(entryRepositoryProvider)
            .setPrimaryCategory(entry.entryId, category.id);
        ref.read(dataRefreshProvider.notifier).bump();
      case 'duplicate':
        // Копия не создаётся молча: форма открывается заполненной, человек
        // меняет то, что отличается, — бренд, год, оценку.
        await QuickAddSheet.show(context, duplicateOf: entry);
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
    final chosen = await CollectionPicker.show(context, ref);
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
