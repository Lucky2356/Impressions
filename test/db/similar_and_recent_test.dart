import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/models/entry_view.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/features/catalog/catalog_providers.dart';
import 'package:impressions/features/catalog/saved_filters.dart';
import 'package:impressions/features/search/recent_store.dart';

import 'test_db.dart';

/// Связи между записями, недавнее и сохранённые отборы.
void main() {
  group('похожее рядом', () {
    late AppDatabase db;
    late EntryRepository entries;
    late ProfileRow me;
    late ObjectTypeRow food;
    late ObjectTypeRow films;

    setUp(() async {
      db = openTestDb();
      entries = EntryRepository(db);
      me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
      food = await entries.createObjectType(me.id, 'Продукты');
      films = await entries.createObjectType(me.id, 'Фильмы');
    });

    tearDown(() => db.close());

    Future<ProfileEntryRow> add(
      String title, {
      required ObjectTypeRow type,
      double? rating,
    }) async {
      final object = await entries.createObject(typeId: type.id, title: title);
      return entries.createEntry(
        profileId: me.id,
        objectId: object.id,
        rating: rating,
      );
    }

    test('близкая оценка того же типа попадает в похожее', () async {
      final source = await add('Докторская', type: food, rating: 8);
      final close = await add('Краковская', type: food, rating: 7.5);
      await add('Молоко', type: food, rating: 3);
      await add('Интерстеллар', type: films, rating: 8);

      final similar = await entries.similarTo(me.id, source.id);

      expect(similar.map((e) => e.entryId), [close.id]);
    });

    test('общий тег весит больше близкой оценки', () async {
      final source = await add('Докторская', type: food, rating: 8);
      final tagged = await add('Сервелат', type: food, rating: 2);
      final byRating = await add('Краковская', type: food, rating: 8);
      await entries.addTag(me.id, source.id, 'Колбасы');
      await entries.addTag(me.id, tagged.id, 'Колбасы');

      final similar = await entries.similarTo(me.id, source.id);

      expect(similar.first.entryId, tagged.id);
      expect(similar.map((e) => e.entryId), contains(byRating.id));
    });

    test('сама запись в похожие не попадает', () async {
      final source = await add('Докторская', type: food, rating: 8);
      await add('Краковская', type: food, rating: 8);

      final similar = await entries.similarTo(me.id, source.id);

      expect(similar.map((e) => e.entryId), isNot(contains(source.id)));
    });

    test('одинокой записи похожее не выдумывается', () async {
      final source = await add('Докторская', type: food, rating: 8);

      expect(await entries.similarTo(me.id, source.id), isEmpty);
    });
  });

  group('недавнее', () {
    test('новое значение встаёт первым и не дублируется', () {
      var list = RecentStore.push(const [], 'колбаса');
      list = RecentStore.push(list, 'чай');
      list = RecentStore.push(list, 'колбаса');

      expect(list, ['колбаса', 'чай']);
    });

    test('список не растёт без предела', () {
      var list = <String>[];
      for (var i = 0; i < RecentStore.limit + 5; i++) {
        list = RecentStore.push(list, 'запрос $i');
      }

      expect(list, hasLength(RecentStore.limit));
      expect(list.first, 'запрос ${RecentStore.limit + 4}');
    });

    test('пустое значение не запоминается', () {
      expect(RecentStore.push(const ['чай'], '   '), ['чай']);
    });

    test('испорченная запись читается как пустая история', () {
      expect(RecentStore.parse('не json'), isEmpty);
      expect(RecentStore.parse(null), isEmpty);
      expect(RecentStore.parse('["чай", 5, ""]'), ['чай']);
    });
  });

  group('сохранённые отборы', () {
    test('отбор переживает запись и чтение', () {
      const filters = CatalogState(
        typeId: 't1',
        relation: 'love',
        withoutRating: true,
        sort: EntrySort.rating,
        reverseSort: true,
      );
      const saved = SavedFilter(name: 'Любимое', filters: filters);

      final restored = SavedFilter.fromJson(saved.toJson())!;

      expect(restored.name, 'Любимое');
      expect(restored.filters.typeId, 't1');
      expect(restored.filters.relation, 'love');
      expect(restored.filters.withoutRating, isTrue);
      expect(restored.filters.sort, EntrySort.rating);
      expect(restored.filters.reverseSort, isTrue);
    });

    test('мусор в списке пропускается, остальное остаётся', () {
      final list = SavedFilters.parse(
        '[{"name":"Любимое","filters":{"relation":"love"}},'
        '{"name":""},null,5]',
      );

      expect(list, hasLength(1));
      expect(list.single.name, 'Любимое');
    });

    test('испорченная настройка не роняет список', () {
      expect(SavedFilters.parse('не json'), isEmpty);
      expect(SavedFilters.parse(null), isEmpty);
    });
  });
}
