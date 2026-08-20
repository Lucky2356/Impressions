import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/design_system/design_system.dart';
import 'package:impressions/features/catalog/catalog_providers.dart';
import 'package:impressions/features/catalog/catalog_screen.dart';
import 'package:impressions/data/models/entry_view.dart';
import 'package:impressions/features/categories/category_providers.dart';
import 'package:impressions/features/home/home_screen.dart';
import 'package:impressions/features/home/home_providers.dart';

import '../db/test_db.dart';
import 'screens_test.dart' show app, entryView;

/// Заглушки на время загрузки.
///
/// До 1.19.0 на время запроса показывалась пустота: экран моргал, а на
/// медленной базе пустой экран было не отличить от «здесь ничего нет».
void main() {
  late AppDatabase db;
  late ProfileRow me;

  setUp(() async {
    db = openTestDb();
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
  });

  tearDown(() => db.close());

  /// Каталог с запросом, который сам собой не завершится.
  Future<void> pumpCatalog(WidgetTester tester, {required bool loading}) async {
    tester.view.physicalSize = const Size(900, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activeProfileProvider.overrideWithValue(me),
          objectTypesProvider.overrideWith((ref) async => const []),
          allCategoriesProvider.overrideWith((ref) async => const []),
          catalogResultsProvider.overrideWith(
            (ref) => loading
                // Никогда не завершается — ровно то состояние, которое
                // раньше показывалось пустотой.
                ? Completer<CatalogResults>().future
                : Future.value(
                    CatalogResults.of([
                      entryView(id: 'e1', title: 'Папа может'),
                    ]),
                  ),
          ),
        ],
        child: app(const CatalogScreen()),
      ),
    );
    await tester.pump();
  }

  testWidgets('пока каталог грузится, на экране заглушки', (tester) async {
    await pumpCatalog(tester, loading: true);

    expect(find.byType(SkeletonBox), findsWidgets);
  });

  testWidgets('главная не утверждает, что записей нет, пока их считает', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activeProfileProvider.overrideWithValue(me),
          recentEntriesProvider.overrideWith(
            (ref) => Completer<List<EntryView>>().future,
          ),
        ],
        child: app(const HomeScreen()),
      ),
    );
    await tester.pump();

    // «Записей пока нет» — неправда, пока ответа ещё нет: на большом профиле
    // главная успевала предложить завести первую запись тому, у кого их тысяча.
    expect(find.text('Записей пока нет'), findsNothing);
    expect(find.byType(SkeletonBox), findsWidgets);
  });

  testWidgets('с готовыми данными заглушек нет', (tester) async {
    await pumpCatalog(tester, loading: false);
    await tester.pumpAndSettle();

    expect(find.text('Папа может'), findsOneWidget);
    expect(find.byType(SkeletonBox), findsNothing);
  });
}
