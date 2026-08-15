import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/core/domain/entry_status.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/repositories/category_repository.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/repositories/year_review.dart';

import 'test_db.dart';

/// Итоги года (§14): ретроспектива вместо таблиц.
void main() {
  late AppDatabase db;
  late EntryRepository entries;
  late CategoryRepository cats;
  late ProfileRow me;
  late ObjectTypeRow films;

  setUp(() async {
    db = openTestDb();
    entries = EntryRepository(db);
    cats = CategoryRepository(db);
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    films = await entries.createObjectType(me.id, 'Фильмы');
  });

  tearDown(() => db.close());

  Future<ProfileEntryRow> add(
    String title, {
    DateTime? impressionDate,
    double? rating,
    String? relation,
    String? status,
    String? categoryId,
  }) async {
    final object = await entries.createObject(typeId: films.id, title: title);
    return entries.createEntry(
      profileId: me.id,
      objectId: object.id,
      impressionDate: impressionDate,
      rating: rating,
      relation: relation,
      status: status,
      primaryCategoryId: categoryId,
    );
  }

  test('пустой год отдаёт пустые итоги', () async {
    await add('Вне года', impressionDate: DateTime(2024, 5, 1));

    final review = await entries.yearReview(me.id, 2025);
    expect(review.isEmpty, isTrue);
    expect(review.total, 0);
  });

  test('считает год по дате впечатления', () async {
    await add('Январское', impressionDate: DateTime(2025, 1, 10));
    await add('Декабрьское', impressionDate: DateTime(2025, 12, 31, 23));
    await add('Прошлогоднее', impressionDate: DateTime(2024, 12, 31));
    await add('Следующее', impressionDate: DateTime(2026, 1, 1));

    final review = await entries.yearReview(me.id, 2025);
    expect(review.total, 2);
    expect(review.first?.title, 'Январское');
    expect(review.last?.title, 'Декабрьское');
  });

  test('запись без даты впечатления считается по дате заведения', () async {
    // Дату впечатления проставляют редко: считай итоги только по ней — и год
    // выглядел бы пустым.
    await add('Без даты');

    final review = await entries.yearReview(me.id, DateTime.now().year);
    expect(review.total, 1);
    expect(review.first?.title, 'Без даты');
  });

  test('лучшее идёт по убыванию оценки', () async {
    await add('Среднее', impressionDate: DateTime(2025, 3, 1), rating: 6);
    await add('Лучшее', impressionDate: DateTime(2025, 4, 1), rating: 9.5);
    await add('Хорошее', impressionDate: DateTime(2025, 5, 1), rating: 8);
    await add('Без оценки', impressionDate: DateTime(2025, 6, 1));

    final review = await entries.yearReview(me.id, 2025);
    expect(review.best.map((e) => e.title), ['Лучшее', 'Хорошее', 'Среднее']);
    expect(review.rated, 3);
    expect(review.averageRating, closeTo(7.83, 0.01));
  });

  test('ветка года считается по всей ветке', () async {
    final root = await cats.createRoot(me.id, 'Кино');
    final child = await cats.createChild(root.id, 'Сериалы');
    final other = await cats.createRoot(me.id, 'Книги');

    await add(
      'Раз',
      impressionDate: DateTime(2025, 2, 1),
      categoryId: child.id,
    );
    await add(
      'Два',
      impressionDate: DateTime(2025, 2, 2),
      categoryId: child.id,
    );
    await add(
      'Три',
      impressionDate: DateTime(2025, 2, 3),
      categoryId: other.id,
    );

    final review = await entries.yearReview(me.id, 2025);
    // «Кино» само по себе пусто, но в его ветке две записи — иначе корень
    // выглядел бы пустым, а всё лежало бы в подкатегории.
    expect(review.topCategory?.name, 'Кино');
    expect(review.topCategory?.count, 2);
  });

  test('самый насыщенный месяц, отношения и стадии', () async {
    for (var i = 1; i <= 3; i++) {
      await add(
        'Март $i',
        impressionDate: DateTime(2025, 3, i),
        relation: 'love',
        status: EntryStatus.doneKey,
      );
    }
    await add('Май', impressionDate: DateTime(2025, 5, 1), relation: 'like');
    await add(
      'Начатое',
      impressionDate: DateTime(2025, 6, 1),
      status: EntryStatus.inProgress,
    );

    final review = await entries.yearReview(me.id, 2025);
    expect(review.busiestMonth?.month.month, 3);
    expect(review.busiestMonth?.count, 3);
    expect(review.byRelation['love'], 3);
    expect(review.byRelation['like'], 1);
    // Доведённое до конца — записи на завершающей стадии.
    expect(review.finished, 3);
  });

  test('новые ветки считаются по году их появления', () async {
    await cats.createRoot(me.id, 'Заведено сейчас');
    // Запись без даты впечатления попадает в текущий год — вместе с веткой.
    await add('Запись этого года');
    await add('Запись 2025-го', impressionDate: DateTime(2025, 1, 1));

    final thisYear = await entries.yearReview(me.id, DateTime.now().year);
    expect(thisYear.newCategories, 1);

    final review2025 = await entries.yearReview(me.id, 2025);
    expect(
      review2025.newCategories,
      DateTime.now().year == 2025 ? 1 : 0,
      reason: 'ветку завели сегодня, а не в 2025-м',
    );
  });

  test('архивные записи в итоги не попадают', () async {
    final entry = await add('Убранное', impressionDate: DateTime(2025, 7, 1));
    await add('Осталось', impressionDate: DateTime(2025, 7, 2));
    await entries.archiveEntry(entry.id);

    final review = await entries.yearReview(me.id, 2025);
    expect(review.total, 1);
    expect(review.first?.title, 'Осталось');
  });
}
