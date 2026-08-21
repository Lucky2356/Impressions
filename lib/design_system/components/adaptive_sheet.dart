import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_dimens.dart';

/// Показывает содержимое диалогом на широком экране и листом снизу на узком.
///
/// Правило одно и то же для формы записи, карточки, сканера и выбора записей в
/// подборку, но было написано в каждом из них заново — и уже разошлось в
/// мелочах. [height] задаёт высоту диалога, [heightFactor] — какую часть
/// экрана занимает лист на телефоне.
Future<T?> showAdaptiveSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  double width = 560,
  double? height,
  double? heightFactor,
}) {
  final screen = MediaQuery.sizeOf(context);
  final wide = screen.width >= AppDimens.breakpointExpanded;
  if (wide) {
    return showDialog<T>(
      context: context,
      builder: (ctx) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          // Диалог растёт по содержимому, и на невысоком окне длинная форма
          // уезжала нижним краем за экран вместе с кнопкой «Сохранить»:
          // прокрутка внутри упиралась в то, что прокручивать уже некуда.
          constraints: BoxConstraints(maxHeight: screen.height * 0.9),
          child: SizedBox(width: width, height: height, child: builder(ctx)),
        ),
      ),
    );
  }
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => _EscapeScope(
      child: heightFactor == null
          ? builder(ctx)
          : FractionallySizedBox(
              heightFactor: heightFactor,
              child: builder(ctx),
            ),
    ),
  );
}

/// Закрывает нижний лист по Escape.
///
/// Escape обещан в справке, но `showModalBottomSheet` его не ловит: на Windows
/// листы открывают так же часто, как диалоги, а закрыть их с клавиатуры было
/// нечем. Перехват стоит здесь, а не в каждом листе.
class _EscapeScope extends StatefulWidget {
  const _EscapeScope({required this.child});

  final Widget child;

  @override
  State<_EscapeScope> createState() => _EscapeScopeState();
}

class _EscapeScopeState extends State<_EscapeScope> {
  final _node = FocusNode(debugLabel: 'sheet-escape', skipTraversal: true);

  @override
  void initState() {
    super.initState();
    // Фокус берём, только если внутри его никто не взял: без фокуса нажатие
    // до нас не долетит, но отбирать курсор у поля нельзя — форма записи
    // открывается с курсором в названии, и так это и должно остаться.
    // Через кадр после первого: автофокус поля разбирается в конце первого
    // кадра, и проверка, сделанная там же, успевала увидеть «фокуса нет» — а
    // взяв его, отменила бы автофокус вовсе.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_node.hasFocus) _node.requestFocus();
      });
    });
  }

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.of(context).maybePop(),
      },
      child: Focus(focusNode: _node, child: widget.child),
    );
  }
}
