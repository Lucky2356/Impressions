import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/models/entry_view.dart';
import '../entry/entry_context_menu.dart';
import '../entry/entry_detail_sheet.dart';
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
    required this.selectionActive,
    required this.order,
    required this.builder,
  });

  final EntryView entry;

  /// Хотя бы одна запись уже выделена: обычное нажатие тоже выделяет.
  final bool selectionActive;

  /// Порядок записей на экране: по нему Shift+клик выделяет диапазон.
  ///
  /// Именно показанный порядок, а не порядок отбора: человек тянет выделение
  /// по тому, что видит.
  final List<String> order;

  /// Строит саму карточку. Нажатие приходит извне, чтобы карточка осталась
  /// кнопкой: только так работают обход фокуса стрелками и Enter.
  final Widget Function(VoidCallback onTap) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final selection = ref.read(catalogSelectionProvider.notifier);

    // Карточка следит только за собой. Раньше список смотрел на всё выделение
    // целиком, и один Ctrl+клик перестраивал все карточки страницы — а с ними
    // и все обложки.
    final selected = ref.watch(
      catalogSelectionProvider.select((s) => s.contains(entry.entryId)),
    );

    void open() => EntryDetailSheet.show(context, entry.entryId);
    void toggle() => selection.toggle(entry.entryId);

    void onTap() {
      // Shift тянет выделение от последней отмеченной записи: убрать в архив
      // тридцать штук подряд иначе означало тридцать нажатий.
      if (HardwareKeyboard.instance.isShiftPressed) {
        selection.selectTo(entry.entryId, order);
        return;
      }
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
      onSecondaryTapUp: (details) => EntryContextMenu.show(
        context,
        ref,
        entry,
        details.globalPosition,
        onSelect: toggle,
      ),
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
