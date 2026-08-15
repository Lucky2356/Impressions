import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:impressions/app/app_state.dart';
import 'package:impressions/core/l10n/gen/app_localizations.dart';
import 'package:impressions/core/theme/app_theme.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/models/entry_view.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/design_system/design_system.dart';
import 'package:impressions/features/catalog/catalog_providers.dart';
import 'package:impressions/features/catalog/catalog_screen.dart';
import 'package:impressions/features/categories/categories_screen.dart';
import 'package:impressions/features/categories/category_branch_page.dart';
import 'package:impressions/features/categories/category_tree_pane.dart';
import 'package:impressions/features/categories/category_providers.dart';
import 'package:impressions/features/collections/collection_providers.dart';
import 'package:impressions/features/collections/collections_screen.dart';
import 'package:impressions/features/compare/compare_screen.dart';
import 'package:impressions/features/home/home_providers.dart';

import '../db/test_db.dart';

ProfileRow profileRow(String id, String name) => ProfileRow(
  id: id,
  type: 'myPrimary',
  firstName: name,
  profileVersion: 1,
  retransmitMode: 'allowed',
  createdAt: DateTime(2026, 7, 23),
  updatedAt: DateTime(2026, 7, 23),
);

CategoryRow categoryRow({
  required String id,
  required String profileId,
  required String name,
  String? parentId,
  int level = 0,
  String? path,
}) => CategoryRow(
  id: id,
  profileId: profileId,
  parentId: parentId,
  name: name,
  normalizedName: name.toLowerCase(),
  sortOrder: 0,
  level: level,
  path: path ?? id,
  createdAt: DateTime(2026, 7, 23),
);

EntryView entryView({
  required String id,
  required String title,
  List<String> path = const [],
  String? relation,
  double? rating,
}) => EntryView(
  entryId: id,
  objectId: 'obj-$id',
  title: title,
  typeName: 'Продукты',
  categoryPath: path,
  relation: relation,
  rating: rating,
);

/// Оборачивает экран в приложение с русской локалью.
///
/// Список подмен передаётся в [ProviderScope] на месте вызова: тип `Override`
/// в Riverpod 3 не экспортируется публично, поэтому его нельзя назвать в
/// сигнатуре — Dart выводит его сам из литерала списка.
Widget app(Widget child, {Brightness brightness = Brightness.light}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('ru'),
    theme: brightness == Brightness.light ? AppTheme.light() : AppTheme.dark(),
    home: Scaffold(body: child),
  );
}

