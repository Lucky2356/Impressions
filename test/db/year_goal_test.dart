import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/repositories/settings_repository.dart';
import 'package:impressions/data/repositories/year_review.dart';
import 'package:impressions/features/year/year_providers.dart';

import 'test_db.dart';

/// Цель на год: счёт пройденного и хранение самой цели.
void main() {
  late AppDatabase db;
  late EntryRepository entries;
  late SettingsRepository settings;
  late ProfileRow me;
  late ObjectTypeRow films;

  setUp(() async {
    db = openTestDb();
    entries = EntryRepository(db);
    settings = SettingsRepository(db);
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    films = await entries.createObjectType(me.id, 'Фильмы');
  });

  tearDown(() => db.close());

  Future<ProfileEntryRow> add(
    String title, {
    DateTime? impressionDate,
    String? profileId,
  }) async {
    final object = await entries.createObject(typeId: films.id, title: title);
    return entries.createEntry(
      profileId: profileId ?? me.id,
      objectId: object.id,
      impressionDate: impressionDate,
    );
  }

  group('счёт пройденного', () {
    test('считает впечатления года', () async {
      await add('Январское', impressionDate: DateTime(2026, 1, 10));
      await add('Декабрьское', impressionDate: DateTime(2026, 12, 31, 23));
      await add('Прошлогоднее', impressionDate: DateTime(2025, 12, 31));
      // И соседний год сверху: дату впечатления ставят и будущую — билет
      // куплен, концерт в следующем году, — и в этот год она не входит.
      await add('Будущее', impressionDate: DateTime(2027, 1, 1));

      expect(await entries.yearCount(me.id, 2026), 2);
    });

    test('запись без даты впечатления считается по дате заведения', () async {
      // Дату впечатления проставляют редко, и без этого цель выглядела бы
      // непройденной у того, кто просто заводит записи.
      await add('Без даты');

      expect(await entries.yearCount(me.id, DateTime.now().year), 1);
    });

    test('архивное в счёт не идёт', () async {
      final entry = await add('Архивное', impressionDate: DateTime(2026, 3, 1));
      await entries.archiveEntry(entry.id);

      expect(await entries.yearCount(me.id, 2026), 0);
    });

    test('чужой профиль в счёт не идёт', () async {
      final other = await ProfileRepository(
        db,
      ).createOwnProfile(firstName: 'Он', type: 'myOtherDevice');
      await add(
        'Чужое',
        impressionDate: DateTime(2026, 3, 1),
        profileId: other.id,
      );

      expect(await entries.yearCount(me.id, 2026), 0);
    });

    test('пустой год отдаёт ноль, а не ошибку', () async {
      expect(await entries.yearCount(me.id, 2019), 0);
    });
  });

  group('хранение цели', () {
    test('непоставленная цель — ноль', () async {
      expect(await settings.yearGoal(2026), 0);
    });

    test('цель сохраняется по году', () async {
      await settings.setYearGoal(2026, 50);
      await settings.setYearGoal(2025, 30);

      expect(await settings.yearGoal(2026), 50);
      expect(await settings.yearGoal(2025), 30);
    });

    test('нулевая цель убирает поставленную', () async {
      await settings.setYearGoal(2026, 50);
      await settings.setYearGoal(2026, 0);

      expect(await settings.yearGoal(2026), 0);
    });

    test('невыполнимое значение считается отсутствием цели', () async {
      // В таблице настроек могла оказаться чужая строка: цель, которую нельзя
      // выполнить, — это отсутствие цели, а не цель «минус пять».
      await settings.set(SettingKeys.yearGoalOf(2026), '-5');
      expect(await settings.yearGoal(2026), 0);

      await settings.set(SettingKeys.yearGoalOf(2026), 'полсотни');
      expect(await settings.yearGoal(2026), 0);
    });
  });

  group('остатки', () {
    YearGoal goal(int done, int target, DateTime now) =>
        YearGoal(year: 2026, goal: target, done: done, now: now);

    test('непройденное считается остатком', () {
      final g = goal(34, 50, DateTime(2026, 7, 1));
      expect(g.left, 16);
      expect(g.reached, isFalse);
      expect(g.share, closeTo(0.68, 0.001));
    });

    test('перевыполненная цель не уходит в минус', () {
      final g = goal(60, 50, DateTime(2026, 7, 1));
      expect(g.reached, isTrue);
      expect(g.left, 0);
      // Полоса не уезжает за край: доля больше единицы её бы сломала.
      expect(g.share, 1);
    });

    test('дни до конца года считаются от сегодняшнего дня', () {
      expect(goal(1, 50, DateTime(2026, 12, 31, 23, 59)).daysLeft, 1);
      expect(goal(1, 50, DateTime(2026, 12, 1)).daysLeft, 31);
    });

    test('у прошлого года времени не осталось', () {
      // «До конца года ноль дней» — единственное правдивое, что можно сказать
      // про год, который кончился.
      expect(goal(1, 50, DateTime(2027, 3, 1)).daysLeft, 0);
    });
  });
}
