import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/features/catalog/catalog_providers.dart';
import 'package:impressions/features/catalog/catalog_screen.dart';
import 'package:impressions/features/categories/category_providers.dart';
import 'package:impressions/features/home/home_providers.dart';

import '../db/test_db.dart';
import 'screens_test.dart' show app, entryView, profileRow;

/// Чипы «что я не доделал»: нажатие включает именно свой отбор.
///
/// Они стоят друг за другом и отличаются одним словом в обработчике: перепутать
/// их местами — самая вероятная ошибка в этом месте, и по виду она незаметна.
void main() {
  late AppDatabase db;

  setUp(() => db = openTestDb());
  tearDown(() => db.close());

  Future<ProviderContainer> openCatalog(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          profilesProvider.overrideWith(
            (ref) => Stream.value([profileRow('p1', 'Александр')]),
          ),
          catalogResultsProvider.overrideWith(
            (ref) async => CatalogResults.of([
              entryView(id: 'e1', title: 'Папа может', path: ['Продукты']),
            ]),
          ),
          objectTypesProvider.overrideWith((ref) async => []),
          allCategoriesProvider.overrideWith((ref) async => []),
        ],
        child: app(const CatalogScreen()),
      ),
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(
      tester.element(find.byType(CatalogScreen)),
    );
  }

  testWidgets('«Без заметки» включает свой отбор и ничего кроме', (
    tester,
  ) async {
    final container = await openCatalog(tester);

    await tester.tap(find.widgetWithText(FilterChip, 'Без заметки'));
    await tester.pumpAndSettle();

    final state = container.read(catalogStateProvider);
    expect(state.withoutNote, isTrue);
    expect(state.withoutRating, isFalse);
    expect(state.withoutPhoto, isFalse);
    expect(state.withoutCategory, isFalse);
  });

  testWidgets('повторное нажатие выключает отбор', (tester) async {
    final container = await openCatalog(tester);

    await tester.tap(find.widgetWithText(FilterChip, 'Без заметки'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Без заметки'));
    await tester.pumpAndSettle();

    expect(container.read(catalogStateProvider).withoutNote, isFalse);
  });

  testWidgets('соседний чип включает своё', (tester) async {
    // Тот же путь у «Без фотографии»: если обработчики перепутаны, одна из
    // двух проверок это покажет.
    final container = await openCatalog(tester);

    await tester.tap(find.widgetWithText(FilterChip, 'Без фотографии'));
    await tester.pumpAndSettle();

    final state = container.read(catalogStateProvider);
    expect(state.withoutPhoto, isTrue);
    expect(state.withoutNote, isFalse);
  });
}
