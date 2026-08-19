import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/design_system/design_system.dart';
import 'package:impressions/features/entry/entry_detail_sheet.dart';
import 'package:impressions/features/entry/entry_visits.dart';

import '../db/test_db.dart';
import 'screens_test.dart' show app;

/// Повторные впечатления в карточке записи (§10).
///
/// До схемы 8 второй поход в то же кафе затирал первый: у записи одна дата и
/// одна оценка.
void main() {
  late AppDatabase db;
  late EntryRepository entries;
  late ProfileRow me;
  late String entryId;

  setUp(() async {
    db = openTestDb();
    entries = EntryRepository(db);
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    final type = await entries.createObjectType(me.id, 'Места');
    final object = await entries.createObject(typeId: type.id, title: 'Кафе');
    final entry = await entries.createEntry(
      profileId: me.id,
      objectId: object.id,
      rating: 6,
      impressionDate: DateTime(2026, 1, 10),
    );
    entryId = entry.id;
  });

  tearDown(() => db.close());

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activeProfileProvider.overrideWithValue(me),
        ],
        child: app(EntryDetailSheet(entryId: entryId)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('без повторов блок предлагает добавить, но истории не строит', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('Был ещё раз'), findsOneWidget);
    // Единственная дата уже стоит выше — повторять её списком незачем.
    expect(find.text('10 января 2026 г.'), findsNothing);
  });

  testWidgets('повторы показываются списком, свежие сверху', (tester) async {
    await entries.addVisit(
      entryId: entryId,
      occurredAt: DateTime(2026, 3, 1),
      rating: 7,
    );
    await entries.addVisit(
      entryId: entryId,
      occurredAt: DateTime(2026, 8, 1),
      rating: 9,
      note: 'Стало заметно лучше',
    );

    await pump(tester);
    await tester.ensureVisible(find.text('Ещё раз'));
    await tester.pumpAndSettle();

    // Ищем внутри самого блока: дату свежего повтора карточка показывает и
    // выше — запись хранит последнее впечатление, и это правильно.
    Finder inBlock(Finder matching) =>
        find.descendant(of: find.byType(EntryVisitsBlock), matching: matching);

    expect(inBlock(find.text('Стало заметно лучше')), findsOneWidget);
    expect(inBlock(find.textContaining('августа 2026')), findsOneWidget);
    expect(inBlock(find.textContaining('марта 2026')), findsOneWidget);
  });

  testWidgets('карточка в списке помечена числом повторов', (tester) async {
    await entries.addVisit(entryId: entryId, occurredAt: DateTime(2026, 3, 1));
    await entries.addVisit(entryId: entryId, occurredAt: DateTime(2026, 4, 1));

    final view = (await entries.entryViews(me.id)).single;
    expect(view.visitCount, 2);

    await tester.pumpWidget(
      app(
        SizedBox(
          width: 400,
          child: EntryCardCompact(
            data: EntryCardData(title: view.title, visitCount: view.visitCount),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget);
    expect(find.byIcon(Icons.replay_rounded), findsOneWidget);
  });
}
