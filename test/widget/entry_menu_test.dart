import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/models/entry_view.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/features/entry/entry_context_menu.dart';

import '../db/test_db.dart';
import 'screens_test.dart' show app;

/// Отношение и оценка прямо из списка.
///
/// Меню умело открыть, выделить, сменить категорию, положить в подборку и
/// убрать в архив. Самого частого — «понравилось / не понравилось» — там не
/// было, ради него приходилось открывать карточку.
void main() {
  late AppDatabase db;
  late EntryRepository entries;
  late ProfileRow me;
  late ProfileEntryRow entry;
  late EntryView view;

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
    view = EntryView(
      entryId: entry.id,
      objectId: object.id,
      title: object.title,
      typeName: 'Продукты',
      categoryPath: const [],
    );
  });

  tearDown(() => db.close());

  Future<ProfileEntryRow> saved() => (db.select(
    db.profileEntries,
  )..where((e) => e.id.equals(entry.id))).getSingle();

  Future<void> openMenu(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activeProfileProvider.overrideWithValue(me),
        ],
        child: app(
          Center(
            child: EntryMenuTarget(
              entry: view,
              // Непрозрачный ребёнок: пустой SizedBox не проходит проверку
              // попадания, и долгое нажатие до меню не доходит.
              child: Container(
                width: 200,
                height: 200,
                color: const Color(0xFFEEEEEE),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.byType(EntryMenuTarget));
    await tester.pumpAndSettle();
  }

  testWidgets('отношение ставится из меню', (tester) async {
    await openMenu(tester);

    await tester.tap(find.text('Обожаю'));
    await tester.pumpAndSettle();

    expect((await saved()).relation, 'love');
  });

  testWidgets('повторный выбор того же отношения снимает его', (tester) async {
    await entries.updateEntry(entry.id, relation: 'love');
    // Меню смотрит на карточку из списка, поэтому она тоже должна знать про
    // выбранное отношение — в каталоге эти данные приходят вместе.
    view = EntryView(
      entryId: view.entryId,
      objectId: view.objectId,
      title: view.title,
      typeName: view.typeName,
      categoryPath: const [],
      relation: 'love',
    );

    await openMenu(tester);
    await tester.tap(find.text('Обожаю'));
    await tester.pumpAndSettle();

    expect((await saved()).relation, isNull);
  });

  testWidgets('оценка ставится из меню, не открывая карточку', (tester) async {
    await openMenu(tester);

    await tester.tap(find.text('Поставить оценку'));
    await tester.pumpAndSettle();

    // Диалог открывается с семёркой — её и сохраняем.
    await tester.tap(find.widgetWithText(FilledButton, 'Сохранить'));
    await tester.pumpAndSettle();

    expect((await saved()).rating, 7);
  });
}
