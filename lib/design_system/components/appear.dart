import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';

/// Мягкое появление элемента списка или сетки.
///
/// Карточки возникали разом и без движения — вместе с ленивой подгрузкой это
/// читалось как «экран моргнул». Здесь каждая следующая появляется чуть позже
/// предыдущей, но задержка ограничена: ждать очереди двадцатой карточки никто
/// не должен.
///
/// Ленивый список заводит ячейку заново каждый раз, когда она входит в область
/// показа, и уничтожает, когда уходит далеко. Поэтому карточка появлялась
/// заново на каждый проход прокрутки: контроллер анимации и таймер на каждую
/// вплывающую ячейку, а на экране — пустые клетки, ждущие своей очереди до
/// 300 мс. [AppearScope] помнит, что уже показывалось, и раздаёт лесенку
/// только тому, что пришло вместе со списком.
class Appear extends StatelessWidget {
  const Appear({super.key, required this.child, this.index = 0, this.id});

  final Widget child;

  /// Порядковый номер в списке — задаёт задержку.
  final int index;

  /// Чем элемент отличается от соседей — обычно идентификатор записи.
  ///
  /// По нему [AppearScope] узнаёт уже показанное. Без области или без метки
  /// элемент появляется каждый раз заново — так ведут себя короткие списки
  /// с постоянным составом, которым помнить нечего.
  final Object? id;

  /// Через сколько после предыдущего появляется следующий элемент.
  static const Duration step = Duration(milliseconds: 25);

  /// Дальше этого номера задержка не растёт.
  static const int maxStaggered = 12;

  /// Сколько после появления списка элементы ещё считаются пришедшими вместе
  /// с ним.
  ///
  /// Лесенка нужна там, где элементы появляются пачкой. Домотанной до середины
  /// ячейке ждать очереди не за кем — она приходит одна, и задержка означала бы
  /// просто пустую клетку.
  static const Duration batchWindow = Duration(milliseconds: 150);

  @override
  Widget build(BuildContext context) {
    // Системное «убрать анимацию» — не пожелание, а требование: у кого-то от
    // движения кружится голова. Показываем сразу готовый вид, а не ускоренный.
    if (MediaQuery.disableAnimationsOf(context)) return child;

    return _Appearing(
      memory: AppearScope.maybeOf(context),
      id: id,
      index: index,
      child: child,
    );
  }
}

/// Память списка о том, что уже появлялось.
///
/// Ставится вокруг ленивого списка — одна на список, а не на элемент.
class AppearScope extends StatefulWidget {
  const AppearScope({super.key, required this.child});

  final Widget child;

  static AppearMemory? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_AppearMemoryScope>()?.memory;

  @override
  State<AppearScope> createState() => _AppearScopeState();
}

/// То, что область помнит: показанное и время своего появления.
class AppearMemory {
  AppearMemory();

  final Set<Object> _seen = {};
  final DateTime _born = DateTime.now();

  /// Отмечает элемент показанным. `true` — если видим его впервые.
  bool markSeen(Object id) => _seen.add(id);

  /// Список только что появился, и элементы приходят пачкой.
  bool get freshBatch => DateTime.now().difference(_born) < Appear.batchWindow;
}

class _AppearScopeState extends State<AppearScope> {
  final AppearMemory _memory = AppearMemory();

  @override
  Widget build(BuildContext context) =>
      _AppearMemoryScope(memory: _memory, child: widget.child);
}

class _AppearMemoryScope extends InheritedWidget {
  const _AppearMemoryScope({required this.memory, required super.child});

  final AppearMemory memory;

  // Память меняется на месте и о себе не сообщает: перестраивать из-за неё
  // ячейки незачем — решение принимается один раз, при их заведении.
  @override
  bool updateShouldNotify(_AppearMemoryScope old) => false;
}

class _Appearing extends StatefulWidget {
  const _Appearing({
    required this.memory,
    required this.id,
    required this.index,
    required this.child,
  });

  final AppearMemory? memory;
  final Object? id;
  final int index;
  final Widget child;

  @override
  State<_Appearing> createState() => _AppearingState();
}

class _AppearingState extends State<_Appearing>
    with SingleTickerProviderStateMixin {
  /// `null` — элемент показывается сразу, без анимации и без тикера.
  AnimationController? _controller;
  Animation<double>? _fade;

  /// Отменяемый таймер задержки: `Future.delayed` отменить нельзя, и в тестах
  /// незавершённый таймер роняет проверку «остались висящие таймеры».
  Timer? _delay;

  @override
  void initState() {
    super.initState();
    // Решение принимается один раз, при заведении ячейки: перестроение не
    // должно обрывать уже идущую анимацию.
    final memory = widget.memory;
    final id = widget.id;
    if (memory != null && id != null && !memory.markSeen(id)) return;

    final controller = AnimationController(
      vsync: this,
      duration: AppDimens.durationSlow,
    );
    _controller = controller;
    _fade = CurvedAnimation(parent: controller, curve: Curves.easeOut);

    final delay = memory == null || memory.freshBatch
        ? Appear.step *
              (widget.index > Appear.maxStaggered
                  ? Appear.maxStaggered
                  : widget.index)
        : Duration.zero;
    if (delay == Duration.zero) {
      controller.forward();
    } else {
      _delay = Timer(delay, () {
        if (mounted) controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _delay?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fade = _fade;
    if (fade == null) return widget.child;

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(fade),
        child: widget.child,
      ),
    );
  }
}
