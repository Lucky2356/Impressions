import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/core/l10n/gen/app_localizations.dart';
import 'package:impressions/core/theme/app_theme.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/category_repository.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/features/categories/categories_screen.dart';

import '../db/test_db.dart';

/// Объединение веток и массовый перенос из интерфейса.
///
/// Свести две одинаковые по смыслу категории было нечем: оставалось
/// перекладывать записи руками по одной.
void main() {
  late AppDatabase db;
  late CategoryRepository cats;
  late EntryRepository entries;
  late ProfileRow me;

  setUp(() async {
    db = openTestDb();
    cats = CategoryRepository(db);
    entries = EntryRepository(db);
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
  });
  tearDown(() => db.close());

  Future<CategoryRow> reload(String id) =>
      (db.select(db.categories)..where((c) => c.id.equals(id))).getSingle();

  Future<String> makeEntry(String title, String categoryId) async {
    final type = await entries.createObjectType(me.id, 'Тип $title');
    final obj = await entries.createObject(typeId: type.id, title: title);
    final row = await entries.createEntry(
      profileId: me.id,
      objectId: obj.id,
      primaryCategoryId: categoryId,
    );
    return row.id;
  }

  Future<void> pumpScreen(WidgetTester tester) async {
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

  /// Открывает меню «…» выбранной ветки и жмёт пункт.
  Future<void> branchMenu(WidgetTester tester, String item) async {
    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text(item));
    await tester.pumpAndSettle();
  }

  testWidgets('объединение переносит записи и уводит ветку в архив', (
    tester,
  ) async {
    final from = await cats.createRoot(me.id, 'Колбаса');
    final to = await cats.createRoot(me.id, 'Колбасы');
    final entry = await makeEntry('Папа может', from.id);

    await pumpScreen(tester);
    await tester.tap(find.text('Колбаса').first);
    await tester.pumpAndSettle();

    await branchMenu(tester, 'Объединить с…');
    // Саму ветку целью не предлагают: сливать её с собой бессмысленно.
    // Ищем строки списка выбора, а не текст вообще: в дереве позади диалога
    // «Колбаса» никуда не делась.
    expect(find.widgetWithText(ListTile, 'Колбаса'), findsNothing);
    expect(find.widgetWithText(ListTile, 'Колбасы'), findsOneWidget);
    await tester.tap(find.widgetWithText(ListTile, 'Колбасы'));
    await tester.pumpAndSettle();

    // Отменить одним нажатием нельзя, поэтому спрашивают до.
    expect(find.textContaining('уйдёт в архив'), findsOneWidget);
    await tester.tap(find.text('Объединить'));
    await tester.pumpAndSettle();

    expect(await entries.primaryCategoryOf(entry), to.id);
    expect((await reload(from.id)).archivedAt, isNotNull);
  });

  testWidgets('отказ от подтверждения ничего не меняет', (tester) async {
    final from = await cats.createRoot(me.id, 'Колбаса');
    await cats.createRoot(me.id, 'Колбасы');

    await pumpScreen(tester);
    await tester.tap(find.text('Колбаса').first);
    await tester.pumpAndSettle();

    await branchMenu(tester, 'Объединить с…');
    await tester.tap(find.widgetWithText(ListTile, 'Колбасы'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();

    expect((await reload(from.id)).archivedAt, isNull);
  });

  testWidgets('подкатегории переносятся разом', (tester) async {
    final from = await cats.createRoot(me.id, 'Откуда');
    final to = await cats.createRoot(me.id, 'Куда');
    final first = await cats.createChild(from.id, 'Первая');
    final second = await cats.createChild(from.id, 'Вторая');

    await pumpScreen(tester);
    await tester.tap(find.text('Откуда').first);
    await tester.pumpAndSettle();

    await branchMenu(tester, 'Перенести подкатегории…');
    await tester.tap(find.widgetWithText(ListTile, 'Куда'));
    await tester.pumpAndSettle();

    expect((await reload(first.id)).parentId, to.id);
    expect((await reload(second.id)).parentId, to.id);
    // Сама ветка остаётся: переносили её содержимое, а не её.
    expect((await reload(from.id)).archivedAt, isNull);
  });

  testWidgets('записи ветки переносятся разом', (tester) async {
    final from = await cats.createRoot(me.id, 'Откуда');
    final to = await cats.createRoot(me.id, 'Куда');
    final kid = await cats.createChild(from.id, 'Внутри');
    final here = await makeEntry('Прямо здесь', from.id);
    final deeper = await makeEntry('Глубже', kid.id);

    await pumpScreen(tester);
    await tester.tap(find.text('Откуда').first);
    await tester.pumpAndSettle();

    await branchMenu(tester, 'Перенести записи…');
    await tester.tap(find.widgetWithText(ListTile, 'Куда'));
    await tester.pumpAndSettle();

    // Переносится вся ветка, а не только верхняя полка.
    expect(await entries.primaryCategoryOf(here), to.id);
    expect(await entries.primaryCategoryOf(deeper), to.id);
  });
}
