import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/features/archive/archive_screen.dart';
import 'package:impressions/features/categories/category_providers.dart';

import '../db/test_db.dart';
import 'screens_test.dart' show app;

/// Архив разбирается пачкой.
///
/// Вернуть десяток записей — десять нажатий, а удаление насовсем спрашивало
/// подтверждение на каждую.
void main() {
  late AppDatabase db;
  late EntryRepository entries;
  late ProfileRow me;
  late List<ProfileEntryRow> archived;

  setUp(() async {
    db = openTestDb();
    entries = EntryRepository(db);
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    final type = await entries.createObjectType(me.id, 'Продукты');

    archived = [];
    for (final title in ['Папа может', 'Молоко', 'Хлеб']) {
      final object = await entries.createObject(typeId: type.id, title: title);
      final entry = await entries.createEntry(
        profileId: me.id,
        objectId: object.id,
      );
      await entries.archiveEntry(entry.id);
      archived.add(entry);
    }
  });

  tearDown(() => db.close());

  Future<int> liveCount() async => (await entries.entryViews(me.id)).length;

  Future<int> archivedCount() async =>
      (await entries.entryViews(me.id, archived: true)).length;

  Future<void> openArchive(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activeProfileProvider.overrideWithValue(me),
          archivedCategoriesProvider.overrideWith((ref) async => const []),
        ],
        child: app(const ArchiveScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('выбранные возвращаются одним действием', (tester) async {
    await openArchive(tester);

    await tester.tap(find.text('Выбрать все'));
    await tester.pumpAndSettle();
    // Первая кнопка «Восстановить» — в панели выделения; ниже такие же стоят
    // у каждой строки.
    await tester.tap(find.widgetWithText(OutlinedButton, 'Восстановить').first);
    await tester.pumpAndSettle();

    expect(await liveCount(), 3);
    expect(await archivedCount(), 0);
    expect(find.text('3 записи возвращены'), findsOneWidget);
  });

  testWidgets('удаление насовсем спрашивает один раз на пачку', (tester) async {
    await openArchive(tester);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox).at(1));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Удалить навсегда'));
    await tester.pumpAndSettle();

    // Один вопрос на всю пачку — и в нём сказано, сколько записей исчезнет.
    expect(find.text('Удалить 2 записи навсегда?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Удалить навсегда'));
    await tester.pumpAndSettle();

    expect(await archivedCount(), 1);
  });

  testWidgets('без выделения панели нет', (tester) async {
    await openArchive(tester);

    expect(
      find.widgetWithText(OutlinedButton, 'Удалить навсегда'),
      findsNothing,
    );
  });
}
