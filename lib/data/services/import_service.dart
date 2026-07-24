import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';

import '../../core/config/app_config.dart';
import '../../core/utils/hashing.dart';
import '../../core/utils/ids.dart';
import '../db/database.dart';
import 'image_service.dart';
import 'key_service.dart';

/// Причина отказа во время проверки пакета (§21).
enum ImportProblem {
  tooLarge,
  notAnArchive,
  wrongPassword,
  unexpectedFile,
  unsafePath,
  missingManifest,
  unsupportedVersion,
  checksumMismatch,
  badSignature,
  signatureChanged,
  limitExceeded,
  malformed,
}

/// Ошибка импорта с понятным пользователю сообщением.
class ImportException implements Exception {
  ImportException(this.problem, this.message);
  final ImportProblem problem;
  final String message;
  @override
  String toString() => 'ImportException(${problem.name}): $message';
}

/// Результат предварительного разбора пакета (§20 п.8).
class ImportPreview {
  ImportPreview({
    required this.packageHash,
    required this.packageId,
    required this.profileId,
    required this.profileName,
    required this.fingerprint,
    required this.publicKey,
    required this.isKnownProfile,
    required this.alreadyImported,
    required this.newEntries,
    required this.changedEntries,
    required this.newCategories,
    required this.movedCategories,
    required this.newObjects,
    required this.newRevisions,
    required this.newAttachments,
    required this.unchanged,
    required this.payload,
  });

  final String packageHash;
  final String packageId;
  final String profileId;
  final String profileName;
  final String fingerprint;
  final String publicKey;

  /// Профиль уже есть локально — импорт обновит существующую копию (§20).
  final bool isKnownProfile;

  /// Этот пакет уже импортировался — изменений не будет.
  final bool alreadyImported;

  final int newEntries;
  final int changedEntries;
  final int newCategories;
  final int movedCategories;
  final int newObjects;
  final int newRevisions;
  final int newAttachments;
  final int unchanged;

  /// Разобранное содержимое пакета для применения.
  final ImportPayload payload;

  bool get hasChanges =>
      newEntries > 0 ||
      changedEntries > 0 ||
      newCategories > 0 ||
      movedCategories > 0 ||
      newObjects > 0 ||
      newRevisions > 0 ||
      newAttachments > 0;
}

/// Итог применённого импорта (§20).
class ImportResult {
  const ImportResult({
    required this.profileName,
    required this.newEntries,
    required this.changedEntries,
    required this.newCategories,
    required this.movedCategories,
    required this.newImages,
    required this.unchanged,
  });

  final String profileName;
  final int newEntries;
  final int changedEntries;
  final int newCategories;
  final int movedCategories;
  final int newImages;
  final int unchanged;
}

/// Безопасный импорт профиля из контейнера `*.impressions` (§20, §21).
///
/// Порядок: SHA-256 пакета → распаковка с защитой от Zip Slip → белый список
/// файлов → manifest и версия формата → контрольные суммы → подпись → лимиты →
/// полный разбор → предпросмотр → (по подтверждению) транзакционное применение.
class ImportService {
  ImportService(this.db) : _images = ImageService(db);

  final AppDatabase db;
  final ImageService _images;

  /// Разрешённые файлы контейнера (§21 «список разрешённых файлов»).
  static const Set<String> allowedFiles = {
    'manifest.json',
    'profile.json',
    'devices.json',
    'categories.jsonl',
    'objects.jsonl',
    'entries.jsonl',
    'revisions.jsonl',
    'checksums.json',
    'signature.json',
  };

  static const String _attachmentsPrefix = 'attachments/';

