import 'dart:io';

import 'package:drift/drift.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/config/app_config.dart';
import '../../core/utils/hashing.dart';
import '../../core/utils/ids.dart';
import '../db/database.dart';

/// Результат добавления изображения.
sealed class ImageResult {
  const ImageResult();
}

class ImageAdded extends ImageResult {
  const ImageAdded(this.attachment);
  final AttachmentRow attachment;
}

/// Изображение с таким SHA-256 уже есть — повторно не сохраняем (§16).
class ImageDuplicate extends ImageResult {
  const ImageDuplicate(this.attachment);
  final AttachmentRow attachment;
}

class ImageRejected extends ImageResult {
  const ImageRejected(this.reason);
  final String reason;
}

/// Обработка изображений (§16), полностью локальная, без сети.
///
/// Порядок: проверка сигнатуры → определение MIME → отклонение подозрительных
/// файлов → удаление EXIF (включая геолокацию) → исправление ориентации →
/// ограничение размера → оптимизированный оригинал + thumbnail → SHA-256 →
/// дедупликация → атомарная запись.
class ImageService {
  ImageService(this.db, {Directory? mediaDirectory})
    : _mediaOverride = mediaDirectory;

  final AppDatabase db;

  /// Каталог хранения для тестов; в приложении используется папка приложения.
  final Directory? _mediaOverride;

  /// Максимальная сторона оптимизированного оригинала.
  static const int maxSide = 2048;

  /// Сторона миниатюры.
  static const int thumbSide = 400;

  static const int _jpegQuality = 88;

