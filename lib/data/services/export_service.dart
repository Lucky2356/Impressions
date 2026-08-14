import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../../core/config/app_config.dart';
import '../../core/utils/hashing.dart';
import '../../core/utils/ids.dart';
import '../db/database.dart';
import '../repositories/entry_repository.dart';
import 'image_service.dart';
import 'key_service.dart';
import 'readable_export_service.dart';

/// Контрольные суммы файлов пакета.
///
/// Функция верхнего уровня: уходит в [Isolate.run], а замыкание не должно
/// тянуть за собой ссылки на объекты вызывающего изолята.
Map<String, Object?> _checksumsOf(Map<String, List<int>> files) => {
  for (final entry in files.entries) entry.key: Hashing.sha256Hex(entry.value),
};

/// Собирает zip из готовых файлов пакета.
List<int> _zipOf(Map<String, List<int>> files) {
  final archive = Archive();
  for (final entry in files.entries) {
    archive.add(ArchiveFile(entry.key, entry.value.length, entry.value));
  }
  return ZipEncoder().encode(archive);
}

/// Режим экспорта (§19).
enum ExportMode { full, branch, collection, selection, backup }

/// Параметры экспорта (§19, §25).
class ExportOptions {
  const ExportOptions({
    this.mode = ExportMode.full,
    this.includePhotos = true,
    this.password,
    this.categoryId,
    this.collectionId,
    this.entryIds,
    this.since,
  });

  final ExportMode mode;
  final bool includePhotos;

  /// Пароль для защищённого пакета; null — обычный пакет.
  final String? password;

  /// Ветка категории для режима [ExportMode.branch].
  final String? categoryId;
  final String? collectionId;
  final Set<String>? entryIds;

  /// Только изменения после даты.
  final DateTime? since;

  bool get isProtected => password != null && password!.isNotEmpty;
}

/// Состав экспорта — показывается пользователю до сохранения файла (§19).
class ExportSummary {
  const ExportSummary({
    required this.profileName,
    required this.entries,
    required this.categories,
    required this.subcategories,
    required this.objects,
    required this.revisions,
    required this.attachments,
    required this.excludedPrivate,
    required this.includesPhotos,
    required this.protected,
    required this.mode,
    this.byteSize,
  });

  final String profileName;
  final int entries;
  final int categories;
  final int subcategories;
  final int objects;
  final int revisions;
  final int attachments;

  /// Сколько записей исключено из-за приватности «Только мне» (§25).
  final int excludedPrivate;

  final bool includesPhotos;
  final bool protected;
  final ExportMode mode;
  final int? byteSize;
}

/// Результат экспорта.
class ExportResult {
  const ExportResult({
    required this.bytes,
    required this.summary,
    required this.packageId,
  });

  final List<int> bytes;
  final ExportSummary summary;
  final String packageId;
}

/// Сборка подписанного контейнера профиля `*.impressions` (§19).
class ExportService {
  ExportService(this.db) : _keys = KeyService(db), _images = ImageService(db);

  final AppDatabase db;
  final KeyService _keys;
  final ImageService _images;

  /// Приватность, при которой запись не покидает устройство (§25).
  static const String privacyOnlyMe = 'onlyMe';
  static const String privacyNoNote = 'shareNoNote';
  static const String privacyNoPhotos = 'shareNoPhotos';

  /// Собирает данные для экспорта и считает состав, ничего не записывая.
  Future<ExportSummary> preview(String profileId, ExportOptions options) async {
    final data = await _collect(profileId, options);
    return data.summary;
  }

