import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';

/// Мягкое появление элемента списка или сетки.
///
/// Карточки возникали разом и без движения — вместе с ленивой подгрузкой это
/// читалось как «экран моргнул». Здесь каждая следующая появляется чуть позже
/// предыдущей, но задержка ограничена: ждать очереди двадцатой карточки никто
/// не должен.
class Appear extends StatefulWidget {
  const Appear({super.key, required this.child, this.index = 0});

  final Widget child;

  /// Порядковый номер в списке — задаёт задержку.
  final int index;

  /// Через сколько после предыдущего появляется следующий элемент.
  static const Duration step = Duration(milliseconds: 25);

  /// Дальше этого номера задержка не растёт.
  static const int maxStaggered = 12;

  @override
  State<Appear> createState() => _AppearState();
}

class _AppearState extends State<Appear> with SingleTickerProviderStateMixin {
  /// Заводится в [initState], а не отложенным полем: при выключенной системной
  /// анимации `build` до контроллера не доходит, и отложенное поле создавало
  /// его прямо в `dispose` — то есть искало предка у уже отцепленного виджета.
  late final AnimationController _controller;

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  /// Отменяемый таймер задержки: `Future.delayed` отменить нельзя, и в тестах
  /// незавершённый таймер роняет проверку «остались висящие таймеры».
  Timer? _delay;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDimens.durationSlow,
    );
    final delay =
        Appear.step *
        (widget.index > Appear.maxStaggered
            ? Appear.maxStaggered
            : widget.index);
    _delay = Timer(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _delay?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Системное «убрать анимацию» — не пожелание, а требование: у кого-то от
    // движения кружится голова. Показываем сразу готовый вид, а не ускоренный.
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(_fade),
        child: widget.child,
      ),
    );
  }
}
