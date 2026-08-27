import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/app/data_refresh.dart';
import 'package:impressions/core/domain/entry_status.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/category_repository.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/features/categories/category_providers.dart';
import 'package:impressions/features/collections/collection_providers.dart';
import 'package:impressions/features/home/home_providers.dart';

import 'query_counter.dart';

/// Карта категорий читается один раз на экран, а не на каждый запрос.
///
/// Путь в карточке — «Продукты / Колбасы» — строится по всем категориям
/// профиля, и таблица поднималась целиком на каждый вызов. Главная спрашивает
/// записи шестью разными провайдерами, то есть читала её шесть раз подряд.
void main() {
  late AppDatabase db;
  late QueryCounter counter;
  late ProfileRow me;

  setUp(() async {
    (db, counter) = openCountingDb();
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');

    // Без записей `_viewsOf` выходит раньше, чем доберётся до категорий, и
    // проверка мерила бы пустоту. Ветка нужна тоже: путь в карточке строится
    // именно по ней.
    //
    // Каждому блоку главной — своя запись, иначе четыре блока из пяти вернут
    // пусто, до чтения категорий не дойдут, и проверка перестанет что-либо
    // ловить.
    final entries = EntryRepository(db);
    final categories = CategoryRepository(db);
    final food = await categories.createRoot(me.id, 'Продукты');
    final sausages = await categories.createChild(food.id, 'Колбасы');
    final type = await entries.createObjectType(me.id, 'Продукты');

    final yearAgo = DateTime.now().subtract(const Duration(days: 365));
    final seed = <({String title, String? status, DateTime? impression})>[
      (title: 'Папа может', status: null, impression: null),
      (title: 'Докторская', status: EntryStatus.planned, impression: null),
      (title: 'Сервелат', status: EntryStatus.planned, impression: null),
      (title: 'Салями', status: EntryStatus.inProgress, impression: null),
      (title: 'Ветчина', status: null, impression: yearAgo),
    ];
    for (final it in seed) {
      final object = await entries.createObject(
        typeId: type.id,
        title: it.title,
      );
      await entries.createEntry(
        profileId: me.id,
        objectId: object.id,
        primaryCategoryId: sausages.id,
        status: it.status,
        impressionDate: it.impression,
      );
    }
  });
  tearDown(() => db.close());

  /// Профиль подставляется готовым: поток профилей — это drift-стрим, а он
  /// в таких проверках оставляет висящие таймеры. Нас интересуют запросы
  /// категорий, а не то, как профиль доехал.
  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        activeProfileProvider.overrideWithValue(me),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  /// Сколько раз подняли таблицу категорий целиком.
  int categoryReads() => counter.sql
      .where((s) => s.contains('FROM "categories"'))
      .where((s) => s.contains('"profile_id"'))
      .length;

  test('шесть блоков главной читают категории один раз', () async {
    final c = container();
    counter.reset();

    await Future.wait([
      c.read(recentEntriesProvider.future),
      c.read(plannedEntriesProvider.future),
      c.read(inProgressEntriesProvider.future),
      c.read(yearAgoEntriesProvider.future),
      c.read(plannedSuggestionPoolProvider.future),
    ]);

    expect(categoryReads(), 1);
  });

  test('правка записи не заставляет перечитывать категории', () async {
    final c = container();
    await c.read(recentEntriesProvider.future);
    counter.reset();

    // Изменились записи, дерево не тронуто.
    c.read(dataRefreshProvider.notifier).bump([DataKind.entries]);
    await c.read(recentEntriesProvider.future);

    expect(categoryReads(), 0);
  });

  /// Даёт провайдерам пересчитаться после пробуждения.
  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 50));

  test('правка записи не будит запросы дерева', () async {
    final c = container();
    // Подписка держит провайдеры живыми: без неё они пересчитываются лениво,
    // и проверка мерила бы не «кого разбудило», а «кого потом прочитали».
    c.listen(recentEntriesProvider, (_, _) {});
    c.listen(allCategoriesProvider, (_, _) {});
    c.listen(collectionsProvider, (_, _) {});
    await settle();
    counter.reset();

    c.read(dataRefreshProvider.notifier).bump(const [DataKind.entries]);
    await settle();

    expect(
      counter.matching('FROM "categories"'),
      0,
      reason: 'дерево не читалось: его никто не трогал',
    );
    expect(
      counter.matching('FROM "collections"'),
      isNot(0),
      reason: 'у живой подборки счётчик считается по записям',
    );
  });

  test('правка настройки не будит ни записи, ни дерево', () async {
    final c = container();
    c.listen(recentEntriesProvider, (_, _) {});
    c.listen(allCategoriesProvider, (_, _) {});
    await settle();
    counter.reset();

    c.read(dataRefreshProvider.notifier).bump(const [DataKind.settings]);
    await settle();

    expect(counter.matching('FROM "profile_entries"'), 0);
    expect(counter.matching('FROM "categories"'), 0);
  });

  // Обратная сторона: правка дерева обязана дойти до карточек. Путь
  // «Продукты / Колбасы» показывает карточка записи, и после переименования
  // ветки он должен смениться — значит запросы записей будятся, и это не
  // упущение, а требование.
  test('правка дерева доходит до карточек', () async {
    final c = container();
    c.listen(recentEntriesProvider, (_, _) {});
    await settle();
    counter.reset();

    c.read(dataRefreshProvider.notifier).bump(const [DataKind.categories]);
    await settle();

    expect(counter.matching('FROM "profile_entries"'), isNot(0));
  });

  test('правка дерева заставляет перечитать карту', () async {
    final c = container();
    await c.read(recentEntriesProvider.future);
    counter.reset();

    c.read(dataRefreshProvider.notifier).bump([DataKind.categories]);
    await c.read(categoryIndexProvider.future);

    expect(categoryReads(), 1);
  });
}
