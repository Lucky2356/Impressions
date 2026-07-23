import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/collection_repository.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/features/quick_add/quick_add_sheet.dart';

import '../db/test_db.dart';
import 'screens_test.dart' show app;

void main() {
  late AppDatabase db;
  late ProfileRow me;
  late EntryRepository entries;
  late CollectionRepository collections;

  setUp(() async {
    db = openTestDb();
    entries = EntryRepository(db);
    collections = CollectionRepository(db);
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    await entries.createObjectType(me.id, 'Продукты');
  });

  tearDown(() => db.close());

  /// Форма прокручивается: с подробностями она выше окна, и слепой tap
  /// промахивается мимо кнопки.
  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> openSheet(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activeProfileProvider.overrideWithValue(me),
        ],
        child: app(const QuickAddSheet()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('запись сохраняется вместе с тегом', (tester) async {
    await openSheet(tester);

    await tester.enterText(find.byType(TextFormField).first, 'Хлеб');
    await tapVisible(tester, find.text('Добавить подробности'));

    // Тег заводится прямо из формы: раньше за ним приходилось открывать
    // уже сохранённую запись.
    await tapVisible(tester, find.text('Добавить тег'));
    await tester.enterText(find.byType(TextField).last, 'Завтрак');
    await tester.tap(find.widgetWithText(FilledButton, 'Сохранить').last);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(InputChip, 'Завтрак'), findsOneWidget);

    await tapVisible(tester, find.widgetWithText(FilledButton, 'Сохранить'));

    final saved = await entries.entryViews(me.id);
    expect(saved.single.title, 'Хлеб');
    final tags = await entries.tagsOfEntry(saved.single.entryId);
    expect(tags.map((t) => t.name), ['Завтрак']);
  });

  testWidgets('запись сразу попадает в выбранную подборку', (tester) async {
    final collection = await collections.create(me.id, 'На выходные');
    await openSheet(tester);

    await tester.enterText(find.byType(TextFormField).first, 'Сыр');
    await tapVisible(tester, find.text('Добавить подробности'));

    // Список подборок — единственное поле с необязательным значением.
    await tapVisible(tester, find.byType(DropdownButtonFormField<String?>));
    await tester.tap(find.text('На выходные').last);
    await tester.pumpAndSettle();

    await tapVisible(tester, find.widgetWithText(FilledButton, 'Сохранить'));

    final inCollection = await collections.entriesOf(
      collection.id,
      me.id,
      entriesLoader: (ids) => entries.entryViews(me.id, entryIds: ids),
    );
    expect(inCollection.single.title, 'Сыр');
  });

  testWidgets('без подробностей запись сохраняется как прежде', (tester) async {
    await openSheet(tester);

    await tester.enterText(find.byType(TextFormField).first, 'Молоко');
    await tapVisible(tester, find.widgetWithText(FilledButton, 'Сохранить'));

    final saved = await entries.entryViews(me.id);
    expect(saved.single.title, 'Молоко');
    expect(await entries.tagsOfEntry(saved.single.entryId), isEmpty);
  });
}
