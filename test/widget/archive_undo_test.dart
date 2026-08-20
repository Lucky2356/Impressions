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
import 'package:impressions/features/entry/entry_detail_sheet.dart';

import '../db/test_db.dart';
import 'screens_test.dart' show app;

/// Архивирование не спрашивает «точно?».
///
/// Диалог подтверждения ничего не защищал: сразу после него появлялось
/// «Вернуть», то есть действие обратимо и отмена под рукой. А разбор каталога
/// — это десятки таких движений подряд, и каждое упиралось в лишнее нажатие.
void main() {
  late AppDatabase db;
  late EntryRepository entries;
  late ProfileRow me;
  late ProfileEntryRow first;
  late ProfileEntryRow second;

  setUp(() async {
    db = openTestDb();
    entries = EntryRepository(db);
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    final type = await entries.createObjectType(me.id, 'Продукты');
    final papa = await entries.createObject(
      typeId: type.id,
      title: 'Папа может',
    );
    final milk = await entries.createObject(typeId: type.id, title: 'Молоко');
    first = await entries.createEntry(profileId: me.id, objectId: papa.id);
    second = await entries.createEntry(profileId: me.id, objectId: milk.id);
  });

  tearDown(() => db.close());

  Future<DateTime?> archivedAt(String entryId) async {
    final row = await (db.select(
      db.profileEntries,
    )..where((e) => e.id.equals(entryId))).getSingle();
    return row.archivedAt;
  }

  group('карточка записи', () {
    Future<void> openCard(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            activeProfileProvider.overrideWithValue(me),
          ],
          child: app(
            Builder(
              builder: (context) => TextButton(
                onPressed: () => EntryDetailSheet.show(context, first.id),
                child: const Text('открыть'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('открыть'));
      await tester.pumpAndSettle();
    }

    testWidgets('архивирование идёт сразу, без вопроса', (tester) async {
      await openCard(tester);

      // Действия над записью с 1.20.0 живут в одном меню: значков в шапке
      // было три, а название самой записи при этом лежало ниже.
      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.archive_outlined));
      await tester.pumpAndSettle();

      // Никакого «точно?»: запись уже в архиве, а рядом лежит «Вернуть».
      expect(find.byType(AlertDialog), findsNothing);
      expect(await archivedAt(first.id), isNotNull);
      expect(find.text('Запись убрана в архив'), findsOneWidget);
      expect(find.text('Вернуть'), findsOneWidget);
    });

    testWidgets('«Вернуть» возвращает запись', (tester) async {
      await openCard(tester);
      // Действия над записью с 1.20.0 живут в одном меню: значков в шапке
      // было три, а название самой записи при этом лежало ниже.
      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.archive_outlined));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Вернуть'));
      await tester.pumpAndSettle();

      expect(await archivedAt(first.id), isNull);
    });
  });

  group('панель выделения', () {
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

    testWidgets('пачка уходит в архив без вопроса и возвращается', (
      tester,
    ) async {
      await pumpBar(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'В архив'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(await archivedAt(first.id), isNotNull);
      expect(await archivedAt(second.id), isNotNull);

      await tester.tap(find.text('Вернуть'));
      await tester.pumpAndSettle();

      expect(await archivedAt(first.id), isNull);
      expect(await archivedAt(second.id), isNull);
    });
  });
}
