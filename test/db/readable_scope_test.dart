import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/core/domain/relation.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/repositories/category_repository.dart';
import 'package:impressions/data/repositories/collection_repository.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/services/export_service.dart';
import 'package:impressions/data/services/readable_export_service.dart';

import 'test_db.dart';

/// Выгрузка «для чтения» должна брать тот же объём, что показан в панели
/// «Что войдёт в файл».
///
/// До 1.11.0 таблица и текст всегда забирали весь профиль: человек выбирал
/// ветку, видел «войдёт две записи» и получал файл на всё подряд.
void main() {
  late AppDatabase db;
  late String profileId;
  late String productsId;
  late String booksId;
  late String collectionId;

  setUp(() async {
    db = openTestDb();
    final profiles = ProfileRepository(db);
    final cats = CategoryRepository(db);
    final entries = EntryRepository(db);
    final collections = CollectionRepository(db);

    final me = await profiles.createOwnProfile(firstName: 'Я');
    profileId = me.id;

    final products = await cats.createRoot(me.id, 'Продукты');
    final sausages = await cats.createChild(products.id, 'Колбасы');
    final books = await cats.createRoot(me.id, 'Книги');
    productsId = products.id;
    booksId = books.id;

    final type = await entries.createObjectType(me.id, 'Всё подряд');

    Future<String> add(String title, String categoryId) async {
      final obj = await entries.createObject(typeId: type.id, title: title);
      final entry = await entries.createEntry(
        profileId: me.id,
        objectId: obj.id,
        relation: Relation.like.name,
        rating: 7.0,
        primaryCategoryId: categoryId,
      );
      return entry.id;
    }

    final sausage = await add('Папа может', sausages.id);
    await add('Сыр', products.id);
    final novel = await add('Война и мир', books.id);

    final collection = await collections.create(me.id, 'Любимое');
    collectionId = collection.id;
    await collections.addEntry(collection.id, sausage);
    await collections.addEntry(collection.id, novel);
  });

  tearDown(() => db.close());

  test('весь профиль — все записи', () async {
    final ids = await ExportService(
      db,
    ).scopedEntryIds(profileId, const ExportOptions());
    expect(ids.length, 3);
  });

  /// Готовая таблица — то, что человек в итоге открывает.
  Future<String> csv(ExportOptions options) => ExportService(db).readable(
    profileId,
    options,
    format: ReadableFormat.csv,
    profileName: 'Я',
    relationLabel: (name) => name ?? '',
  );

  test('в таблицу ветки попадает ветка, а не весь профиль', () async {
    final text = await csv(
      ExportOptions(mode: ExportMode.branch, categoryId: productsId),
    );

    expect(text, contains('Папа может'));
    expect(text, contains('Сыр'));
    expect(
      text,
      isNot(contains('Война и мир')),
      reason: 'книга из соседней ветки в выгрузку попадать не должна',
    );
  });

  test('в таблицу подборки попадает подборка', () async {
    final text = await csv(
      ExportOptions(mode: ExportMode.collection, collectionId: collectionId),
    );

    expect(text, contains('Папа может'));
    expect(text, contains('Война и мир'));
    expect(text, isNot(contains('Сыр')));
  });

  test('ветка с одной записью отдаёт одну строку', () async {
    final text = await csv(
      ExportOptions(mode: ExportMode.branch, categoryId: booksId),
    );

    // Заголовок плюс одна запись.
    expect(
      const LineSplitter().convert(text).where((l) => l.isNotEmpty).length,
      2,
    );
    expect(text, contains('Война и мир'));
  });

  test('состав в панели и объём выгрузки сходятся', () async {
    const options = ExportOptions();
    final summary = await ExportService(db).preview(profileId, options);
    final ids = await ExportService(db).scopedEntryIds(profileId, options);
    expect(ids.length, summary.entries);
  });
}
