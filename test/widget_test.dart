import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:impressions/app/app.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/design_system/design_system.dart';
import 'package:impressions/features/onboarding/onboarding_screen.dart';

/// Тестовый профиль без обращения к базе.
ProfileRow _profile(String id, String name) => ProfileRow(
  id: id,
  type: 'myPrimary',
  firstName: name,
  profileVersion: 1,
  retransmitMode: 'allowed',
  createdAt: DateTime(2026, 7, 23),
  updatedAt: DateTime(2026, 7, 23),
);

/// UI-тесты используют подменённый список профилей: drift-стримы в widget-тестах
/// оставляют висящие таймеры, а поведение БД покрыто отдельными db-тестами.
ProviderScope _app(List<ProfileRow> profiles) => ProviderScope(
  overrides: [profilesProvider.overrideWith((ref) => Stream.value(profiles))],
  child: const ImpressionsApp(),
);

void main() {
  /// Язык системы для теста.
  ///
  /// Выбор языка идёт по списку `locales`, а не по одному `locale`, поэтому
  /// задавать нужно оба: иначе приложение продолжит смотреть на настоящую
  /// систему, где у тестового окружения английский.
  void systemLanguage(String code) {
    final dispatcher =
        TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher;
    dispatcher.localeTestValue = Locale(code);
    dispatcher.localesTestValue = [Locale(code)];
  }

  // Язык интерфейса берётся из системы, а тестовое окружение отвечает
  // «английский». Проверки ниже написаны по русским подписям — задаём язык
  // явно, как на машине, где приложением и пользуются.
  setUp(() => systemLanguage('ru'));

  tearDown(() {
    final dispatcher =
        TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher;
    dispatcher.clearLocaleTestValue();
    dispatcher.clearLocalesTestValue();
  });

  testWidgets('интерфейс говорит на языке системы', (tester) async {
    systemLanguage('en');
    tester.view.physicalSize = const Size(1000, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(const []));
    await tester.pump();

    expect(
      find.text('Your taste, not someone else\'s ratings'),
      findsOneWidget,
    );
  });

  testWidgets('Нет профилей: онбординг начинается с объяснения', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(const []));
    await tester.pump();

    expect(find.byType(OnboardingScreen), findsOneWidget);
    // Сначала объясняем, зачем это нужно, и только потом просим имя.
    expect(find.text('Ваши вкусы, а не чужие оценки'), findsOneWidget);
    expect(find.text('Создать профиль'), findsNothing);
  });

  testWidgets('Объяснение можно пропустить и перейти к имени', (tester) async {
    tester.view.physicalSize = const Size(1000, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(const []));
    await tester.pump();

    await tester.tap(find.text('Пропустить'));
    await tester.pump();

    expect(find.text('Создать профиль'), findsOneWidget);
  });

  testWidgets('Онбординг требует имя', (tester) async {
    tester.view.physicalSize = const Size(1000, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(const []));
    await tester.pump();

    await tester.tap(find.text('Пропустить'));
    await tester.pump();
    await tester.tap(find.text('Создать профиль'));
    await tester.pump();

    expect(find.text('Укажите имя'), findsOneWidget);
  });

  testWidgets('Есть профиль: широкая раскладка с боковой навигацией', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app([_profile('p1', 'Александр')]));
    await tester.pump();

    expect(find.byType(NavSidebar), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.text('Главная'), findsWidgets);
    // Записей нет — главная показывает пустое состояние, а не пустые блоки (§14).
    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.byType(SummaryStrip), findsNothing);
  });

  testWidgets('Узкая раскладка: нижняя навигация вместо боковой', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(700, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app([_profile('p1', 'Александр')]));
    await tester.pump();

    expect(find.byType(NavSidebar), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
