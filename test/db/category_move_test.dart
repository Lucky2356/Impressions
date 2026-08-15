import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/models/category_tree.dart';
import 'package:impressions/data/repositories/category_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';

import 'query_counter.dart';
import 'test_db.dart';

/// Перемещение и порядок веток.
///
/// Раньше перемещение читало потомков и писало каждого отдельным запросом: на
/// ветке в триста узлов это триста с лишним обращений к базе на одно действие.
/// Порядок задавался только шагами «выше/ниже» — перетаскиванию нужен способ
/// положить ветку сразу на нужное место.
void main() {
  late AppDatabase db;
  late CategoryRepository cats;
  late ProfileRepository profiles;

  setUp(() {
    db = openTestDb();
    cats = CategoryRepository(db);
    profiles = ProfileRepository(db);
  });
  tearDown(() => db.close());

  Future<CategoryRow> reload(String id) =>
      (db.select(db.categories)..where((c) => c.id.equals(id))).getSingle();

  test('moveTo с местом ставит ветку между соседями', () async {
    final me = await profiles.createOwnProfile(firstName: 'Порядок');
    final a = await cats.createRoot(me.id, 'А');
    final b = await cats.createRoot(me.id, 'Б');
    final c = await cats.createRoot(me.id, 'В');
    final home = await cats.createRoot(me.id, 'Дом');
    final guest = await cats.createChild(home.id, 'Гость');

    await cats.moveTo(guest.id, index: 1);

    final roots = await cats.roots(me.id);
    expect(
      [for (final r in roots) r.name],
      ['А', 'Гость', 'Б', 'В', 'Дом'],
      reason: 'ветка встала на указанное место, остальные — по порядку',
    );
    expect([a.id, b.id, c.id], everyElement(isNotEmpty));
  });

  test('без указания места ветка встаёт последней у нового родителя', () async {
    // Прежний sortOrder относился к другому ряду соседей: сохранив его, ветка
    // прыгнула бы в начало нового списка.
    final me = await profiles.createOwnProfile(firstName: 'Последней');
    final from = await cats.createRoot(me.id, 'Откуда');
    final to = await cats.createRoot(me.id, 'Куда');
    await cats.createChild(to.id, 'Первый');
    await cats.createChild(to.id, 'Второй');
    final moved = await cats.createChild(from.id, 'Переехавший');

    await cats.move(moved.id, to.id);

    final kids = await cats.children(to.id);
    expect([for (final k in kids) k.name], ['Первый', 'Второй', 'Переехавший']);
  });

  test('поддерево пересчитывается одним запросом', () async {
    final (counting, counter) = openCountingDb();
    addTearDown(counting.close);
    final repo = CategoryRepository(counting);
    final me = await ProfileRepository(
      counting,
    ).createOwnProfile(firstName: 'Много детей');

    final root = await repo.createRoot(me.id, 'Корень');
    final branch = await repo.createChild(root.id, 'Ветка');
    for (var i = 0; i < 40; i++) {
      final mid = await repo.createChild(branch.id, 'Узел $i');
      await repo.createChild(mid.id, 'Лист $i');
    }
    final target = await repo.createRoot(me.id, 'Новое место');

    counter.reset();
    await repo.move(branch.id, target.id);

    expect(
      counter.matching('substr(path'),
      1,
      reason: 'все 80 потомков переписываются одним оператором',
    );
    // Проверка не про «мало запросов вообще», а про то, что их число не
    // растёт вместе с веткой.
    expect(counter.statements, lessThan(12));

    final leaf = await (counting.select(
      counting.categories,
    )..where((c) => c.name.equals('Лист 7'))).getSingle();
    expect(leaf.level, 3);
    expect(CategoryTree.pathIds(leaf.path).first, target.id);
  });

  test('перемещение не роняет глубину ветки за предел', () async {
    // Раньше проверялся только сам узел: ветку с потомками можно было
    // засунуть так, что нижние листья оказывались за пределом.
    final me = await profiles.createOwnProfile(firstName: 'Глубина');
    var deep = await cats.createRoot(me.id, 'Глубокая');
    for (var i = 0; i < 19; i++) {
      deep = await cats.createChild(deep.id, 'Уровень $i');
    }
    final tall = await cats.createRoot(me.id, 'Высокая');
    final mid = await cats.createChild(tall.id, 'Середина');
    await cats.createChild(mid.id, 'Низ');

    expect(
      () => cats.move(tall.id, deep.id),
      throwsA(isA<CategoryTreeException>()),
    );
    expect(
      (await reload(tall.id)).parentId,
      isNull,
      reason: 'дерево не тронуто',
    );
  });

  test(
    'moveMany не двигает то, что уже переехало вместе с родителем',
    () async {
      final me = await profiles.createOwnProfile(firstName: 'Пачкой');
      final source = await cats.createRoot(me.id, 'Источник');
      final parent = await cats.createChild(source.id, 'Родитель');
      final child = await cats.createChild(parent.id, 'Ребёнок');
      final loner = await cats.createChild(source.id, 'Одиночка');
      final target = await cats.createRoot(me.id, 'Цель');

      final moved = await cats.moveMany([
        child.id,
        parent.id,
        loner.id,
      ], target.id);

      expect(moved, 2, reason: 'ребёнок уехал внутри родителя');
      expect((await reload(child.id)).parentId, parent.id);
      expect((await reload(parent.id)).parentId, target.id);
      expect((await reload(loner.id)).parentId, target.id);
      expect(
        CategoryTree.pathIds((await reload(child.id)).path).first,
        target.id,
      );
    },
  );

  test('порядок соседей пишется пачкой, а не запросом на каждого', () async {
    final (counting, counter) = openCountingDb();
    addTearDown(counting.close);
    final repo = CategoryRepository(counting);
    final me = await ProfileRepository(
      counting,
    ).createOwnProfile(firstName: 'Пачка');
    final ids = [
      for (var i = 0; i < 10; i++) (await repo.createRoot(me.id, 'К$i')).id,
    ];

    counter.reset();
    await repo.reorderSiblings(ids.reversed.toList());

    expect(counter.statements, 0);
    expect(counter.batched, 10);

    final roots = await repo.roots(me.id);
    expect([for (final r in roots) r.name].first, 'К9');
  });
}