  /// Экспортирует профиль в байты контейнера.
  Future<ExportResult> export(String profileId, ExportOptions options) async {
    final data = await _collect(profileId, options);
    final packageId = Ids.newId();

    final files = <String, List<int>>{};

    files['profile.json'] = _json(data.profileJson);
    files['devices.json'] = _json(data.devicesJson);
    files['categories.jsonl'] = _jsonl(data.categoriesJson);
    files['objects.jsonl'] = _jsonl(data.objectsJson);
    files['entries.jsonl'] = _jsonl(data.entriesJson);
    files['revisions.jsonl'] = _jsonl(data.revisionsJson);

    for (final att in data.attachments) {
      final path = await _images.absolutePath(att.storagePath);
      final file = File(path);
      if (file.existsSync()) {
        files['attachments/${att.sha256}.jpg'] = await file.readAsBytes();
      }
    }

    final key = await _keys.ensureKeyPair(profileId);
    final manifest = <String, Object?>{
      'formatVersion': AppConfig.exportFormatVersion,
      'packageId': packageId,
      'profileId': profileId,
      'profilePublicKey': key.publicKey,
      'profileFingerprint': key.fingerprint,
      'exportMode': options.mode.name,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'counts': {
        'entries': data.summary.entries,
        'categories': data.summary.categories,
        'objects': data.summary.objects,
        'revisions': data.summary.revisions,
        'attachments': data.summary.attachments,
      },
      'includesPhotos': options.includePhotos,
      'protected': options.isProtected,
    };
    files['manifest.json'] = _json(manifest);

    // Контрольные суммы всех файлов, кроме самих checksums и signature.
    // Считаются в отдельном изоляте: с фотографиями пакет весит десятки
    // мегабайт, и один проход хеширования по ним замораживал окно целиком.
    final checksums = await Isolate.run(() => _checksumsOf(files));
    files['checksums.json'] = _json(checksums);

    // Подпись над каноническим представлением manifest + checksums (§22).
    final signedPayload = utf8.encode(
      Hashing.canonicalJson(manifest) + Hashing.canonicalJson(checksums),
    );
    final signature = await _keys.sign(profileId, signedPayload);
    files['signature.json'] = _json({
      'algorithm': 'ed25519',
      'publicKey': key.publicKey,
      'fingerprint': key.fingerprint,
      'signature': signature,
    });

    // Упаковка — тоже в изоляте: сжатие пакета с фотографиями идёт секундами,
    // и всё это время интерфейс не отвечал вовсе.
    var bytes = await Isolate.run(() => _zipOf(files));

    if (options.isProtected) {
      bytes = await KeyService.encryptWithPassword(bytes, options.password!);
    }

    await db
        .into(db.exportBatches)
        .insert(
          ExportBatchesCompanion.insert(
            id: Ids.newId(),
            packageId: packageId,
            profileId: profileId,
            mode: options.mode.name,
            exportedAt: DateTime.now(),
            summaryJson: Value(jsonEncode(manifest['counts'])),
          ),
        );

    return ExportResult(
      bytes: bytes,
      packageId: packageId,
      summary: ExportSummary(
        profileName: data.summary.profileName,
        entries: data.summary.entries,
        categories: data.summary.categories,
        subcategories: data.summary.subcategories,
        objects: data.summary.objects,
        revisions: data.summary.revisions,
        attachments: data.summary.attachments,
        excludedPrivate: data.summary.excludedPrivate,
        includesPhotos: options.includePhotos,
        protected: options.isProtected,
        mode: options.mode,
        byteSize: bytes.length,
      ),
    );
  }

  /// Имя файла по умолчанию для сохранения.
  static String suggestFileName(String profileName) {
    final safe = profileName.replaceAll(
      RegExp(r'[^\p{L}\p{N}]+', unicode: true),
      '_',
    );
    final date = DateTime.now();
    final stamp =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return '${safe}_$stamp.${AppConfig.profileFileExtension}';
  }

  List<int> _json(Object? value) => utf8.encode(jsonEncode(value));

  List<int> _jsonl(List<Map<String, Object?>> rows) =>
      utf8.encode(rows.map(jsonEncode).join('\n'));

  /// Категории профиля в пределах выбранного объёма: для ветки — только её
  /// поддерево, иначе все.
  Future<List<CategoryRow>> scopedCategories(
    String profileId,
    ExportOptions options,
  ) async {
    final categories = await (db.select(
      db.categories,
    )..where((c) => c.profileId.equals(profileId))).get();
    if (options.categoryId == null) return categories;

    final root = categories
        .where((c) => c.id == options.categoryId)
        .firstOrNull;
    if (root == null) return categories;

    final prefix = '${root.path}/';
    return categories
        .where((c) => c.id == root.id || c.path.startsWith(prefix))
        .toList();
  }

