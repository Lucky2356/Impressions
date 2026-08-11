import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/collection_repository.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/features/catalog/catalog_selection.dart';
import 'package:impressions/features/collections/collection_providers.dart';

import '../db/test_db.dart';
import 'screens_test.dart' show app;

/// «В подборку» без подборок больше не тупик.
///
/// Обработчик выходил на пустом списке: `if (collections.isEmpty) return;`.
/// Кнопка нажималась, и не происходило ничего — ровно та же болезнь, что была
/// у экспорта профиля на Android.
void main() {
  late AppDatabase db;
  late EntryRepository entries;
  late CollectionRepository collections;
  late ProfileRow me;
  late ProfileEntryRow entry;

  setUp(() async {
    db = openTestDb();
    entries = EntryRepository(db);
    collections = CollectionRepository(db);
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    final type = await entries.createObjectType(me.id, 'Продукты');
    final object = await entries.createObject(
      typeId: type.id,
      title: 'Папа может',
    );
    entry = await entries.createEntry(profileId: me.id, objectId: object.id);
  });

  tearDown(() => db.close());

  late ProviderContainer container;

  Future<void> pumpBar(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        activeProfileProvider.overrideWithValue(me),
        collectionsProvider.overrideWith((ref) async => const []),
      ],
    );
    addTearDown(container.dispose);
    container.read(catalogSelectionProvider.notifier).selectAll([entry.id]);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: app(BulkActionsBar(onSelectAll: () {})),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('кнопка «В подборку» видна и без подборок', (tester) async {
    await pumpBar(tester);

    expect(find.widgetWithText(OutlinedButton, 'В подборку'), findsOneWidget);
  });

  testWidgets('пустой список предлагает завести подборку', (tester) async {
    await pumpBar(tester);

    await tester.tap(find.widgetWithText(OutlinedButton, 'В подборку'));
    await tester.pumpAndSettle();

    // Не тишина: окно объясняет, что это такое, и предлагает создать первую.
    expect(find.text('Добавить в подборку'), findsOneWidget);
    expect(find.text('Новая подборка'), findsOneWidget);
  });

  testWidgets('созданная тут же подборка получает выделенные записи', (
    tester,
  ) async {
    await pumpBar(tester);

    await tester.tap(find.widgetWithText(OutlinedButton, 'В подборку'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Новая подборка'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'На выходные');
    await tester.tap(find.widgetWithText(FilledButton, 'Сохранить').last);
    await tester.pumpAndSettle();

    final created = (await collections.listWithCounts(me.id)).single;
    expect(created.collection.name, 'На выходные');
    final inside = await collections.entriesOf(
      created.collection.id,
      me.id,
      entriesLoader: (ids) => entries.entryViews(me.id, entryIds: ids),
    );
    expect(inside.single.entryId, entry.id);
  });
}
