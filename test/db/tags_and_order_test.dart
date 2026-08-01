import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/core/domain/relation.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/repositories/category_repository.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/services/purge_service.dart';

import 'test_db.dart';

void main() {
  late AppDatabase db;
  late EntryRepository entries;
  late String profileId;
  late String typeId;

  setUp(() async {
    db = openTestDb();
    entries = EntryRepository(db);
    final me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    profileId = me.id;
    typeId = (await entries.createObjectType(me.id, 'Всё подряд')).id;
  });

  tearDown(() => db.close());

  Future<String> addEntry(String title) async {
    final obj = await entries.createObject(typeId: typeId, title: title);
    final entry = await entries.createEntry(
      profileId: profileId,
      objectId: obj.id,
      relation: Relation.like.name,
    );
    return entry.id;
  }

  group('Теги: их стало можно убрать', () {
    test('переименование меняет название', () async {
      final entry = await addEntry('Чай');
      final tag = await entries.addTag(profileId, entry, 'вечерний');

      final kept = await entries.renameTag(tag.id, 'Вечернее');

      expect(kept.id, tag.id);
      expect(kept.name, 'Вечернее');
      final all = await entries.tagsOfProfile(profileId);
      expect(all.map((t) => t.name), ['Вечернее']);
    });

    test('переименование в занятое название сливает теги', () async {
      final tea = await addEntry('Чай');
      final coffee = await addEntry('Кофе');
      final evening = await entries.addTag(profileId, tea, 'вечерний');
      final typo = await entries.addTag(profileId, coffee, 'вечерниий');

      final kept = await entries.renameTag(typo.id, 'вечерний');

      expect(kept.id, evening.id, reason: 'уцелеть должен тот, что был');
      expect(await entries.tagsOfProfile(profileId), hasLength(1));
      expect((await entries.tagsOfEntry(coffee)).single.id, evening.id);
      expect((await entries.tagsOfEntry(tea)).single.id, evening.id);
    });

    test('слияние не плодит дублей на записи с обоими тегами', () async {
      final entry = await addEntry('Чай');
      final evening = await entries.addTag(profileId, entry, 'вечерний');
      final typo = await entries.addTag(profileId, entry, 'вечерниий');

      await entries.renameTag(typo.id, 'вечерний');

      final onEntry = await entries.tagsOfEntry(entry);
      expect(onEntry.map((t) => t.id), [evening.id]);
      expect(await entries.tagUsage(profileId), {evening.id: 1});
    });

    test('«ё» и регистр — одно и то же название', () async {
      final tea = await addEntry('Чай');
      final coffee = await addEntry('Кофе');
      await entries.addTag(profileId, tea, 'Ёлочное');
      final other = await entries.addTag(profileId, coffee, 'зимнее');

      await entries.renameTag(other.id, 'елочное');

      expect(await entries.tagsOfProfile(profileId), hasLength(1));
    });

    test('удаление снимает тег с записей и убирает его самого', () async {
      final entry = await addEntry('Чай');
      final tag = await entries.addTag(profileId, entry, 'вечерний');

      await entries.deleteTag(tag.id);

      expect(await entries.tagsOfProfile(profileId), isEmpty);
      expect(await entries.tagsOfEntry(entry), isEmpty);
    });

    test('счётчик показывает, сколько записей помечено', () async {
      final tea = await addEntry('Чай');
      final coffee = await addEntry('Кофе');
      final evening = await entries.addTag(profileId, tea, 'вечерний');
      await entries.addTag(profileId, coffee, 'вечерний');
      final lonely = await entries.addTag(profileId, tea, 'редкий');

      expect(await entries.tagUsage(profileId), {evening.id: 2, lonely.id: 1});
    });

    test('тег без записей не остаётся после удаления последней', () async {
      final entry = await addEntry('Чай');
      await entries.addTag(profileId, entry, 'вечерний');

      await PurgeService(db).purgeEntry(entry);

      expect(
        await entries.tagsOfProfile(profileId),
        isEmpty,
        reason: 'иначе метка навсегда остаётся в списке фильтров',
      );
    });

    test('тег, который носит кто-то ещё, остаётся', () async {
      final tea = await addEntry('Чай');
      final coffee = await addEntry('Кофе');
      await entries.addTag(profileId, tea, 'вечерний');
      await entries.addTag(profileId, coffee, 'вечерний');

      await PurgeService(db).purgeEntry(tea);

      expect(await entries.tagsOfProfile(profileId), hasLength(1));
    });
  });

  group('Порядок категорий: его стало можно задать', () {
    late CategoryRepository cats;

    setUp(() => cats = CategoryRepository(db));

    Future<List<String>> names() async =>
        (await cats.roots(profileId)).map((c) => c.name).toList();

    test('новые категории встают в конец, а не перемешиваются', () async {
      await cats.createRoot(profileId, 'Яблоки');
      await cats.createRoot(profileId, 'Апельсины');
      await cats.createRoot(profileId, 'Бананы');

      expect(await names(), ['Яблоки', 'Апельсины', 'Бананы']);
    });

    test('«Выше» и «Ниже» переставляют категорию', () async {
      await cats.createRoot(profileId, 'Первая');
      final second = await cats.createRoot(profileId, 'Вторая');
      await cats.createRoot(profileId, 'Третья');

      expect(await cats.reorder(second.id, up: true), isTrue);
      expect(await names(), ['Вторая', 'Первая', 'Третья']);

      expect(await cats.reorder(second.id, up: false), isTrue);
      expect(await names(), ['Первая', 'Вторая', 'Третья']);
    });

    test('крайнюю категорию за край не уводит', () async {
      final first = await cats.createRoot(profileId, 'Первая');
      final last = await cats.createRoot(profileId, 'Вторая');

      expect(await cats.reorder(first.id, up: true), isFalse);
      expect(await cats.reorder(last.id, up: false), isFalse);
      expect(await names(), ['Первая', 'Вторая']);
    });

    test('порядок задаётся отдельно внутри каждой ветки', () async {
      final root = await cats.createRoot(profileId, 'Продукты');
      await cats.createChild(root.id, 'Колбасы');
      final cheese = await cats.createChild(root.id, 'Сыры');

      await cats.reorder(cheese.id, up: true);

      final children = await cats.children(root.id);
      expect(children.map((c) => c.name), ['Сыры', 'Колбасы']);
    });

    test('порядок у старых категорий предсказуем, а не случаен', () async {
      // До 1.11.0 sortOrder никто не выставлял: у всех ноль. Такие категории
      // должны идти по алфавиту, а не как повезёт.
      await cats.createRoot(profileId, 'Яблоки', sortOrder: 0);
      await cats.createRoot(profileId, 'Апельсины', sortOrder: 0);
      await cats.createRoot(profileId, 'Бананы', sortOrder: 0);

      expect(await names(), ['Апельсины', 'Бананы', 'Яблоки']);
    });

    test('перестановка чинит нулевой порядок', () async {
      await cats.createRoot(profileId, 'Апельсины', sortOrder: 0);
      final bananas = await cats.createRoot(profileId, 'Бананы', sortOrder: 0);
      await cats.createRoot(profileId, 'Яблоки', sortOrder: 0);

      expect(await cats.reorder(bananas.id, up: true), isTrue);
      expect(await names(), ['Бананы', 'Апельсины', 'Яблоки']);
    });
  });
}