  /// Записи в пределах выбранного объёма, без приватных (§25).
  ///
  /// Правило отбора одно на все выгрузки: и подписанный контейнер, и таблица
  /// «для чтения» берут отсюда. Иначе панель «что войдёт в файл» рассказывает
  /// про один объём, а файл получается про другой — так и было до 1.11.0.
  Future<({List<ProfileEntryRow> entries, int excludedPrivate})> scopedEntries(
    String profileId,
    ExportOptions options,
    Set<String> categoryIds,
  ) async {
    var entries = await (db.select(
      db.profileEntries,
    )..where((e) => e.profileId.equals(profileId))).get();

    final excludedPrivate = entries
        .where((e) => e.privacy == privacyOnlyMe)
        .length;
    entries = entries.where((e) => e.privacy != privacyOnlyMe).toList();

    if (options.since != null) {
      entries = entries
          .where((e) => e.createdAt.isAfter(options.since!))
          .toList();
    }
    if (options.entryIds != null) {
      entries = entries.where((e) => options.entryIds!.contains(e.id)).toList();
    }
    if (options.collectionId != null) {
      final links = await (db.select(
        db.collectionEntries,
      )..where((ce) => ce.collectionId.equals(options.collectionId!))).get();
      final allowed = links.map((l) => l.entryId).toSet();
      entries = entries.where((e) => allowed.contains(e.id)).toList();
    }
    if (options.categoryId != null) {
      final links = await (db.select(db.entryCategories)).get();
      final allowed = links
          .where((l) => categoryIds.contains(l.categoryId))
          .map((l) => l.entryId)
          .toSet();
      entries = entries.where((e) => allowed.contains(e.id)).toList();
    }

    return (entries: entries, excludedPrivate: excludedPrivate);
  }

  /// Идентификаторы записей, которые попадут в выгрузку при этих условиях.
  Future<List<String>> scopedEntryIds(
    String profileId,
    ExportOptions options,
  ) async {
    final categories = await scopedCategories(profileId, options);
    final selected = await scopedEntries(
      profileId,
      options,
      categories.map((c) => c.id).toSet(),
    );
    return selected.entries.map((e) => e.id).toList();
  }

  /// Выгрузка «для чтения»: таблица или текст вместо контейнера обмена.
  ///
  /// Без подписи и вложений — это не формат обмена, а способ открыть свои
  /// записи в таблице или распечатать их. Объём при этом тот же, что у
  /// контейнера: и то и другое идёт через [scopedEntryIds].
  Future<String> readable(
    String profileId,
    ExportOptions options, {
    required ReadableFormat format,
    required String profileName,
    required String Function(String? relation) relationLabel,
  }) async {
    final ids = await scopedEntryIds(profileId, options);
    final entries = await EntryRepository(
      db,
    ).entryViews(profileId, entryIds: ids);
    return const ReadableExportService().build(
      entries: entries,
      format: format,
      profileName: profileName,
      relationLabel: relationLabel,
    );
  }

