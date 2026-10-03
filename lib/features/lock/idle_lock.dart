import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/db/connection.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/services/database_lock_service.dart';

/// Сроки бездействия, которые можно выбрать в настройках. `0` — не запирать.
///
/// Не свободное поле: вводить минуты руками незачем, а выбор из пяти пунктов
/// сам показывает, какой порядок величин здесь уместен.
const List<int> idleLockChoices = <int>[0, 1, 5, 15, 30];

/// Через сколько минут бездействия запирать приложение; `0` — не запирать.
final idleLockMinutesProvider = FutureProvider<int>((ref) async {
  ref.watchData(DataKind.settings);
  final raw = await ref
      .read(settingsRepositoryProvider)
      .get(SettingKeys.idleLockMinutes);
  final minutes = int.tryParse(raw ?? '') ?? 0;
  // Чужое значение в таблице настроек не должно запирать приложение на срок,
  // которого нет в списке: читаем только то, что сами записываем.
  return idleLockChoices.contains(minutes) ? minutes : 0;
});

/// Запирает приложение, если с ним давно не работали (§32).
///
/// Шифрование базы защищает файл: унесённый ноутбук записей не выдаст. От
/// того, кто подошёл к включённому устройству, оно не защищает — об этом
/// прямо сказано в настройках. Этот замок закрывает именно тот случай: пароль
/// спрашивается снова, когда человек отошёл.
///
/// Запирание не закрывает базу и не трогает ключ: drift держит файл открытым,
/// а закрыть и открыть его заново — это перезапуск половины экранов. Защита
/// здесь от того, кто сидит за устройством, и ей достаточно того, что поверх
/// всего приложения стоит экран с паролем.
class IdleLockGate extends ConsumerStatefulWidget {
  const IdleLockGate({
    super.key,
    required this.child,
    this.lock = const DatabaseLockService(),
    this.now = DateTime.now,
  });

  final Widget child;

  /// Чем сверяется пароль. Отдельным параметром — ради проверок.
  final DatabaseLockService lock;

  /// Часы. Сроки считаются по календарному времени, а не таймером: пока
  /// приложение свёрнуто, таймеры Android не идут, а время идёт.
  final DateTime Function() now;

  @override
  ConsumerState<IdleLockGate> createState() => _IdleLockGateState();
}

