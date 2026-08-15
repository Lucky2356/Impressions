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
import 'package:impressions/features/archive/archive_screen.dart';
import 'package:impressions/features/catalog/catalog_providers.dart';
import 'package:impressions/features/categories/category_branch_page.dart';
import 'package:impressions/features/categories/category_providers.dart';
import 'package:impressions/features/collections/collection_providers.dart';
import 'package:impressions/features/collections/collections_screen.dart';
import 'package:impressions/features/compare/compare_screen.dart';
import 'package:impressions/features/exchange/incoming_screen.dart';
import 'package:impressions/features/insights/insights_screen.dart';
import 'package:impressions/features/profiles/profiles_screen.dart';
import 'package:impressions/features/quick_add/category_picker.dart';
import 'package:impressions/features/settings/backups_section.dart';
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
    status: 'planned',
    statusLabel: 'Хочу попробовать',
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
          // Экран читает `wishlistProvider`; подмена соседнего провайдера
          // главной оставляла его пустым, и тест смотрел на пустое состояние.
          wishlistProvider.overrideWith(
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

  testWidgets('шапка ветки на телефоне не сжимает подпись в столбик', (
    tester,
  ) async {
    // Название, счётчик, «Добавить подкатегорию» и «Добавить» в одну строку на
    // телефоне не помещались. Переполнения при этом не возникало: Expanded
    // честно сжимался до нуля, и подпись печаталась по букве в строку.
    await pumpPhone(
      tester,
      ProviderScope(
        overrides: [
          ...base(),
          allCategoriesProvider.overrideWith(
            (ref) async => [category('c1', 'Фильмы')],
          ),
          categoryDirectCountsProvider.overrideWith((ref) async => const {}),
          categoryBranchResultsProvider.overrideWith(
            (ref) async => const CatalogResults(items: [], total: 0),
          ),
        ],
        child: app(
          CategoryBranchPage(category: category('c1', 'Фильмы'), onBack: () {}),
        ),
      ),
    );

    expect(tester.takeException(), isNull);

    // Подпись занимает нормальную строку, а не колонку в одну букву.
    final summary = find.text('0 записей в ветке');
    expect(summary, findsOneWidget);
    final size = tester.getSize(summary);
    expect(size.width, greaterThan(120));
    expect(size.height, lessThan(40));

    // Обе кнопки шапки при этом остаются на экране целиком. «Добавить» ищем
    // первой: такая же кнопка есть в пустом состоянии ветки ниже.
    final buttons = [
      find.widgetWithText(OutlinedButton, 'Добавить подкатегорию'),
      find.widgetWithText(FilledButton, 'Добавить').first,
    ];
    for (final button in buttons) {
      final rect = tester.getRect(button);
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(400));
      expect(rect.width, greaterThan(0));
    }
  });

  testWidgets('статистика на телефоне помещается в ширину', (tester) async {
    await pumpPhone(
      tester,
      ProviderScope(overrides: [...base()], child: app(const InsightsScreen())),
    );
    expect(tester.takeException(), isNull);
  });

  /// Заголовки разделов не должны сжиматься кнопками до нечитаемого.
  ///
  /// Проверяется именно ширина: переполнения в этом месте не бывает — шапка
  /// честно отдаёт всё место кнопкам, а заголовку остаётся сколько осталось.
  /// Ровно так и сломалась ветка категорий, где кнопок было две.
  void expectTitleReadable(WidgetTester tester, String title) {
    final finder = find.text(title);
    expect(finder, findsOneWidget);
    expect(tester.getSize(finder).width, greaterThan(90));
  }

  testWidgets('подборки на телефоне: заголовок не съеден кнопкой', (
    tester,
  ) async {
    await pumpPhone(
      tester,
      ProviderScope(
        overrides: [
          ...base(),
          collectionsProvider.overrideWith(
            (ref) async => [
              CollectionView(
                collection: CollectionRow(
                  id: 'k1',
                  profileId: 'p1',
                  name: 'На выходные',
                  sortOrder: 0,
                  createdAt: DateTime(2026, 7, 24),
                ),
                entryCount: 3,
              ),
            ],
          ),
        ],
        child: app(const CollectionsScreen()),
      ),
    );

    expectTitleReadable(tester, 'Подборки');
    expect(tester.takeException(), isNull);
  });

  testWidgets('профили на телефоне: заголовок не съеден кнопкой', (
    tester,
  ) async {
    await pumpPhone(
      tester,
      ProviderScope(overrides: [...base()], child: app(const ProfilesScreen())),
    );

    expectTitleReadable(tester, 'Профили');
    expect(tester.takeException(), isNull);
  });

  testWidgets('выбор категории помещается на телефоне с клавиатурой', (
    tester,
  ) async {
    // Поле поиска в выборе категории получает фокус само, так что на телефоне
    // клавиатура открыта всегда — и окну остаётся заметно меньше высоты.
    // Вставки задаются самому окну: `MediaQuery` поверх `MaterialApp` тот
    // перекрыл бы своим, собранным из окна.
    tester.view.viewInsets = const FakeViewPadding(bottom: 340);
    addTearDown(tester.view.resetViewInsets);

    await pumpPhone(
      tester,
      ProviderScope(
        overrides: [
          ...base(),
          allCategoriesProvider.overrideWith(
            (ref) async => [category('c1', 'Продукты')],
          ),
        ],
        child: app(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => CategoryPicker.show(context),
              child: const Text('открыть'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('открыть'));
    await tester.pumpAndSettle();

    expect(find.byType(CategoryPicker), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('входящие изменения на телефоне: заголовок не съеден кнопкой', (
    tester,
  ) async {
    await pumpPhone(
      tester,
      ProviderScope(
        overrides: [
          ...base(),
          incomingChangesProvider.overrideWith(
            (ref) async => [
              IncomingItem(
                change: IncomingChangeRow(
                  id: 'i1',
                  profileId: 'p1',
                  entityKind: 'entry',
                  entityId: 'e1',
                  revisionId: 'r1',
                  receivedAt: DateTime(2026, 7, 24),
                  seen: false,
                ),
                label: 'Папа может',
                profileName: 'Лариса',
              ),
            ],
          ),
        ],
        child: app(const IncomingScreen()),
      ),
    );

    expectTitleReadable(tester, 'Входящие изменения');
    // Ссылок на разделы задания в интерфейсе быть не должно.
    expect(find.textContaining('§'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
