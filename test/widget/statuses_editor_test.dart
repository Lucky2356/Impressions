import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/core/domain/entry_status.dart';
import 'package:impressions/core/l10n/gen/app_localizations.dart';
import 'package:impressions/core/theme/app_theme.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/features/settings/statuses_editor.dart';

import '../db/test_db.dart';

/// Редактор стадий типа (§10).
///
/// Столбец `profile_entries.status` был в базе с самого начала и не читался ни
/// одним экраном: стадию изображало отношение «Хочу попробовать».
void main() {
  late AppDatabase db;
  late EntryRepository entries;
  late ProfileRow me;

  setUp(() async {
    db = openTestDb();
    entries = EntryRepository(db);
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
  });
  tearDown(() => db.close());

  Future<ObjectTypeRow> reload(String id) =>
      (db.select(db.objectTypes)..where((t) => t.id.equals(id))).getSingle();

  Future<void> open(WidgetTester tester, ObjectTypeRow type) async {
    tester.view.physicalSize = const Size(900, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activeProfileProvider.overrideWithValue(me),
          profilesProvider.overrideWith((ref) => Stream.value([me])),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ru'),
          theme: AppTheme.light(),
          home: Scaffold(body: StatusesEditor(type: type)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('стадии встроенного типа видны и переименовываются', (
    tester,
  ) async {
    final books = await entries.createObjectType(
      me.id,
      'Книги',
      statusesJson: EntryStatus.encode(
        BuiltInStatuses.forTypeName('Книги')!.statuses,
      ),
      progressUnit: 'страница',
    );

    await open(tester, books);
    expect(find.text('Читаю'), findsOneWidget);

    await tester.tap(find.byTooltip('Переименовать стадию').at(1));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'В процессе чтения');
    await tester.tap(find.widgetWithText(FilledButton, 'Сохранить').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Сохранить'));
    await tester.pumpAndSettle();

    final saved = EntryStatus.decode((await reload(books.id)).statusesJson);
    expect(
      saved.map((s) => s.name),
      contains('В процессе чтения'),
      reason: 'название стадии у каждого типа своё',
    );
    // Ключи при этом не трогаются: по ним работает отбор во всех типах сразу.
    expect(saved.map((s) => s.key), [
      EntryStatus.planned,
      EntryStatus.inProgress,
      EntryStatus.doneKey,
    ]);
  });

  testWidgets('стадию можно убрать', (tester) async {
    final films = await entries.createObjectType(
      me.id,
      'Фильмы',
      statusesJson: EntryStatus.encode(
        BuiltInStatuses.forTypeName('Фильмы')!.statuses,
      ),
    );

    await open(tester, films);
    await tester.tap(find.byTooltip('Убрать стадию').at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Сохранить'));
    await tester.pumpAndSettle();

    final saved = EntryStatus.decode((await reload(films.id)).statusesJson);
    expect(saved.map((s) => s.key), [EntryStatus.planned, EntryStatus.doneKey]);
  });

  testWidgets('пользовательский тип начинает без стадий и получает их', (
    tester,
  ) async {
    // Угаданный набор был бы навязанным: «Настолки» — не книги и не фильмы.
    final custom = await entries.createObjectType(me.id, 'Настолки');

    await open(tester, custom);
    expect(find.textContaining('стадий нет'), findsOneWidget);

    await tester.tap(find.text('Добавить стадию'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Хочу сыграть');
    await tester.tap(find.widgetWithText(FilledButton, 'Сохранить').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Сохранить'));
    await tester.pumpAndSettle();

    final saved = EntryStatus.decode((await reload(custom.id)).statusesJson);
    expect(saved.single.key, EntryStatus.planned);
    expect(saved.single.name, 'Хочу сыграть');
  });

  testWidgets('единица прогресса сохраняется и стирается', (tester) async {
    final series = await entries.createObjectType(
      me.id,
      'Сериалы',
      statusesJson: EntryStatus.encode(
        BuiltInStatuses.forTypeName('Сериалы')!.statuses,
      ),
      progressUnit: 'серия',
    );

    await open(tester, series);
    await tester.enterText(find.widgetWithText(TextField, 'серия'), '');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Сохранить'));
    await tester.pumpAndSettle();

    // Пустое поле значит «считать нечего», а не «оставить как было».
    expect((await reload(series.id)).progressUnit, isNull);
  });
}
