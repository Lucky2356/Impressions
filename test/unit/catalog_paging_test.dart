import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/app/data_refresh.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/models/entry_view.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/features/catalog/catalog_providers.dart';
import 'package:impressions/features/categories/category_providers.dart';

import '../db/query_counter.dart';

EntryView _entry(int i) => EntryView(
  entryId: 'e$i',
  objectId: 'o$i',
  title: 'Запись $i',
  typeName: 'Продукты',
  categoryPath: const [],
);

void main() {
  group('Постраничная выдача каталога', () {
    test('страница короче полного результата, а всего считается по нему', () {
      final all = [for (var i = 0; i < 150; i++) _entry(i)];
      final page = CatalogResults(
        items: all.take(catalogPageSize).toList(),
        total: all.length,
      );

      expect(page.items, hasLength(catalogPageSize));
      // Счётчик в заголовке показывает всё найденное, а не загруженное.
      expect(page.total, 150);
      expect(page.hasMore, isTrue);
    });

    test('когда всё поместилось, подгружать нечего', () {
      final results = CatalogResults.of([
        for (var i = 0; i < 5; i++) _entry(i),
      ]);
      expect(results.total, 5);
      expect(results.hasMore, isFalse);
    });

    test('пустой результат не считается незавершённым', () {
      final results = CatalogResults.of(const []);
      expect(results.total, 0);
      expect(results.hasMore, isFalse);
    });
  });

  group('Подгрузка идёт страницами, а не сначала', () {
    late AppDatabase db;
    late QueryCounter counter;
    late ProviderContainer container;

    setUp(() async {
      (db, counter) = openCountingDb();
      final entries = EntryRepository(db);
      final me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
      final type = await entries.createObjectType(me.id, 'Продукты');
      for (var i = 0; i < 130; i++) {
        final object = await entries.createObject(
          typeId: type.id,
          title: 'Запись ${i.toString().padLeft(3, '0')}',
        );
        await entries.createEntry(profileId: me.id, objectId: object.id);
      }

      container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activeProfileProvider.overrideWithValue(me),
          allCategoriesProvider.overrideWith((ref) async => const []),
        ],
      );
      // Список живёт, пока на него кто-то смотрит, — как экран каталога.
      container.listen(catalogFeedProvider, (_, _) {});
      // Контроллер каталога дочитывает сохранённые фильтры из базы уже после
      // создания и ставит новое состояние — дожидаемся, иначе список начнётся
      // заново прямо посреди проверки.
      container.read(catalogStateProvider);
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    Future<CatalogResults> shown() =>
        container.read(catalogFeedProvider.future);

    test('первая страница — шестьдесят записей, а не весь каталог', () async {
      final results = await shown();

      expect(results.items, hasLength(catalogPageSize));
      expect(results.total, 130, reason: 'счётчик показывает всё найденное');
      expect(results.hasMore, isTrue);
    });

    test('шаг прокрутки просит только свою страницу', () async {
      final first = await shown();

      counter.reset();
      await container.read(catalogFeedProvider.notifier).more();
      final second = container.read(catalogFeedProvider).value!;

      expect(second.items, hasLength(catalogPageSize * 2));
      expect(
        second.items.take(catalogPageSize).map((e) => e.entryId),
        first.items.map((e) => e.entryId),
        reason: 'прежние строки остались на местах',
      );
      expect(
        counter.matching('LIMIT $catalogPageSize OFFSET $catalogPageSize'),
        greaterThan(0),
        reason: 'раньше вторая страница просила у базы первые сто двадцать',
      );
    });

    test('дальше конца не просит', () async {
      final feed = container.read(catalogFeedProvider.notifier);
      await shown();
      await feed.more();
      await feed.more();

      final all = container.read(catalogFeedProvider).value!;
      expect(all.items, hasLength(130));
      expect(all.hasMore, isFalse);

      counter.reset();
      await feed.more();
      expect(counter.statements, isZero, reason: 'просить больше нечего');
    });

    test('смена фильтра начинает список заново', () async {
      await shown();
      await container.read(catalogFeedProvider.notifier).more();
      expect(container.read(catalogFeedProvider).value!.items, hasLength(120));

      container.read(catalogStateProvider.notifier).setSearch('Запись');

      final after = await shown();
      expect(after.items, hasLength(catalogPageSize));
    });

    test('правка записи не сбрасывает подгруженное', () async {
      await shown();
      await container.read(catalogFeedProvider.notifier).more();
      expect(container.read(catalogFeedProvider).value!.items, hasLength(120));

      container.read(dataRefreshProvider.notifier).bump();
      final after = await shown();

      expect(
        after.items,
        hasLength(120),
        reason: 'иначе список прыгал бы в начало под рукой у человека',
      );
    });
  });
}
