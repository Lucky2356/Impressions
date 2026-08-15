import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/core/l10n/gen/app_localizations.dart';
import 'package:impressions/core/theme/app_theme.dart';
import 'package:impressions/core/utils/normalize.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/features/categories/categories_screen.dart';
import 'package:impressions/features/categories/category_providers.dart';

import '../db/test_db.dart';

/// Свёрнутые ветки дерева категорий.
///
/// Видимость строки раньше решалась разбором материализованного пути на каждую
/// строку — ещё один проход по всему дереву, и так на каждый кадр. Теперь она
/// считается тем же проходом, что и «есть ли дети»: родитель в списке всегда
/// стоит раньше детей, поэтому его видимость к этому моменту уже известна.
void main() {
  late AppDatabase db;
  late ProfileRow me;

  CategoryRow category(
    String id,
    String name, {
    String? parentId,
    required String path,
    required int level,
  }) => CategoryRow(
    id: id,
    profileId: 'p1',
    parentId: parentId,
    name: name,
    normalizedName: Normalize.name(name),
    level: level,
    path: path,
    sortOrder: 0,
    createdAt: DateTime(2026, 8, 15),
  );

  // Продукты › Колбасы › Варёные, и рядом Фильмы.
  final tree = [
    category('c1', 'Продукты', path: 'c1', level: 0),
    category('c2', 'Колбасы', parentId: 'c1', path: 'c1/c2', level: 1),
    category('c3', 'Варёные', parentId: 'c2', path: 'c1/c2/c3', level: 2),
    category('c4', 'Фильмы', path: 'c4', level: 0),
  ];

  setUp(() {
    db = openTestDb();
    me = ProfileRow(
      id: 'p1',
      type: 'myPrimary',
      firstName: 'Я',
      profileVersion: 1,
      retransmitMode: 'allowed',
      createdAt: DateTime(2026, 8, 15),
      updatedAt: DateTime(2026, 8, 15),
    );
  });

  tearDown(() => db.close());

  Future<void> pumpTree(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activeProfileProvider.overrideWithValue(me),
          profilesProvider.overrideWith((ref) => Stream.value([me])),
          allCategoriesProvider.overrideWith((ref) async => tree),
          categoryDirectCountsProvider.overrideWith((ref) async => const {}),
          categoryBranchCountsProvider.overrideWith((ref) async => const {}),
          categoryCoversProvider.overrideWith((ref) async => const {}),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ru'),
          theme: AppTheme.light(),
          home: const Scaffold(body: CategoriesScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('свёрнутая ветка прячет и детей, и внуков', (tester) async {
    await pumpTree(tester);
    expect(find.text('Колбасы'), findsOneWidget);
    expect(find.text('Варёные'), findsOneWidget);

    // Сворачиваем корень: с ним уходит вся ветка, а соседний корень остаётся.
    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('Продукты'), findsOneWidget);
    expect(find.text('Колбасы'), findsNothing);
    expect(
      find.text('Варёные'),
      findsNothing,
      reason: 'внук прячется вместе с веткой, а не только прямой ребёнок',
    );
    expect(find.text('Фильмы'), findsOneWidget);
  });

  testWidgets('свёрнутая середина прячет только своё поддерево', (
    tester,
  ) async {
    await pumpTree(tester);

    // Второй значок сверху — у «Колбас»: у «Варёных» детей нет.
    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded).at(1));
    await tester.pumpAndSettle();

    expect(find.text('Продукты'), findsOneWidget);
    expect(find.text('Колбасы'), findsOneWidget);
    expect(find.text('Варёные'), findsNothing);
  });

  testWidgets('поиск показывает совпавшее вместе с путём', (tester) async {
    await pumpTree(tester);

    await tester.enterText(find.byType(TextField).first, 'варёные');
    await tester.pumpAndSettle();

    expect(find.text('Варёные'), findsOneWidget);
    expect(find.text('Продукты'), findsOneWidget, reason: 'путь не теряется');
    expect(find.text('Колбасы'), findsOneWidget);
    expect(find.text('Фильмы'), findsNothing);
  });

  group('выделение нескольких веток', () {
    /// Включает режим выделения и отмечает названные ветки.
    Future<void> select(WidgetTester tester, List<String> names) async {
      await tester.tap(find.byIcon(Icons.checklist_rounded));
      await tester.pumpAndSettle();
      for (final name in names) {
        await tester.tap(find.text(name));
        await tester.pumpAndSettle();
      }
    }

    testWidgets('галочки появляются только в своём режиме', (tester) async {
      await pumpTree(tester);
      expect(find.byType(Checkbox), findsNothing);

      await tester.tap(find.byIcon(Icons.checklist_rounded));
      await tester.pumpAndSettle();

      // По галочке на каждую видимую ветку.
      expect(find.byType(Checkbox), findsNWidgets(4));
      expect(find.text('Выбрано 0 веток'), findsOneWidget);
    });

    testWidgets('нажатие на строку отмечает, а не переходит', (tester) async {
      await pumpTree(tester);
      await select(tester, ['Колбасы', 'Фильмы']);

      expect(find.text('Выбрано 2 ветки'), findsOneWidget);
      // Повторное нажатие снимает отметку.
      await tester.tap(find.text('Фильмы'));
      await tester.pumpAndSettle();
      expect(find.text('Выбрана 1 ветка'), findsOneWidget);
    });

    testWidgets('без выделенного действия недоступны', (tester) async {
      await pumpTree(tester);
      await tester.tap(find.byIcon(Icons.checklist_rounded));
      await tester.pumpAndSettle();

      final move = tester.widget<OutlinedButton>(
        find.ancestor(
          of: find.text('Переместить'),
          matching: find.byType(OutlinedButton),
        ),
      );
      expect(move.onPressed, isNull);
    });

    testWidgets('выход из режима снимает выделение', (tester) async {
      await pumpTree(tester);
      await select(tester, ['Колбасы']);

      await tester.tap(find.byIcon(Icons.checklist_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(Checkbox), findsNothing);
      expect(find.textContaining('Выбран'), findsNothing);
    });
  });
}
