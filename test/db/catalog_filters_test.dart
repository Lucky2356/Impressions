import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/models/entry_view.dart';
import 'package:impressions/data/repositories/category_repository.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/services/image_service.dart';

import 'test_db.dart';

/// Направление сортировки и отбор «что я не доделал».
///
/// Порядок был задан жёстко: названия только А→Я, оценки и даты только от
/// больших. А фильтры отвечали лишь на «покажи вот такие» — найти записи без
/// оценки или сложенные мимо категорий было нельзя вовсе.
void main() {
  late AppDatabase db;
  late EntryRepository entries;
  late ProfileRow me;
  late ObjectTypeRow type;

  setUp(() async {
    db = openTestDb();
    entries = EntryRepository(db);
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    type = await entries.createObjectType(me.id, 'Продукты');
  });

  tearDown(() => db.close());

  Future<ProfileEntryRow> add(
    String title, {
    double? rating,
    String? categoryId,
  }) async {
    final object = await entries.createObject(typeId: type.id, title: title);
    return entries.createEntry(
      profileId: me.id,
      objectId: object.id,
      rating: rating,
      primaryCategoryId: categoryId,
    );
  }

  Future<List<String>> titles({
    EntrySort sort = EntrySort.recent,
    bool reverse = false,
    bool withoutRating = false,
    bool withoutCategory = false,
    bool withoutPhoto = false,
  }) async {
    final views = await entries.entryViews(
      me.id,
      sort: sort,
      reverseSort: reverse,
      withoutRating: withoutRating,
      withoutCategory: withoutCategory,
      withoutPhoto: withoutPhoto,
    );
    return [for (final v in views) v.title];
  }

  test('обратный порядок разворачивает именно обычный', () async {
    await add('Ананас', rating: 3);
    await add('Банан', rating: 9);
    await add('Вишня', rating: 6);

    expect(await titles(sort: EntrySort.title), ['Ананас', 'Банан', 'Вишня']);
    expect(await titles(sort: EntrySort.title, reverse: true), [
      'Вишня',
      'Банан',
      'Ананас',
    ]);

    // У оценок обычный порядок — от больших, значит обратный показывает
    // «что понравилось меньше всего».
    expect(await titles(sort: EntrySort.rating), ['Банан', 'Вишня', 'Ананас']);
    expect(
      await titles(sort: EntrySort.rating, reverse: true).then((t) => t.first),
      'Ананас',
    );
  });

  test('«без оценки» показывает только неоценённое', () async {
    await add('Оценено', rating: 7);
    await add('Не оценено');

    expect(await titles(withoutRating: true), ['Не оценено']);
  });

  test('«без категории» показывает сложенное мимо полок', () async {
    final branch = await CategoryRepository(db).createRoot(me.id, 'Колбасы');
    await add('В категории', categoryId: branch.id);
    await add('Без категории');

    expect(await titles(withoutCategory: true), ['Без категории']);
  });

  test('«без фотографии» не считает записи со снимком', () async {
    final media = Directory.systemTemp.createTempSync('impressions_filters');
    addTearDown(() => media.deleteSync(recursive: true));
    final images = ImageService(db, mediaDirectory: media);
    final withPhoto = await add('Со снимком');
    await add('Без снимка');

    final added = await images.addFromBytes(_jpeg());
    final attachment = switch (added) {
      ImageAdded(attachment: final a) => a,
      ImageDuplicate(attachment: final a) => a,
      ImageRejected() => null,
    };
    expect(attachment, isNotNull);
    await images.attachToEntry(
      entryId: withPhoto.id,
      attachmentId: attachment!.id,
      revisionId: withPhoto.currentRevisionId!,
    );

    expect(await titles(withoutPhoto: true), ['Без снимка']);
  });

  test('фильтры складываются друг с другом', () async {
    final branch = await CategoryRepository(db).createRoot(me.id, 'Колбасы');
    await add('Ни того ни другого');
    await add('Только категория', categoryId: branch.id);
    await add('Только оценка', rating: 5);

    expect(await titles(withoutRating: true, withoutCategory: true), [
      'Ни того ни другого',
    ]);
  });
}

/// Простая картинка — обработчику изображений нужен настоящий файл.
Uint8List _jpeg() {
  final image = img.Image(width: 40, height: 40);
  img.fill(image, color: img.ColorRgb8(120, 100, 100));
  return Uint8List.fromList(img.encodeJpg(image));
}
