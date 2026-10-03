import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/services/export_service.dart';
import 'package:impressions/data/services/image_service.dart';
import 'package:impressions/features/entry/entry_providers.dart';
import 'package:impressions/features/entry/entry_share_card.dart';

import 'test_db.dart';

/// Карточка записи картинкой: что на неё попадает.
///
/// Решает это приватность самой записи, а не желание поделиться: картинка —
/// такой же выход наружу, как файл обмена, и правила здесь те же.
void main() {
  // Обработчик изображений ходит в платформу за каталогом: без привязки
  // канал падает на первом же вызове.
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late EntryRepository entries;
  late ProfileRow me;
  late ObjectTypeRow books;
  late ProviderContainer container;

  setUp(() async {
    // Путь к обложке строится от каталога приложения: без подмены канала
    // path_provider запрос за ней не возвращается вовсе.
    final media = Directory.systemTemp.createTempSync('impressions_card_media');
    addTearDown(() {
      if (media.existsSync()) media.deleteSync(recursive: true);
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => media.path,
        );
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            null,
          ),
    );

    db = openTestDb();
    entries = EntryRepository(db);
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    books = await entries.createObjectType(me.id, 'Книги');
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

  /// Запись с настоящей фотографией: её обложку и прячет пометка.
  Future<EntryCardContent> withPhoto({String? privacy}) async {
    final media = Directory.systemTemp.createTempSync('impressions_card');
    addTearDown(() => media.deleteSync(recursive: true));
    final images = ImageService(db, mediaDirectory: media);

    final object = await entries.createObject(typeId: books.id, title: 'Дюна');
    final entry = await entries.createEntry(
      profileId: me.id,
      objectId: object.id,
    );
    final added = await images.addFromBytes(_jpeg());
    final attachment = switch (added) {
      ImageAdded(attachment: final a) => a,
      ImageDuplicate(attachment: final a) => a,
      ImageRejected() => null,
    };
    expect(attachment, isNotNull);
    await images.attachToEntry(
      entryId: entry.id,
      attachmentId: attachment!.id,
      revisionId: entry.currentRevisionId!,
    );
    if (privacy != null) {
      await entries.updateEntry(entry.id, privacy: privacy);
    }

    final detail = await container.read(entryDetailProvider(entry.id).future);
    return EntryCardContent.of(detail!);
  }

  Future<EntryCardContent> content(
    String title, {
    double? rating,
    String? shortNote,
    String? detailedNote,
    String? privacy,
  }) async {
    final object = await entries.createObject(typeId: books.id, title: title);
    final entry = await entries.createEntry(
      profileId: me.id,
      objectId: object.id,
      rating: rating,
      shortNote: shortNote,
      detailedNote: detailedNote,
    );
    if (privacy != null) {
      await entries.updateEntry(entry.id, privacy: privacy);
    }
    final detail = await container.read(entryDetailProvider(entry.id).future);
    return EntryCardContent.of(detail!);
  }

  group('что попадает на картинку', () {
    test('название, тип и оценка', () async {
      final card = await content('Дюна', rating: 9.5);

      expect(card.title, 'Дюна');
      expect(card.typeName, 'Книги');
      expect(card.rating, 9.5);
    });

    test('короткая заметка важнее подробной', () async {
      final card = await content(
        'Дюна',
        shortNote: 'Коротко',
        detailedNote: 'Длинно и подробно',
      );

      expect(card.note, 'Коротко');
    });

    test('без короткой берётся подробная', () async {
      final card = await content('Дюна', detailedNote: 'Длинно и подробно');

      expect(card.note, 'Длинно и подробно');
    });

    test('стёртая заметка считается отсутствующей', () async {
      // Поле стирают, а не убирают: пустая строка и пробелы — это отсутствие
      // заметки, а не пустая заметка на картинке.
      final card = await content('Дюна', shortNote: '  ', detailedNote: '');

      expect(card.note, isNull);
    });

    test('длинная заметка укорачивается по пробелу', () async {
      final long = List.filled(60, 'слово').join(' ');
      final card = await content('Дюна', shortNote: long);

      expect(
        card.note!.length,
        lessThanOrEqualTo(EntryCardContent.noteLimit + 1),
      );
      expect(card.note, endsWith('…'));
      // Обрывок посреди слова читался бы как сбой.
      expect(card.note, isNot(contains('слов…')));
    });

    test('переводы строк в заметке схлопываются', () async {
      // Картинку смотрят: заметка в пять строк превращает её в страницу
      // текста.
      final card = await content('Дюна', shortNote: 'Первое\n\nВторое');

      expect(card.note, 'Первое Второе');
    });
  });

  group('приватность', () {
    test('«только мне» картинку не разрешает', () {
      expect(EntryCardContent.allowed(ExportService.privacyOnlyMe), isFalse);
      expect(EntryCardContent.allowed('shareable'), isTrue);
      expect(EntryCardContent.allowed(ExportService.privacyNoNote), isTrue);
      expect(EntryCardContent.allowed(ExportService.privacyNoPhotos), isTrue);
    });

    test('«передавать без заметки» убирает заметку', () async {
      final card = await content(
        'Дюна',
        shortNote: 'Личное',
        privacy: ExportService.privacyNoNote,
      );

      expect(card.note, isNull);
      expect(card.title, 'Дюна', reason: 'сама запись при этом остаётся');
    });

    test('обложка попадает на картинку', () async {
      expect((await withPhoto()).coverPath, isNotNull);
    });

    test('«без фотографий» убирает обложку', () async {
      final card = await withPhoto(privacy: ExportService.privacyNoPhotos);

      expect(
        card.coverPath,
        isNull,
        reason: 'фотография есть, но передавать её человек запретил',
      );
    });
  });

  group('имя файла', () {
    test('включает название записи', () async {
      final card = await content('Дюна');

      expect(card.fileName, endsWith('.png'));
      expect(card.fileName, contains('Дюна'));
    });

    test('слэш из названия в имя файла не попадает', () async {
      // «AC/DC» создал бы вложенную папку, а то и обрубил бы путь.
      final card = await content('AC/DC — лучшее');

      expect(card.fileName, isNot(contains('/')));
      expect(card.fileName, contains('AC DC'));
    });

    test('длинное название обрезается', () async {
      final card = await content('Очень длинное название ' * 10);

      expect(card.fileName.length, lessThan(80));
    });

    test('название из одних знаков не оставляет пустого имени', () async {
      final card = await content('«»!');

      expect(card.fileName, endsWith('card.png'));
    });
  });
}

/// Простая картинка — обработчику изображений нужен настоящий файл.
Uint8List _jpeg() {
  final image = img.Image(width: 40, height: 40);
  img.fill(image, color: img.ColorRgb8(120, 100, 100));
  return Uint8List.fromList(img.encodeJpg(image));
}
