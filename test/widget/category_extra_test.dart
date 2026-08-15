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
import 'package:impressions/features/entry/entry_detail_sheet.dart';

import '../db/test_db.dart';

/// Дополнительные категории (§7.2).
///
/// Схема поддерживала их с самого начала — `entry_categories.is_primary`, — но
/// интерфейс знал только про основную: положить запись на две полки было
/// нечем.
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

  Future<String> makeEntry(String categoryId) async {
    final type = await entries.createObjectType(me.id, 'Продукты');
    final obj = await entries.createObject(
      typeId: type.id,
      title: 'Папа может',
    );
    final row = await entries.createEntry(
      profileId: me.id,
      objectId: obj.id,
      primaryCategoryId: categoryId,
    );
    return row.id;
  }

  Future<void> openEntry(WidgetTester tester, String entryId) async {
    tester.view.physicalSize = const Size(1000, 1000);
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
          home: Scaffold(body: EntryDetailSheet(entryId: entryId)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('запись кладётся ещё на одну полку и снимается с неё', (
    tester,
  ) async {
    final primary = await cats.createRoot(me.id, 'Колбасы');
    final extra = await cats.createRoot(me.id, 'Для завтрака');
    final entry = await makeEntry(primary.id);

    await openEntry(tester, entry);
    await tester.tap(find.widgetWithText(ActionChip, 'Ещё категории'));
    await tester.pumpAndSettle();

    // Основную полку целью не предлагают: запись и так на ней лежит.
    expect(find.widgetWithText(ListTile, 'Колбасы'), findsNothing);
    await tester.tap(find.widgetWithText(ListTile, 'Для завтрака'));
    await tester.pumpAndSettle();

    expect(await entries.extraCategoriesOf(entry), [extra.id]);
    expect(find.widgetWithText(Chip, 'Для завтрака'), findsOneWidget);

    // Снимаем — крестиком на чипе.
    await tester.tap(find.byIcon(Icons.cancel).first);
    await tester.pumpAndSettle();

    expect(await entries.extraCategoriesOf(entry), isEmpty);
  });

  testWidgets('основная категория не снимается как дополнительная', (
    tester,
  ) async {
    // Без основной категории у записи пропадает путь, и в каталоге вместо
    // крошек оказывается пустота.
    final primary = await cats.createRoot(me.id, 'Колбасы');
    final entry = await makeEntry(primary.id);

    await entries.removeCategory(entry, primary.id);

    expect(await entries.primaryCategoryOf(entry), primary.id);
  });

  testWidgets('дополнительные категории видны в карточке', (tester) async {
    final primary = await cats.createRoot(me.id, 'Колбасы');
    final extra = await cats.createRoot(me.id, 'Для завтрака');
    final entry = await makeEntry(primary.id);
    await entries.addCategory(entry, extra.id);

    await openEntry(tester, entry);

    // Основная остаётся крошками, дополнительные — чипами: разницу видно без
    // объяснений.
    expect(find.widgetWithText(Chip, 'Для завтрака'), findsOneWidget);
    expect(find.text('Ещё категории'), findsOneWidget);
  });
}
