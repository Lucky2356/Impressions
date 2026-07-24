import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:impressions/app/app_state.dart';
import 'package:impressions/core/l10n/gen/app_localizations.dart';
import 'package:impressions/core/theme/app_theme.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/models/entry_view.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/features/archive/archive_screen.dart';
import 'package:impressions/features/categories/category_providers.dart';
import 'package:impressions/features/compare/compare_screen.dart';
import 'package:impressions/features/home/home_providers.dart';
import 'package:impressions/features/insights/insights_screen.dart';
import 'package:impressions/features/settings/settings_screen.dart';
import 'package:impressions/features/wishlist/wishlist_screen.dart';

import '../db/test_db.dart';

/// Разделы, которые до появления пункта «Ещё» на телефон просто не попадали.
///
/// Их вёрстку никто не проверял в узкую ширину, а именно там ломались строки
/// резервных копий и переключатель темы: кнопки забирали всё место, и текст
/// печатался по букве в строку. Тест держит ширину телефона — переполнение
/// раскладки здесь считается провалом.
void main() {
  late AppDatabase db;

  setUp(() => db = openTestDb());
  tearDown(() => db.close());

  ProfileRow profile() => ProfileRow(
    id: 'p1',
    type: 'myPrimary',
    firstName: 'Александр',
    profileVersion: 1,
    retransmitMode: 'allowed',
    createdAt: DateTime(2026, 7, 24),
    updatedAt: DateTime(2026, 7, 24),
  );

  EntryView entry(String id, String title) => EntryView(
    entryId: id,
    objectId: 'obj-$id',
    title: title,
    typeName: 'Продукты',
    categoryPath: const ['Продукты', 'Колбасы'],
    relation: 'wantToTry',
    rating: 8,
  );

  CategoryRow category(String id, String name) => CategoryRow(
    id: id,
    profileId: 'p1',
    name: name,
    normalizedName: name.toLowerCase(),
    sortOrder: 0,
    level: 0,
    path: id,
    createdAt: DateTime(2026, 7, 24),
  );

  Widget app(Widget child) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('ru'),
    theme: AppTheme.light(),
    home: Scaffold(body: child),
  );

  /// Ширина телефона: 400×860 логических точек.
  ///
  /// Дерево приходит уже собранным: тип `Override` в Riverpod 3 не
  /// экспортируется публично и не может стоять в сигнатуре.
  Future<void> pumpPhone(WidgetTester tester, Widget tree) async {
    tester.view.physicalSize = const Size(400, 860);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(tree);
    await tester.pumpAndSettle();
  }

  base() => [
    appDatabaseProvider.overrideWithValue(db),
    profilesProvider.overrideWith((ref) => Stream.value([profile()])),
  ];

  testWidgets('настройки на телефоне помещаются в ширину', (tester) async {
    await pumpPhone(
      tester,
      ProviderScope(
        overrides: [
          ...base(),
          backupsProvider.overrideWith((ref) async => const []),
        ],
        child: app(const SettingsScreen()),
      ),
    );

    expect(find.text('Оформление'), findsOneWidget);
    // Основные разделы идут раньше дополнительных.
    expect(find.text('Резервные копии'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('архив на телефоне помещается в ширину', (tester) async {
    await pumpPhone(
      tester,
      ProviderScope(
        overrides: [
          ...base(),
          archivedEntriesProvider.overrideWith(
            (ref) async => [
              entry('e1', 'Очень длинное название записи, которое не влезает'),
            ],
          ),
          archivedCategoriesProvider.overrideWith(
            (ref) async => [
              category('c1', 'Архивная категория с длинным именем'),
            ],
          ),
          archivedCollectionsProvider.overrideWith((ref) async => const []),
        ],
        child: app(const ArchiveScreen()),
      ),
    );

    expect(find.textContaining('Очень длинное название'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('«Хочу попробовать» на телефоне помещается в ширину', (
    tester,
  ) async {
    await pumpPhone(
      tester,
      ProviderScope(
        overrides: [
          ...base(),
          wantToTryProvider.overrideWith(
            (ref) async => [
              entry('e1', 'Длинное название для проверки переноса'),
            ],
          ),
        ],
        child: app(const WishlistScreen()),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('сравнение двух профилей помещается в ширину', (tester) async {
    await pumpPhone(
      tester,
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          profilesProvider.overrideWith(
            (ref) => Stream.value([
              profile(),
              ProfileRow(
                id: 'p2',
                type: 'myPrimary',
                firstName: 'Лариса',
                profileVersion: 1,
                retransmitMode: 'allowed',
                createdAt: DateTime(2026, 7, 24),
                updatedAt: DateTime(2026, 7, 24),
              ),
            ]),
          ),
        ],
        child: app(const CompareScreen()),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('статистика на телефоне помещается в ширину', (tester) async {
    await pumpPhone(
      tester,
      ProviderScope(overrides: [...base()], child: app(const InsightsScreen())),
    );
    expect(tester.takeException(), isNull);
  });
}
