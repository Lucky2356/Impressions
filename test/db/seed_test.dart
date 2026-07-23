import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/repositories/category_repository.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/services/seed_service.dart';

import 'test_db.dart';

void main() {
  test('стартовый набор создаёт типы и корневые категории (§8)', () async {
    final db = openTestDb();
    addTearDown(db.close);

    final me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    await SeedService(db).seedForProfile(me.id);

    final types = await EntryRepository(db).objectTypes(me.id);
    expect(types.length, SeedService.starterTypes.length);
    expect(types.map((t) => t.name), contains('Продукты'));
    expect(types.every((t) => t.builtIn), isTrue);

    final roots = await CategoryRepository(db).roots(me.id);
    expect(roots.map((c) => c.name), contains('Продукты'));
    expect(roots.map((c) => c.name), contains('Фильмы'));
  });

  test('стартовые подкатегории создаются и от них можно отказаться', () async {
    final db = openTestDb();
    addTearDown(db.close);
    final cats = CategoryRepository(db);
    final profiles = ProfileRepository(db);

    final withSubs = await profiles.createOwnProfile(firstName: 'С');
    await SeedService(
      db,
    ).seedForProfile(withSubs.id, withStarterSubcategories: true);
    final productsWith = (await cats.roots(
      withSubs.id,
    )).firstWhere((c) => c.name == 'Продукты');
    final children = await cats.children(productsWith.id);
    expect(children.map((c) => c.name), contains('Колбасы'));

    final withoutSubs = await profiles.createOwnProfile(firstName: 'Б');
    await SeedService(
      db,
    ).seedForProfile(withoutSubs.id, withStarterSubcategories: false);
    final productsWithout = (await cats.roots(
      withoutSubs.id,
    )).firstWhere((c) => c.name == 'Продукты');
    expect(await cats.children(productsWithout.id), isEmpty);
  });

  test('путь Продукты / Колбасы / Папа может строится корректно', () async {
    final db = openTestDb();
    addTearDown(db.close);
    final cats = CategoryRepository(db);
    final entries = EntryRepository(db);

    final me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    await SeedService(db).seedForProfile(me.id);

    final products = (await cats.roots(
      me.id,
    )).firstWhere((c) => c.name == 'Продукты');
    final sausages = (await cats.children(
      products.id,
    )).firstWhere((c) => c.name == 'Колбасы');

    final type = (await entries.objectTypes(
      me.id,
    )).firstWhere((t) => t.name == 'Продукты');
    final obj = await entries.createObject(
      typeId: type.id,
      title: 'Папа может',
    );
    await entries.createEntry(
      profileId: me.id,
      objectId: obj.id,
      primaryCategoryId: sausages.id,
      relation: 'like',
    );

    final crumbs = await cats.breadcrumb(sausages.id);
    final path = [...crumbs.map((c) => c.name), obj.title].join(' / ');
    expect(path, 'Продукты / Колбасы / Папа может');
  });
}
