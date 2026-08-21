import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/core/domain/hotkeys.dart';
import 'package:impressions/core/l10n/gen/app_localizations.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/category_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/design_system/design_system.dart';
import 'package:impressions/features/search/command_palette.dart';

import '../db/test_db.dart';
import 'screens_test.dart' show app;

/// Клавиатура делает то, что обещает справка.
///
/// До 1.21.0 Enter в самом частом диалоге приложения не делал ничего, Escape
/// не закрывал нижние листы, а по палитре команд водила только мышь — при том
/// что открывают её с клавиатуры.
void main() {
  late AppDatabase db;
  late ProfileRow me;

  setUp(() async {
    db = openTestDb();
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    await CategoryRepository(db).createRoot(me.id, 'Колбасы');
  });

  tearDown(() => db.close());

  Future<void> press(WidgetTester tester, LogicalKeyboardKey key) async {
    await tester.sendKeyEvent(key);
    await tester.pumpAndSettle();
  }

  testWidgets('Enter подтверждает обычный диалог', (tester) async {
    bool? answer;
    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              answer = await ConfirmDialog.show(context, title: 'Сохранить?');
            },
            child: const Text('открыть'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('открыть'));
    await tester.pumpAndSettle();

    await press(tester, LogicalKeyboardKey.enter);
    expect(answer, isTrue);
  });

  testWidgets('Enter не подтверждает необратимое', (tester) async {
    bool? answer;
    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              answer = await ConfirmDialog.show(
                context,
                title: 'Удалить навсегда?',
                destructive: true,
              );
            },
            child: const Text('открыть'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('открыть'));
    await tester.pumpAndSettle();

    await press(tester, LogicalKeyboardKey.enter);
    expect(
      answer,
      isFalse,
      reason: 'у необратимого действия фокус стоит на «Отмене»',
    );
  });

  testWidgets('Escape закрывает нижний лист', (tester) async {
    // Узкое окно: широкое показало бы диалог, а его Escape закрывает и без нас.
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showAdaptiveSheet<void>(
              context,
              builder: (_) => const SizedBox(
                height: 200,
                child: Center(child: Text('содержимое листа')),
              ),
            ),
            child: const Text('открыть'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('открыть'));
    await tester.pumpAndSettle();
    expect(find.text('содержимое листа'), findsOneWidget);

    await press(tester, LogicalKeyboardKey.escape);
    expect(find.text('содержимое листа'), findsNothing);
  });

  testWidgets('перехват Escape не отбирает фокус у поля листа', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final focus = FocusNode();
    addTearDown(focus.dispose);

    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showAdaptiveSheet<void>(
              context,
              builder: (_) => SizedBox(
                height: 200,
                child: TextField(focusNode: focus, autofocus: true),
              ),
            ),
            child: const Text('открыть'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('открыть'));
    await tester.pumpAndSettle();

    expect(
      focus.hasFocus,
      isTrue,
      reason: 'форма записи открывается с курсором в названии — так и остаётся',
    );
  });

  testWidgets('по палитре команд можно ходить стрелками', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activeProfileProvider.overrideWithValue(me),
        ],
        child: app(const SizedBox(height: 520, child: CommandPalette())),
      ),
    );
    await tester.pumpAndSettle();

    ListTile selected() => tester
        .widgetList<ListTile>(find.byType(ListTile))
        .firstWhere((t) => t.selected);

    final first = (selected().title! as Text).data;
    await press(tester, LogicalKeyboardKey.arrowDown);
    final second = (selected().title! as Text).data;

    expect(second, isNot(first), reason: 'стрелка переводит на другую строку');

    await press(tester, LogicalKeyboardKey.arrowUp);
    expect((selected().title! as Text).data, first);
  });

  test('справка обещает только то, что работает', () {
    // Список показывается человеку, и однажды он уже разошёлся с кодом:
    // Ctrl + E вёл в «Профили», то есть делал то же, что Ctrl + P.
    final keys = appHotkeys(_ru).map((h) => h.keys).toList();
    expect(
      keys.toSet().length,
      keys.length,
      reason: 'сочетания не дублируются',
    );
  });
}

/// Локализация без BuildContext — списку горячих клавиш нужны только подписи.
final _ru = lookupAppLocalizations(const Locale('ru'));
