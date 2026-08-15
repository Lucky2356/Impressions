import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/core/domain/entry_status.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/design_system/design_system.dart';
import 'package:impressions/features/entry/entry_detail_sheet.dart';
import 'package:impressions/features/quick_add/quick_add_sheet.dart';

import '../db/test_db.dart';
import 'screens_test.dart' show app;

/// Стадия и прогресс в форме и в карточке записи (§10).
///
/// До схемы 7 стадию изображало отношение «Хочу попробовать»: сказать «уже
/// смотрю, но пока без мнения» было нечем.
void main() {
  late AppDatabase db;
  late EntryRepository entries;
  late ProfileRow me;
  late ObjectTypeRow series;

  setUp(() async {
    db = openTestDb();
    entries = EntryRepository(db);
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    series = await entries.createObjectType(
      me.id,
      'Сериалы',
      statusesJson: EntryStatus.encode(
        BuiltInStatuses.forTypeName('Сериалы')!.statuses,
      ),
      progressUnit: 'серия',
    );
  });

  tearDown(() => db.close());

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> pump(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(1280, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activeProfileProvider.overrideWithValue(me),
        ],
        child: app(child),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('форма заводит запись сразу со стадией', (tester) async {
    await pump(tester, const QuickAddSheet());

    await tester.enterText(find.byType(TextFormField).first, 'Твин Пикс');
    // Названия стадий у типа свои — в форме именно они, а не общие ключи.
    await tapVisible(tester, find.text('Смотрю'));
    await tapVisible(tester, find.widgetWithText(FilledButton, 'Сохранить'));

    final saved = (await entries.entryViews(me.id)).single;
    expect(saved.status, EntryStatus.inProgress);
    expect(saved.statusLabel, 'Смотрю');
    // Мнения при этом нет: стадия и отношение — про разное.
    expect(saved.relation, isNull);
  });

  testWidgets('прогресс сохраняется вместе с записью', (tester) async {
    await pump(tester, const QuickAddSheet());

    await tester.enterText(find.byType(TextFormField).first, 'Твин Пикс');
    await tapVisible(tester, find.text('Добавить подробности'));

    await tester.enterText(find.widgetWithText(TextField, 'Пройдено'), '3');
    await tester.enterText(find.widgetWithText(TextField, 'Всего'), '12');
    await tester.pumpAndSettle();
    await tapVisible(tester, find.widgetWithText(FilledButton, 'Сохранить'));

    final saved = (await entries.entryViews(me.id)).single;
    expect(saved.progressCurrent, 3);
    expect(saved.progressTotal, 12);
    expect(saved.progressUnit, 'серия');
  });

  testWidgets('карточка переключает стадию и пишет прогресс', (tester) async {
    final object = await entries.createObject(
      typeId: series.id,
      title: 'Твин Пикс',
    );
    final entry = await entries.createEntry(
      profileId: me.id,
      objectId: object.id,
      status: EntryStatus.planned,
    );

    await pump(tester, EntryDetailSheet(entryId: entry.id));

    await tapVisible(tester, find.text('Смотрю'));
    await tester.enterText(find.widgetWithText(TextField, 'Пройдено'), '5');
    // Прогресс пишется, когда курсор ушёл из поля: иначе «12» из «120»
    // успевало бы стать отдельной версией записи.
    await tapVisible(tester, find.widgetWithText(TextField, 'Заметка'));

    final saved = (await entries.entryViews(me.id)).single;
    expect(saved.status, EntryStatus.inProgress);
    expect(saved.progressCurrent, 5);
  });

  testWidgets('у типа без стадий форма не показывает пустой ряд', (
    tester,
  ) async {
    // Пользовательский тип стадий не получает: угаданный набор был бы
    // навязанным.
    await entries.createObjectType(me.id, 'Настолки');
    await pump(tester, const QuickAddSheet());

    await tapVisible(tester, find.text('Сериалы'));
    await tapVisible(tester, find.text('Настолки').last);

    expect(find.text('Стадия'), findsNothing);
    expect(find.text('Смотрю'), findsNothing);
  });

  testWidgets('стадия видна на карточке списка, когда мнения ещё нет', (
    tester,
  ) async {
    await pump(
      tester,
      const _Cards(
        planned: EntryCardData(title: 'Твин Пикс', statusLabel: 'Смотрю · 3'),
        rated: EntryCardData(title: 'Фарго', rating: 8),
      ),
    );

    expect(find.text('Смотрю · 3'), findsOneWidget);
  });
}

/// Две карточки рядом: с мнением и без него.
class _Cards extends StatelessWidget {
  const _Cards({required this.planned, required this.rated});

  final EntryCardData planned;
  final EntryCardData rated;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      EntryCardCompact(data: planned),
      EntryCardCompact(data: rated),
    ],
  );
}
