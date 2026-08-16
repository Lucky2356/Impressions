import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/app/navigation.dart';
import 'package:impressions/core/l10n/gen/app_localizations.dart';
import 'package:impressions/core/theme/app_theme.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/features/catalog/catalog_providers.dart';
import 'package:impressions/features/categories/category_providers.dart';
import 'package:impressions/features/settings/settings_screen.dart';
import 'package:impressions/features/shell/app_shell.dart';

import '../db/test_db.dart';

/// Системная кнопка «Назад» на Android.
///
/// Разделы — ветки `switch`, а не маршруты, поэтому Navigator о них не знал:
/// нажатие «Назад» в любом разделе закрывало приложение целиком.
void main() {
  late AppDatabase db;
  late ProfileRow me;

  setUp(() async {
    db = openTestDb();
    me = ProfileRow(
      id: 'p1',
      type: 'myPrimary',
      firstName: 'Я',
      profileVersion: 1,
      retransmitMode: 'allowed',
      createdAt: DateTime(2026, 7, 30),
      updatedAt: DateTime(2026, 7, 30),
    );
  });

  tearDown(() => db.close());

  late ProviderContainer container;

  Future<void> pumpShell(WidgetTester tester) async {
    // Ширина телефона: «Назад» есть только там, но перехват общий.
    tester.view.physicalSize = const Size(400, 860);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        activeProfileProvider.overrideWithValue(me),
        profilesProvider.overrideWith((ref) => Stream.value([me])),
        allCategoriesProvider.overrideWith((ref) async => const []),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ru'),
          theme: AppTheme.light(),
          home: const AppShell(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Нажатие системной кнопки «Назад».
  Future<void> pressBack(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }

  testWidgets('из раздела «Назад» возвращает на главную', (tester) async {
    await pumpShell(tester);
    container.read(navProvider.notifier).go(NavIds.catalog);
    await tester.pumpAndSettle();

    await pressBack(tester);

    expect(container.read(navProvider), NavIds.home);
  });

  testWidgets('из открытой ветки «Назад» возвращает к дереву', (tester) async {
    await pumpShell(tester);
    container.read(navProvider.notifier).go(NavIds.categories);
    container.read(selectedCategoryProvider.notifier).select('c1');
    await tester.pumpAndSettle();

    await pressBack(tester);

    // Сначала закрывается ветка, раздел остаётся прежним.
    expect(container.read(selectedCategoryProvider), isNull);
    expect(container.read(navProvider), NavIds.categories);

    await pressBack(tester);
    expect(container.read(navProvider), NavIds.home);
  });

  testWidgets('из раздела настроек «Назад» возвращает к списку', (
    tester,
  ) async {
    await pumpShell(tester);
    container.read(navProvider.notifier).go(NavIds.settings);
    container.read(selectedSettingsSectionProvider.notifier).select('backups');
    await tester.pumpAndSettle();

    await pressBack(tester);

    // Сначала закрывается раздел: выкинуть на главную из «Резервных копий»
    // значит потерять и место в настройках.
    expect(container.read(selectedSettingsSectionProvider), isNull);
    expect(container.read(navProvider), NavIds.settings);

    await pressBack(tester);
    expect(container.read(navProvider), NavIds.home);
  });

  testWidgets('с главной «Назад» отдаётся системе', (tester) async {
    await pumpShell(tester);

    // Приложение просит систему закрыть его — в тесте это виден вызов
    // SystemNavigator.pop, а не выход из процесса.
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        calls.add(call.method);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await pressBack(tester);

    expect(calls, contains('SystemNavigator.pop'));
  });

  testWidgets('значок поиска в шапке телефона ведёт в каталог', (tester) async {
    await pumpShell(tester);

    await tester.tap(find.byIcon(Icons.search_rounded));
    await tester.pumpAndSettle();

    expect(container.read(navProvider), NavIds.catalog);
    // И просит каталог поставить курсор в поле поиска.
    expect(container.read(catalogSearchFocusProvider), greaterThan(0));
  });
}
