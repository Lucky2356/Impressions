import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/repositories/category_repository.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';

import 'test_db.dart';

void main() {
  late final db = openTestDb();
  late final profiles = ProfileRepository(db);
  late final cats = CategoryRepository(db);
  late final entries = EntryRepository(db);

  tearDownAll(() => db.close());

  test(
    'создание корня, подкатегории и под-подкатегории: path и level',
    () async {
      final me = await profiles.createOwnProfile(firstName: 'Я');
      final products = await cats.createRoot(me.id, 'Продукты');
      final sausages = await cats.createChild(products.id, 'Колбасы');
      final boiled = await cats.createChild(sausages.id, 'Варёные');

      expect(products.level, 0);
      expect(products.path, products.id);
      expect(sausages.level, 1);
      expect(sausages.path, '${products.id}/${sausages.id}');
      expect(boiled.level, 2);
      expect(boiled.path, '${products.id}/${sausages.id}/${boiled.id}');
    },
  );

  test('хлебные крошки строят путь Продукты / Колбасы', () async {
    final me = await profiles.createOwnProfile(firstName: 'Крошки');
    final products = await cats.createRoot(me.id, 'Продукты');
    final sausages = await cats.createChild(products.id, 'Колбасы');

    final crumbs = await cats.breadcrumb(sausages.id);
    expect(crumbs.map((c) => c.name).toList(), ['Продукты', 'Колбасы']);
  });

  test('запрет: категория не может быть своим родителем', () async {
    final me = await profiles.createOwnProfile(firstName: 'Цикл1');
    final a = await cats.createRoot(me.id, 'A');
    expect(() => cats.move(a.id, a.id), throwsA(isA<CategoryTreeException>()));
  });

  test('запрет: перемещение родителя внутрь своего потомка (цикл)', () async {
    final me = await profiles.createOwnProfile(firstName: 'Цикл2');
    final a = await cats.createRoot(me.id, 'A');
    final b = await cats.createChild(a.id, 'B');
    final c = await cats.createChild(b.id, 'C');
    expect(() => cats.move(a.id, c.id), throwsA(isA<CategoryTreeException>()));
  });

  test('перемещение ветки обновляет path/level потомков', () async {
    final me = await profiles.createOwnProfile(firstName: 'Перенос');
    final root1 = await cats.createRoot(me.id, 'Корень1');
    final root2 = await cats.createRoot(me.id, 'Корень2');
    final b = await cats.createChild(root1.id, 'B');
    final c = await cats.createChild(b.id, 'C');

    await cats.move(b.id, root2.id);

    final movedB = (await cats.byId(b.id))!;
    final movedC = (await cats.byId(c.id))!;
    expect(movedB.parentId, root2.id);
    expect(movedB.level, 1);
    expect(movedB.path, '${root2.id}/${b.id}');
    expect(movedC.level, 2);
    expect(movedC.path, '${root2.id}/${b.id}/${c.id}');
  });

  test('перемещение в корень: level=0, path=id', () async {
    final me = await profiles.createOwnProfile(firstName: 'ВКорень');
    final a = await cats.createRoot(me.id, 'A');
    final b = await cats.createChild(a.id, 'B');
    await cats.move(b.id, null);
    final movedB = (await cats.byId(b.id))!;
    expect(movedB.level, 0);
    expect(movedB.parentId, isNull);
    expect(movedB.path, b.id);
  });

  test('перемещение не теряет записи (§7.1)', () async {
    final me = await profiles.createOwnProfile(firstName: 'НеТеряем');
    final type = await entries.createObjectType(me.id, 'Продукты');
    final root1 = await cats.createRoot(me.id, 'Корень1');
    final root2 = await cats.createRoot(me.id, 'Корень2');
    final sub = await cats.createChild(root1.id, 'Под');
    final obj = await entries.createObject(
      typeId: type.id,
      title: 'Папа может',
    );
    await entries.createEntry(
      profileId: me.id,
      objectId: obj.id,
      primaryCategoryId: sub.id,
    );

    expect(await cats.countEntriesInBranch(sub.id), 1);
    await cats.move(sub.id, root2.id);
    expect(await cats.countEntriesInBranch(sub.id), 1);
  });

  test('подсчёт записей в ветке с подкатегориями и без', () async {
    final me = await profiles.createOwnProfile(firstName: 'Счёт');
    final type = await entries.createObjectType(me.id, 'Продукты');
    final products = await cats.createRoot(me.id, 'Продукты');
    final sausages = await cats.createChild(products.id, 'Колбасы');

    final o1 = await entries.createObject(typeId: type.id, title: 'Объект1');
    final o2 = await entries.createObject(typeId: type.id, title: 'Объект2');
    await entries.createEntry(
      profileId: me.id,
      objectId: o1.id,
      primaryCategoryId: products.id,
    );
    await entries.createEntry(
      profileId: me.id,
      objectId: o2.id,
      primaryCategoryId: sausages.id,
    );

    expect(
      await cats.countEntriesInBranch(products.id, includeSubcategories: false),
      1,
    );
    expect(
      await cats.countEntriesInBranch(products.id, includeSubcategories: true),
      2,
    );
  });

  test('архивирование и восстановление категории с поддеревом', () async {
    final me = await profiles.createOwnProfile(firstName: 'Архив');
    final a = await cats.createRoot(me.id, 'A');
    final b = await cats.createChild(a.id, 'B');

    await cats.archive(a.id);
    expect((await cats.byId(a.id))!.archivedAt, isNotNull);
    expect((await cats.byId(b.id))!.archivedAt, isNotNull);

    await cats.restore(a.id);
    expect((await cats.byId(a.id))!.archivedAt, isNull);
  });

  test('изоляция категорий между профилями (§7.3)', () async {
    final me = await profiles.createOwnProfile(firstName: 'П1');
    final other = await profiles.createOwnProfile(firstName: 'П2');
    await cats.createRoot(me.id, 'Только у П1');

    final rootsMe = await cats.roots(me.id);
    final rootsOther = await cats.roots(other.id);
    expect(rootsMe.length, 1);
    expect(rootsOther, isEmpty);
  });

  test('потомки и предки', () async {
    final me = await profiles.createOwnProfile(firstName: 'ПотомкиПредки');
    final a = await cats.createRoot(me.id, 'A');
    final b = await cats.createChild(a.id, 'B');
    final c = await cats.createChild(b.id, 'C');

    final descs = await cats.descendants(a);
    expect(descs.map((e) => e.id).toSet(), {b.id, c.id});

    final anc = await cats.ancestors(c);
    expect(anc.map((e) => e.name).toList(), ['A', 'B']);
  });
}
