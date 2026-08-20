import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/features/entry/entry_detail_sheet.dart';
import 'package:impressions/features/entry/entry_disclosure.dart';
import 'package:impressions/features/entry/entry_hero.dart';
import 'package:impressions/features/entry/entry_opinion.dart';

import '../db/test_db.dart';
import 'screens_test.dart' show app;

/// Устройство карточки записи.
///
/// До 1.20.0 это была одна лента из шестнадцати блоков, и все они были
/// раскрыты: чтобы поставить оценку, приходилось искать её глазами среди
/// тегов, приватности и истории версий.
void main() {
  late AppDatabase db;
  late EntryRepository entries;
  late ProfileRow me;
  late String entryId;

  setUp(() async {
    db = openTestDb();
    entries = EntryRepository(db);
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    final type = await entries.createObjectType(me.id, 'Сериалы');
    final object = await entries.createObject(
      typeId: type.id,
      title: 'Твин Пикс',
    );
    await entries.updateObject(object.id, altTitle: 'Twin Peaks');
    final entry = await entries.createEntry(
      profileId: me.id,
      objectId: object.id,
      rating: 8,
    );
    entryId = entry.id;
  });

  tearDown(() => db.close());

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 900);
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

  testWidgets('сначала видно, что это, потом — что вы об этом думаете', (
    tester,
  ) async {
    await pump(tester);

    // Название записи стоит выше карточки мнения, а не после неё.
    final hero = tester.getTopLeft(find.byType(EntryHero)).dy;
    final opinion = tester.getTopLeft(find.byType(EntryOpinionCard)).dy;
    expect(hero, lessThan(opinion));

    expect(find.text('Твин Пикс'), findsOneWidget);
    expect(find.text('Twin Peaks'), findsOneWidget);
  });

  testWidgets('редкое свёрнуто, а не развёрнуто на всю ленту', (tester) async {
    await pump(tester);
    // Свёрнутые разделы стоят в конце ленты — до них надо долистать. То, что
    // они туда помещаются, и есть смысл переделки: раньше эта же лента была
    // втрое длиннее.
    await tester.drag(find.byType(EntryOpinionCard), const Offset(0, -1200));
    await tester.pumpAndSettle();

    // Заголовки разделов на месте, а их содержимое — нет, пока не раскроют.
    expect(find.byType(EntryDisclosure), findsWidgets);
    expect(find.text('История изменений'), findsOneWidget);
    expect(find.text('Доступность'), findsOneWidget);
    expect(
      find.text('Можно передавать'),
      findsNothing,
      reason: 'приватность спрашивают редко — она свёрнута',
    );

    await tester.tap(find.text('Доступность'));
    await tester.pumpAndSettle();
    expect(find.text('Можно передавать'), findsOneWidget);
  });

  testWidgets('действия над записью собраны в одно меню', (tester) async {
    await pump(tester);

    // В шапке остались только меню и закрытие: раньше значков было три, а
    // ещё два прятались рядом с названием объекта.
    expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);
    expect(find.byIcon(Icons.archive_outlined), findsNothing);

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Изменить описание'), findsOneWidget);
    expect(find.text('Архивировать запись'), findsOneWidget);
  });
}
