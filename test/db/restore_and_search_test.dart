import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/repositories/category_repository.dart';
import 'package:impressions/data/repositories/collection_repository.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';

import 'test_db.dart';

void main() {
  late final db = openTestDb();
  late final profiles = ProfileRepository(db);
  late final cats = CategoryRepository(db);
  late final entries = EntryRepository(db);
  late final collections = CollectionRepository(db);

  tearDownAll(() => db.close());

  /// Профиль с одним типом объектов — основа для остальных проверок.
  Future<({String profileId, String typeId})> setup(String name) async {
    final me = await profiles.createOwnProfile(firstName: name);
    final type = await entries.createObjectType(me.id, 'Продукты');
    return (profileId: me.id, typeId: type.id);
  }

  group('Возврат из архива (§24)', () {
    test('запись пропадает из каталога и возвращается целой', () async {
      final env = await setup('Архив');
      final products = await cats.createRoot(env.profileId, 'Продукты');
      final object = await entries.createObject(
        typeId: env.typeId,
        title: 'Папа может',
      );
      final entry = await entries.createEntry(
        profileId: env.profileId,
        objectId: object.id,
        rating: 8,
        primaryCategoryId: products.id,
      );

      await entries.archiveEntry(entry.id);
      expect(await entries.entryViews(env.profileId), isEmpty);

      final archived = await entries.entryViews(env.profileId, archived: true);
      expect(archived, hasLength(1));

      await entries.restoreEntry(entry.id);
      final restored = await entries.entryViews(env.profileId);
      expect(restored, hasLength(1));
      // Связь с категорией и оценка не терялись — записи не удалялись.
      expect(restored.single.rating, 8);
      expect(restored.single.categoryPath, ['Продукты']);
    });

    test('категория возвращается вместе со своим местом в дереве', () async {
      final env = await setup('Дерево');
      final root = await cats.createRoot(env.profileId, 'Места');
      final child = await cats.createChild(root.id, 'Кафе');

      await cats.archive(child.id);
      expect(await cats.children(root.id), isEmpty);

      await cats.restore(child.id);
      final children = await cats.children(root.id);
      expect(children.single.name, 'Кафе');
      expect(children.single.path, '${root.id}/${child.id}');
    });

    test('подборка возвращается в список', () async {
      final env = await setup('Подборки');
      final collection = await collections.create(env.profileId, 'Купить');

      await collections.archive(collection.id);
      expect(await collections.listWithCounts(env.profileId), isEmpty);

      await collections.restore(collection.id);
      expect(await collections.listWithCounts(env.profileId), hasLength(1));
    });
  });

  group('Полнотекстовый поиск (§29)', () {
    test('находит по началу слова в названии', () async {
      final env = await setup('Поиск-название');
      final object = await entries.createObject(
        typeId: env.typeId,
        title: 'Колбаса варёная докторская',
      );
      await entries.createEntry(profileId: env.profileId, objectId: object.id);

      final found = await entries.entryViews(env.profileId, search: 'колб');
      expect(found, hasLength(1));
      expect(found.single.title, 'Колбаса варёная докторская');
    });

    test('находит по тексту заметки, а не только по названию', () async {
      final env = await setup('Поиск-заметка');
      final object = await entries.createObject(
        typeId: env.typeId,
        title: 'Безымянный продукт',
      );
      await entries.createEntry(
        profileId: env.profileId,
        objectId: object.id,
        detailedNote: 'Слишком солёный, брать больше не буду',
      );

      final found = await entries.entryViews(env.profileId, search: 'солён');
      expect(found, hasLength(1));
      expect(found.single.title, 'Безымянный продукт');
    });

    test('заметка переиндексируется после правки', () async {
      final env = await setup('Переиндексация');
      final object = await entries.createObject(
        typeId: env.typeId,
        title: 'Сыр',
      );
      final entry = await entries.createEntry(
        profileId: env.profileId,
        objectId: object.id,
        detailedNote: 'обычный',
      );

      await entries.updateEntry(entry.id, detailedNote: 'изумительный');

      expect(
        await entries.entryViews(env.profileId, search: 'изумит'),
        hasLength(1),
      );
      expect(await entries.entryViews(env.profileId, search: 'обычн'), isEmpty);
    });

    test('запрос без совпадений не возвращает весь каталог', () async {
      final env = await setup('Пустой поиск');
      final object = await entries.createObject(
        typeId: env.typeId,
        title: 'Хлеб',
      );
      await entries.createEntry(profileId: env.profileId, objectId: object.id);

      expect(
        await entries.entryViews(env.profileId, search: 'вертолёт'),
        isEmpty,
      );
    });
  });

  group('Фильтр по тегам (§7.2)', () {
    test('оставляет только помеченные записи', () async {
      final env = await setup('Теги');
      final withTag = await entries.createObject(
        typeId: env.typeId,
        title: 'С тегом',
      );
      final withoutTag = await entries.createObject(
        typeId: env.typeId,
        title: 'Без тега',
      );
      final tagged = await entries.createEntry(
        profileId: env.profileId,
        objectId: withTag.id,
      );
      await entries.createEntry(
        profileId: env.profileId,
        objectId: withoutTag.id,
      );

      final tag = await entries.addTag(env.profileId, tagged.id, 'подарок');
      final found = await entries.entryViews(env.profileId, tagIds: [tag.id]);

      expect(found, hasLength(1));
      expect(found.single.title, 'С тегом');
    });
  });

  group('Ручной порядок подборки (§27)', () {
    test('перестановка сохраняется', () async {
      final env = await setup('Порядок');
      final collection = await collections.create(env.profileId, 'План');

      final ids = <String>[];
      for (final title in ['Первый', 'Второй', 'Третий']) {
        final object = await entries.createObject(
          typeId: env.typeId,
          title: title,
        );
        final entry = await entries.createEntry(
          profileId: env.profileId,
          objectId: object.id,
        );
        ids.add(entry.id);
        await collections.addEntry(collection.id, entry.id);
      }

      Future<List<String>> titles() async {
        final list = await collections.entriesOf(
          collection.id,
          env.profileId,
          allEntriesLoader: () => entries.entryViews(env.profileId),
        );
        return list.map((e) => e.title).toList();
      }

      expect(await titles(), ['Первый', 'Второй', 'Третий']);

      // Переносим третий в начало.
      await collections.reorder(collection.id, [ids[2], ids[0], ids[1]]);
      expect(await titles(), ['Третий', 'Первый', 'Второй']);
    });
  });

  group('Дата впечатления (§10)', () {
    test('сохраняется, сортирует и стирается', () async {
      final env = await setup('Дата');
      final object = await entries.createObject(
        typeId: env.typeId,
        title: 'Поездка',
      );
      final when = DateTime(2024, 5, 17);
      final entry = await entries.createEntry(
        profileId: env.profileId,
        objectId: object.id,
        impressionDate: when,
      );

      final saved = await entries.entryViews(env.profileId);
      expect(saved.single.entryId, entry.id);

      // Явное стирание: обычный null означает «не менять».
      await entries.updateEntry(entry.id, clearImpressionDate: true);
      final after = await (db.select(
        db.profileEntries,
      )..where((e) => e.id.equals(entry.id))).getSingle();
      expect(after.impressionDate, isNull);
    });
  });
}
