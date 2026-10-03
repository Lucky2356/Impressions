import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/features/quick_add/quick_add_sheet.dart';

import '../db/test_db.dart';
import 'screens_test.dart' show app;

void main() {
  late AppDatabase db;
  late ProfileRow me;

  /// Что лежит в буфере обмена. `null` — буфер пуст.
  String? clipboard;

  setUp(() async {
    db = openTestDb();
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    await EntryRepository(db).createObjectType(me.id, 'Книги');

    clipboard = null;
    // Буфер обмена живёт на платформе, которой в тесте нет: канал отвечает
    // сам.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method != 'Clipboard.getData') return null;
          return clipboard == null ? null : {'text': clipboard};
        });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
    await db.close();
  });

  Future<void> openSheet(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activeProfileProvider.overrideWithValue(me),
        ],
        child: app(const QuickAddSheet()),
      ),
    );
    await tester.pumpAndSettle();
  }

  final offer = find.textContaining('Вставить: ');

  testWidgets('название из буфера предлагается вставить', (tester) async {
    clipboard = 'Дюна';
    await openSheet(tester);

    expect(offer, findsOneWidget);
    // Предлагаемое видно до вставки целиком: в буфере может лежать что
    // угодно, вплоть до пароля.
    expect(find.text('Вставить: Дюна'), findsOneWidget);
  });

  testWidgets('вставка переносит название в поле', (tester) async {
    clipboard = '«Дюна»\nФрэнк Герберт';
    await openSheet(tester);

    await tester.tap(offer);
    await tester.pumpAndSettle();

    final field = tester.widget<TextFormField>(
      find.byType(TextFormField).first,
    );
    expect(field.controller?.text, 'Дюна');
    // Предложение уходит: поле больше не пустое, и затирать набранное
    // кнопке нечем.
    expect(offer, findsNothing);
  });

  testWidgets('набранное вручную прячет предложение', (tester) async {
    clipboard = 'Дюна';
    await openSheet(tester);

    await tester.enterText(find.byType(TextFormField).first, 'Хлеб');
    await tester.pumpAndSettle();

    expect(offer, findsNothing);
  });

  testWidgets('пустой буфер ничего не предлагает', (tester) async {
    await openSheet(tester);

    expect(offer, findsNothing);
  });

  testWidgets('ссылка в буфере ничего не предлагает', (tester) async {
    clipboard = 'https://openlibrary.org/works/OL893415W';
    await openSheet(tester);

    expect(offer, findsNothing);
  });
}
