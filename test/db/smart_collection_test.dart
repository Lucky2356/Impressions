import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/core/domain/entry_status.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/repositories/collection_repository.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/repositories/settings_repository.dart';
import 'package:impressions/features/catalog/catalog_providers.dart';
import 'package:impressions/features/collections/smart_collections.dart';

import 'test_db.dart';

/// Живые подборки (§27): подборка, состав которой задан условием.
///
/// До 1.16.0 сохранённый отбор каталога и подборка были двумя механизмами:
/// первый жил в настройках и умел только применяться к фильтрам, вторая — в
/// базе и только вручную.
void main() {
  late AppDatabase db;
  late EntryRepository entries;
  late CollectionRepository collections;
  late SettingsRepository settings;
  late ProfileRow me;
  late ObjectTypeRow books;

  setUp(() async {
    db = openTestDb();
    entries = EntryRepository(db);
    collections = CollectionRepository(db);
    settings = SettingsRepository(db);
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    books = await entries.createObjectType(me.id, 'Книги');
  });

  tearDown(() => db.close());

  test('условие сохраняется вместе с подборкой', () async {
    const filter = CatalogState(status: EntryStatus.inProgress);
    final created = await collections.create(
      me.id,
      'Читаю сейчас',
      filterJson: jsonEncode(filter.toJson()),
    );

    final saved = (await collections.byId(created.id))!;
    expect(smartFilterOf(saved)?.status, EntryStatus.inProgress);

    // Ручная подборка отличается ровно отсутствием условия.
    final manual = await collections.create(me.id, 'На выходные');
    expect(smartFilterOf((await collections.byId(manual.id))!), isNull);
  });

  test('оформление правится и стирается', () async {
    final created = await collections.create(me.id, 'Любимое');

    await collections.updateAppearance(
      created.id,
      description: 'То, что не стыдно посоветовать',
      color: 0xFF336699,
      coverAttachmentId: 'att-1',
    );
    var saved = (await collections.byId(created.id))!;
    expect(saved.description, 'То, что не стыдно посоветовать');
    expect(saved.color, 0xFF336699);
    expect(saved.coverAttachmentId, 'att-1');

    // null здесь значит именно null: «убрать обложку», а не «не трогать».
    await collections.updateAppearance(created.id, coverAttachmentId: null);
    saved = (await collections.byId(created.id))!;
    expect(saved.coverAttachmentId, isNull);
    expect(saved.description, 'То, что не стыдно посоветовать');
  });

  test('состав живой подборки не хранится, а считается', () async {
    final object = await entries.createObject(typeId: books.id, title: 'Идиот');
    await entries.createEntry(
      profileId: me.id,
      objectId: object.id,
      status: EntryStatus.inProgress,
    );

    final created = await collections.create(
      me.id,
      'Читаю сейчас',
      filterJson: jsonEncode(
        const CatalogState(status: EntryStatus.inProgress).toJson(),
      ),
    );

    // Записи в `collection_entries` не заводились: подборка знает условие, а
    // не список.
    final links = await db.select(db.collectionEntries).get();
    expect(links, isEmpty);

    final matching = await entries.entryViews(
      me.id,
      status: smartFilterOf((await collections.byId(created.id))!)!.status,
    );
    expect(matching.single.title, 'Идиот');
  });

  group('переезд сохранённых отборов', () {
    Future<int> migrate() => migrateSavedFiltersToCollections(
      profileId: me.id,
      settings: settings,
      collections: collections,
    );

    test('отбор из настроек становится живой подборкой', () async {
      await settings.set(
        SettingKeys.catalogSavedFilters,
        '[{"name":"Без оценки","filters":{"withoutRating":true}},'
        '{"name":"Любимое","filters":{"relation":"love"}}]',
      );

      expect(await migrate(), 2);

      final list = await collections.listWithCounts(me.id);
      expect(list.map((v) => v.collection.name), ['Без оценки', 'Любимое']);
      expect(list.every((v) => v.isSmart), isTrue);
      expect(smartFilterOf(list.first.collection)?.withoutRating, isTrue);
    });

    test('повторный запуск ничего не удваивает', () async {
      await settings.set(
        SettingKeys.catalogSavedFilters,
        '[{"name":"Любимое","filters":{"relation":"love"}}]',
      );

      expect(await migrate(), 1);
      // Настройка стёрта — второму проходу нечего переносить.
      expect(await migrate(), 0);
      expect(await collections.listWithCounts(me.id), hasLength(1));
    });

    test('мусор в списке пропускается, остальное переезжает', () async {
      await settings.set(
        SettingKeys.catalogSavedFilters,
        '[{"name":"Любимое","filters":{"relation":"love"}},'
        '{"name":""},null,5]',
      );

      expect(await migrate(), 1);
    });

    test('испорченная настройка не мешает запуску', () async {
      await settings.set(SettingKeys.catalogSavedFilters, 'не json');

      expect(await migrate(), 0);
      expect(await collections.listWithCounts(me.id), isEmpty);
    });

    test('одноимённая подборка второй раз не заводится', () async {
      await collections.create(me.id, 'Любимое');
      await settings.set(
        SettingKeys.catalogSavedFilters,
        '[{"name":"любимое","filters":{"relation":"love"}}]',
      );

      expect(await migrate(), 0);
      expect(await collections.listWithCounts(me.id), hasLength(1));
    });
  });
}
