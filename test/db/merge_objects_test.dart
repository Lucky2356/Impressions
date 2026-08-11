import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/services/purge_service.dart';

import 'test_db.dart';

/// Объединение уже заведённых дублей.
///
/// Диалог похожих объектов работает только в момент создания. Если два
/// одинаковых объекта уже есть, свести их было нечем — приходилось заводить
/// запись заново и терять историю.
void main() {
  late AppDatabase db;
  late EntryRepository entries;
  late PurgeService purge;
  late ProfileRow me;
  late ProfileRow friend;
  late ObjectTypeRow type;

  setUp(() async {
    db = openTestDb();
    entries = EntryRepository(db);
    purge = PurgeService(db);
    final profiles = ProfileRepository(db);
    me = await profiles.createOwnProfile(firstName: 'Я');
    friend = await profiles.createOwnProfile(firstName: 'Лариса');
    type = await entries.createObjectType(me.id, 'Продукты');
  });

  tearDown(() => db.close());

  Future<ObjectRow> object(String title, {String? creator}) =>
      entries.createObject(typeId: type.id, title: title, creator: creator);

  Future<int> objectCount() async => (await db.select(db.objects).get()).length;

  Future<String> objectOf(String entryId) async {
    final row = await (db.select(
      db.profileEntries,
    )..where((e) => e.id.equals(entryId))).getSingle();
    return row.objectId;
  }

  test('записи переезжают на оставшийся объект, лишний исчезает', () async {
    final ahmad = await object('Чай зелёный', creator: 'Ахмад');
    final lipton = await object('Чай зелёный', creator: 'Липтон');
    final first = await entries.createEntry(
      profileId: me.id,
      objectId: ahmad.id,
      rating: 8,
    );
    final second = await entries.createEntry(
      profileId: me.id,
      objectId: lipton.id,
    );

    await purge.mergeObjects(mergeId: lipton.id, keepId: ahmad.id);

    expect(await objectOf(first.id), ahmad.id);
    expect(await objectOf(second.id), ahmad.id);
    expect(await objectCount(), 1);
  });

  test('история и оценка записи остаются при ней', () async {
    final ahmad = await object('Чай зелёный', creator: 'Ахмад');
    final lipton = await object('Чай зелёный', creator: 'Липтон');
    final entry = await entries.createEntry(
      profileId: me.id,
      objectId: lipton.id,
      rating: 9,
      detailedNote: 'Крепкий',
    );
    final revisionsBefore = (await db.select(db.profileEntryRevisions).get())
        .where((r) => r.entryId == entry.id)
        .length;

    await purge.mergeObjects(mergeId: lipton.id, keepId: ahmad.id);

    final row = await (db.select(
      db.profileEntries,
    )..where((e) => e.id.equals(entry.id))).getSingle();
    expect(row.rating, 9);
    expect(row.detailedNote, 'Крепкий');
    expect(
      (await db.select(db.profileEntryRevisions).get())
          .where((r) => r.entryId == entry.id)
          .length,
      revisionsBefore,
    );
  });

  test('объект, на который смотрит чужой профиль, тоже переезжает', () async {
    final keep = await object('Чай зелёный', creator: 'Ахмад');
    final merged = await object('Чай зелёный', creator: 'Липтон');
    final mine = await entries.createEntry(
      profileId: me.id,
      objectId: merged.id,
    );
    final theirs = await entries.createEntry(
      profileId: friend.id,
      objectId: merged.id,
    );

    await purge.mergeObjects(mergeId: merged.id, keepId: keep.id);

    // Обе записи смотрят на оставшийся объект, а пустой убран: держать его
    // было бы не за что.
    expect(await objectOf(mine.id), keep.id);
    expect(await objectOf(theirs.id), keep.id);
    expect(await objectCount(), 1);
  });

  test('объединение с самим собой ничего не делает', () async {
    final only = await object('Чай зелёный');
    final entry = await entries.createEntry(
      profileId: me.id,
      objectId: only.id,
    );

    await purge.mergeObjects(mergeId: only.id, keepId: only.id);

    expect(await objectCount(), 1);
    expect(await objectOf(entry.id), only.id);
  });
}
