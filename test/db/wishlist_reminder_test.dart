import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/core/domain/entry_status.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/repositories/settings_repository.dart';
import 'package:impressions/features/notifications/notifications.dart';

import 'test_db.dart';

/// Напоминание о задуманном (§14).
///
/// «Хочу попробовать» — список пассивный: пока сам не откроешь, не вспомнишь.
/// Смысл приложения ровно обратный — не забыть то, до чего руки не дошли.
void main() {
  late AppDatabase db;
  late ProfileRow me;
  late String typeId;
  late ProviderContainer container;

  setUp(() async {
    db = openTestDb();
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    typeId = (await EntryRepository(db).createObjectType(me.id, 'Фильмы')).id;
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

  /// Задуманное с заданной давностью: дату заведения ставим сами, иначе всё
  /// созданное тестом свежее, а напоминание про свежее молчит намеренно.
  Future<void> plan(String title, {required int daysAgo}) async {
    final entries = EntryRepository(db);
    final object = await entries.createObject(typeId: typeId, title: title);
    final entry = await entries.createEntry(
      profileId: me.id,
      objectId: object.id,
      status: EntryStatus.planned,
    );
    final at = DateTime.now().subtract(Duration(days: daysAgo));
    await (db.update(db.profileEntries)..where((e) => e.id.equals(entry.id)))
        .write(ProfileEntriesCompanion(createdAt: Value(at)));
  }

  Future<void> enableReminder() =>
      SettingsRepository(db).setBool(SettingKeys.wishlistReminder, true);

  Future<List<AppNotification>> notifications() =>
      container.read(notificationsProvider.future);

  Future<bool> hasReminder() async =>
      (await notifications()).any((n) => n.kind == NotificationKind.wishlist);

  test('выключено по умолчанию — приложение молчит', () async {
    await plan('Интерстеллар', daysAgo: 200);

    expect(await hasReminder(), isFalse);
  });

  test('включено и задуманное залежалось — напоминание приходит', () async {
    await enableReminder();
    await plan('Интерстеллар', daysAgo: 200);
    await plan('Дюна', daysAgo: 40);

    final reminder = (await notifications()).firstWhere(
      (n) => n.kind == NotificationKind.wishlist,
    );

    // Счёт и давность считаются при сборке события: панель их не
    // перезапрашивает.
    expect(reminder.title, '2');
    expect(reminder.unread, isTrue);

    // В событии — дата самой давней задумки, а не последней добавленной:
    // «ждёт с марта» про то, сколько список лежит, а не когда его трогали.
    final since = DateTime.parse(reminder.body);
    final between = DateTime.now().difference(since).inDays;
    expect(between, greaterThan(100));
  });

  test('свежее задуманное не тревожит', () async {
    await enableReminder();
    await plan('Дюна', daysAgo: 3);

    expect(await hasReminder(), isFalse);
  });

  test('пустой список не повод для напоминания', () async {
    await enableReminder();

    expect(await hasReminder(), isFalse);
  });

  test('архивированное не считается ждущим', () async {
    await enableReminder();
    await plan('Интерстеллар', daysAgo: 200);
    await (db.update(
      db.profileEntries,
    )).write(ProfileEntriesCompanion(archivedAt: Value(DateTime.now())));

    expect(await hasReminder(), isFalse);
  });

  test('отметка «прочитано» гасит до следующего месяца', () async {
    await enableReminder();
    await plan('Интерстеллар', daysAgo: 200);
    expect(await hasReminder(), isTrue);

    // Общая отметка, та же, что гасит остальные уведомления.
    await SettingsRepository(
      db,
    ).set('notifications_seen_at', DateTime.now().toIso8601String());
    container.invalidate(notificationsProvider);

    final reminder = (await notifications()).firstWhere(
      (n) => n.kind == NotificationKind.wishlist,
    );
    expect(reminder.unread, isFalse);
  });
}
