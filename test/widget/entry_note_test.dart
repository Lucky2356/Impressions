import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/features/entry/entry_detail_sheet.dart';

import '../db/test_db.dart';
import 'screens_test.dart' show app;

/// Заметка в карточке записи не должна пропадать без нажатия «Сохранить».
///
/// Отношение, оценка и дата рядом сохраняются сразу, а заметка ждала кнопки:
/// закрыли карточку крестиком, свайпом вниз или нажатием мимо — набранное
/// исчезало молча.
void main() {
  late AppDatabase db;
  late EntryRepository entries;
  late ProfileRow me;
  late ProfileEntryRow entry;

  setUp(() async {
    db = openTestDb();
    entries = EntryRepository(db);
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    final type = await entries.createObjectType(me.id, 'Продукты');
    final object = await entries.createObject(
      typeId: type.id,
      title: 'Папа может',
    );
    entry = await entries.createEntry(profileId: me.id, objectId: object.id);
  });

  tearDown(() => db.close());

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
              onPressed: () => EntryDetailSheet.show(context, entry.id),
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

  Future<String?> savedNote() async {
    final row = await (db.select(
      db.profileEntries,
    )..where((e) => e.id.equals(entry.id))).getSingle();
    return row.detailedNote;
  }

  testWidgets('закрытие карточки дописывает заметку', (tester) async {
    await openCard(tester);

    await tester.enterText(
      find.widgetWithText(TextField, 'Заметка'),
      'Солоновата, но берём',
    );
    await tester.pumpAndSettle();

    // Кнопку «Сохранить» намеренно не нажимаем — просто закрываем карточку.
    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pumpAndSettle();

    expect(await savedNote(), 'Солоновата, но берём');
  });

  testWidgets('заметка видна при следующем открытии карточки', (tester) async {
    await openCard(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Заметка'), 'Вкусно');
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('открыть'));
    await tester.pumpAndSettle();

    expect(find.text('Вкусно'), findsOneWidget);
  });

  testWidgets('карточка без правок новой версии не заводит', (tester) async {
    final before = await (db.select(
      db.profileEntryRevisions,
    )..where((r) => r.entryId.equals(entry.id))).get();

    await openCard(tester);
    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pumpAndSettle();

    final after = await (db.select(
      db.profileEntryRevisions,
    )..where((r) => r.entryId.equals(entry.id))).get();
    expect(after.length, before.length);
  });
}
