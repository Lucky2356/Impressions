import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/entry_stats.dart';
import 'package:impressions/data/repositories/profile_repository.dart';

import 'test_db.dart';

/// Начатое и брошенное: записи на полпути, которых давно не трогали.
///
/// Напоминание должно отличать «читаю» от «забыл»: разница между ними не в
/// прогрессе, а в том, когда запись последний раз двигали.
void main() {
  late AppDatabase db;
  late EntryRepository entries;
  late ProfileRow me;
  late String typeId;

  setUp(() async {
    db = openTestDb();
    entries = EntryRepository(db);
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    typeId = (await entries.createObjectType(me.id, 'Книги')).id;
  });

  tearDown(() => db.close());

  /// Запись с прогрессом. [touchedDaysAgo] отодвигает её свежайшую версию
  /// назад: `updateEntry` пишет версию с нынешним временем, а проверять надо
  /// именно давность — поэтому дата правится в базе напрямую.
  Future<String> entryWith({
    int? current,
    int? total,
    int touchedDaysAgo = 0,
    String? profileId,
  }) async {
    final object = await entries.createObject(
      typeId: typeId,
      title: 'Книга ${DateTime.now().microsecondsSinceEpoch}',
    );
    final entry = await entries.createEntry(
      profileId: profileId ?? me.id,
      objectId: object.id,
      progressCurrent: current,
      progressTotal: total,
    );
    if (touchedDaysAgo > 0) {
      final at = DateTime.now().subtract(Duration(days: touchedDaysAgo));
      await db.customStatement(
        'UPDATE profile_entry_revisions SET created_at = ? WHERE entry_id = ?',
        [at.millisecondsSinceEpoch ~/ 1000, entry.id],
      );
    }
    return entry.id;
  }

  test('запись на полпути, забытая давно, попадает в счёт', () async {
    await entryWith(current: 3, total: 12, touchedDaysAgo: 90);

    final stalled = await entries.stalledProgress(me.id);
    expect(stalled.count, 1);
    expect(stalled.since, isNotNull);
  });

  test('ту, что двигали вчера, напоминание не трогает', () async {
    await entryWith(current: 3, total: 12, touchedDaysAgo: 1);

    expect((await entries.stalledProgress(me.id)).count, 0);
  });

  test('дочитанное до конца брошенным не считается', () async {
    await entryWith(current: 12, total: 12, touchedDaysAgo: 90);

    expect(
      (await entries.stalledProgress(me.id)).count,
      0,
      reason: 'прогресс дошёл до конца — это законченное, а не забытое',
    );
  });

  test('запись без прогресса не брошена, а просто без прогресса', () async {
    await entryWith(touchedDaysAgo: 90);

    expect((await entries.stalledProgress(me.id)).count, 0);
  });

  test('прогресс без общего числа считается начатым', () async {
    // У сериала без известного числа серий общего числа нет, но начатым он
    // быть может.
    await entryWith(current: 4, touchedDaysAgo: 90);

    expect((await entries.stalledProgress(me.id)).count, 1);
  });

  test('архивная запись не напоминает о себе', () async {
    final id = await entryWith(current: 3, total: 12, touchedDaysAgo: 90);
    await entries.archiveEntry(id);

    expect((await entries.stalledProgress(me.id)).count, 0);
  });

  test('считается давнее из забытых', () async {
    await entryWith(current: 1, total: 10, touchedDaysAgo: 70);
    await entryWith(current: 2, total: 10, touchedDaysAgo: 200);

    final stalled = await entries.stalledProgress(me.id);
    expect(stalled.count, 2);
    final days = DateTime.now().difference(stalled.since!).inDays;
    expect(
      days,
      greaterThan(150),
      reason: 'показывать надо давнее — оно и объясняет, зачем напоминать',
    );
  });

  test('чужой профиль в счёт не идёт', () async {
    final other = await ProfileRepository(
      db,
    ).createOwnProfile(firstName: 'Он', type: 'myOtherDevice');
    await entryWith(
      current: 3,
      total: 12,
      touchedDaysAgo: 90,
      profileId: other.id,
    );

    expect((await entries.stalledProgress(me.id)).count, 0);
  });

  test('порог давности задаётся вызывающим', () async {
    await entryWith(current: 3, total: 12, touchedDaysAgo: 10);

    expect((await entries.stalledProgress(me.id)).count, 0);
    expect(
      (await entries.stalledProgress(
        me.id,
        untouched: const Duration(days: 7),
      )).count,
      1,
    );
  });
}
