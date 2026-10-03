import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/services/export_service.dart';
import 'package:impressions/features/entry/entry_providers.dart';
import 'package:impressions/features/entry/entry_share_card.dart';

import '../db/test_db.dart';
import 'screens_test.dart' show app;

/// Картинка записи: то, что человек увидит перед тем, как её сохранить.
void main() {
  late AppDatabase db;
  late EntryRepository entries;
  late ProfileRow me;
  late ObjectTypeRow books;

  setUp(() async {
    db = openTestDb();
    entries = EntryRepository(db);
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    books = await entries.createObjectType(me.id, 'Книги');
  });

  tearDown(() => db.close());

  /// Запись и её подробности — настоящим запросом, как на экране.
  ///
  /// Сбор идёт в `setUp`-времени, а не внутри теста: в теле `testWidgets`
  /// время поддельное, и обращение к базе там не доезжает.
  Future<EntryDetail> detailOf({
    String? shortNote,
    String? privacy,
    double? rating,
  }) async {
    final object = await entries.createObject(typeId: books.id, title: 'Дюна');
    final entry = await entries.createEntry(
      profileId: me.id,
      objectId: object.id,
      rating: rating,
      shortNote: shortNote,
    );
    if (privacy != null) {
      await entries.updateEntry(entry.id, privacy: privacy);
    }
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        activeProfileProvider.overrideWithValue(me),
      ],
    );
    addTearDown(container.dispose);
    final detail = await container.read(entryDetailProvider(entry.id).future);
    return detail!;
  }

  Future<void> pumpCard(WidgetTester tester, EntryDetail detail) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activeProfileProvider.overrideWithValue(me),
        ],
        child: app(EntryShareCard(detail: detail)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('на картинке название, оценка и заметка', (tester) async {
    final detail = await detailOf(rating: 9.5, shortNote: 'Лучшее, что читал');
    await pumpCard(tester, detail);

    expect(find.text('Дюна'), findsOneWidget);
    expect(find.text('9.5'), findsOneWidget);
    expect(find.text('Лучшее, что читал'), findsOneWidget);
    // Подпись приложения — чтобы картинка объясняла, откуда она.
    expect(find.text('Впечатления'), findsOneWidget);
  });

  testWidgets('«передавать без заметки» убирает заметку с картинки', (
    tester,
  ) async {
    final detail = await detailOf(
      rating: 9.5,
      shortNote: 'Личное',
      privacy: ExportService.privacyNoNote,
    );
    await pumpCard(tester, detail);

    expect(find.text('Дюна'), findsOneWidget);
    expect(find.text('Личное'), findsNothing);
  });

  testWidgets('кнопка сохранения на месте', (tester) async {
    final detail = await detailOf();
    await pumpCard(tester, detail);

    expect(
      find.widgetWithText(FilledButton, 'Сохранить картинкой'),
      findsOneWidget,
    );
  });
}