class _IdleLockGateState extends ConsumerState<IdleLockGate>
    with WidgetsBindingObserver {
  /// Когда с приложением работали в последний раз.
  late DateTime _activeAt;

  /// Срок бездействия; [Duration.zero] — замок выключен.
  Duration _after = Duration.zero;

  Timer? _ticker;

  /// Экран с паролем уже стоит — второй раз его поверх не надо.
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    _activeAt = widget.now();
    WidgetsBinding.instance.addObserver(this);
    // Касания и прокрутка во всём приложении, а не только в поддереве этого
    // виджета: диалоги и листы живут выше него, и работа в них — это работа.
    GestureBinding.instance.pointerRouter.addGlobalRoute(_onPointer);
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    HardwareKeyboard.instance.removeHandler(_onKey);
    GestureBinding.instance.pointerRouter.removeGlobalRoute(_onPointer);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onPointer(PointerEvent event) {
    // Мышь, просто оказавшаяся над окном, работой не считается: такое
    // событие Flutter досылает и сам, когда под курсором сменилось дерево.
    // Список, обновляющийся раз в минуту, иначе держал бы замок открытым без
    // всякого участия человека.
    if (event is PointerHoverEvent) return;
    _active();
  }

  bool _onKey(KeyEvent event) {
    _active();
    // Обработчик только смотрит: нажатие идёт дальше, в поле ввода.
    return false;
  }

  /// Отметка «с приложением работают» — без перерисовки: кадра это не стоит.
  void _active() => _activeAt = widget.now();

  /// Перевод замка на новый срок.
  void _apply(Duration after) {
    if (after == _after) return;
    _after = after;
    _ticker?.cancel();
    if (after == Duration.zero) {
      _ticker = null;
      return;
    }
    _activeAt = widget.now();
    // Шаг проверки — четверть срока, но не чаще раза в пять секунд и не реже
    // раза в минуту. Точность до секунды тут никому не нужна, а проверять
    // на каждом кадре дороже самой проверки.
    final step = Duration(seconds: (after.inSeconds / 4).round().clamp(5, 60));
    _ticker = Timer.periodic(step, (_) => _lockIfIdle());
  }

  void _lockIfIdle() {
    if (_locked || _after == Duration.zero || !mounted) return;
    // Запирать нечем: пароля у незашифрованной базы нет, и сверять введённое
    // будет не с чем. Настройка такую базу и не предлагает запирать.
    if (databaseKey == null) return;
    if (widget.now().difference(_activeAt) < _after) return;
    _lock();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Пока приложение свёрнуто, таймер не идёт — значит срок проверяется ещё
    // и на возврате. Иначе отсутствие любой длины не запирало бы ничего:
    // телефон как раз и не держит свёрнутое приложение живым.
    if (state == AppLifecycleState.resumed) _lockIfIdle();
  }

  Future<void> _lock() async {
    _locked = true;
    // Экран идёт отдельным маршрутом в корневом навигаторе: так он встаёт
    // поверх всего, включая открытый диалог или лист, — а после отпирания
    // человек возвращается туда же, где его застали.
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => IdleLockScreen(lock: widget.lock),
        settings: const RouteSettings(name: 'idleLock'),
      ),
    );
    // Отметку «работают» здесь обновлять незачем: отпирают через поле
    // пароля, то есть вводом, а ввод её и обновляет.
    _locked = false;
  }

  @override
  Widget build(BuildContext context) {
    _apply(Duration(minutes: ref.watch(idleLockMinutesProvider).value ?? 0));
    return widget.child;
  }
}

/// Экран пароля поверх работающего приложения.
///
/// Сам закрывается, когда пароль подошёл. «Назад» его не убирает: иначе замок
/// снимался бы одной кнопкой.
class IdleLockScreen extends StatefulWidget {
  const IdleLockScreen({super.key, this.lock = const DatabaseLockService()});

  final DatabaseLockService lock;

  @override
  State<IdleLockScreen> createState() => _IdleLockScreenState();
}

class _IdleLockScreenState extends State<IdleLockScreen> {
  final _password = TextEditingController();
  bool _busy = false;
  bool _wrong = false;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    if (_busy || _password.text.isEmpty) return;
    setState(() {
      _busy = true;
      _wrong = false;
    });

    final ok = await widget.lock.matches(_password.text);
    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _busy = false;
      _wrong = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.space24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.lock_clock_rounded,
                    size: 48,
                    color: c.accentPrimary,
                  ),
                  const SizedBox(height: AppDimens.space16),
                  Text(
                    l10n.idleLockTitle,
                    textAlign: TextAlign.center,
                    style: context.text.titleLarge,
                  ),
                  const SizedBox(height: AppDimens.space8),
                  Text(
                    l10n.idleLockMessage,
                    textAlign: TextAlign.center,
                    style: context.text.bodyMedium?.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimens.space24),
                  TextField(
                    controller: _password,
                    autofocus: true,
                    obscureText: true,
                    enabled: !_busy,
                    onSubmitted: (_) => _open(),
                    decoration: InputDecoration(
                      labelText: l10n.lockPasswordLabel,
                      errorText: _wrong ? l10n.lockWrongPassword : null,
                    ),
                  ),
                  const SizedBox(height: AppDimens.space16),
                  FilledButton(
                    onPressed: _busy ? null : _open,
                    child: _busy
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.lockOpen),
                  ),
                  const SizedBox(height: AppDimens.space8),
                  // Тот же выход, что и на экране запуска: пароль забыт — из
                  // приложения всё равно должно быть чем выйти.
                  TextButton(
                    onPressed: _busy ? null : () => exit(0),
                    child: Text(l10n.lockQuit),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
