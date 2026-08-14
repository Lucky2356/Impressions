import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:impressions/app/app_state.dart';
import 'package:impressions/core/l10n/gen/app_localizations.dart';
import 'package:impressions/core/theme/app_theme.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/models/entry_view.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/features/catalog/catalog_providers.dart';
import 'package:impressions/features/catalog/catalog_screen.dart';
import 'package:impressions/features/categories/categories_screen.dart';
import 'package:impressions/features/categories/category_providers.dart';
import 'package:impressions/features/home/home_providers.dart';
import 'package:impressions/features/settings/backups_section.dart';
import 'package:impressions/features/settings/settings_screen.dart';

import '../db/test_db.dart';

/// Вёрстка при увеличенном системном шрифте.
///
/// Высоты полей, кнопок и карточек заданы в точках, а размер текста задаёт
/// система: при «Крупном шрифте» — частой настройке у людей старшего возраста —
/// текст перестаёт помещаться в свои коробки. Проверяем обычный масштаб и
/// увеличенный.
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

  CategoryRow category(
    String id,
    String name, {
    String? parent,
    int level = 0,
  }) => CategoryRow(
    id: id,
    profileId: 'p1',
    parentId: parent,
    name: name,
    normalizedName: name.toLowerCase(),
    sortOrder: 0,
    level: level,
    path: parent == null ? id : '$parent/$id',
    createdAt: DateTime(2026, 7, 24),
  );

  Widget app(Widget child, double scale) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('ru'),
    theme: AppTheme.light(),
    builder: (context, widget) => MediaQuery.withClampedTextScaling(
      minScaleFactor: scale,
      maxScaleFactor: scale,
      child: widget!,
    ),
    home: Scaffold(body: child),
  );

  Future<void> pumpAt(
    WidgetTester tester,
    Widget tree, {
    Size size = const Size(400, 900),
  }) async {
    tester.view.physicalSize = size;
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

  // Обычный и увеличенный системный шрифт.
  for (final scale in [1.0, 1.3]) {
    final label = scale == 1.0 ? 'обычном' : 'увеличенном';

    testWidgets('каталог при $label шрифте не переполняется', (tester) async {
      await pumpAt(
        tester,
        ProviderScope(
          overrides: [
            ...base(),
            catalogResultsProvider.overrideWith(
              (ref) async => CatalogResults.of([
                EntryView(
                  entryId: 'e1',
                  objectId: 'o1',
                  title: 'Папа может',
                  typeName: 'Продукты',
                  categoryPath: const ['Продукты', 'Колбасы'],
                  relation: 'like',
                  rating: 7,
                ),
              ]),
            ),
            objectTypesProvider.overrideWith((ref) async => []),
            allCategoriesProvider.overrideWith((ref) async => []),
          ],
          child: app(const CatalogScreen(), scale),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('настройки при $label шрифте не переполняются', (tester) async {
      await pumpAt(
        tester,
        ProviderScope(
          overrides: [
            ...base(),
            backupsProvider.overrideWith((ref) async => const []),
          ],
          child: app(const SettingsScreen(), scale),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('категории при $label шрифте не переполняются', (tester) async {
      await pumpAt(
        tester,
        ProviderScope(
          overrides: [
            ...base(),
            allCategoriesProvider.overrideWith(
              (ref) async => [
                category('c1', 'Продукты'),
                category('c2', 'Колбасы', parent: 'c1', level: 1),
              ],
            ),
            categoryDirectCountsProvider.overrideWith((ref) async => {'c2': 3}),
          ],
          child: app(const CategoriesScreen(), scale),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
