import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/features/settings/settings_screen.dart';

import '../db/test_db.dart';
import 'screens_test.dart' show app;

/// Настройки: список разделов и поиск по нему.
///
/// До 1.18.0 все двенадцать разделов лежали в одной ленте раскрытыми, и путь к
/// «Типам объектов» шёл через резервные копии и товарные базы целиком. Поиск
/// помогал только тому, кто уже знает нужное слово.
void main() {
  late AppDatabase db;
  late ProfileRow me;

  setUp(() async {
    db = openTestDb();
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
  });

  tearDown(() => db.close());

  Future<void> openSettings(WidgetTester tester, {required Size size}) async {
    // Через view, а не setSurfaceSize: MediaQuery берёт размер отсюда, и от
    // него зависит, какая раскладка — список или список с разделом рядом.
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activeProfileProvider.overrideWithValue(me),
        ],
        child: app(const SettingsScreen()),
      ),
    );
    await tester.pump();
  }

  Future<void> openPhone(WidgetTester tester) =>
      openSettings(tester, size: const Size(400, 860));

  Future<void> openDesktop(WidgetTester tester) =>
      openSettings(tester, size: const Size(1280, 1000));

  Future<void> search(WidgetTester tester, String query) async {
    await tester.enterText(find.byType(TextField).first, query);
    await tester.pump();
  }

  testWidgets('«копи» оставляет резервные копии и убирает остальное', (
    tester,
  ) async {
    await openPhone(tester);
    expect(find.text('Оформление'), findsOneWidget);

    await search(tester, 'копи');

    expect(find.text('Резервные копии'), findsOneWidget);
    expect(find.text('Оформление'), findsNothing);
    expect(find.text('Теги'), findsNothing);
  });

  testWidgets('ищется и по словам, которых нет в названии', (tester) async {
    await openPhone(tester);

    // «Тёмная» — не название раздела, а то, за чем в него заходят.
    await search(tester, 'темная');

    expect(find.text('Оформление'), findsOneWidget);
    expect(find.text('Резервные копии'), findsNothing);
  });

  testWidgets('ничего не найдено — так и сказано', (tester) async {
    await openPhone(tester);

    await search(tester, 'квазар');

    expect(find.text('Ничего не нашлось'), findsOneWidget);
  });

  testWidgets('пустой запрос возвращает все разделы', (tester) async {
    await openPhone(tester);
    await search(tester, 'копи');
    await search(tester, '');

    expect(find.text('Оформление'), findsOneWidget);
    expect(find.text('Резервные копии'), findsOneWidget);
  });

  testWidgets('на телефоне раздел открывается вместо списка', (tester) async {
    await openPhone(tester);

    // Список — это только названия и подписи: содержимого разделов на нём нет,
    // и прокручивать до нужного нечего.
    expect(find.text('Тема'), findsNothing);

    await tester.tap(find.text('Оформление'));
    await tester.pumpAndSettle();

    expect(find.text('Тема'), findsOneWidget);
    // Соседние разделы ушли с экрана целиком.
    expect(find.text('Резервные копии'), findsNothing);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Резервные копии'), findsOneWidget);
    expect(find.text('Тема'), findsNothing);
  });

  testWidgets('на широком экране список и раздел видны сразу', (tester) async {
    await openDesktop(tester);

    // Пока раздел не выбран, справа сказано, что делать.
    expect(find.text('Выберите раздел'), findsOneWidget);

    await tester.tap(find.text('Оформление'));
    await tester.pumpAndSettle();

    // Список никуда не делся: возврата к нему на широком экране не требуется.
    expect(find.text('Резервные копии'), findsOneWidget);
    expect(find.text('Тема'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);
  });
}
