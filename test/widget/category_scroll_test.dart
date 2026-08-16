import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/core/l10n/gen/app_localizations.dart';
import 'package:impressions/core/theme/app_theme.dart';
import 'package:impressions/core/utils/normalize.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/features/catalog/catalog_providers.dart';
import 'package:impressions/features/categories/categories_screen.dart';
import 'package:impressions/features/categories/category_branch_page.dart';
import 'package:impressions/features/categories/category_providers.dart';

import '../db/test_db.dart';
import 'screens_test.dart' show entryView;

/// Категории прокручиваются на телефоне.
///
/// До 1.18.0 корневые полки лежали прямо в каркасе раздела: сетка считала
/// полную высоту, каркас обрезал её высотой экрана, а собственная прокрутка у
/// сетки была выключена. Всё ниже сгиба было не просто неудобно достать — его
/// не было. На странице ветки шапка стояла над прокруткой и при крупном
/// системном шрифте съедала почти всю высоту.
void main() {
  late AppDatabase db;
  late ProfileRow me;

  CategoryRow category(String id, String name) => CategoryRow(
    id: id,
    profileId: 'p1',
    name: name,
    normalizedName: Normalize.name(name),
    level: 0,
    path: id,
    sortOrder: 0,
    createdAt: DateTime(2026, 8, 16),
  );

  // Два десятка корневых веток: в один экран телефона они не помещаются
  // заведомо, а последняя достижима только прокруткой.
  final roots = [for (var i = 0; i < 20; i++) category('c$i', 'Ветка $i')];

  setUp(() {
    db = openTestDb();
    me = ProfileRow(
      id: 'p1',
      type: 'myPrimary',
      firstName: 'Я',
      profileVersion: 1,
      retransmitMode: 'allowed',
      createdAt: DateTime(2026, 8, 16),
      updatedAt: DateTime(2026, 8, 16),
    );
  });

  tearDown(() => db.close());

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    double textScale = 1.0,
  }) async {
    // Телефон: ровно та раскладка, в которой пришла жалоба.
    tester.view.physicalSize = const Size(400, 860);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activeProfileProvider.overrideWithValue(me),
          profilesProvider.overrideWith((ref) => Stream.value([me])),
          allCategoriesProvider.overrideWith((ref) async => roots),
          categoryDirectCountsProvider.overrideWith((ref) async => const {}),
          categoryBranchCountsProvider.overrideWith((ref) async => const {}),
          categoryCoversProvider.overrideWith((ref) async => const {}),
          categoryCoverPathsProvider.overrideWith((ref) async => const {}),
          categoryBranchResultsProvider.overrideWith(
            (ref) async => CatalogResults.of([
              for (var i = 0; i < 30; i++)
                entryView(id: 'e$i', title: 'Запись $i'),
            ]),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ru'),
          theme: AppTheme.light(),
          home: Scaffold(
            body: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
              child: child,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  // Вложенные сетки — тоже Scrollable, хоть физика у них и выключена, поэтому
  // ищем прокрутку страницы по ключу, а не «последнюю в дереве».
  double offset(WidgetTester tester, String key) => tester
      .state<ScrollableState>(
        find
            .descendant(
              of: find.byKey(PageStorageKey(key)),
              matching: find.byType(Scrollable),
            )
            .first,
      )
      .position
      .pixels;

  testWidgets('корневые полки листаются до последней ветки', (tester) async {
    await pump(tester, const CategoriesScreen());

    await tester.drag(find.text('Ветка 0'), const Offset(0, -600));
    await tester.pumpAndSettle();

    // До починки полки лежали в каркасе раздела без прокрутки, и смещение
    // оставалось нулевым, сколько ни тащи.
    expect(offset(tester, 'categories-root'), greaterThan(0));

    // И до последней ветки действительно можно доехать: сетка строит все
    // карточки сразу, поэтому важно не «нашлась», а «попала на экран».
    await tester.ensureVisible(find.text('Ветка 19'));
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.text('Ветка 19')).bottom,
      lessThanOrEqualTo(tester.view.physicalSize.height),
    );
  });

  testWidgets('страница ветки листается вместе с шапкой', (tester) async {
    await pump(tester, CategoryBranchPage(category: roots.first));

    // Шапка теперь часть ленты, а не прибита сверху.
    expect(find.text('Ветка 0'), findsOneWidget);

    await tester.drag(find.text('Запись 0'), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(offset(tester, 'category-branch-c0'), greaterThan(0));
  });

  testWidgets('крупный системный шрифт не переполняет карточки записей', (
    tester,
  ) async {
    // Высота ячейки задавалась подобранными 104 точками, тогда как карточке с
    // 1.17.0 нужно 136 даже при обычном шрифте.
    await pump(
      tester,
      CategoryBranchPage(category: roots.first),
      textScale: 1.6,
    );

    expect(tester.takeException(), isNull);
  });
}