  /// Разбирает и проверяет пакет, ничего не записывая в базу.
  Future<ImportPreview> inspect(Uint8List bytes, {String? password}) async {
    if (bytes.length > AppConfig.maxPackageBytes) {
      throw ImportException(
        ImportProblem.tooLarge,
        'Файл больше допустимого размера',
      );
    }

    final packageHash = Hashing.sha256OfBytes(bytes);

    var archiveBytes = bytes;
    if (password != null && password.isNotEmpty) {
      final decrypted = await KeyService.decryptWithPassword(bytes, password);
      if (decrypted == null) {
        throw ImportException(
          ImportProblem.wrongPassword,
          'Неверный пароль пакета',
        );
      }
      archiveBytes = decrypted;
    }

    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(archiveBytes);
    } on Object {
      throw ImportException(
        ImportProblem.notAnArchive,
        'Файл повреждён или не является пакетом профиля',
      );
    }

    // Сколько выйдет после распаковки — известно из оглавления архива. Раньше
    // предел проверялся по ходу дела, то есть уже после того, как содержимое
    // оказывалось в памяти: к моменту отказа памяти могло не остаться. Теперь
    // заведомо неподъёмный архив отклоняется, не распаковав ни байта.
    final declared = archive.files.fold<int>(0, (sum, f) => sum + f.size);
    if (declared > AppConfig.maxUnpackedBytes) {
      throw ImportException(
        ImportProblem.limitExceeded,
        'Распакованные данные превышают лимит',
      );
    }

    // Распаковка в память с проверками путей (§21).
    final files = <String, Uint8List>{};
    var unpacked = 0;
    for (final file in archive.files) {
      final name = file.name;
      _assertSafePath(name);
      if (!file.isFile) {
        throw ImportException(
          ImportProblem.unsafePath,
          'В пакете недопустимый элемент: $name',
        );
      }
      final isAttachment = name.startsWith(_attachmentsPrefix);
      if (!allowedFiles.contains(name) && !isAttachment) {
        throw ImportException(
          ImportProblem.unexpectedFile,
          'Неожиданный файл в пакете: $name',
        );
      }
      final content = file.content as List<int>;
      if (isAttachment && content.length > AppConfig.maxAttachmentBytes) {
        throw ImportException(
          ImportProblem.limitExceeded,
          'Вложение больше допустимого размера',
        );
      }
      unpacked += content.length;
      if (unpacked > AppConfig.maxUnpackedBytes) {
        throw ImportException(
          ImportProblem.limitExceeded,
          'Распакованные данные превышают лимит',
        );
      }
      files[name] = Uint8List.fromList(content);
    }

    if (!files.containsKey('manifest.json')) {
      throw ImportException(
        ImportProblem.missingManifest,
        'В пакете нет manifest.json',
      );
    }

    final manifest = _decodeJsonMap(files['manifest.json']!, 'manifest.json');
    final formatVersion = manifest['formatVersion'];
    if (formatVersion is! int ||
        formatVersion > AppConfig.exportFormatVersion) {
      throw ImportException(
        ImportProblem.unsupportedVersion,
        'Версия формата пакета не поддерживается',
      );
    }

    // Контрольные суммы.
    if (!files.containsKey('checksums.json')) {
      throw ImportException(
        ImportProblem.checksumMismatch,
        'В пакете нет контрольных сумм',
      );
    }
    final checksums = _decodeJsonMap(
      files['checksums.json']!,
      'checksums.json',
    );
    for (final entry in checksums.entries) {
      final data = files[entry.key];
      if (data == null) {
        throw ImportException(
          ImportProblem.checksumMismatch,
          'Файл ${entry.key} отсутствует в пакете',
        );
      }
      if (Hashing.sha256OfBytes(data) != entry.value) {
        throw ImportException(
          ImportProblem.checksumMismatch,
          'Контрольная сумма не совпадает: ${entry.key}',
        );
      }
    }

    // Подпись (§22).
    if (!files.containsKey('signature.json')) {
      throw ImportException(ImportProblem.badSignature, 'В пакете нет подписи');
    }
    final signature = _decodeJsonMap(
      files['signature.json']!,
      'signature.json',
    );
    final publicKey = signature['publicKey'] as String? ?? '';
    final signedPayload = utf8.encode(
      Hashing.canonicalJson(manifest) + Hashing.canonicalJson(checksums),
    );
    final signatureOk = await KeyService.verify(
      data: signedPayload,
      signatureB64: signature['signature'] as String? ?? '',
      publicKeyB64: publicKey,
    );
    if (!signatureOk) {
      throw ImportException(
        ImportProblem.badSignature,
        'Подпись пакета некорректна. Импорт остановлен.',
      );
    }

