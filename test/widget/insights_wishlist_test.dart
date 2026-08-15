import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/core/l10n/gen/app_localizations.dart';
import 'package:impressions/core/theme/app_theme.dart';
import 'package:impressions/data/models/entry_view.dart';
import 'package:impressions/design_system/design_system.dart';
import 'package:impressions/features/insights/insights_screen.dart';
import 'package:impressions/features/wishlist/wishlist_screen.dart';

/// Тип `Override` в Riverpod 3 публично не экспортируется, поэтому список
/// подмен передаётся прямо в [ProviderScope] на месте вызова, а здесь
/// остаётся только оболочка приложения.
Widget _app(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('ru'),
  theme: AppTheme.light(),
  home: Scaffold(body: child),
);

void _surface(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

ProfileInsights _rich() => ProfileInsights(
  total: 240,
  rated: 180,
  averageRating: 7.4,
  ratingBuckets: const [2, 0, 5, 8, 14, 22, 30, 41, 38, 20],
  byRelation: const {
    'love': 60,
    'like': 80,
    'neutral': 40,
    'dislike': 30,
    'avoid': 12,
  },
  topCategories: const [
    (id: 'c1', name: 'Продукты питания и напитки', count: 120),
    (id: 'c2', name: 'Колбасные изделия', count: 64),
    (id: 'c3', name: 'Места', count: 30),
  ],
  byMonth: [
    for (var i = 0; i < 30; i++)
      (month: DateTime(2024, 1 + i % 12), count: (i * 7) % 40 + 1),
  ],
  withPhotos: 90,
  withNotes: 150,
);

EntryView _wish(String title) => EntryView(
  entryId: 'e-$title',
  objectId: 'o-$title',
  title: title,
  typeName: 'Продукты',
  categoryPath: const ['Продукты', 'Колбасы'],
  status: 'planned',
  statusLabel: 'Хочу попробовать',
);

void main() {
  group('Статистика', () {
    testWidgets('насыщенные данные не ломают диаграммы', (tester) async {
      _surface(tester, const Size(1400, 1000));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileInsightsProvider.overrideWith((ref) async => _rich()),
          ],
          child: _app(const InsightsScreen()),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Распределение оценок'), findsOneWidget);
      expect(find.text('7.4'), findsOneWidget);
    });

    testWidgets('узкое окно не приводит к переполнению', (tester) async {
      _surface(tester, const Size(420, 900));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileInsightsProvider.overrideWith((ref) async => _rich()),
          ],
          child: _app(const InsightsScreen()),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('пустой профиль объясняет, чего не хватает', (tester) async {
      _surface(tester, const Size(1000, 800));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileInsightsProvider.overrideWith(
              (ref) async => const ProfileInsights(
                total: 0,
                rated: 0,
                averageRating: null,
                ratingBuckets: [],
                byRelation: {},
                topCategories: [],
                byMonth: [],
                withPhotos: 0,
                withNotes: 0,
              ),
            ),
          ],
          child: _app(const InsightsScreen()),
        ),
      );
      await tester.pump();

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('Пока нечего показывать'), findsOneWidget);
    });
  });

  group('Хочу попробовать', () {
    testWidgets('показывает список с кнопкой отметки', (tester) async {
      _surface(tester, const Size(1200, 900));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            wishlistProvider.overrideWith(
              (ref) async => [_wish('Суши'), _wish('Прогулка по набережной')],
            ),
          ],
          child: _app(const WishlistScreen()),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Суши'), findsOneWidget);
      expect(find.text('Попробовал'), findsNWidgets(2));
    });

    testWidgets('пустой список объясняет, как им пользоваться', (tester) async {
      _surface(tester, const Size(1000, 800));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [wishlistProvider.overrideWith((ref) async => [])],
          child: _app(const WishlistScreen()),
        ),
      );
      await tester.pump();

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('Список пуст'), findsOneWidget);
    });
  });
}
