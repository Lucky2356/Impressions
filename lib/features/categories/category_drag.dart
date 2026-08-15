import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/db/database.dart';
import '../../data/models/category_tree.dart';

/// Что тащат: ветку или запись.
///
/// Один запечатанный тип на оба груза, а не два независимых: у зоны приёма
/// тогда один `DragTarget` и один разбор случаев, который анализатор проверяет
/// на полноту. С двумя типами таргеты пришлось бы вешать друг на друга.
sealed class CategoryDropPayload {
  const CategoryDropPayload();
}

class CategoryDrag extends CategoryDropPayload {
  const CategoryDrag(this.category);
  final CategoryRow category;
}

class EntryDrag extends CategoryDropPayload {
  const EntryDrag({required this.entryId, required this.title});
  final String entryId;
  final String title;
}

/// Куда именно ложится груз относительно строки.
enum DropEdge { before, into, after }

/// Высота полосок «поставить перед/после» по краям строки.
const double dropEdgeHeight = 8;

/// Сколько указатель должен провисеть над свёрнутой веткой, чтобы она
/// раскрылась.
const Duration dropExpandDelay = Duration(milliseconds: 700);

/// То, что можно утащить.
///
/// На Windows тянем сразу, на Android — после долгого нажатия: там короткий
/// протяг это прокрутка списка, и мгновенный захват сделал бы дерево
/// непрокручиваемым.
class CategoryDraggable extends StatelessWidget {
  const CategoryDraggable({
    super.key,
    required this.payload,
    required this.label,
    required this.icon,
    required this.tone,
    required this.child,
  });

  final CategoryDropPayload payload;
  final String label;
  final IconData icon;
  final Color tone;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final feedback = _Feedback(label: label, icon: icon, tone: tone);
    final dimmed = Opacity(opacity: 0.4, child: child);

    // Экранный диктор не перетаскивает: подпись объясняет, что у строки есть
    // и другой путь — контекстное меню и Ctrl+стрелки.
    final described = Semantics(hint: l10n.categoryDragHint, child: child);

    return switch (Theme.of(context).platform) {
      TargetPlatform.android || TargetPlatform.iOS => LongPressDraggable(
        data: payload,
        feedback: feedback,
        childWhenDragging: dimmed,
        hapticFeedbackOnStart: true,
        child: described,
      ),
      _ => Draggable(
        data: payload,
        feedback: feedback,
        childWhenDragging: dimmed,
        child: described,
      ),
    };
  }
}

/// Что видно под указателем во время перетаскивания.
class _Feedback extends StatelessWidget {
  const _Feedback({
    required this.label,
    required this.icon,
    required this.tone,
  });

  final String label;
  final IconData icon;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      elevation: 6,
      borderRadius: AppDimens.brMd,
      color: c.surface,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 260),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space12,
          vertical: AppDimens.space8,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: tone),
            const SizedBox(width: AppDimens.space8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.labelLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Можно ли положить груз к этой ветке.
///
/// Отказы считаются до броска, чтобы зона не подсвечивалась вовсе: подсветить
/// и потом показать ошибку — это обещание, которого не сдержали.
bool canDropOn({
  required CategoryDropPayload payload,
  required CategoryRow target,
  required DropEdge edge,
  required List<CategoryRow> all,
  required int maxDepth,
}) {
  switch (payload) {
    case EntryDrag():
      // Запись ложится в саму ветку; «перед» и «после» для неё бессмысленны.
      return edge == DropEdge.into;
    case CategoryDrag(category: final moved):
      if (moved.profileId != target.profileId) return false;
      if (moved.id == target.id) return false;
      // Внутрь собственного потомка — это цикл.
      if (target.path.startsWith('${moved.path}${CategoryTree.separator}')) {
        return false;
      }

      final newParentId = edge == DropEdge.into ? target.id : target.parentId;
      if (moved.parentId == newParentId && edge == DropEdge.into) return false;

      final parentLevel = edge == DropEdge.into
          ? target.level
          : target.level - 1;
      final height = _subtreeHeight(all, moved);
      return parentLevel + 1 + height <= maxDepth;
  }
}

/// Насколько глубоко уходит поддерево — 0 у листа.
int _subtreeHeight(List<CategoryRow> all, CategoryRow node) {
  var deepest = node.level;
  final prefix = '${node.path}${CategoryTree.separator}';
  for (final c in all) {
    if (c.path.startsWith(prefix) && c.level > deepest) deepest = c.level;
  }
  return deepest - node.level;
}

/// Раскрывает свёрнутую ветку, если груз повисел над ней достаточно долго.
///
/// Без этого в свёрнутую ветку нечем положить: чтобы добраться до её
/// подкатегории, пришлось бы сначала бросить груз, раскрыть ветку и взять
/// груз заново.
class DropHoverExpand extends StatefulWidget {
  const DropHoverExpand({
    super.key,
    required this.active,
    required this.onExpand,
    required this.child,
  });

  final bool active;
  final VoidCallback onExpand;
  final Widget child;

  @override
  State<DropHoverExpand> createState() => _DropHoverExpandState();
}

class _DropHoverExpandState extends State<DropHoverExpand> {
  Timer? _timer;

  @override
  void didUpdateWidget(DropHoverExpand old) {
    super.didUpdateWidget(old);
    if (widget.active == old.active) return;
    _timer?.cancel();
    if (!widget.active) return;
    _timer = Timer(dropExpandDelay, widget.onExpand);
  }

  @override
  void dispose() {
    // Таймер обязан умереть вместе с виджетом: иначе pumpAndSettle в тестах
    // ждёт его вечно, а раскрытие приходит уже после броска.
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Прокручивает список, пока груз висит у его края.
///
/// Иначе перетащить ветку за пределы видимой части дерева нечем: рука занята
/// грузом, а колесо мыши во время перетаскивания списку не достаётся.
class DropAutoScroll extends StatefulWidget {
  const DropAutoScroll({
    super.key,
    required this.active,
    required this.controller,
    required this.forward,
    required this.child,
  });

  final bool active;
  final ScrollController controller;

  /// `true` — вниз, `false` — вверх.
  final bool forward;

  final Widget child;

  /// Шаг прокрутки за такт.
  static const double step = 14;

  @override
  State<DropAutoScroll> createState() => _DropAutoScrollState();
}

class _DropAutoScrollState extends State<DropAutoScroll> {
  Timer? _timer;

  @override
  void didUpdateWidget(DropAutoScroll old) {
    super.didUpdateWidget(old);
    if (widget.active == old.active) return;
    _timer?.cancel();
    if (!widget.active) return;
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) => _scroll());
  }

  void _scroll() {
    if (!widget.controller.hasClients) return;
    final position = widget.controller.position;
    final target = widget.forward
        ? position.pixels + DropAutoScroll.step
        : position.pixels - DropAutoScroll.step;
    widget.controller.jumpTo(
      target.clamp(position.minScrollExtent, position.maxScrollExtent),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
