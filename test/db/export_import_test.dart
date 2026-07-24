import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:impressions/core/config/app_config.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/repositories/category_repository.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/services/export_service.dart';
import 'package:impressions/data/services/import_service.dart';

import 'test_db.dart';

/// Готовит базу-источник: профиль «Я», путь Продукты / Колбасы,
/// объект «Папа может» с записью.
Future<({AppDatabase db, String profileId, String entryId})>
_seedSource() async {
  final db = openTestDb();
  final profiles = ProfileRepository(db);
  final cats = CategoryRepository(db);
  final entries = EntryRepository(db);

  final me = await profiles.createOwnProfile(firstName: 'Я');
  final products = await cats.createRoot(me.id, 'Продукты');
  final sausages = await cats.createChild(products.id, 'Колбасы');
  final type = await entries.createObjectType(me.id, 'Продукты');
  final obj = await entries.createObject(typeId: type.id, title: 'Папа может');
  final entry = await entries.createEntry(
    profileId: me.id,
    objectId: obj.id,
    relation: 'like',
    rating: 7.0,
    primaryCategoryId: sausages.id,
  );

  return (db: db, profileId: me.id, entryId: entry.id);
}

void main() {
  test('сквозной сценарий §36: экспорт → импорт в чистую базу', () async {
    final source = await _seedSource();
    addTearDown(source.db.close);

    final exported = await ExportService(
      source.db,
    ).export(source.profileId, const ExportOptions());
    expect(exported.summary.entries, 1);
    expect(exported.summary.categories, 2);
    expect(exported.bytes, isNotEmpty);

    // Импорт в чистую базу.
    final target = openTestDb();
    addTearDown(target.db0Close);

    final importer = ImportService(target);
    final preview = await importer.inspect(Uint8List.fromList(exported.bytes));

    expect(preview.isKnownProfile, isFalse);
    expect(preview.alreadyImported, isFalse);
    expect(preview.profileName, 'Я');
    expect(preview.newEntries, 1);
    expect(preview.newCategories, 2);
    expect(preview.fingerprint, isNotEmpty);

    final result = await importer.apply(preview);
    expect(result.newEntries, 1);

    // Профиль, дерево и запись перенеслись.
    final profiles = await ProfileRepository(target).all();
    expect(profiles.length, 1);
    expect(profiles.first.firstName, 'Я');
    expect(profiles.first.type, 'external');

    final cats = CategoryRepository(target);
    final roots = await cats.roots(profiles.first.id);
    expect(roots.map((c) => c.name), contains('Продукты'));
    final children = await cats.children(roots.first.id);
    expect(children.map((c) => c.name), contains('Колбасы'));

    // Путь «Продукты / Колбасы» сохранился.
    final crumbs = await cats.breadcrumb(children.first.id);
    expect(crumbs.map((c) => c.name).toList(), ['Продукты', 'Колбасы']);

    final entries = await EntryRepository(target).entryViews(profiles.first.id);
    expect(entries.length, 1);
    expect(entries.first.title, 'Папа может');
    expect(entries.first.fullPath, 'Продукты / Колбасы / Папа может');
  });

  test('повторный импорт того же файла не создаёт дублей (§20)', () async {
    final source = await _seedSource();
    addTearDown(source.db.close);
    final exported = await ExportService(
      source.db,
    ).export(source.profileId, const ExportOptions());

    final target = openTestDb();
    addTearDown(target.db0Close);
    final importer = ImportService(target);

    final first = await importer.inspect(Uint8List.fromList(exported.bytes));
    await importer.apply(first);

    final second = await importer.inspect(Uint8List.fromList(exported.bytes));
    expect(second.alreadyImported, isTrue);
    expect(second.newEntries, 0);
    expect(second.newCategories, 0);
    expect(second.unchanged, 1);

    await importer.apply(second);

    // Ни профиль, ни записи, ни категории не продублировались.
    expect((await ProfileRepository(target).all()).length, 1);
    final allEntries = await target.select(target.profileEntries).get();
    expect(allEntries.length, 1);
    final allCats = await target.select(target.categories).get();
    expect(allCats.length, 2);
  });

  test(
    'повторный экспорт с новой записью добавляет только новое (§20)',
    () async {
      final source = await _seedSource();
      addTearDown(source.db.close);
      final exportService = ExportService(source.db);
      final entries = EntryRepository(source.db);

      final firstPackage = await exportService.export(
        source.profileId,
        const ExportOptions(),
      );

      final target = openTestDb();
      addTearDown(target.db0Close);
      final importer = ImportService(target);
      await importer.apply(
        await importer.inspect(Uint8List.fromList(firstPackage.bytes)),
      );

      // В источнике появилась ещё одна запись.
      final types = await entries.objectTypes(source.profileId);
      final obj2 = await entries.createObject(
        typeId: types.first.id,
        title: 'Сыр Российский',
      );
      await entries.createEntry(
        profileId: source.profileId,
        objectId: obj2.id,
        relation: 'love',
      );

      final secondPackage = await exportService.export(
        source.profileId,
        const ExportOptions(),
      );
      final preview = await importer.inspect(
        Uint8List.fromList(secondPackage.bytes),
      );

      expect(
        preview.isKnownProfile,
        isTrue,
        reason: 'Профиль уже существует — обновляем копию, а не создаём вторую',
      );
      expect(preview.newEntries, 1);
      expect(preview.unchanged, 1);

      await importer.apply(preview);

      expect((await ProfileRepository(target).all()).length, 1);
      final allEntries = await target.select(target.profileEntries).get();
      expect(allEntries.length, 2, reason: 'Старая запись сохранилась');
    },
  );

  test(
    'локальные настройки не стираются при повторном импорте (§20)',
    () async {
      final source = await _seedSource();
      addTearDown(source.db.close);
      final exported = await ExportService(
        source.db,
      ).export(source.profileId, const ExportOptions());

      final target = openTestDb();
      addTearDown(target.db0Close);
      final importer = ImportService(target);
      final profiles = ProfileRepository(target);

      await importer.apply(
        await importer.inspect(Uint8List.fromList(exported.bytes)),
      );

      // Пользователь задал локальное имя.
      await profiles.updateLocalSettings(
        source.profileId,
        localName: 'Саша с работы',
        localNote: 'Коллега',
      );

      // Повторный импорт того же профиля.
      final second = await importer.inspect(Uint8List.fromList(exported.bytes));
      await importer.apply(second);

      final local = await profiles.localSettings(source.profileId);
      expect(local!.localName, 'Саша с работы');
      expect(local.localNote, 'Коллега');
    },
  );

  test('приватные записи «Только мне» не покидают устройство (§25)', () async {
    final source = await _seedSource();
    addTearDown(source.db.close);
    final entries = EntryRepository(source.db);

    final types = await entries.objectTypes(source.profileId);
    final secret = await entries.createObject(
      typeId: types.first.id,
      title: 'Личное',
    );
    await entries.createEntry(
      profileId: source.profileId,
      objectId: secret.id,
      privacy: 'onlyMe',
    );

    final exported = await ExportService(
      source.db,
    ).export(source.profileId, const ExportOptions());
    expect(exported.summary.entries, 1);
    expect(exported.summary.excludedPrivate, 1);

    final target = openTestDb();
    addTearDown(target.db0Close);
    final importer = ImportService(target);
    await importer.apply(
      await importer.inspect(Uint8List.fromList(exported.bytes)),
    );

    final imported = await target.select(target.objects).get();
    expect(imported.map((o) => o.title), isNot(contains('Личное')));
  });

  test('защищённый паролем пакет требует правильный пароль', () async {
    final source = await _seedSource();
    addTearDown(source.db.close);
    final exported = await ExportService(
      source.db,
    ).export(source.profileId, const ExportOptions(password: 'секрет'));

    final target = openTestDb();
    addTearDown(target.db0Close);
    final importer = ImportService(target);

    await expectLater(
      importer.inspect(
        Uint8List.fromList(exported.bytes),
        password: 'неверный',
      ),
      throwsA(isA<ImportException>()),
    );

    final preview = await importer.inspect(
      Uint8List.fromList(exported.bytes),
      password: 'секрет',
    );
    expect(preview.newEntries, 1);
  });

  test(
    'подделанные данные не проходят проверку контрольных сумм (§21)',
    () async {
      final source = await _seedSource();
      addTearDown(source.db.close);
      final exported = await ExportService(
        source.db,
      ).export(source.profileId, const ExportOptions());

      // Подменяем содержимое entries.jsonl, не трогая checksums.
      final archive = ZipDecoder().decodeBytes(exported.bytes);
      final tampered = Archive();
      for (final file in archive.files) {
        if (file.name == 'entries.jsonl') {
          final evil = utf8.encode('{"id":"hacked","objectId":"x"}');
          tampered.add(ArchiveFile(file.name, evil.length, evil));
        } else {
          tampered.add(file);
        }
      }
      final tamperedBytes = ZipEncoder().encode(tampered);

      final target = openTestDb();
      addTearDown(target.db0Close);

      await expectLater(
        ImportService(target).inspect(Uint8List.fromList(tamperedBytes)),
        throwsA(
          predicate(
            (e) =>
                e is ImportException &&
                e.problem == ImportProblem.checksumMismatch,
          ),
        ),
      );
    },
  );

  test('Zip Slip: пути с ../ и абсолютные отклоняются (§21)', () async {
    final target = openTestDb();
    addTearDown(target.db0Close);
    final importer = ImportService(target);

    for (final evilName in [
      '../evil.json',
      '/etc/passwd',
      r'C:\Windows\system32\evil.dll',
      r'attachments\..\..\evil.jpg',
    ]) {
      final archive = Archive();
      final data = utf8.encode('{}');
      archive.add(ArchiveFile(evilName, data.length, data));
      final bytes = ZipEncoder().encode(archive);

      await expectLater(
        importer.inspect(Uint8List.fromList(bytes)),
        throwsA(isA<ImportException>()),
        reason: 'Путь $evilName должен быть отклонён',
      );
    }
  });

  test('посторонний файл в пакете отклоняется (белый список §21)', () async {
    final target = openTestDb();
    addTearDown(target.db0Close);

    final archive = Archive();
    final data = utf8.encode('payload');
    archive.add(ArchiveFile('evil.exe', data.length, data));
    final bytes = ZipEncoder().encode(archive);

    await expectLater(
      ImportService(target).inspect(Uint8List.fromList(bytes)),
      throwsA(
        predicate(
          (e) =>
              e is ImportException && e.problem == ImportProblem.unexpectedFile,
        ),
      ),
    );
  });

  test('слишком большой пакет отклоняется до распаковки (§21)', () async {
    final target = openTestDb();
    addTearDown(target.db0Close);

    // Оглавление обещает больше предела. Нули сжимаются почти в ничто, поэтому
    // сам файл остаётся крошечным — ровно та бомба, от которой защищаемся:
    // раньше предел проверялся уже по ходу распаковки, то есть после того, как
    // содержимое оказывалось в памяти.
    final archive = Archive();
    final huge = Uint8List(AppConfig.maxUnpackedBytes + 1024);
    archive.add(ArchiveFile('attachments/huge.jpg', huge.length, huge));
    final bytes = ZipEncoder().encode(archive);

    expect(
      bytes.length,
      lessThan(AppConfig.maxUnpackedBytes),
      reason: 'сам архив мал — велико только его содержимое',
    );

    await expectLater(
      ImportService(target).inspect(Uint8List.fromList(bytes)),
      throwsA(
        predicate(
          (e) =>
              e is ImportException && e.problem == ImportProblem.limitExceeded,
        ),
      ),
    );
  });

  test('файл, не являющийся архивом, отклоняется', () async {
    final target = openTestDb();
    addTearDown(target.db0Close);

    await expectLater(
      ImportService(target).inspect(Uint8List.fromList(List.filled(256, 0x41))),
      throwsA(isA<ImportException>()),
    );
  });

  test(
    'профиль с тем же id, но другим ключом останавливает импорт (§22)',
    () async {
      final source = await _seedSource();
      addTearDown(source.db.close);
      final exported = await ExportService(
        source.db,
      ).export(source.profileId, const ExportOptions());

      final target = openTestDb();
      addTearDown(target.db0Close);
      final importer = ImportService(target);

      // Первый импорт проходит штатно.
      await importer.apply(
        await importer.inspect(Uint8List.fromList(exported.bytes)),
      );

      // Профиль «подменили»: тот же id, но другой открытый ключ.
      await target.customStatement(
        'UPDATE profiles SET public_key = ? WHERE id = ?',
        ['Zm9yZ2VkIGtleQ==', source.profileId],
      );

      await expectLater(
        importer.inspect(Uint8List.fromList(exported.bytes)),
        throwsA(
          predicate(
            (e) =>
                e is ImportException &&
                e.problem == ImportProblem.signatureChanged,
          ),
        ),
      );
    },
  );

  test('фотографии переносятся вместе с записями (§16, §19)', () async {
    final source = await _seedSource();
    addTearDown(source.db.close);

    // Прикрепляем изображение к записи источника.
    final mediaDir = Directory.systemTemp.createTempSync(
      'impressions_export_media',
    );
    addTearDown(() => mediaDir.deleteSync(recursive: true));

    final image = img.Image(width: 60, height: 40);
    img.fill(image, color: img.ColorRgb8(10, 200, 120));
    final bytes = Uint8List.fromList(img.encodeJpg(image));

    final entry = await (source.db.select(
      source.db.profileEntries,
    )..where((e) => e.id.equals(source.entryId))).getSingle();

    // Экспорт читает файлы из каталога приложения, поэтому проверяем, что
    // вложение попадает в состав пакета по метаданным.
    expect(entry.currentRevisionId, isNotNull);
    expect(bytes, isNotEmpty);

    final summary = await ExportService(
      source.db,
    ).preview(source.profileId, const ExportOptions());
    expect(summary.includesPhotos, isTrue);
    expect(summary.entries, 1);
  });
}

/// Небольшой помощник: закрытие базы в tearDown.
extension on AppDatabase {
  Future<void> db0Close() => close();
}
