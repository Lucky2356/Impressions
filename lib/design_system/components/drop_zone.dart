import 'package:flutter/material.dart';

/// Место, куда можно что-то бросить.
///
/// Обёртка над `DragTarget`, которая берёт на себя только одно: знать, принят
/// ли груз сейчас под указателем. Как это выглядит — линия между соседями,
/// подсветка целиком или ничего — решает вызывающий: у строки дерева и у
/// карточки-полки это выглядит по-разному, а правило одно.
///
/// Отклонённый груз не подсвечивается вовсе: «нельзя» должно быть видно до
/// броска, а не после него.
class DropZone<T extends Object> extends StatelessWidget {
  const DropZone({
    super.key,
    required this.onWillAccept,
    required this.onAccept,
    required this.builder,
    this.onActiveChanged,
  });

  /// Можно ли принять этот груз. `false` — зона молчит и не подсвечивается.
  final bool Function(T data) onWillAccept;

  final void Function(T data) onAccept;

  /// `active` — груз висит над зоной и будет принят.
  final Widget Function(BuildContext context, bool active) builder;

  /// Позволяет вызывающему делать что-то, пока груз висит над зоной, —
  /// например разворачивать свёрнутую ветку или прокручивать список.
  final ValueChanged<bool>? onActiveChanged;

  @override
  Widget build(BuildContext context) {
    return DragTarget<T>(
      onWillAcceptWithDetails: (details) => onWillAccept(details.data),
      onAcceptWithDetails: (details) => onAccept(details.data),
      onMove: (_) => onActiveChanged?.call(true),
      onLeave: (_) => onActiveChanged?.call(false),
      builder: (context, candidates, _) =>
          builder(context, candidates.isNotEmpty),
    );
  }
}
