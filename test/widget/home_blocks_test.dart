import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/core/l10n/gen/app_localizations.dart';
import 'package:impressions/core/theme/app_theme.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/models/entry_view.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/collection_repository.dart';
import 'package:impressions/data/repositories/settings_repository.dart';
import 'package:impressions/design_system/design_system.dart';
import 'package:impressions/features/categories/category_providers.dart';
import 'package:impressions/features/collections/collection_providers.dart';
import 'package:impressions/features/home/home_providers.dart';
import 'package:impressions/features/home/home_screen.dart';
import 'package:impressions/features/home/pinned_store.dart';

import '../db/test_db.dart';

/// Блоки живой главной (§14).
///
/// Главная показывала три числа, график и недавнее — то есть то, что решило
/// приложение. На чём человек остановился и что он ведёт прямо сейчас, она не
/// знала. Пустыми блоки не показываются: правило главной с самого начала.
void main() {
  late AppDatabase db;

  setUp(() => db = openTestDb());
  tearDown(() => db.close());

  ProfileRow profile() => ProfileRow(
    id: 'p1',
    type: 'myPrimary',
    firstName: 'Я',
    profileVersion: 1,
    retransmitMode: 'allowed',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  EntryView entry(String id, String title, {String? statusLabel}) => EntryView(
    entryId: id,
    objectId: 'o-$id',
    title: title,
    typeName: 'Сериалы',
    statusLabel: statusLabel,
  );

  CategoryRow category(String id, String name) => CategoryRow(
    id: id,
    profileId: 'p1',
    name: name,
    normalizedName: name.toLowerCase(),
    sortOrder: 0,
    level: 0,
    path: id,
    createdAt: DateTime(2026, 1, 1),
  );

  /// Главная на широком экране со своими данными.
  ///
  /// Недавнее не пустое всегда: пустой профиль показывает приглашение завести
  /// первую запись, и до блоков дело не доходит.
  Future<void> pumpHome(
    WidgetTester tester, {
    List<EntryView> inProgress = const [],
    List<EntryView> yearAgo = const [],
    List<EntryView> planned = const [],
    List<String> pinnedCategories = const [],
    List<CategoryRow> categories = const [],
  }) async {
    tester.view.physicalSize = const Size(1400, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    if (pinnedCategories.isNotEmpty) {
      await SettingsRepository(db).set(
        SettingKeys.homePinnedCategories,
        '["${pinnedCategories.join('","')}"]',
      );
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activeProfileProvider.overrideWithValue(profile()),
          profilesProvider.overrideWith((ref) => Stream.value([profile()])),
          recentEntriesProvider.overrideWith(
            (ref) async => [entry('r1', 'Недавнее')],
          ),
          inProgressEntriesProvider.overrideWith((ref) async => inProgress),
          yearAgoEntriesProvider.overrideWith((ref) async => yearAgo),
          plannedEntriesProvider.overrideWith((ref) async => planned),
          plannedSuggestionPoolProvider.overrideWith((ref) async => planned),
          allCategoriesProvider.overrideWith((ref) async => categories),
          rootCategoriesProvider.overrideWith((ref) async => const []),
          collectionsProvider.overrideWith(
            (ref) async => const <CollectionView>[],
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ru'),
          theme: AppTheme.light(),
          home: const Scaffold(body: HomeScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('начатое показывается отдельным блоком', (tester) async {
    await pumpHome(
      tester,
      inProgress: [entry('e1', 'Твин Пикс', statusLabel: 'Смотрю · 3 серия')],
    );

    expect(find.text('Продолжить начатое'), findsOneWidget);
    expect(find.text('Твин Пикс'), findsOneWidget);
    // Стадия и прогресс видны прямо на карточке — ради этого блок и нужен.
    expect(find.text('Смотрю · 3 серия'), findsOneWidget);
  });

  testWidgets('пустые блоки не занимают места', (tester) async {
    await pumpHome(tester);

    expect(find.text('Продолжить начатое'), findsNothing);
    expect(find.text('Год назад'), findsNothing);
    expect(find.text('Закреплённое'), findsNothing);
    expect(find.text('Может, сегодня?'), findsNothing);
  });

  testWidgets('«Год назад» показывает то, что было тогда', (tester) async {
    await pumpHome(tester, yearAgo: [entry('e2', 'Прошлогоднее')]);

    expect(find.text('Год назад'), findsOneWidget);
    // Обложка рисует название сама и без файла показывает заглушку, поэтому
    // ищем карточку, а не строку.
    expect(
      find.byWidgetPredicate(
        (w) => w is CoverProgress && w.title == 'Прошлогоднее',
      ),
      findsOneWidget,
    );
  });

  testWidgets('подсказка дня берётся из задуманного', (tester) async {
    await pumpHome(tester, planned: [entry('e3', 'Дюна')]);

    expect(find.text('Может, сегодня?'), findsOneWidget);
    // Одна и та же запись и в подсказке, и в списке «Хочу попробовать».
    expect(find.text('Дюна'), findsWidgets);
  });

  testWidgets('закреплённая ветка попадает на главную', (tester) async {
    await pumpHome(
      tester,
      pinnedCategories: const ['c1'],
      categories: [category('c1', 'Смотрим вдвоём'), category('c2', 'Книги')],
    );

    expect(find.text('Закреплённое'), findsOneWidget);
    expect(find.text('Смотрим вдвоём'), findsOneWidget);
    // Незакреплённая ветка в блок не попадает.
    expect(find.text('Книги'), findsNothing);
  });

  testWidgets('исчезнувшее закреплённое пропускается молча', (tester) async {
    // Ветку могли убрать в архив или удалить: плитка в никуда хуже, чем её
    // отсутствие.
    await pumpHome(
      tester,
      pinnedCategories: const ['удалённая'],
      categories: [category('c1', 'Смотрим вдвоём')],
    );

    expect(find.text('Закреплённое'), findsNothing);
  });

  test('список закреплённого не ломается от мусора', () {
    expect(PinnedIds.parse(null), isEmpty);
    expect(PinnedIds.parse('не json'), isEmpty);
    expect(PinnedIds.parse('["c1", 5, "", "c2"]'), ['c1', 'c2']);
  });
}
