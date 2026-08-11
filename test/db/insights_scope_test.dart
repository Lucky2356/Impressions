import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/repositories/category_repository.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';

import 'test_db.dart';

/// Срезы статистики: за период и по ветке категорий.
///
/// Экран считал по всему профилю: вопрос «а что было в этом году» задать было
/// нечем, хотя данные для него есть.
void main() {
  late AppDatabase db;
  late EntryRepository entries;
  late CategoryRepository categories;
  late ProfileRow me;
  late ObjectTypeRow type;

  setUp(() async {
    db = openTestDb();
    entries = EntryRepository(db);
    categories = CategoryRepository(db);
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    type = await entries.createObjectType(me.id, 'Продукты');
  });

  tearDown(() => db.close());

  /// Запись с подставленной датой заведения: срез по периоду смотрит на неё.
  Future<ProfileEntryRow> add(
    String title, {
    String? categoryId,
    double? rating,
    DateTime? createdAt,
  }) async {
    final object = await entries.createObject(typeId: type.id, title: title);
    final entry = await entries.createEntry(
      profileId: me.id,
      objectId: object.id,
      rating: rating,
      primaryCategoryId: categoryId,
    );
    if (createdAt != null) {
      await (db.update(db.profileEntries)..where((e) => e.id.equals(entry.id)))
          .write(ProfileEntriesCompanion(createdAt: Value(createdAt)));
    }
    return entry;
  }

  test('за год попадают только записи года', () async {
    final now = DateTime.now();
    await add('Свежая', rating: 8);
    await add('Позапрошлогодняя', rating: 2, createdAt: DateTime(now.year - 2));

    final all = await entries.insights(me.id);
    final year = await entries.insights(
      me.id,
      since: DateTime(now.year - 1, now.month, now.day),
    );

    expect(all.total, 2);
    expect(year.total, 1);
    expect(year.averageRating, 8);
  });

  test('срез по ветке считает вместе с подкатегориями', () async {
    final food = await categories.createRoot(me.id, 'Еда');
    final sausages = await categories.createChild(food.id, 'Колбасы');
    final films = await categories.createRoot(me.id, 'Фильмы');
    await add('Докторская', categoryId: sausages.id);
    await add('Сыр', categoryId: food.id);
    await add('Интерстеллар', categoryId: films.id);

    final branch = await entries.insights(
      me.id,
      categoryIds: [food.id, sausages.id],
    );

    expect(branch.total, 2);
    expect(branch.topCategories.map((c) => c.name), contains('Еда'));
    expect(branch.topCategories.map((c) => c.name), isNot(contains('Фильмы')));
  });

  test(
    'пустой срез отдаёт пустую статистику, а не считает весь профиль',
    () async {
      final films = await categories.createRoot(me.id, 'Фильмы');
      await add('Докторская');

      final empty = await entries.insights(me.id, categoryIds: [films.id]);

      expect(empty.total, 0);
      expect(empty.isEmpty, isTrue);
    },
  );

  test('оба среза вместе', () async {
    final now = DateTime.now();
    final food = await categories.createRoot(me.id, 'Еда');
    await add('Свежая колбаса', categoryId: food.id);
    await add(
      'Старая колбаса',
      categoryId: food.id,
      createdAt: DateTime(now.year - 3),
    );
    await add('Свежий фильм');

    final scoped = await entries.insights(
      me.id,
      since: DateTime(now.year - 1, now.month, now.day),
      categoryIds: [food.id],
    );

    expect(scoped.total, 1);
  });
}
