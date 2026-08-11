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

/// Поиск по настройкам.
///
/// Десять разделов подряд и никакого поиска: чтобы найти переключатель, надо
/// было помнить, в каком он разделе, и прокручивать всю ленту.
void main() {
  late AppDatabase db;
  late ProfileRow me;

  setUp(() async {
    db = openTestDb();
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
  });

  tearDown(() => db.close());

  Future<void> openSettings(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

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

  Future<void> search(WidgetTester tester, String query) async {
    await tester.enterText(find.byType(TextField).first, query);
    await tester.pump();
  }

  testWidgets('«копи» оставляет резервные копии и убирает остальное', (
    tester,
  ) async {
    await openSettings(tester);
    expect(find.text('Оформление'), findsOneWidget);

    await search(tester, 'копи');

    expect(find.text('Резервные копии'), findsOneWidget);
    expect(find.text('Оформление'), findsNothing);
    expect(find.text('Теги'), findsNothing);
  });

  testWidgets('ищется и по словам, которых нет в названии', (tester) async {
    await openSettings(tester);

    // «Тёмная» — не название раздела, а то, за чем в него заходят.
    await search(tester, 'темная');

    expect(find.text('Оформление'), findsOneWidget);
    expect(find.text('Резервные копии'), findsNothing);
  });

  testWidgets('ничего не найдено — так и сказано', (tester) async {
    await openSettings(tester);

    await search(tester, 'квазар');

    expect(find.text('Ничего не нашлось'), findsOneWidget);
  });

  testWidgets('пустой запрос возвращает все разделы', (tester) async {
    await openSettings(tester);
    await search(tester, 'копи');
    await search(tester, '');

    // Дальние разделы список строит по мере прокрутки, поэтому проверяем
    // ближние: главное — отбор снят и лента снова целая.
    expect(find.text('Оформление'), findsOneWidget);
    expect(find.text('Резервные копии'), findsOneWidget);
  });
}
