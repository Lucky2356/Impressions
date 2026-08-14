import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/repositories/category_repository.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/entry_stats.dart';
import 'package:impressions/data/repositories/profile_repository.dart';

import 'test_db.dart';

void main() {
  late final db = openTestDb();
  late final profiles = ProfileRepository(db);
  late final cats = CategoryRepository(db);
  late final entries = EntryRepository(db);

  tearDownAll(() => db.close());

  Future<({String profileId, String typeId})> setup(String name) async {
    final me = await profiles.createOwnProfile(firstName: name);
    final type = await entries.createObjectType(me.id, 'Продукты');
    return (profileId: me.id, typeId: type.id);
  }

  Future<String> addEntry(
    ({String profileId, String typeId}) env,
    String title, {
    double? rating,
    String? relation,
    String? note,
    String? categoryId,
  }) async {
    final object = await entries.createObject(typeId: env.typeId, title: title);
    final entry = await entries.createEntry(
      profileId: env.profileId,
      objectId: object.id,
      rating: rating,
      relation: relation,
      detailedNote: note,
      primaryCategoryId: categoryId,
    );
    return entry.id;
  }

  group('Статистика профиля', () {
    test('пустой профиль отдаёт пустую статистику', () async {
      final env = await setup('Пусто');
      final data = await entries.insights(env.profileId);
      expect(data.isEmpty, isTrue);
      expect(data.averageRating, isNull);
    });

    test('считает среднюю оценку только по оценённым', () async {
      final env = await setup('Средняя');
      await addEntry(env, 'Раз', rating: 8);
      await addEntry(env, 'Два', rating: 6);
      await addEntry(env, 'Без оценки');

      final data = await entries.insights(env.profileId);
      expect(data.total, 3);
      expect(data.rated, 2);
      expect(data.averageRating, 7);
    });

    test('раскладывает оценки по корзинам, десятка идёт в последнюю', () async {
      final env = await setup('Корзины');
      await addEntry(env, 'Ноль', rating: 0.5);
      await addEntry(env, 'Пять', rating: 5.5);
      await addEntry(env, 'Десять', rating: 10);

      final data = await entries.insights(env.profileId);
      expect(data.ratingBuckets, hasLength(10));
      expect(data.ratingBuckets[0], 1);
      expect(data.ratingBuckets[5], 1);
      // 10 не должна выпасть за пределы массива.
      expect(data.ratingBuckets[9], 1);
    });

    test('считает отношения и заметки', () async {
      final env = await setup('Отношения');
      await addEntry(env, 'Раз', relation: 'love', note: 'отличная вещь');
      await addEntry(env, 'Два', relation: 'love');
      await addEntry(env, 'Три', relation: 'avoid');

      final data = await entries.insights(env.profileId);
      expect(data.byRelation['love'], 2);
      expect(data.byRelation['avoid'], 1);
      expect(data.withNotes, 1);
    });

    test('категории считаются по ветке, а не только по своему уровню', () async {
      final env = await setup('Ветки');
      final root = await cats.createRoot(env.profileId, 'Продукты');
      final child = await cats.createChild(root.id, 'Колбасы');

      await addEntry(env, 'Раз', categoryId: child.id);
      await addEntry(env, 'Два', categoryId: child.id);

      final data = await entries.insights(env.profileId);
      final byName = {for (final c in data.topCategories) c.name: c.count};
      // Корень не должен выглядеть пустым, если записи лежат в его подкатегории.
      expect(byName['Продукты'], 2);
      expect(byName['Колбасы'], 2);
    });

    test('архивные записи в статистику не попадают', () async {
      final env = await setup('Архив-статистика');
      final id = await addEntry(env, 'Убранная', rating: 9);
      await addEntry(env, 'Оставшаяся', rating: 5);

      await entries.archiveEntry(id);
      final data = await entries.insights(env.profileId);

      expect(data.total, 1);
      expect(data.averageRating, 5);
    });

    test('добавления группируются по месяцам', () async {
      final env = await setup('Месяцы');
      await addEntry(env, 'Раз');
      await addEntry(env, 'Два');

      final data = await entries.insights(env.profileId);
      expect(data.byMonth, hasLength(1));
      expect(data.byMonth.single.count, 2);
    });
  });
}