void main() {
  late AppDatabase db;

  setUp(() => db = openTestDb());
  tearDown(() => db.close());

  // Тип возвращаемого значения выводится Dart'ом (см. комментарий к [app]).
  baseOverrides({List<ProfileRow>? profiles}) => [
    appDatabaseProvider.overrideWithValue(db),
    profilesProvider.overrideWith(
      (ref) => Stream.value(profiles ?? [profileRow('p1', 'Александр')]),
    ),
  ];

  group('Каталог', () {
    testWidgets('на телефоне поле поиска занимает всю ширину', (tester) async {
      // Ширина телефона. Раньше поиск делил строку с кнопкой фильтров и
      // переключателем вида и схлопывался до одного значка.
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...baseOverrides(),
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
      await tester.pump();

      final field = find.byType(AppSearchField);
      expect(field, findsOneWidget);
      // Поле должно занимать почти всю строку, а не сжиматься под значок.
      final width = tester.getSize(field).width;
      expect(width, greaterThan(300));
    });

    testWidgets('показывает записи с путём категорий', (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...baseOverrides(),
            catalogResultsProvider.overrideWith(
              (ref) async => CatalogResults.of([
                entryView(
                  id: 'e1',
                  title: 'Папа может',
                  path: ['Продукты', 'Колбасы'],
                  relation: 'like',
                  rating: 7,
                ),
              ]),
            ),
            objectTypesProvider.overrideWith((ref) async => []),
            allCategoriesProvider.overrideWith((ref) async => []),
          ],
          child: app(const CatalogScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Папа может'), findsOneWidget);
      // Карточка компактная: из пути показывается только последняя категория,
      // полный путь остаётся в карточке записи.
      expect(find.text('Колбасы'), findsOneWidget);
      expect(find.byType(EntryCard), findsOneWidget);
      // Счётчик склоняется по-русски: одна запись — «найдена», а не «найдено».
      expect(find.text('Найдена 1 запись'), findsOneWidget);
    });

    testWidgets('пустой результат показывает пустое состояние', (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...baseOverrides(),
            catalogResultsProvider.overrideWith(
              (ref) async => CatalogResults.of(const []),
            ),
            objectTypesProvider.overrideWith((ref) async => []),
            allCategoriesProvider.overrideWith((ref) async => []),
          ],
          child: app(const CatalogScreen()),
        ),
      );
      await tester.pump();

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('Записей пока нет'), findsOneWidget);
    });

    testWidgets('длинные названия не ломают вёрстку', (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...baseOverrides(),
            catalogResultsProvider.overrideWith(
              (ref) async => CatalogResults.of([
                entryView(
                  id: 'e1',
                  title:
                      'Очень длинное название записи, которое обязано корректно '
                      'сокращаться и не приводить к переполнению вёрстки',
                  path: [
                    'Очень длинная категория верхнего уровня',
                    'И ещё одна вложенная категория с длинным названием',
                  ],
                ),
              ]),
            ),
            objectTypesProvider.overrideWith((ref) async => []),
            allCategoriesProvider.overrideWith((ref) async => []),
          ],
          child: app(const CatalogScreen()),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(EntryCard), findsOneWidget);
    });
  });

  group('Категории', () {
    /// Две категории: корневая «Продукты» и вложенные «Колбасы» с тремя
    /// записями.
    Future<void> pumpTwoLevels(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...baseOverrides(),
            allCategoriesProvider.overrideWith(
              (ref) async => [
                categoryRow(
                  id: 'c1',
                  profileId: 'p1',
                  name: 'Продукты',
                  path: 'c1',
                ),
                categoryRow(
                  id: 'c2',
                  profileId: 'p1',
                  name: 'Колбасы',
                  parentId: 'c1',
                  level: 1,
                  path: 'c1/c2',
                ),
              ],
            ),
            categoryDirectCountsProvider.overrideWith((ref) async => {'c2': 3}),
          ],
          child: app(const CategoriesScreen()),
        ),
      );
      await tester.pump();
    }

    testWidgets('дерево видно сразу, без переключения режимов', (tester) async {
      await pumpTwoLevels(tester);
      await tester.pumpAndSettle();

      // До 1.16.0 обзор начинался с полок, а дерево было вторым режимом.
      expect(find.byType(CategoryTreeRow), findsNWidgets(2));
      expect(find.text('Продукты'), findsWidgets);
      expect(find.text('Колбасы'), findsWidgets);
    });

    testWidgets('ветка открывается из дерева и показывает подкатегории', (
      tester,
    ) async {
      await pumpTwoLevels(tester);
      await tester.pumpAndSettle();

      // Пока ветка не выбрана, справа подсказка, а не пустота.
      expect(find.byType(CategoryBranchPage), findsNothing);

      await tester.tap(find.text('Продукты').first);
      await tester.pumpAndSettle();

      // Одно нажатие — один исход: открылась страница ветки, а в ней полкой
      // лежит подкатегория со счётчиком по своей ветке.
      expect(find.byType(CategoryBranchPage), findsOneWidget);
      expect(find.widgetWithText(CategoryShelfCard, 'Колбасы'), findsOneWidget);
      expect(find.text('3 записи'), findsOneWidget);
    });

    testWidgets('навигатор и страница ветки видны одновременно', (
      tester,
    ) async {
      await pumpTwoLevels(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Колбасы').first);
      await tester.pumpAndSettle();

      // Дерево не подменяется содержимым: по нему видно, где мы находимся.
      expect(find.byType(CategoryTreeRow), findsNWidgets(2));
      expect(find.byType(CategoryBranchPage), findsOneWidget);
    });

    testWidgets('пустое дерево предлагает создать категорию', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...baseOverrides(),
            allCategoriesProvider.overrideWith((ref) async => []),
            categoryDirectCountsProvider.overrideWith((ref) async => {}),
          ],
          child: app(const CategoriesScreen()),
        ),
      );
      await tester.pump();

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('Новая корневая категория'), findsOneWidget);
    });
  });

  group('Сравнение', () {
    testWidgets('с одним профилем предлагает добавить второй', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: baseOverrides(),
          child: app(const CompareScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Нужны два разных профиля'), findsOneWidget);
    });

    testWidgets('с двумя профилями показывает режимы сравнения', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1600, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: baseOverrides(
            profiles: [
              profileRow('p1', 'Александр'),
              profileRow('p2', 'Лариса'),
            ],
          ),
          child: app(const CompareScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Есть у обоих'), findsOneWidget);
      expect(find.text('Нравится обоим'), findsOneWidget);
      expect(find.text('Оценки сильно отличаются'), findsOneWidget);
    });
  });

  group('Подборки', () {
    testWidgets('пустое состояние объясняет назначение', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...baseOverrides(),
            collectionsProvider.overrideWith((ref) async => []),
          ],
          child: app(const CollectionsScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Подборок пока нет'), findsOneWidget);
    });
  });

  group('Темы', () {
    testWidgets('тёмная тема рендерится без ошибок', (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...baseOverrides(),
            catalogResultsProvider.overrideWith(
              (ref) async => CatalogResults.of([
                entryView(id: 'e1', title: 'Интерстеллар', rating: 9.5),
              ]),
            ),
            objectTypesProvider.overrideWith((ref) async => []),
            allCategoriesProvider.overrideWith((ref) async => []),
          ],
          child: app(const CatalogScreen(), brightness: Brightness.dark),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Интерстеллар'), findsOneWidget);
    });
  });

  group('Много профилей', () {
    testWidgets('десять профилей отображаются в сравнении', (tester) async {
      tester.view.physicalSize = const Size(1600, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: baseOverrides(
            profiles: [
              for (var i = 0; i < 10; i++) profileRow('p$i', 'Профиль $i'),
            ],
          ),
          child: app(const CompareScreen()),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Есть у обоих'), findsOneWidget);
    });
  });
}
