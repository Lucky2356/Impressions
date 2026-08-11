import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:impressions/app/app_state.dart';
import 'package:impressions/core/domain/relation.dart';
import 'package:impressions/core/l10n/gen/app_localizations.dart';
import 'package:impressions/core/theme/app_theme.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/design_system/design_system.dart';
import 'package:impressions/features/catalog/catalog_providers.dart';
import 'package:impressions/features/catalog/catalog_screen.dart';
import 'package:impressions/features/categories/categories_screen.dart';
import 'package:impressions/features/categories/category_detail.dart';
import 'package:impressions/features/categories/category_providers.dart';
import 'package:impressions/features/home/home_providers.dart';

import '../db/test_db.dart';
import '../widget/screens_test.dart' show profileRow, categoryRow, entryView;

/// Golden-тесты ключевых экранов и компонентов (§31).
///
/// Цель — заметить случайную деградацию дизайна: изменение палитры, отступов,
/// радиусов или структуры карточек изменит эталонное изображение.
Widget golden(Widget child, {required Brightness brightness, Size? size}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('ru'),
    theme: brightness == Brightness.light ? AppTheme.light() : AppTheme.dark(),
    home: Scaffold(
      body: Center(
        child: SizedBox(width: size?.width, height: size?.height, child: child),
      ),
    ),
  );
}

void main() {
  late AppDatabase db;

  setUp(() => db = openTestDb());
  tearDown(() => db.close());

  baseOverrides() => [
    appDatabaseProvider.overrideWithValue(db),
    profilesProvider.overrideWith(
      (ref) => Stream.value([profileRow('p1', 'Александр')]),
    ),
  ];

  for (final brightness in Brightness.values) {
    final suffix = brightness == Brightness.light ? 'light' : 'dark';

    testWidgets('golden: карточка записи ($suffix)', (tester) async {
      await tester.pumpWidget(
        golden(
          const EntryCard(
            data: EntryCardData(
              title: 'Папа может',
              subtitle: 'Варёная колбаса',
              categoryPath: ['Продукты', 'Колбасы'],
              relation: Relation.like,
              rating: 7.5,
            ),
          ),
          brightness: brightness,
          // Высоту не фиксируем: карточка сама определяет её по содержимому.
          size: const Size(220, 440),
        ),
      );
      await tester.pump();

      await expectLater(
        find.byType(EntryCard),
        matchesGoldenFile('goldens/entry_card_$suffix.png'),
      );
    });

    testWidgets('golden: пустое состояние ($suffix)', (tester) async {
      await tester.pumpWidget(
        golden(
          const EmptyState(
            icon: Icons.auto_stories_rounded,
            title: 'Записей пока нет',
            message: 'Добавьте первую запись — это займёт несколько секунд.',
          ),
          brightness: brightness,
          size: const Size(420, 360),
        ),
      );
      await tester.pump();

      await expectLater(
        find.byType(EmptyState),
        matchesGoldenFile('goldens/empty_state_$suffix.png'),
      );
    });

    testWidgets('golden: карточка статистики ($suffix)', (tester) async {
      await tester.pumpWidget(
        golden(
          StatCard(
            title: 'Записей',
            value: '128',
            unit: 'шт.',
            subtitle: '+14 за месяц',
            trend: const [4, 6, 5, 8, 7, 10, 9, 12, 11, 14],
            trendColor: const Color(0xFF35C759),
          ),
          brightness: brightness,
          size: const Size(320, 170),
        ),
      );
      await tester.pump();

      await expectLater(
        find.byType(StatCard),
        matchesGoldenFile('goldens/stat_card_$suffix.png'),
      );
    });

    testWidgets('golden: дерево категорий ($suffix)', (tester) async {
      tester.view.physicalSize = const Size(900, 600);
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
                categoryRow(
                  id: 'c3',
                  profileId: 'p1',
                  name: 'Фильмы',
                  path: 'c3',
                ),
              ],
            ),
            categoryDirectCountsProvider.overrideWith(
              (ref) async => {'c2': 14},
            ),
          ],
          child: golden(const CategoriesScreen(), brightness: brightness),
        ),
      );
      // Ждём появления карточек: Appear заводит отложенные таймеры, и без
      // полной прокрутки анимаций golden снимался бы на середине перехода.
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(CategoriesScreen),
        matchesGoldenFile('goldens/categories_$suffix.png'),
      );
    });

    testWidgets('golden: ветка категорий на телефоне ($suffix)', (
      tester,
    ) async {
      // Именно телефонная ширина: в одну строку заголовок ветки, счётчик и
      // обе кнопки не помещаются, и раньше подпись сжималась в столбик.
      tester.view.physicalSize = const Size(400, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final films = categoryRow(id: 'c3', profileId: 'p1', name: 'Фильмы');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...baseOverrides(),
            allCategoriesProvider.overrideWith((ref) async => [films]),
            categoryDirectCountsProvider.overrideWith((ref) async => const {}),
            categoryEntriesProvider.overrideWith((ref, id) async => const []),
          ],
          child: golden(
            CategoryDetail(
              category: films,
              onOpenChild: (_) {},
              onAddChild: () {},
              onRename: () {},
              onIcon: () {},
              onMove: () {},
              onReorder: ({required up}) {},
              onArchive: () {},
              onBack: () {},
            ),
            brightness: brightness,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(CategoryDetail),
        matchesGoldenFile('goldens/category_branch_phone_$suffix.png'),
      );
    });

    testWidgets('golden: каталог ($suffix)', (tester) async {
      tester.view.physicalSize = const Size(1000, 700);
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
                entryView(
                  id: 'e2',
                  title: 'Интерстеллар',
                  path: ['Фильмы'],
                  relation: 'love',
                  rating: 9.5,
                ),
              ]),
            ),
            objectTypesProvider.overrideWith((ref) async => []),
            allCategoriesProvider.overrideWith((ref) async => []),
          ],
          child: golden(const CatalogScreen(), brightness: brightness),
        ),
      );
      // Ждём появления карточек: Appear заводит отложенные таймеры, и без
      // полной прокрутки анимаций golden снимался бы на середине перехода.
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(CatalogScreen),
        matchesGoldenFile('goldens/catalog_$suffix.png'),
      );
    });

    testWidgets('golden: выбор оценки ($suffix)', (tester) async {
      await tester.pumpWidget(
        golden(
          RatingPicker(value: 8, onChanged: (_) {}),
          brightness: brightness,
          size: const Size(380, 120),
        ),
      );
      await tester.pump();

      await expectLater(
        find.byType(RatingPicker),
        matchesGoldenFile('goldens/rating_picker_$suffix.png'),
      );
    });
  }
}
