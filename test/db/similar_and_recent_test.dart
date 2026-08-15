import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/models/entry_view.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/features/catalog/catalog_providers.dart';
import 'package:impressions/features/collections/smart_collections.dart';
import 'package:impressions/features/search/recent_store.dart';

import 'query_counter.dart';

/// Связи между записями, недавнее и условие живой подборки.
void main() {
  group('похожее рядом', () {
    late AppDatabase db;
    late QueryCounter counter;
    late EntryRepository entries;
    late ProfileRow me;
    late ObjectTypeRow food;
    late ObjectTypeRow films;

    setUp(() async {
      (db, counter) = openCountingDb();
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

    test('на полном каталоге не поднимает весь тип', () async {
      // Раньше сюда приезжали все записи того же типа и сравнивались в
      // памяти — тысячи строк ради пяти показанных, и так на каждое открытие
      // карточки.
      final source = await add('Докторская', type: food, rating: 8);
      for (var i = 0; i < 200; i++) {
        await add('Далёкая \$i', type: food, rating: 1);
      }
      final close = await add('Краковская', type: food, rating: 7.5);

      counter.reset();
      final similar = await entries.similarTo(me.id, source.id);

      expect(similar.map((e) => e.entryId), [close.id]);
      expect(
        counter.matching('LIMIT 20'),
        greaterThan(0),
        reason: 'кандидатов должна ограничивать база, а не Dart',
      );
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

  group('условие живой подборки', () {
    CollectionRow collection(String? filterJson) => CollectionRow(
      id: 'c1',
      profileId: 'p1',
      name: 'Любимое',
      sortOrder: 0,
      filterJson: filterJson,
      createdAt: DateTime(2026, 1, 1),
    );

    test('отбор переживает запись и чтение', () {
      const filters = CatalogState(
        typeId: 't1',
        relation: 'love',
        status: 'done',
        withoutRating: true,
        sort: EntrySort.rating,
        reverseSort: true,
      );

      final restored = smartFilterOf(collection(jsonEncode(filters.toJson())))!;

      expect(restored.typeId, 't1');
      expect(restored.relation, 'love');
      expect(restored.status, 'done');
      expect(restored.withoutRating, isTrue);
      expect(restored.sort, EntrySort.rating);
      expect(restored.reverseSort, isTrue);
    });

    test('подборка без условия — ручная', () {
      expect(smartFilterOf(collection(null)), isNull);
      expect(smartFilterOf(collection('')), isNull);
    });

    test('испорченное условие не роняет экран', () {
      // Подборка могла приехать из пакета, собранного другой версией: это
      // «ничего не находится», а не авария.
      expect(smartFilterOf(collection('не json')), isNull);
      expect(smartFilterOf(collection('[1,2,3]')), isNull);
    });
  });
}
