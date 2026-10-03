import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/models/entry_view.dart';
import 'package:impressions/data/repositories/entry_stats.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/repositories/settings_repository.dart';
import 'package:impressions/features/notifications/notifications.dart';

import 'test_db.dart';

/// Напоминание вернуться к любимому.
///
/// Два напоминания до него — про то, до чего не дошли руки. Это — про то, что
/// уже понравилось настолько, что стоит вернуться: высокая оценка, поставленная
/// годы назад, иначе просто лежит в архиве собственной памяти.
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

  /// Запись с оценкой и датой впечатления заданной давности.
  Future<ProfileEntryRow> rated(
    String title, {
    double? rating,
    int? yearsAgo,
    String? profileId,
  }) async {
    final entries = EntryRepository(db);
    final object = await entries.createObject(typeId: typeId, title: title);
    return entries.createEntry(
      profileId: profileId ?? me.id,
      objectId: object.id,
      rating: rating,
      impressionDate: yearsAgo == null
          ? null
          : DateTime.now().subtract(Duration(days: 365 * yearsAgo)),
    );
  }

  Future<void> enableReminder() =>
      SettingsRepository(db).setBool(SettingKeys.revisitReminder, true);

  Future<List<AppNotification>> notifications() =>
      container.read(notificationsProvider.future);

  Future<bool> hasReminder() async =>
      (await notifications()).any((n) => n.kind == NotificationKind.revisit);

  group('запрос', () {
    Future<RevisitFavourites> ask() =>
        EntryRepository(db).favouritesToRevisit(me.id);

    test('любимое многолетней давности попадает в счёт', () async {
      await rated('Дюна', rating: 10, yearsAgo: 4);
      await rated('Солярис', rating: 9, yearsAgo: 3);

      final found = await ask();
      expect(found.count, 2);
      // Давность самого давнего — она и объясняет, зачем напоминать.
      expect(
        DateTime.now().difference(found.since!).inDays,
        greaterThan(365 * 3),
      );
    });

    test('средняя оценка возвращения не требует', () async {
      // Напоминание про любимое, а не про всё прочитанное: семёрка годы назад
      // ничего не говорит о желании вернуться.
      await rated('Проходное', rating: 7, yearsAgo: 5);

      expect((await ask()).count, 0);
    });

    test('неоценённое в счёт не идёт', () async {
      await rated('Без оценки', yearsAgo: 5);

      expect((await ask()).count, 0);
    });

    test('свежее впечатление возвращения не требует', () async {
      await rated('Недавнее', rating: 10, yearsAgo: 0);

      expect((await ask()).count, 0);
    });

    test('архивное в счёт не идёт', () async {
      final entry = await rated('Архивное', rating: 10, yearsAgo: 5);
      await EntryRepository(db).archiveEntry(entry.id);

      expect((await ask()).count, 0);
    });

    test('чужой профиль в счёт не идёт', () async {
      final other = await ProfileRepository(
        db,
      ).createOwnProfile(firstName: 'Он', type: 'myOtherDevice');
      await rated('Чужое', rating: 10, yearsAgo: 5, profileId: other.id);

      expect((await ask()).count, 0);
    });

    test('без даты впечатления давность берётся по заведению', () async {
      // Дату впечатления проставляют редко; по ней одной напоминание обходило
      // бы большинство записей.
      final entry = await rated('Без даты', rating: 10);

      expect(
        (await ask()).count,
        0,
        reason: 'запись заведена сейчас — возвращаться к ней ещё рано',
      );

      // Отодвигаем саму дату заведения: именно по ней считается давность,
      // когда даты впечатления нет.
      final long = DateTime.now().subtract(const Duration(days: 365 * 4));
      await db.customStatement(
        'UPDATE profile_entries SET created_at = ? WHERE id = ?',
        [long.millisecondsSinceEpoch ~/ 1000, entry.id],
      );

      expect((await ask()).count, 1);
    });

    test('порог давности — параметр, а не жизнь', () async {
      await rated('Годовалое', rating: 10, yearsAgo: 1);

      expect((await ask()).count, 0);
      expect(
        (await EntryRepository(db).favouritesToRevisit(
          me.id,
          untouched: const Duration(days: 300),
        )).count,
        1,
      );
    });
  });

  group('напоминание', () {
    test('выключено по умолчанию — приложение молчит', () async {
      await rated('Дюна', rating: 10, yearsAgo: 4);

      expect(
        await hasReminder(),
        isFalse,
        reason: 'напоминать о себе тому, кто не просил, приложение не должно',
      );
    });

    test('включено и любимое ждёт — напоминание приходит', () async {
      await enableReminder();
      await rated('Дюна', rating: 10, yearsAgo: 4);
      await rated('Недавнее', rating: 10, yearsAgo: 0);

      final reminder = (await notifications()).firstWhere(
        (n) => n.kind == NotificationKind.revisit,
      );

      expect(reminder.title, '1');
      expect(reminder.unread, isTrue);
    });

    test('отметка времени — начало месяца, как у остальных', () async {
      await enableReminder();
      await rated('Дюна', rating: 10, yearsAgo: 4);

      final reminder = (await notifications()).firstWhere(
        (n) => n.kind == NotificationKind.revisit,
      );
      final now = DateTime.now();
      expect(reminder.at, DateTime(now.year, now.month));
    });
  });
}
