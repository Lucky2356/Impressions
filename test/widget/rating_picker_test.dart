import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/design_system/design_system.dart';
import 'package:impressions/features/quick_add/quick_add_sheet.dart';

import '../db/test_db.dart';
import 'screens_test.dart' show app;

/// Оценка одним касанием.
///
/// Ставилась только ползунком: двадцать делений на всю ширину, на телефоне
/// одно деление — около двадцати точек, палец перекрывает шкалу, и попасть в
/// нужный балл с первого раза не выходит.
void main() {
  late AppDatabase db;
  late EntryRepository entries;
  late ProfileRow me;

  setUp(() async {
    db = openTestDb();
    entries = EntryRepository(db);
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    await entries.createObjectType(me.id, 'Продукты');
  });

  tearDown(() => db.close());

  testWidgets('в диалоге оценки нажатие на «8» ставит 8,0', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    double? saved;
    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              saved = await RatingDialog.show(context, title: 'Папа может');
            },
            child: const Text('оценить'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('оценить'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(InkWell, '8'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Сохранить'));
    await tester.pumpAndSettle();

    expect(saved, 8.0);
  });

  testWidgets('в форме добавления нажатие на «8» ставит 8,0', (tester) async {
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

    await tester.enterText(find.byType(TextFormField).first, 'Молоко');
    final eight = find.widgetWithText(InkWell, '8');
    await tester.ensureVisible(eight);
    await tester.pumpAndSettle();
    await tester.tap(eight);
    await tester.pumpAndSettle();

    // Оценка видна сразу, до сохранения: рядом со шкалой стоит выбранное.
    expect(find.text('8.0'), findsOneWidget);

    final save = find.widgetWithText(FilledButton, 'Сохранить');
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();

    final list = await entries.entryViews(me.id);
    expect(list.single.rating, 8.0);
  });

  testWidgets('ползунок остаётся: половинки ставятся им', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    double? value = 7;
    await tester.pumpWidget(
      app(
        StatefulBuilder(
          builder: (context, setState) => RatingPicker(
            value: value,
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Slider), findsOneWidget);
    await tester.tap(find.widgetWithText(InkWell, '3'));
    await tester.pumpAndSettle();

    expect(value, 3.0);
  });
}