  Future<_ExportData> _collect(String profileId, ExportOptions options) async {
    final profile = await (db.select(
      db.profiles,
    )..where((p) => p.id.equals(profileId))).getSingle();

    final categories = await scopedCategories(profileId, options);
    final categoryIds = categories.map((c) => c.id).toSet();

    final selected = await scopedEntries(profileId, options, categoryIds);
    final entries = selected.entries;
    final excludedPrivate = selected.excludedPrivate;
    final entryIds = entries.map((e) => e.id).toSet();

    // Объекты, на которые ссылаются выбранные записи.
    final objectIds = entries.map((e) => e.objectId).toSet();
    final objects = objectIds.isEmpty
        ? <ObjectRow>[]
        : await (db.select(
            db.objects,
          )..where((o) => o.id.isIn(objectIds.toList()))).get();

    // Типы объектов — нужны получателю, кладём вместе с объектами.
    final typeIds = objects.map((o) => o.typeId).toSet();
    final types = typeIds.isEmpty
        ? <ObjectTypeRow>[]
        : await (db.select(
            db.objectTypes,
          )..where((t) => t.id.isIn(typeIds.toList()))).get();

    // Версии выбранных сущностей.
    final entryRevisions = entryIds.isEmpty
        ? <ProfileEntryRevisionRow>[]
        : await (db.select(
            db.profileEntryRevisions,
          )..where((r) => r.entryId.isIn(entryIds.toList()))).get();
    final objectRevisions = objectIds.isEmpty
        ? <ObjectRevisionRow>[]
        : await (db.select(
            db.objectRevisions,
          )..where((r) => r.objectId.isIn(objectIds.toList()))).get();
    final categoryRevisions = categoryIds.isEmpty
        ? <CategoryRevisionRow>[]
        : await (db.select(
            db.categoryRevisions,
          )..where((r) => r.categoryId.isIn(categoryIds.toList()))).get();

    // Связи запись↔категория (только внутри выбранного). Спрашиваем нужные, а
    // не всю таблицу: раньше сюда приезжали связи всех профилей сразу, и
    // выгрузка одной ветки читала их целиком.
    final links = entryIds.isEmpty
        ? <EntryCategoryRow>[]
        : (await (db.select(
                db.entryCategories,
              )..where((l) => l.entryId.isIn(entryIds.toList()))).get())
              .where((l) => categoryIds.contains(l.categoryId))
              .toList();

    // Кому какая запись принадлежит — по идентификатору, а не поиском в
    // списке: у выгрузки на пять тысяч записей это был перебор всего списка
    // на каждую версию.
    final entryById = {for (final e in entries) e.id: e};
    final linksByEntry = <String, List<EntryCategoryRow>>{};
    for (final link in links) {
      (linksByEntry[link.entryId] ??= []).add(link);
    }

    // Вложения (§25: приватность «без фотографий»).
    var attachments = <AttachmentRow>[];
    if (options.includePhotos) {
      final revisionIds = entryRevisions
          .where((r) {
            final entry = entryById[r.entryId];
            return entry != null && entry.privacy != privacyNoPhotos;
          })
          .map((r) => r.id)
          .toList();
      if (revisionIds.isNotEmpty) {
        final attLinks = await (db.select(
          db.revisionAttachments,
        )..where((ra) => ra.revisionId.isIn(revisionIds))).get();
        final attIds = attLinks.map((l) => l.attachmentId).toSet();
        if (attIds.isNotEmpty) {
          attachments = await (db.select(
            db.attachments,
          )..where((a) => a.id.isIn(attIds.toList()))).get();
        }
      }
    }

    final devices = await (db.select(
      db.profileDevices,
    )..where((d) => d.profileId.equals(profileId))).get();

    return _ExportData(
      profileJson: {
        'id': profile.id,
        'firstName': profile.firstName,
        'lastName': profile.lastName,
        'nickname': profile.nickname,
        'bio': profile.bio,
        'color': profile.color,
        'profileVersion': profile.profileVersion,
        'retransmitMode': profile.retransmitMode,
        'createdAt': profile.createdAt.toUtc().toIso8601String(),
        'updatedAt': profile.updatedAt.toUtc().toIso8601String(),
      },
      devicesJson: [
        for (final d in devices)
          {
            'id': d.id,
            'name': d.name,
            'deviceType': d.deviceType,
            'os': d.os,
            'registeredAt': d.registeredAt.toUtc().toIso8601String(),
          },
      ],
      categoriesJson: [
        for (final c in categories)
          {
            'id': c.id,
            'parentId': c.parentId,
            'name': c.name,
            'normalizedName': c.normalizedName,
            'description': c.description,
            'icon': c.icon,
            'color': c.color,
            'sortOrder': c.sortOrder,
            'level': c.level,
            'path': c.path,
            'archivedAt': c.archivedAt?.toUtc().toIso8601String(),
            'createdAt': c.createdAt.toUtc().toIso8601String(),
          },
      ],
      objectsJson: [
        for (final t in types)
          {
            'kind': 'type',
            'id': t.id,
            'name': t.name,
            'normalizedName': t.normalizedName,
            'icon': t.icon,
            'color': t.color,
            'sortOrder': t.sortOrder,
            'builtIn': t.builtIn,
          },
        for (final o in objects)
          {
            'kind': 'object',
            'id': o.id,
            'typeId': o.typeId,
            'title': o.title,
            'normalizedTitle': o.normalizedTitle,
            'altTitle': o.altTitle,
            'summary': o.summary,
            'creator': o.creator,
            'year': o.year,
            'barcode': o.barcode,
            'createdAt': o.createdAt.toUtc().toIso8601String(),
          },
      ],
      entriesJson: [
        for (final e in entries)
          {
            'id': e.id,
            'objectId': e.objectId,
            'relation': e.relation,
            'rating': e.rating,
            'status': e.status,
            'shortNote': e.privacy == privacyNoNote ? null : e.shortNote,
            'detailedNote': e.privacy == privacyNoNote ? null : e.detailedNote,
            'impressionDate': e.impressionDate?.toUtc().toIso8601String(),
            'privacy': e.privacy,
            'createdAt': e.createdAt.toUtc().toIso8601String(),
            'archivedAt': e.archivedAt?.toUtc().toIso8601String(),
            'categories': [
              for (final l in linksByEntry[e.id] ?? const <EntryCategoryRow>[])
                {'categoryId': l.categoryId, 'isPrimary': l.isPrimary},
            ],
          },
      ],
      revisionsJson: [
        for (final r in entryRevisions)
          {
            'kind': 'entry',
            'id': r.id,
            'entityId': r.entryId,
            'parentRevisionId': r.parentRevisionId,
            'authorProfileId': r.authorProfileId,
            'createdAt': r.createdAt.toUtc().toIso8601String(),
            'payloadVersion': r.payloadVersion,
            'payloadJson': r.payloadJson,
            'contentHash': r.contentHash,
          },
        for (final r in objectRevisions)
          {
            'kind': 'object',
            'id': r.id,
            'entityId': r.objectId,
            'parentRevisionId': r.parentRevisionId,
            'authorProfileId': r.authorProfileId,
            'createdAt': r.createdAt.toUtc().toIso8601String(),
            'payloadVersion': r.payloadVersion,
            'payloadJson': r.payloadJson,
            'contentHash': r.contentHash,
          },
        for (final r in categoryRevisions)
          {
            'kind': 'category',
            'id': r.id,
            'entityId': r.categoryId,
            'parentRevisionId': r.parentRevisionId,
            'authorProfileId': r.authorProfileId,
            'createdAt': r.createdAt.toUtc().toIso8601String(),
            'payloadVersion': r.payloadVersion,
            'payloadJson': r.payloadJson,
            'contentHash': r.contentHash,
          },
      ],
      attachments: attachments,
      summary: ExportSummary(
        profileName: profile.firstName,
        entries: entries.length,
        categories: categories.length,
        subcategories: categories.where((c) => c.parentId != null).length,
        objects: objects.length,
        revisions:
            entryRevisions.length +
            objectRevisions.length +
            categoryRevisions.length,
        attachments: attachments.length,
        excludedPrivate: excludedPrivate,
        includesPhotos: options.includePhotos,
        protected: options.isProtected,
        mode: options.mode,
      ),
    );
  }
}

class _ExportData {
  const _ExportData({
    required this.profileJson,
    required this.devicesJson,
    required this.categoriesJson,
    required this.objectsJson,
    required this.entriesJson,
    required this.revisionsJson,
    required this.attachments,
    required this.summary,
  });

  final Map<String, Object?> profileJson;
  final List<Map<String, Object?>> devicesJson;
  final List<Map<String, Object?>> categoriesJson;
  final List<Map<String, Object?>> objectsJson;
  final List<Map<String, Object?>> entriesJson;
  final List<Map<String, Object?>> revisionsJson;
  final List<AttachmentRow> attachments;
  final ExportSummary summary;
}

/// Утилита: путь файла для сохранения рядом с указанным каталогом.
String defaultExportPath(Directory dir, String profileName) =>
    p.join(dir.path, ExportService.suggestFileName(profileName));
