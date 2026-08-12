import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/category_repository.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/services/barcode_decoder.dart';
import 'package:impressions/features/barcode/barcode_scan_sheet.dart';
import 'package:impressions/features/quick_add/quick_add_sheet.dart';

import '../db/test_db.dart';
import 'screens_test.dart' show app;

/// Пачка сканирования и копия записи.
///
/// Разбирая пакет из магазина, сканер открывали заново на каждую позицию, а
/// «то же, но другой бренд» заводили с нуля.
void main() {
  late AppDatabase db;
  late EntryRepository entries;
  late ProfileRow me;

  setUp(() async {
    db = openTestDb();
    entries = EntryRepository(db);
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    await entries.createObjectType(me.id, 'Продукты');
  });

  tearDown(() => db.close());

  Future<void> openSheet(WidgetTester tester, Widget sheet) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activeProfileProvider.overrideWithValue(me),
        ],
        child: app(sheet),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  ScannedProduct scanned(String code) => ScannedProduct(
    code: DecodedCode(value: code, format: 'EAN-13'),
  );

  testWidgets('очередь кодов заводится подряд, без повторного открытия', (
    tester,
  ) async {
    await openSheet(
      tester,
      QuickAddSheet(
        queue: [scanned('4600000000001'), scanned('4600000000002')],
      ),
    );

    // Первый код уже в форме, второй ждёт очереди.
    expect(find.text('4600000000001'), findsOneWidget);
    expect(find.text('Осталось ещё 1 код'), findsOneWidget);

    await tapVisible(tester, find.widgetWithText(FilledButton, 'Сохранить'));

    // Форма осталась открытой и заполнилась вторым кодом.
    expect(find.text('4600000000002'), findsOneWidget);
    await tapVisible(tester, find.widgetWithText(FilledButton, 'Сохранить'));

    final saved = await entries.entryViews(me.id);
    expect(
      saved.map((e) => e.title),
      containsAll(['4600000000001', '4600000000002']),
    );
  });

  testWidgets('копия записи открывает форму с её данными', (tester) async {
    final categories = CategoryRepository(db);
    final sausages = await categories.createRoot(me.id, 'Колбасы');
    final type = (await entries.objectTypes(me.id)).single;
    final object = await entries.createObject(
      typeId: type.id,
      title: 'Докторская',
    );
    final entry = await entries.createEntry(
      profileId: me.id,
      objectId: object.id,
      relation: 'like',
      rating: 8,
      primaryCategoryId: sausages.id,
    );
    final view = (await entries.entryViews(me.id, entryIds: [entry.id])).single;

    await openSheet(tester, QuickAddSheet(duplicateOf: view));

    expect(find.text('Докторская'), findsOneWidget);
    expect(find.text('Колбасы'), findsOneWidget);
    expect(find.text('8.0'), findsOneWidget);

    // Меняем название — исходная запись при этом не трогается.
    await tester.enterText(find.byType(TextFormField).first, 'Краковская');
    await tapVisible(tester, find.widgetWithText(FilledButton, 'Сохранить'));

    final saved = await entries.entryViews(me.id);
    expect(
      saved.map((e) => e.title),
      containsAll(['Докторская', 'Краковская']),
    );
    final copy = saved.firstWhere((e) => e.title == 'Краковская');
    expect(copy.rating, 8);
    expect(copy.relation, 'like');
    expect(copy.categoryPath.last, 'Колбасы');
  });
}
