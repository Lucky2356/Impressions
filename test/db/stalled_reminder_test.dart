import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/repositories/settings_repository.dart';
import 'package:impressions/features/notifications/notifications.dart';

import 'test_db.dart';

/// Напоминание о незавершённом.
///
/// Про задуманное напоминание уже есть, про начатое — не было. Разница для
/// человека существенная: задуманное можно и передумать, а брошенное на
/// середине чаще просто забыто.
void main() {
  late AppDatabase db;
  late ProfileRow me;
  late String typeId;
  late ProviderContainer container;

  setUp(() async {
    db = openTestDb();
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    typeId = (await EntryRepository(db).createObjectType(me.id, 'Книги')).id;
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        activeProfileProvider.overrideWithValue(me),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// Начатая запись заданной давности. Давность ставится по свежайшей версии:
  /// именно её читает запрос, и именно она двигается при каждой правке.
  Future<void> started(
    String title, {
    required int current,
    int? total,
    required int touchedDaysAgo,
  }) async {
    final entries = EntryRepository(db);
    final object = await entries.createObject(typeId: typeId, title: title);
    final entry = await entries.createEntry(
      profileId: me.id,
      objectId: object.id,
      progressCurrent: current,
      progressTotal: total,
    );
    final at = DateTime.now().subtract(Duration(days: touchedDaysAgo));
    await db.customStatement(
      'UPDATE profile_entry_revisions SET created_at = ? WHERE entry_id = ?',
      [at.millisecondsSinceEpoch ~/ 1000, entry.id],
    );
  }

  Future<void> enableReminder() =>
      SettingsRepository(db).setBool(SettingKeys.stalledReminder, true);

  Future<List<AppNotification>> notifications() =>
      container.read(notificationsProvider.future);

  Future<bool> hasReminder() async =>
      (await notifications()).any((n) => n.kind == NotificationKind.stalled);

  test('выключено по умолчанию — приложение молчит', () async {
    await started(
      'Война и мир',
      current: 200,
      total: 1300,
      touchedDaysAgo: 200,
    );

    expect(
      await hasReminder(),
      isFalse,
      reason: 'напоминать о себе тому, кто не просил, приложение не должно',
    );
  });

  test('включено и начатое стоит — напоминание приходит', () async {
    await enableReminder();
    await started(
      'Война и мир',
      current: 200,
      total: 1300,
      touchedDaysAgo: 200,
    );
    await started('Улисс', current: 30, total: 900, touchedDaysAgo: 80);

    final reminder = (await notifications()).firstWhere(
      (n) => n.kind == NotificationKind.stalled,
    );

    expect(reminder.title, '2');
    expect(reminder.unread, isTrue);

    // В событии — давность самого залежавшегося: она и объясняет, зачем
    // напоминать вообще.
    final since = DateTime.parse(reminder.body);
    expect(DateTime.now().difference(since).inDays, greaterThan(150));
  });

  test('то, что двигали недавно, напоминания не вызывает', () async {
    await enableReminder();
    await started('Улисс', current: 30, total: 900, touchedDaysAgo: 3);

    expect(
      await hasReminder(),
      isFalse,
      reason:
          'быть на середине книги несколько дней — не повод для напоминания',
    );
  });

  test('дочитанное до конца напоминания не вызывает', () async {
    await enableReminder();
    await started('Улисс', current: 900, total: 900, touchedDaysAgo: 200);

    expect(await hasReminder(), isFalse);
  });

  test(
    'отметка времени — начало месяца, как у остальных напоминаний',
    () async {
      await enableReminder();
      await started('Улисс', current: 30, total: 900, touchedDaysAgo: 200);

      final reminder = (await notifications()).firstWhere(
        (n) => n.kind == NotificationKind.stalled,
      );
      final now = DateTime.now();
      expect(
        reminder.at,
        DateTime(now.year, now.month),
        reason:
            'событие гасится общей отметкой «прочитано» и возвращается через '
            'месяц — своих таймеров для этого не нужно',
      );
    },
  );
}