  /// Определяет MIME по сигнатуре файла (magic bytes), а не по расширению.
  static String? detectMime(Uint8List bytes) {
    if (bytes.length < 12) return null;
    // JPEG: FF D8 FF
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return 'image/jpeg';
    }
    // PNG: 89 50 4E 47 0D 0A 1A 0A
    const png = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
    if (_startsWith(bytes, png)) return 'image/png';
    // WebP: "RIFF" .... "WEBP"
    if (bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return 'image/webp';
    }
    return null;
  }

  static bool _startsWith(Uint8List bytes, List<int> prefix) {
    if (bytes.length < prefix.length) return false;
    for (var i = 0; i < prefix.length; i++) {
      if (bytes[i] != prefix[i]) return false;
    }
    return true;
  }

  /// Каталог хранения изображений внутри приватной папки приложения.
  Future<Directory> _mediaDir() async {
    final override = _mediaOverride;
    if (override != null) {
      if (!override.existsSync()) await override.create(recursive: true);
      return override;
    }
    final base = await getApplicationSupportDirectory();
    final dir = Directory(p.join(base.path, 'media'));
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Добавляет изображение из файла: полный конвейер обработки (§16).
  Future<ImageResult> addFromFile(File source, {String? caption}) async {
    if (!source.existsSync()) {
      return const ImageRejected('Файл не найден');
    }
    final length = await source.length();
    if (length > AppConfig.maxAttachmentBytes) {
      return const ImageRejected('Файл слишком большой');
    }

    final bytes = await source.readAsBytes();
    return addFromBytes(bytes, caption: caption);
  }

  /// Добавляет изображение из байтов (общий путь для файла, камеры и drag-and-drop).
  Future<ImageResult> addFromBytes(Uint8List bytes, {String? caption}) async {
    if (bytes.length > AppConfig.maxAttachmentBytes) {
      return const ImageRejected('Файл слишком большой');
    }

    // 1-3. Сигнатура и MIME; подозрительные файлы отклоняем.
    final mime = detectMime(bytes);
    if (mime == null) {
      return const ImageRejected('Неподдерживаемый формат изображения');
    }

    // Декодирование также подтверждает, что файл действительно изображение.
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return const ImageRejected('Не удалось прочитать изображение');
    }

    // 4-5. Исправление ориентации по EXIF; сам EXIF далее не переносится,
    // поэтому геолокация не сохраняется.
    var image = img.bakeOrientation(decoded);
    image.exif = img.ExifData();

    // 6. Ограничение размера.
    if (image.width > maxSide || image.height > maxSide) {
      image = image.width >= image.height
          ? img.copyResize(image, width: maxSide)
          : img.copyResize(image, height: maxSide);
    }

    // 7-8. Оптимизированный оригинал и миниатюра (всегда JPEG — компактно
    // и предсказуемо; прозрачность для наших сценариев не критична).
    final optimized = Uint8List.fromList(
      img.encodeJpg(image, quality: _jpegQuality),
    );
    final thumbSource = image.width >= image.height
        ? img.copyResize(image, width: thumbSide)
        : img.copyResize(image, height: thumbSide);
    final thumb = Uint8List.fromList(img.encodeJpg(thumbSource, quality: 80));

    // 9-10. SHA-256 и дедупликация.
    final sha = Hashing.sha256OfBytes(optimized);
    final existing = await (db.select(
      db.attachments,
    )..where((a) => a.sha256.equals(sha))).getSingleOrNull();
    if (existing != null) return ImageDuplicate(existing);

    // 11. Атомарная запись: сначала во временный файл, затем rename.
    final dir = await _mediaDir();
    final originalPath = p.join(dir.path, '$sha.jpg');
    final thumbPath = p.join(dir.path, '${sha}_thumb.jpg');
    await _writeAtomic(File(originalPath), optimized);
    await _writeAtomic(File(thumbPath), thumb);

    final id = Ids.newId();
    await db
        .into(db.attachments)
        .insert(
          AttachmentsCompanion.insert(
            id: id,
            sha256: sha,
            storagePath: p.basename(originalPath),
            thumbPath: Value(p.basename(thumbPath)),
            mimeType: 'image/jpeg',
            width: Value(image.width),
            height: Value(image.height),
            byteSize: optimized.length,
            caption: Value(caption),
            createdAt: DateTime.now(),
          ),
        );

    final row = await (db.select(
      db.attachments,
    )..where((a) => a.id.equals(id))).getSingle();
    return ImageAdded(row);
  }

  /// Атомарная запись: временный файл + переименование.
  Future<void> _writeAtomic(File target, Uint8List data) async {
    final tmp = File('${target.path}.tmp');
    await tmp.writeAsBytes(data, flush: true);
    if (target.existsSync()) {
      await target.delete();
    }
    await tmp.rename(target.path);
  }

  /// Абсолютный путь к файлу вложения (в базе хранится только имя файла).
  Future<String> absolutePath(String storagePath) async {
    final dir = await _mediaDir();
    return p.join(dir.path, storagePath);
  }

  /// Каталог хранения изображений.
  ///
  /// Нужен там, где путей сразу много: собирать их через [absolutePath] значит
  /// на каждый запрашивать каталог заново.
  Future<String> mediaDirectoryPath() async => (await _mediaDir()).path;

  /// Привязывает вложение к версии сущности (§16, §18).
  Future<void> attachToEntry({
    required String entryId,
    required String attachmentId,
    required String revisionId,
    bool isPrimary = false,
  }) async {
    final existing =
        await (db.select(db.revisionAttachments)..where(
              (ra) =>
                  ra.revisionId.equals(revisionId) &
                  ra.attachmentId.equals(attachmentId),
            ))
            .getSingleOrNull();
    if (existing != null) return;

    final links = await (db.select(
      db.revisionAttachments,
    )..where((ra) => ra.revisionId.equals(revisionId))).get();
    final next = links.isEmpty
        ? 0
        : links.map((l) => l.sortOrder).reduce((a, b) => a > b ? a : b) + 1;

    await db.transaction(() async {
      // Главная фотография ровно одна: без снятия прежней пометки обложкой в
      // списках так и оставался бы первый добавленный снимок.
      if (isPrimary && links.isNotEmpty) {
        await (db.update(db.revisionAttachments)
              ..where((ra) => ra.revisionId.equals(revisionId)))
            .write(const RevisionAttachmentsCompanion(isPrimary: Value(false)));
      }
      await db
          .into(db.revisionAttachments)
          .insert(
            RevisionAttachmentsCompanion.insert(
              id: Ids.newId(),
              entityKind: 'entry',
              revisionId: revisionId,
              attachmentId: attachmentId,
              sortOrder: Value(next),
              isPrimary: Value(isPrimary || links.isEmpty),
            ),
          );
    });
  }

  /// Делает вложение обложкой записи (§16).
  ///
  /// Обложка видна в каталоге и на главной, поэтому выбирать её должен
  /// пользователь, а не порядок добавления.
  Future<void> setPrimaryAttachment({
    required String revisionId,
    required String attachmentId,
  }) async {
    await db.transaction(() async {
      await (db.update(db.revisionAttachments)
            ..where((ra) => ra.revisionId.equals(revisionId)))
          .write(const RevisionAttachmentsCompanion(isPrimary: Value(false)));
      await (db.update(db.revisionAttachments)..where(
            (ra) =>
                ra.revisionId.equals(revisionId) &
                ra.attachmentId.equals(attachmentId),
          ))
          .write(const RevisionAttachmentsCompanion(isPrimary: Value(true)));
    });
  }

  /// Какое вложение сейчас обложка.
  Future<String?> primaryAttachmentId(String revisionId) async {
    final row =
        await (db.select(db.revisionAttachments)..where(
              (ra) =>
                  ra.revisionId.equals(revisionId) & ra.isPrimary.equals(true),
            ))
            .getSingleOrNull();
    return row?.attachmentId;
  }

  /// Вложения, привязанные к версии.
  Future<List<AttachmentRow>> attachmentsOfRevision(String revisionId) async {
    final links =
        await (db.select(db.revisionAttachments)
              ..where((ra) => ra.revisionId.equals(revisionId))
              ..orderBy([(ra) => OrderingTerm(expression: ra.sortOrder)]))
            .get();
    if (links.isEmpty) return const [];
    final ids = links.map((l) => l.attachmentId).toList();
    final rows = await (db.select(
      db.attachments,
    )..where((a) => a.id.isIn(ids))).get();
    final byId = {for (final r in rows) r.id: r};
    return [
      for (final l in links)
        if (byId[l.attachmentId] != null) byId[l.attachmentId]!,
    ];
  }

  /// Отвязывает вложение от версии (файл остаётся — может использоваться
  /// другими записями; физическое удаление не является обычной операцией §24).
  Future<void> detach(String revisionId, String attachmentId) {
    return (db.delete(db.revisionAttachments)..where(
          (ra) =>
              ra.revisionId.equals(revisionId) &
              ra.attachmentId.equals(attachmentId),
        ))
        .go();
  }
}