    // Разбор данных.
    final payload = ImportPayload(
      profile: _decodeJsonMap(
        files['profile.json'] ?? Uint8List(0),
        'profile.json',
      ),
      categories: _decodeJsonl(files['categories.jsonl']),
      objects: _decodeJsonl(files['objects.jsonl']),
      entries: _decodeJsonl(files['entries.jsonl']),
      revisions: _decodeJsonl(files['revisions.jsonl']),
      attachments: {
        for (final entry in files.entries)
          if (entry.key.startsWith(_attachmentsPrefix)) entry.key: entry.value,
      },
    );

    // Лимиты (§21).
    if (payload.entries.length > AppConfig.maxEntries) {
      throw ImportException(
        ImportProblem.limitExceeded,
        'Слишком много записей в пакете',
      );
    }
    if (payload.revisions.length > AppConfig.maxRevisions) {
      throw ImportException(
        ImportProblem.limitExceeded,
        'Слишком много версий в пакете',
      );
    }
    if (payload.attachments.length > AppConfig.maxAttachments) {
      throw ImportException(
        ImportProblem.limitExceeded,
        'Слишком много вложений в пакете',
      );
    }
    for (final c in payload.categories) {
      final level = c['level'];
      if (level is int && level > AppConfig.hardMaxCategoryDepth) {
        throw ImportException(
          ImportProblem.limitExceeded,
          'Превышена допустимая глубина категорий',
        );
      }
    }

    final profileId = manifest['profileId'] as String? ?? '';
    if (profileId.isEmpty) {
      throw ImportException(
        ImportProblem.malformed,
        'В пакете не указан профиль',
      );
    }

    // Определение профиля (§20): по id + открытому ключу.
    final existing = await (db.select(
      db.profiles,
    )..where((p) => p.id.equals(profileId))).getSingleOrNull();
    if (existing != null &&
        existing.publicKey != null &&
        existing.publicKey != publicKey) {
      throw ImportException(
        ImportProblem.signatureChanged,
        'Подпись профиля изменилась. Автоматический импорт остановлен.',
      );
    }

    // Уже импортировали этот пакет?
    final priorImport = await (db.select(
      db.importBatches,
    )..where((b) => b.packageHash.equals(packageHash))).getSingleOrNull();

    final diff = await _analyse(payload, profileId);

