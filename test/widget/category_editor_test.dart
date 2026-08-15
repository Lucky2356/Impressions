import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/core/domain/app_icons.dart';
import 'package:impressions/core/l10n/gen/app_localizations.dart';
import 'package:impressions/core/theme/app_theme.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/category_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/features/categories/category_editor_sheet.dart';

import '../db/test_db.dart';

/// Оформление ветки.
///
/// До 1.16.0 у категории редактировались только имя и значок: цвет вычислялся
/// сам, а описание в базе было и не показывалось.
void main() {
  late AppDatabase db;
  late CategoryRepository cats;
  late ProfileRow me;

  setUp(() async {
    db = openTestDb();
    cats = CategoryRepository(db);
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
  });
  tearDown(() => db.close());

  Future<CategoryRow> reload(String id) =>
      (db.select(db.categories)..where((c) => c.id.equals(id))).getSingle();

  Future<void> open(WidgetTester tester, CategoryRow category) async {
    tester.view.physicalSize = const Size(900, 1000);
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
          // Через тот же вход, что и в приложении: редактор закрывает себя
          // сам, и без своего маршрута закрывать было бы нечего.
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => CategoryEditorSheet.show(context, category),
                child: const Text('открыть'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('открыть'));
    await tester.pumpAndSettle();
  }

  testWidgets('«как у родителя» записывает пустой цвет', (tester) async {
    final root = await cats.createRoot(me.id, 'Продукты', color: 0xFF112233);
    final kid = await cats.createChild(root.id, 'Колбасы', color: 0xFF445566);

    await open(tester, kid);
    await tester.tap(find.text('Как у родителя'));
    await tester.pump();
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    // Пустое поле — это и есть «как у родителя»: своего цвета у ветки нет.
    expect((await reload(kid.id)).color, isNull);
  });

  testWidgets('описание сохраняется и стирается', (tester) async {
    final root = await cats.createRoot(me.id, 'Продукты');

    await open(tester, root);
    await tester.enterText(
      find.byKey(const Key('category-description')),
      'Что тут лежит',
    );
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();
    expect((await reload(root.id)).description, 'Что тут лежит');

    await open(tester, await reload(root.id));
    await tester.enterText(find.byKey(const Key('category-description')), '');
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    // Пустое описание должно стираться, а не оставаться прежним: раньше null
    // означал и «не трогать», и «убрать».
    expect((await reload(root.id)).description, isNull);
  });

  testWidgets('значок находится поиском', (tester) async {
    final root = await cats.createRoot(me.id, 'Продукты');

    await open(tester, root);
    await tester.tap(find.text('Значок категории'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'колбас');
    await tester.pumpAndSettle();

    // Раньше значки лежали одной кучей без подписей и без поиска.
    expect(find.byIcon(AppIcons.byKey('sausage')), findsOneWidget);
    expect(find.byIcon(AppIcons.byKey('movie')), findsNothing);

    await tester.tap(find.byIcon(AppIcons.byKey('sausage')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    expect((await reload(root.id)).icon, 'sausage');
  });

  testWidgets('имя правится там же, где всё остальное', (tester) async {
    final root = await cats.createRoot(me.id, 'Продукты');

    await open(tester, root);
    await tester.enterText(find.byKey(const Key('category-name')), 'Еда');
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    final saved = await reload(root.id);
    expect(saved.name, 'Еда');
    expect(saved.normalizedName, 'еда');
  });
}
