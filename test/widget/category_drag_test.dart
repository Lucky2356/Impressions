import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart' show kLongPressTimeout;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/core/l10n/gen/app_localizations.dart';
import 'package:impressions/core/theme/app_theme.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/category_repository.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/features/categories/categories_screen.dart';
import 'package:impressions/features/categories/category_drag.dart';

import '../db/test_db.dart';

/// Перетаскивание веток и записей.
///
/// До 1.16.0 переместить ветку можно было только через диалог со списком, а
/// порядок менялся пунктами «Выше/Ниже» по шагу. Перетаскивания в приложении
/// не было вовсе.
void main() {
  late AppDatabase db;
  late CategoryRepository cats;
  late EntryRepository entries;
  late ProfileRow me;

  setUp(() async {
    db = openTestDb();
    cats = CategoryRepository(db);
    entries = EntryRepository(db);
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
  });
  tearDown(() => db.close());

  Future<CategoryRow> reload(String id) =>
      (db.select(db.categories)..where((c) => c.id.equals(id))).getSingle();

  Future<void> pumpTree(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
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
          home: const Scaffold(body: CategoriesScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Тянет от одной точки к другой. На Android захват начинается с долгого
  /// нажатия — там короткий протяг это прокрутка списка.
  Future<void> dragFromTo(
    WidgetTester tester,
    Offset from,
    Offset to, {
    bool longPress = true,
  }) async {
    final gesture = await tester.startGesture(from);
    if (longPress) {
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    }
    await gesture.moveTo(to);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
  }

  testWidgets('бросок на ветку перемещает её внутрь', (tester) async {
    final products = await cats.createRoot(me.id, 'Продукты');
    final movies = await cats.createRoot(me.id, 'Фильмы');

    await pumpTree(tester);
    await dragFromTo(
      tester,
      tester.getCenter(find.text('Фильмы')),
      tester.getCenter(find.text('Продукты')),
    );

    expect((await reload(movies.id)).parentId, products.id);
  });

  testWidgets('бросок в собственного потомка отклоняется', (tester) async {
    final root = await cats.createRoot(me.id, 'Продукты');
    final kid = await cats.createChild(root.id, 'Колбасы');

    await pumpTree(tester);
    await dragFromTo(
      tester,
      tester.getCenter(find.text('Продукты')),
      tester.getCenter(find.text('Колбасы')),
    );

    // Дерево не тронуто: цикл не создан и ошибка не показана — зона просто
    // не приняла груз.
    expect((await reload(root.id)).parentId, isNull);
    expect((await reload(kid.id)).parentId, root.id);
  });

  testWidgets('бросок записи меняет её основную категорию', (tester) async {
    final from = await cats.createRoot(me.id, 'Откуда');
    final to = await cats.createRoot(me.id, 'Куда');
    final type = await entries.createObjectType(me.id, 'Продукты');
    final obj = await entries.createObject(typeId: type.id, title: 'Колбаса');
    final entry = await entries.createEntry(
      profileId: me.id,
      objectId: obj.id,
      primaryCategoryId: from.id,
    );

    await pumpTree(tester);
    await tester.tap(find.text('Откуда'));
    await tester.pumpAndSettle();

    await dragFromTo(
      tester,
      tester.getCenter(find.text('Колбаса').first),
      tester.getCenter(find.text('Куда')),
    );

    expect(await entries.primaryCategoryOf(entry.id), to.id);
    // Перенос обратим: без «Вернуть» промах руки стоил бы поиска, куда именно
    // запись уехала.
    expect(find.text('Вернуть'), findsOneWidget);
  });

  testWidgets('на Windows захват начинается без долгого нажатия', (
    tester,
  ) async {
    // Сбрасываем внутри тела теста, а не в tearDown: проверка «все отладочные
    // переключатели выключены» идёт сразу после тела и раньше tearDown.
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;

    final products = await cats.createRoot(me.id, 'Продукты');
    final movies = await cats.createRoot(me.id, 'Фильмы');

    await pumpTree(tester);
    await dragFromTo(
      tester,
      tester.getCenter(find.text('Фильмы')),
      tester.getCenter(find.text('Продукты')),
      longPress: false,
    );
    debugDefaultTargetPlatformOverride = null;

    expect((await reload(movies.id)).parentId, products.id);
  });

  group('что можно принять', () {
    CategoryRow cat(
      String id, {
      String? parentId,
      String? path,
      int level = 0,
    }) => CategoryRow(
      id: id,
      profileId: 'p1',
      parentId: parentId,
      name: id,
      normalizedName: id,
      sortOrder: 0,
      level: level,
      path: path ?? id,
      createdAt: DateTime(2026, 8, 15),
    );

    test('запись ложится только внутрь ветки', () {
      final target = cat('t');
      const payload = EntryDrag(entryId: 'e1', title: 'Запись');
      for (final edge in DropEdge.values) {
        expect(
          canDropOn(
            payload: payload,
            target: target,
            edge: edge,
            all: [target],
            maxDepth: 20,
          ),
          edge == DropEdge.into,
          reason: 'у записи нет порядка среди веток',
        );
      }
    });

    test('глубина считается по всему поддереву, а не по одному узлу', () {
      // Иначе ветку с потомками можно было засунуть так, что нижние листья
      // оказывались за пределом.
      final deep = cat('deep', path: 'deep', level: 19);
      final tall = cat('tall');
      final leaf = cat('leaf', parentId: 'tall', path: 'tall/leaf', level: 1);

      expect(
        canDropOn(
          payload: CategoryDrag(tall),
          target: deep,
          edge: DropEdge.into,
          all: [deep, tall, leaf],
          maxDepth: 20,
        ),
        isFalse,
      );
    });

    test('ветка не принимает саму себя', () {
      final node = cat('n');
      expect(
        canDropOn(
          payload: CategoryDrag(node),
          target: node,
          edge: DropEdge.into,
          all: [node],
          maxDepth: 20,
        ),
        isFalse,
      );
    });
  });
}
