import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/db/connection.dart';
import 'package:impressions/data/services/database_lock_service.dart';
import 'package:impressions/features/lock/idle_lock.dart';

import 'screens_test.dart' show app;

/// Замок, который сверяет пароль, не трогая ни файл базы, ни хранилище ключей.
///
/// Настоящий [DatabaseLockService.matches] выводит ключ из пароля (120 000
/// итераций) и читает файл состояния рядом с базой: ни того, ни другого в
/// поддельном времени теста не дождаться.
class _FakeLock extends DatabaseLockService {
  const _FakeLock();

  @override
  Future<bool> matches(String password) async => password == 'пароль';
}

void main() {
  /// Часы теста: сроки замка считаются по календарному времени, и настоящее
  /// `DateTime.now` в тесте никуда не двигается.
  late DateTime now;

  setUp(() {
    now = DateTime(2026, 10, 2, 12);
    // База «зашифрована»: без ключа запирать нечем, и замок молчит.
    databaseKey = const [1, 2, 3, 4];
  });

  tearDown(() => databaseKey = null);

  /// Строит приложение с замком на [minutes] минут бездействия.
  Future<void> pumpGate(WidgetTester tester, int minutes) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [idleLockMinutesProvider.overrideWith((ref) => minutes)],
        child: app(
          IdleLockGate(
            lock: const _FakeLock(),
            now: () => now,
            child: const Text('данные'),
          ),
        ),
      ),
    );
    // Настройка приходит провайдером, то есть не в первом кадре: до неё замок
    // считает себя выключенным.
    await tester.pumpAndSettle();
  }

  /// Проводит [away] времени в бездействии.
  ///
  /// Часы теста уходят вперёд, а кадры прокручиваются ещё и после них: замок
  /// срабатывает по таймеру, и утверждение сразу за [WidgetTester.pump] успело
  /// бы встать раньше, чем экран замка окажется построен, — проверка прошла бы
  /// и на сломанной реализации.
  Future<void> idle(WidgetTester tester, Duration away) async {
    now = now.add(away);
    // Шаг проверки — четверть срока, но не реже раза в минуту: восьмидесяти
    // секунд хватает любому сроку из списка.
    await tester.pump(const Duration(seconds: 80));
    await tester.pumpAndSettle();
  }

  /// Уводит приложение в фон и возвращает обратно, не двигая таймеры.
  Future<void> awayAndBack(WidgetTester tester, Duration away) async {
    for (final state in const [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    now = now.add(away);
    for (final state in const [
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await tester.pumpAndSettle();
  }

  final locked = find.text('Приложение заперто');

  testWidgets('бездействие дольше срока запирает приложение', (tester) async {
    await pumpGate(tester, 5);
    expect(locked, findsNothing);

    await idle(tester, const Duration(minutes: 6));

    expect(locked, findsOneWidget);
    expect(find.text('данные'), findsNothing);
  });

  testWidgets('касание отодвигает срок', (tester) async {
    await pumpGate(tester, 5);

    await idle(tester, const Duration(minutes: 4));
    expect(locked, findsNothing);
    await tester.tap(find.text('данные'));

    await idle(tester, const Duration(minutes: 4));

    expect(locked, findsNothing);
  });

  testWidgets('набор на клавиатуре отодвигает срок', (tester) async {
    await pumpGate(tester, 5);

    await idle(tester, const Duration(minutes: 4));
    expect(locked, findsNothing);
    // Длинную заметку набирают, не прикасаясь к мыши: без этого замок
    // закрывался бы посреди слова.
    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);

    await idle(tester, const Duration(minutes: 4));

    expect(locked, findsNothing);
  });

  testWidgets('возврат из фона после долгого отсутствия запирает сразу', (
    tester,
  ) async {
    // Срок в полчаса: шаг проверки у него — минута, а время в тесте не
    // двигается вовсе, так что запереть может только сам возврат.
    await pumpGate(tester, 30);
    await awayAndBack(tester, const Duration(minutes: 31));

    expect(locked, findsOneWidget);
  });

  testWidgets('короткое отсутствие замок не закрывает', (tester) async {
    await pumpGate(tester, 30);
    await awayAndBack(tester, const Duration(minutes: 2));

    expect(locked, findsNothing);
  });

  testWidgets('выключенный замок не запирается никогда', (tester) async {
    await pumpGate(tester, 0);

    await idle(tester, const Duration(days: 10));
    await awayAndBack(tester, const Duration(days: 10));

    expect(locked, findsNothing);
  });

  testWidgets('без шифрования запирать нечем', (tester) async {
    databaseKey = null;
    await pumpGate(tester, 1);

    await idle(tester, const Duration(minutes: 10));
    await awayAndBack(tester, const Duration(minutes: 10));

    expect(locked, findsNothing);
  });

  testWidgets('верный пароль возвращает туда же', (tester) async {
    await pumpGate(tester, 30);
    await awayAndBack(tester, const Duration(minutes: 31));
    expect(locked, findsOneWidget);

    await tester.enterText(find.byType(TextField), 'пароль');
    await tester.tap(find.text('Открыть'));
    await tester.pumpAndSettle();

    expect(locked, findsNothing);
    expect(find.text('данные'), findsOneWidget);
  });

  testWidgets('неверный пароль не отпирает', (tester) async {
    await pumpGate(tester, 30);
    await awayAndBack(tester, const Duration(minutes: 31));

    await tester.enterText(find.byType(TextField), 'не тот');
    await tester.tap(find.text('Открыть'));
    await tester.pumpAndSettle();

    expect(find.text('Неверный пароль'), findsOneWidget);
    expect(locked, findsOneWidget);
    expect(find.text('данные'), findsNothing);
  });

  testWidgets('«назад» замок не снимает', (tester) async {
    await pumpGate(tester, 30);
    await awayAndBack(tester, const Duration(minutes: 31));

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(locked, findsOneWidget);
  });

  testWidgets('после отпирания срок считается заново', (tester) async {
    await pumpGate(tester, 30);
    await awayAndBack(tester, const Duration(minutes: 31));

    await tester.enterText(find.byType(TextField), 'пароль');
    await tester.tap(find.text('Открыть'));
    await tester.pumpAndSettle();
    expect(locked, findsNothing);

    // Отсутствие, которое заперло в прошлый раз, уже прошло — но отсчёт
    // начался заново, и само по себе оно замок не закрывает.
    await idle(tester, const Duration(minutes: 2));
    expect(locked, findsNothing);

    await awayAndBack(tester, const Duration(minutes: 31));
    expect(locked, findsOneWidget);
  });
}
