import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/features/catalog/catalog_selection.dart';
import 'package:impressions/features/collections/collection_providers.dart';

import '../db/test_db.dart';
import 'screens_test.dart' show app;

/// Массовые действия делают то, что делают чаще всего.
///
/// В панели выделения были только категория, тег, подборка и архив. Самое
/// частое — «понравилось / не понравилось» и оценка — приходилось проставлять
/// по одной записи через меню карточки.
void main() {
  late AppDatabase db;
  late EntryRepository entries;
  late ProfileRow me;
  late ProfileEntryRow first;
  late ProfileEntryRow second;
  late ProviderContainer container;

  setUp(() async {
    db = openTestDb();
    entries = EntryRepository(db);
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    final type = await entries.createObjectType(me.id, 'Продукты');
    for (final title in ['Папа может', 'Молоко']) {
      final object = await entries.createObject(typeId: type.id, title: title);
      final entry = await entries.createEntry(
        profileId: me.id,
        objectId: object.id,
      );
      if (title == 'Папа может') {
        first = entry;
      } else {
        second = entry;
      }
    }
  });

  tearDown(() => db.close());

  Future<ProfileEntryRow> saved(String id) =>
      (db.select(db.profileEntries)..where((e) => e.id.equals(id))).getSingle();

  Future<void> pumpBar(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        activeProfileProvider.overrideWithValue(me),
        collectionsProvider.overrideWith((ref) async => const []),
      ],
    );
    addTearDown(container.dispose);
    container.read(catalogSelectionProvider.notifier).selectAll([
      first.id,
      second.id,
    ]);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: app(BulkActionsBar(onSelectAll: () {})),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('отношение ставится всей пачке', (tester) async {
    await pumpBar(tester);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Отношение'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Обожаю').last);
    await tester.pumpAndSettle();

    expect((await saved(first.id)).relation, 'love');
    expect((await saved(second.id)).relation, 'love');
  });

  testWidgets('оценка ставится всей пачке', (tester) async {
    await pumpBar(tester);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Оценка'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(InkWell, '8'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Сохранить'));
    await tester.pumpAndSettle();

    expect((await saved(first.id)).rating, 8);
    expect((await saved(second.id)).rating, 8);
  });

  testWidgets('тег снимается со всей пачки', (tester) async {
    await entries.addTag(me.id, first.id, 'Завтрак');
    await entries.addTag(me.id, second.id, 'Завтрак');
    await pumpBar(tester);

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Снять тег'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Завтрак'));
    await tester.pumpAndSettle();

    expect(await entries.tagsOfEntry(first.id), isEmpty);
    expect(await entries.tagsOfEntry(second.id), isEmpty);
  });

  testWidgets('снимать нечего — так и сказано', (tester) async {
    await pumpBar(tester);

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Снять тег'));
    await tester.pumpAndSettle();

    expect(find.text('У выделенных записей нет тегов'), findsOneWidget);
  });
}
