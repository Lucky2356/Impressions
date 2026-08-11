import 'package:flutter/material.dart';
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
import 'package:impressions/features/home/home_providers.dart';
import 'package:impressions/features/shell/app_shell.dart';

import '../db/test_db.dart';
import 'screens_test.dart' show entryView;

/// Каталог не возвращается в начало.
///
/// Разделы — ветки `switch` в `KeyedSubtree`: при переключении поддерево
/// уничтожается вместе с положением прокрутки. Ушли на главную и вернулись —
/// список каталога в нуле, а докрученное надо докручивать заново.
void main() {
  late AppDatabase db;
  late ProfileRow me;
  late ProviderContainer container;

  setUp(() {
    db = openTestDb();
    me = ProfileRow(
      id: 'p1',
      type: 'myPrimary',
      firstName: 'Я',
      profileVersion: 1,
      retransmitMode: 'allowed',
      createdAt: DateTime(2026, 8, 11),
      updatedAt: DateTime(2026, 8, 11),
    );
  });

  tearDown(() => db.close());

  Future<void> pumpShell(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        activeProfileProvider.overrideWithValue(me),
        profilesProvider.overrideWith((ref) => Stream.value([me])),
        allCategoriesProvider.overrideWith((ref) async => const []),
        objectTypesProvider.overrideWith((ref) async => const []),
        catalogResultsProvider.overrideWith(
          (ref) async => CatalogResults.of([
            for (var i = 0; i < 40; i++)
              entryView(id: 'e$i', title: 'Запись $i'),
          ]),
        ),
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

  double offset(WidgetTester tester) => tester
      .state<ScrollableState>(find.byType(Scrollable).last)
      .position
      .pixels;

  testWidgets('прокрутка каталога переживает уход в другой раздел', (
    tester,
  ) async {
    await pumpShell(tester);
    // Список: в нём смещение считается в точках, а не в рядах сетки.
    await container
        .read(catalogStateProvider.notifier)
        .setView(CatalogViewMode.list);
    container.read(navProvider.notifier).go(NavIds.catalog);
    await tester.pumpAndSettle();

    await tester.drag(find.text('Запись 1'), const Offset(0, -600));
    await tester.pumpAndSettle();
    final scrolled = offset(tester);
    expect(scrolled, greaterThan(0));

    container.read(navProvider.notifier).go(NavIds.home);
    await tester.pumpAndSettle();
    container.read(navProvider.notifier).go(NavIds.catalog);
    await tester.pumpAndSettle();

    expect(offset(tester), scrolled);
  });
}