    return ImportPreview(
      packageHash: packageHash,
      packageId: manifest['packageId'] as String? ?? Ids.newId(),
      profileId: profileId,
      profileName: payload.profile['firstName'] as String? ?? 'Профиль',
      fingerprint: manifest['profileFingerprint'] as String? ?? '',
      publicKey: publicKey,
      isKnownProfile: existing != null,
      alreadyImported: priorImport != null,
      newEntries: diff.newEntries,
      changedEntries: diff.changedEntries,
      newCategories: diff.newCategories,
      movedCategories: diff.movedCategories,
      newObjects: diff.newObjects,
      newRevisions: diff.newRevisions,
      newAttachments: diff.newAttachments,
      unchanged: diff.unchanged,
      payload: payload,
    );
  }

  /// Запрещает абсолютные пути, выход за пределы каталога и обратные слеши
  /// (защита от Zip Slip, §21).
  static void _assertSafePath(String name) {
    if (name.isEmpty) {
      throw ImportException(ImportProblem.unsafePath, 'Пустое имя файла');
    }
    if (name.startsWith('/') ||
        name.startsWith(r'\') ||
        RegExp(r'^[A-Za-z]:').hasMatch(name)) {
      throw ImportException(
        ImportProblem.unsafePath,
        'Абсолютные пути запрещены: $name',
      );
    }
    if (name.contains(r'\')) {
      throw ImportException(
        ImportProblem.unsafePath,
        'Недопустимый разделитель пути: $name',
      );
    }
    final segments = name.split('/');
    if (segments.contains('..') || segments.contains('.')) {
      throw ImportException(
        ImportProblem.unsafePath,
        'Переход по каталогам запрещён: $name',
      );
    }
  }

  static Map<String, Object?> _decodeJsonMap(Uint8List bytes, String what) {
    try {
      final value = jsonDecode(utf8.decode(bytes));
      if (value is! Map<String, Object?>) {
        throw const FormatException();
      }
      return value;
    } on Object {
      throw ImportException(ImportProblem.malformed, 'Повреждён файл $what');
    }
  }

  static List<Map<String, Object?>> _decodeJsonl(Uint8List? bytes) {
    if (bytes == null || bytes.isEmpty) return const [];
    try {
      return utf8
          .decode(bytes)
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) => jsonDecode(line) as Map<String, Object?>)
          .toList();
    } on Object {
      throw ImportException(
        ImportProblem.malformed,
        'Повреждены данные пакета',
      );
    }
  }

  Future<_Diff> _analyse(ImportPayload payload, String profileId) async {
    final existingCategories = await (db.select(
      db.categories,
    )..where((c) => c.profileId.equals(profileId))).get();
    final categoryById = {for (final c in existingCategories) c.id: c};

    var newCategories = 0;
    var movedCategories = 0;
    for (final c in payload.categories) {
      final id = c['id'] as String?;
      if (id == null) continue;
      final local = categoryById[id];
      if (local == null) {
        newCategories++;
      } else if (local.parentId != c['parentId']) {
        movedCategories++;
      }
    }

    final existingEntries = await (db.select(
      db.profileEntries,
    )..where((e) => e.profileId.equals(profileId))).get();
    final entryById = {for (final e in existingEntries) e.id: e};

    var newEntries = 0;
    var unchanged = 0;
    for (final e in payload.entries) {
      final id = e['id'] as String?;
      if (id == null) continue;
      if (entryById.containsKey(id)) {
        unchanged++;
      } else {
        newEntries++;
      }
    }

    final existingRevisionIds =
        (await db
                .customSelect(
                  'SELECT id FROM profile_entry_revisions',
                  readsFrom: {db.profileEntryRevisions},
                )
                .get())
            .map((r) => r.read<String>('id'))
            .toSet();
    final newRevisions = payload.revisions
        .where(
          (r) =>
              r['kind'] == 'entry' &&
              !existingRevisionIds.contains(r['id'] as String? ?? ''),
        )
        .length;
    final changedEntries = payload.entries
        .where((e) => entryById.containsKey(e['id'] as String? ?? ''))
        .where((e) {
          final id = e['id'] as String;
          return payload.revisions.any(
            (r) =>
                r['kind'] == 'entry' &&
                r['entityId'] == id &&
                !existingRevisionIds.contains(r['id'] as String? ?? ''),
          );
        })
        .length;

    final existingObjectIds = (await db.select(db.objects).get())
        .map((o) => o.id)
        .toSet();
    final newObjects = payload.objects
        .where(
          (o) =>
              o['kind'] == 'object' &&
              !existingObjectIds.contains(o['id'] as String? ?? ''),
        )
        .length;

    final existingHashes = (await db.select(db.attachments).get())
        .map((a) => a.sha256)
        .toSet();
    final newAttachments = payload.attachments.keys
        .map((name) => name.split('/').last.replaceAll('.jpg', ''))
        .where((sha) => !existingHashes.contains(sha))
        .length;

    return _Diff(
      newEntries: newEntries,
      changedEntries: changedEntries,
      newCategories: newCategories,
      movedCategories: movedCategories,
      newObjects: newObjects,
      newRevisions: newRevisions,
      newAttachments: newAttachments,
      unchanged: unchanged,
    );
  }

  /// Применяет импорт транзакционно. При ошибке база остаётся как была (§21).
  ///
  /// Локальные настройки профиля не изменяются, данные не удаляются (§20).
  Future<ImportResult> apply(ImportPreview preview) async {
    if (preview.alreadyImported && !preview.hasChanges) {
      return ImportResult(
        profileName: preview.profileName,
        newEntries: 0,
        changedEntries: 0,
        newCategories: 0,
        movedCategories: 0,
        newImages: 0,
        unchanged: preview.unchanged,
      );
    }

    var newImages = 0;

    // Вложения записываем до транзакции: файлы дедуплицируются по SHA-256,
    // а связи создаются уже внутри транзакции.
    final attachmentIdBySha = <String, String>{};
    for (final entry in preview.payload.attachments.entries) {
      final result = await _images.addFromBytes(entry.value);
      switch (result) {
        case ImageAdded(attachment: final a):
          attachmentIdBySha[a.sha256] = a.id;
          newImages++;
        case ImageDuplicate(attachment: final a):
          attachmentIdBySha[a.sha256] = a.id;
        case ImageRejected():
          // Некорректное вложение пропускаем, остальной импорт продолжается.
          break;
      }
    }

    await db.transaction(() async {
      await _applyProfile(preview);
      await _applyCategories(preview);
      await _applyObjects(preview);
      await _applyEntries(preview);
      await _applyRevisions(preview, attachmentIdBySha);

      await db
          .into(db.importBatches)
          .insert(
            ImportBatchesCompanion.insert(
              id: Ids.newId(),
              packageId: preview.packageId,
              packageHash: preview.packageHash,
              profileId: Value(preview.profileId),
              importedAt: DateTime.now(),
              summaryJson: Value(
                jsonEncode({
                  'newEntries': preview.newEntries,
                  'changedEntries': preview.changedEntries,
                  'newCategories': preview.newCategories,
                }),
              ),
            ),
          );
    });

    return ImportResult(
      profileName: preview.profileName,
      newEntries: preview.newEntries,
      changedEntries: preview.changedEntries,
      newCategories: preview.newCategories,
      movedCategories: preview.movedCategories,
      newImages: newImages,
      unchanged: preview.unchanged,
    );
  }

  Future<void> _applyProfile(ImportPreview preview) async {
    final p = preview.payload.profile;
    final now = DateTime.now();
    final existing = await (db.select(
      db.profiles,
    )..where((row) => row.id.equals(preview.profileId))).getSingleOrNull();

    if (existing == null) {
      await db
          .into(db.profiles)
          .insert(
            ProfilesCompanion.insert(
              id: preview.profileId,
              type: const Value('external'),
              firstName: p['firstName'] as String? ?? 'Профиль',
              lastName: Value(p['lastName'] as String?),
              nickname: Value(p['nickname'] as String?),
              bio: Value(p['bio'] as String?),
              color: Value(p['color'] as int?),
              publicKey: Value(preview.publicKey),
              fingerprint: Value(preview.fingerprint),
              retransmitMode: Value(
                p['retransmitMode'] as String? ?? 'allowed',
              ),
              createdAt: _parseDate(p['createdAt']) ?? now,
              updatedAt: now,
            ),
          );
      // Локальные настройки создаются один раз и далее не перезаписываются.
      await db
          .into(db.profileLocalSettings)
          .insert(
            ProfileLocalSettingsCompanion.insert(profileId: preview.profileId),
          );
    } else {
      // Обновляем только передаваемые поля; локальные настройки не трогаем.
      await (db.update(
        db.profiles,
      )..where((row) => row.id.equals(preview.profileId))).write(
        ProfilesCompanion(
          firstName: Value(p['firstName'] as String? ?? existing.firstName),
          lastName: Value(p['lastName'] as String?),
          nickname: Value(p['nickname'] as String?),
          bio: Value(p['bio'] as String?),
          color: Value(p['color'] as int?),
          publicKey: Value(preview.publicKey),
          fingerprint: Value(preview.fingerprint),
          updatedAt: Value(now),
        ),
      );
    }

    await KeyService(db).storePublicKey(
      profileId: preview.profileId,
      publicKeyB64: preview.publicKey,
    );
  }

  Future<void> _applyCategories(ImportPreview preview) async {
    for (final c in preview.payload.categories) {
      final id = c['id'] as String?;
      if (id == null) continue;
      final companion = CategoriesCompanion.insert(
        id: id,
        profileId: preview.profileId,
        parentId: Value(c['parentId'] as String?),
        name: c['name'] as String? ?? '',
        normalizedName: c['normalizedName'] as String? ?? '',
        description: Value(c['description'] as String?),
        icon: Value(c['icon'] as String?),
        color: Value(c['color'] as int?),
        sortOrder: Value(c['sortOrder'] as int? ?? 0),
        level: Value(c['level'] as int? ?? 0),
        path: c['path'] as String? ?? id,
        archivedAt: Value(_parseDate(c['archivedAt'])),
        createdAt: _parseDate(c['createdAt']) ?? DateTime.now(),
      );
      await db.into(db.categories).insertOnConflictUpdate(companion);
    }
  }

  Future<void> _applyObjects(ImportPreview preview) async {
    for (final o in preview.payload.objects) {
      final id = o['id'] as String?;
      if (id == null) continue;

      if (o['kind'] == 'type') {
        await db
            .into(db.objectTypes)
            .insertOnConflictUpdate(
              ObjectTypesCompanion.insert(
                id: id,
                profileId: preview.profileId,
                name: o['name'] as String? ?? '',
                normalizedName: o['normalizedName'] as String? ?? '',
                icon: Value(o['icon'] as String?),
                color: Value(o['color'] as int?),
                sortOrder: Value(o['sortOrder'] as int? ?? 0),
                builtIn: Value(o['builtIn'] as bool? ?? false),
                createdAt: DateTime.now(),
              ),
            );
      } else {
        await db
            .into(db.objects)
            .insertOnConflictUpdate(
              ObjectsCompanion.insert(
                id: id,
                typeId: o['typeId'] as String? ?? '',
                title: o['title'] as String? ?? '',
                normalizedTitle: o['normalizedTitle'] as String? ?? '',
                altTitle: Value(o['altTitle'] as String?),
                summary: Value(o['summary'] as String?),
                creator: Value(o['creator'] as String?),
                year: Value(o['year'] as int?),
                barcode: Value(o['barcode'] as String?),
                createdAt: _parseDate(o['createdAt']) ?? DateTime.now(),
              ),
            );
      }
    }
  }

  Future<void> _applyEntries(ImportPreview preview) async {
    for (final e in preview.payload.entries) {
      final id = e['id'] as String?;
      if (id == null) continue;

      await db
          .into(db.profileEntries)
          .insertOnConflictUpdate(
            ProfileEntriesCompanion.insert(
              id: id,
              profileId: preview.profileId,
              objectId: e['objectId'] as String? ?? '',
              relation: Value(e['relation'] as String?),
              rating: Value((e['rating'] as num?)?.toDouble()),
              status: Value(e['status'] as String?),
              shortNote: Value(e['shortNote'] as String?),
              detailedNote: Value(e['detailedNote'] as String?),
              impressionDate: Value(_parseDate(e['impressionDate'])),
              privacy: Value(e['privacy'] as String? ?? 'shareable'),
              createdAt: _parseDate(e['createdAt']) ?? DateTime.now(),
              archivedAt: Value(_parseDate(e['archivedAt'])),
            ),
          );

      final categories = e['categories'];
      if (categories is List) {
        for (final link in categories) {
          if (link is! Map) continue;
          final categoryId = link['categoryId'] as String?;
          if (categoryId == null) continue;
          await db
              .into(db.entryCategories)
              .insertOnConflictUpdate(
                EntryCategoriesCompanion.insert(
                  entryId: id,
                  categoryId: categoryId,
                  isPrimary: Value(link['isPrimary'] as bool? ?? false),
                ),
              );
        }
      }
    }
  }

  Future<void> _applyRevisions(
    ImportPreview preview,
    Map<String, String> attachmentIdBySha,
  ) async {
    final now = DateTime.now();

    for (final r in preview.payload.revisions) {
      final id = r['id'] as String?;
      final entityId = r['entityId'] as String?;
      if (id == null || entityId == null) continue;

      final createdAt = _parseDate(r['createdAt']) ?? now;
      final payloadJson = r['payloadJson'] as String? ?? '{}';
      final contentHash = r['contentHash'] as String? ?? '';

      switch (r['kind']) {
        case 'entry':
          await db
              .into(db.profileEntryRevisions)
              .insertOnConflictUpdate(
                ProfileEntryRevisionsCompanion.insert(
                  id: id,
                  entryId: entityId,
                  parentRevisionId: Value(r['parentRevisionId'] as String?),
                  authorProfileId: Value(r['authorProfileId'] as String?),
                  createdAt: createdAt,
                  importedAt: Value(now),
                  payloadVersion: Value(r['payloadVersion'] as int? ?? 1),
                  payloadJson: payloadJson,
                  contentHash: contentHash,
                  originPackageId: Value(preview.packageId),
                ),
              );
        case 'object':
          await db
              .into(db.objectRevisions)
              .insertOnConflictUpdate(
                ObjectRevisionsCompanion.insert(
                  id: id,
                  objectId: entityId,
                  parentRevisionId: Value(r['parentRevisionId'] as String?),
                  authorProfileId: Value(r['authorProfileId'] as String?),
                  createdAt: createdAt,
                  importedAt: Value(now),
                  payloadVersion: Value(r['payloadVersion'] as int? ?? 1),
                  payloadJson: payloadJson,
                  contentHash: contentHash,
                  originPackageId: Value(preview.packageId),
                ),
              );
        case 'category':
          await db
              .into(db.categoryRevisions)
              .insertOnConflictUpdate(
                CategoryRevisionsCompanion.insert(
                  id: id,
                  categoryId: entityId,
                  parentRevisionId: Value(r['parentRevisionId'] as String?),
                  authorProfileId: Value(r['authorProfileId'] as String?),
                  createdAt: createdAt,
                  importedAt: Value(now),
                  payloadVersion: Value(r['payloadVersion'] as int? ?? 1),
                  payloadJson: payloadJson,
                  contentHash: contentHash,
                  originPackageId: Value(preview.packageId),
                ),
              );
      }
    }

    // Текущая версия сущностей — последняя по времени создания.
    await db.customStatement(
      'UPDATE profile_entries SET current_revision_id = ('
      'SELECT r.id FROM profile_entry_revisions r WHERE r.entry_id = profile_entries.id '
      'ORDER BY r.created_at DESC, r.rowid DESC LIMIT 1) '
      'WHERE profile_id = ? AND EXISTS ('
      'SELECT 1 FROM profile_entry_revisions r2 WHERE r2.entry_id = profile_entries.id)',
      [preview.profileId],
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value is! String) return null;
    return DateTime.tryParse(value);
  }
}

class ImportPayload {
  const ImportPayload({
    required this.profile,
    required this.categories,
    required this.objects,
    required this.entries,
    required this.revisions,
    required this.attachments,
  });

  final Map<String, Object?> profile;
  final List<Map<String, Object?>> categories;
  final List<Map<String, Object?>> objects;
  final List<Map<String, Object?>> entries;
  final List<Map<String, Object?>> revisions;
  final Map<String, Uint8List> attachments;
}

class _Diff {
  const _Diff({
    required this.newEntries,
    required this.changedEntries,
    required this.newCategories,
    required this.movedCategories,
    required this.newObjects,
    required this.newRevisions,
    required this.newAttachments,
    required this.unchanged,
  });

  final int newEntries;
  final int changedEntries;
  final int newCategories;
  final int movedCategories;
  final int newObjects;
  final int newRevisions;
  final int newAttachments;
  final int unchanged;
}
