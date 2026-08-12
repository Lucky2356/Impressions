import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/repositories/category_repository.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/services/csv_import_service.dart';

import 'test_db.dart';

/// Перенос таблицы в записи.
void main() {
  late AppDatabase db;
  late EntryRepository entries;
  late CategoryRepository categories;
  late ProfileRow me;
  const service = CsvImportService();

  setUp(() async {
    db = openTestDb();
    entries = EntryRepository(db);
    categories = CategoryRepository(db);
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
  });

  tearDown(() => db.close());

  Future<CsvImportResult> importText(String text) async {
    final preview = service.inspect(Uint8List.fromList(utf8.encode(text)));
    return service.apply(
      profileId: me.id,
      rows: preview.rows,
      entries: entries,
      categories: categories,
    );
  }

  test('записи заводятся вместе с типами и ветками категорий', () async {
    final result = await importText(
      'Название;Тип;Категория;Отношение;Оценка\n'
      'Папа может;Продукты;Продукты / Колбасы;Нравится;7.5\n'
      'Интерстеллар;Фильмы;Фильмы;Обожаю;9\n',
    );

    expect(result.created, 2);
    expect(result.typesCreated, 2);
    // «Продукты», «Колбасы» и «Фильмы» — три новые категории.
    expect(result.categoriesCreated, 3);

    final views = await entries.entryViews(me.id);
    final sausage = views.firstWhere((e) => e.title == 'Папа может');
    expect(sausage.categoryPath, ['Продукты', 'Колбасы']);
    expect(sausage.rating, 7.5);
    expect(sausage.relation, 'like');
    expect(sausage.typeName, 'Продукты');
  });

  test('уже заведённые типы и категории переиспользуются', () async {
    final type = await entries.createObjectType(me.id, 'Продукты');
    final food = await categories.createRoot(me.id, 'Продукты');
    await categories.createChild(food.id, 'Колбасы');

    final result = await importText(
      'Название;Тип;Категория\nДокторская;Продукты;Продукты / Колбасы\n',
    );

    expect(result.typesCreated, 0);
    expect(result.categoriesCreated, 0);
    final view = (await entries.entryViews(me.id)).single;
    expect(view.categoryPath, ['Продукты', 'Колбасы']);
    expect((await entries.objectTypes(me.id)).map((t) => t.id), [type.id]);
  });

  test('без типа запись попадает в первый заведённый', () async {
    await entries.createObjectType(me.id, 'Продукты');

    await importText('Название\nМолоко\n');

    expect((await entries.entryViews(me.id)).single.typeName, 'Продукты');
  });

  test('в пустом профиле заводится тип «Разное»', () async {
    final result = await importText('Название\nМолоко\n');

    expect(result.typesCreated, 1);
    expect((await entries.entryViews(me.id)).single.typeName, 'Разное');
  });

  test('заметка и дата доезжают до записи', () async {
    await importText(
      'Название;Заметка;Дата\nЧай;Крепкий, но вкусный;31.12.2026\n',
    );

    final entry = (await db.select(db.profileEntries).get()).single;
    expect(entry.detailedNote, 'Крепкий, но вкусный');
    expect(entry.impressionDate, DateTime(2026, 12, 31));
  });

  test('пустая таблица ничего не заводит', () async {
    final result = await importText('Название;Оценка\n');

    expect(result.created, 0);
    expect(await entries.entryViews(me.id), isEmpty);
  });
}
