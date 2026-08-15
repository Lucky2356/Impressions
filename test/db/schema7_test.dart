import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/core/domain/entry_status.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/repositories/category_repository.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/services/seed_service.dart';

import 'test_db.dart';

void main() {
  late final db = openTestDb();
  late final profiles = ProfileRepository(db);
  late final cats = CategoryRepository(db);
  late final entries = EntryRepository(db);

  tearDownAll(() => db.close());

  Future<CategoryRow> reload(String id) =>
      (db.select(db.categories)..where((c) => c.id.equals(id))).getSingle();

  Future<ObjectTypeRow> reloadType(String id) =>
      (db.select(db.objectTypes)..where((t) => t.id.equals(id))).getSingle();

  group('тип по имени', () {
    test('проставляется ветке с тем же названием, что у типа', () async {
      final me = await profiles.createOwnProfile(firstName: 'Совпало');
      final type = await entries.createObjectType(me.id, 'Фильмы');
      final films = await cats.createRoot(me.id, 'Фильмы');
      final places = await cats.createRoot(me.id, 'Места');

      expect(await db.assignDefaultTypesByName(), greaterThan(0));

      expect((await reload(films.id)).defaultTypeId, type.id);
      // «Места» без одноимённого типа так и остаются без подсказки.
      expect((await reload(places.id)).defaultTypeId, isNull);
    });

    test('не трогает уже заданный тип', () async {
      final me = await profiles.createOwnProfile(firstName: 'Задано');
      final movies = await entries.createObjectType(me.id, 'Кино');
      await entries.createObjectType(me.id, 'Книги');
      // Названия расходятся нарочно: правило по имени выбрало бы «Книги».
      final branch = await cats.createRoot(
        me.id,
        'Книги',
        defaultTypeId: movies.id,
      );

      await db.assignDefaultTypesByName();

      expect((await reload(branch.id)).defaultTypeId, movies.id);
    });

    test('архивный тип не подставляется', () async {
      final me = await profiles.createOwnProfile(firstName: 'Архив');
      final type = await entries.createObjectType(me.id, 'Игры');
      await (db.update(db.objectTypes)..where((t) => t.id.equals(type.id)))
          .write(ObjectTypesCompanion(archivedAt: Value(DateTime(2026, 1, 1))));
      final games = await cats.createRoot(me.id, 'Игры');

      await db.assignDefaultTypesByName();

      expect((await reload(games.id)).defaultTypeId, isNull);
    });

    test('чужой профиль не одалживает свой тип', () async {
      final mine = await profiles.createOwnProfile(firstName: 'Мой');
      final other = await profiles.createOwnProfile(firstName: 'Чужой');
      await entries.createObjectType(other.id, 'Музыка');
      final music = await cats.createRoot(mine.id, 'Музыка');

      await db.assignDefaultTypesByName();

      expect((await reload(music.id)).defaultTypeId, isNull);
    });

    test('регистр и лишние пробелы совпадению не мешают', () async {
      final me = await profiles.createOwnProfile(firstName: 'Регистр');
      final type = await entries.createObjectType(me.id, 'Сериалы');
      final branch = await cats.createRoot(me.id, '  СЕРИАЛЫ ');

      await db.assignDefaultTypesByName();

      expect((await reload(branch.id)).defaultTypeId, type.id);
    });
  });

  group('стартовые статусы', () {
    test('встроенный тип получает стадии, свой — нет', () async {
      final me = await profiles.createOwnProfile(firstName: 'Стадии');
      final books = await entries.createObjectType(me.id, 'Книги');
      final custom = await entries.createObjectType(me.id, 'Настолки');

      await db.seedBuiltInStatuses();

      final seeded = EntryStatus.decode(
        (await reloadType(books.id)).statusesJson,
      );
      expect(
        [for (final s in seeded) s.key],
        [EntryStatus.planned, EntryStatus.inProgress, EntryStatus.doneKey],
      );
      expect(seeded.last.done, isTrue);
      expect((await reloadType(books.id)).progressUnit, 'страница');

      // Пользовательскому типу набор не навязывается.
      expect((await reloadType(custom.id)).statusesJson, isNull);
    });

    test('уже заданные статусы не переписываются', () async {
      final me = await profiles.createOwnProfile(firstName: 'Своё');
      final own = EntryStatus.encode([
        const EntryStatus(key: 'mine', name: 'Моё'),
      ]);
      final films = await entries.createObjectType(
        me.id,
        'Фильмы',
        statusesJson: own,
      );

      await db.seedBuiltInStatuses();

      expect((await reloadType(films.id)).statusesJson, own);
    });
  });

  group('«Хочу попробовать» переезжает в стадию', () {
    /// Заводит запись прямо в таблице: репозиторий такого отношения уже не
    /// знает, а миграции достаются именно такие строки — из старой базы.
    Future<String> legacyEntry(
      String profileId,
      String objectId, {
      String? relation,
      String? status,
    }) async {
      final id = 'e-$profileId-$objectId-${relation ?? status}';
      await db
          .into(db.profileEntries)
          .insert(
            ProfileEntriesCompanion.insert(
              id: id,
              profileId: profileId,
              objectId: objectId,
              relation: Value(relation),
              status: Value(status),
              createdAt: DateTime(2026, 1, 1),
            ),
          );
      return id;
    }

    Future<ProfileEntryRow> reloadEntry(String id) => (db.select(
      db.profileEntries,
    )..where((e) => e.id.equals(id))).getSingle();

    test('отношение становится стадией, а мнение стирается', () async {
      final me = await profiles.createOwnProfile(firstName: 'Задумки');
      final type = await entries.createObjectType(me.id, 'Фильмы');
      final object = await entries.createObject(
        typeId: type.id,
        title: 'Не смотрел',
      );

      final want = await legacyEntry(me.id, object.id, relation: 'wantToTry');
      final liked = await legacyEntry(me.id, object.id, relation: 'like');

      expect(await db.migrateWantToTryToStatus(), 1);

      final moved = await reloadEntry(want);
      expect(moved.status, EntryStatus.planned);
      // «Хочу попробовать» — не мнение о вещи, а отметка, что мнения ещё нет.
      expect(moved.relation, isNull);

      // Настоящее отношение остаётся нетронутым.
      final kept = await reloadEntry(liked);
      expect(kept.relation, 'like');
      expect(kept.status, isNull);
    });

    test('перенесённая запись получает нормальный ключ стадии', () async {
      final me = await profiles.createOwnProfile(firstName: 'Перенос');
      final type = await entries.createObjectType(me.id, 'Книги');
      final object = await entries.createObject(
        typeId: type.id,
        title: 'Чужая',
      );
      // Перенос между профилями писал в колонку стадии ключ отношения.
      final id = await legacyEntry(me.id, object.id, status: 'wantToTry');

      expect(await db.migrateWantToTryToStatus(), 1);
      expect((await reloadEntry(id)).status, EntryStatus.planned);
    });

    test('повторный проход больше ничего не трогает', () async {
      final me = await profiles.createOwnProfile(firstName: 'Дважды');
      final type = await entries.createObjectType(me.id, 'Игры');
      final object = await entries.createObject(typeId: type.id, title: 'Игра');
      await legacyEntry(me.id, object.id, relation: 'wantToTry');

      expect(await db.migrateWantToTryToStatus(), 1);
      expect(await db.migrateWantToTryToStatus(), 0);
    });
  });

  test('первый запуск сразу связывает ветку с её типом', () async {
    final me = await profiles.createOwnProfile(firstName: 'Первый запуск');
    await SeedService(db).seedForProfile(
      me.id,
      withStarterSubcategories: false,
      onlyTypes: const ['Сериалы'],
    );

    final root = (await cats.roots(me.id)).single;
    final type = (await entries.objectTypes(me.id)).single;

    expect(root.defaultTypeId, type.id);
    expect(type.progressUnit, 'серия');
    expect(EntryStatus.decode(type.statusesJson), hasLength(3));
  });

  test('битый набор статусов читается как «статусов нет»', () {
    // Пакет мог приехать с испорченным полем — тип обязан открыться.
    expect(EntryStatus.decode('{не json'), isEmpty);
    expect(EntryStatus.decode('{"key":"planned"}'), isEmpty);
    expect(EntryStatus.decode('[{"name":"без ключа"}]'), isEmpty);
  });
}
