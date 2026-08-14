import 'dart:io';
import 'dart:isolate';

import 'package:drift/drift.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/config/app_config.dart';
import '../../core/utils/chunks.dart';
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

/// Готовые байты после тяжёлой обработки.
class _Processed {
  const _Processed({
    required this.optimized,
    required this.thumb,
    required this.width,
    required this.height,
  });

  final Uint8List optimized;
  final Uint8List thumb;
  final int width;
  final int height;
}

/// Разбор изображения, поворот по EXIF, ограничение размера, сжатие и
/// миниатюра. Возвращает null, если это не изображение.
///
/// Функция верхнего уровня, потому что уходит в [Isolate.run]: замыкание не
/// должно тянуть за собой ссылки на объекты вызывающего изолята. EXIF при этом
/// не переносится — вместе с ним не переносится и геометка съёмки.
_Processed? _processImage(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;

  var image = img.bakeOrientation(decoded);
  image.exif = img.ExifData();

  if (image.width > ImageService.maxSide ||
      image.height > ImageService.maxSide) {
    image = image.width >= image.height
        ? img.copyResize(image, width: ImageService.maxSide)
        : img.copyResize(image, height: ImageService.maxSide);
  }

  // Всегда JPEG — компактно и предсказуемо; прозрачность для наших сценариев
  // не критична.
  final optimized = Uint8List.fromList(
    img.encodeJpg(image, quality: ImageService.jpegQuality),
  );
  final thumbSource = image.width >= image.height
      ? img.copyResize(image, width: ImageService.thumbSide)
      : img.copyResize(image, height: ImageService.thumbSide);
  final thumb = Uint8List.fromList(img.encodeJpg(thumbSource, quality: 80));

  return _Processed(
    optimized: optimized,
    thumb: thumb,
    width: image.width,
    height: image.height,
  );
}

/// То же самое для пачки — по одному изображению за раз в одном изоляте.
///
/// Обрабатываются они последовательно: разобранным в памяти остаётся одно,
/// а изолят запускается один раз на всю пачку вместо раза на фотографию.
List<_Processed?> _processImages(List<Uint8List> batch) => [
  for (final bytes in batch) _processImage(bytes),
];

/// Обработка изображений (§16), полностью локальная, без сети.
///
/// Порядок: проверка сигнатуры → определение MIME → отклонение подозрительных
/// файлов → удаление EXIF (включая геолокацию) → исправление ориентации →
/// ограничение размера → оптимизированный оригинал + thumbnail → SHA-256 →
/// дедупликация → атомарная запись. Тяжёлая середина уходит в отдельный
/// изолят: см. [_processImage].
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

  static const int jpegQuality = 88;

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

  /// Папка приложения, уже спрошенная у платформы.
  ///
  /// Спрашивать её — это вызов через канал платформы, а зовётся он на каждую
  /// фотографию: показать обложки страницы каталога или удалить снимки записи
  /// означало десятки одинаковых вопросов подряд. Путь за время работы не
  /// меняется, а вот существование каталога проверяем каждый раз — его могли
  /// убрать снаружи.
  static Directory? _appMediaDir;

  /// Каталог хранения изображений внутри приватной папки приложения.
  Future<Directory> _mediaDir() async {
    final dir = _mediaOverride ?? _appMediaDir ?? await _resolveMediaDir();
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }

  Future<Directory> _resolveMediaDir() async {
    final base = await getApplicationSupportDirectory();
    return _appMediaDir = Directory(p.join(base.path, 'media'));
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
    // 1-3. Сигнатура и MIME; подозрительные файлы отклоняем.
    final rejection = _rejectionFor(bytes);
    if (rejection != null) return rejection;

    // 4-8. Разбор, поворот по EXIF, сжатие и миниатюра — в отдельном изоляте.
    // `package:image` целиком на Dart, и снимок с телефона обрабатывается
    // секунду-другую: в основном изоляте на это время замирал весь интерфейс,
    // а фотографии как раз чаще всего добавляют с телефона.
    final processed = await Isolate.run(() => _processImage(bytes));
    if (processed == null) {
      return const ImageRejected('Не удалось прочитать изображение');
    }
    return _store(processed, caption);
  }

  /// Сколько изображений уходит в изолят за один раз.
  ///
  /// Внутри они обрабатываются по одному, поэтому разобранным в памяти всегда
  /// остаётся ровно одно, а наружу возвращаются уже сжатые. Больше не берём:
  /// смысл не в размере пачки, а в том, чтобы не запускать изолят заново на
  /// каждую фотографию.
  static const int _processBatchSize = 8;

  /// Добавляет пачку изображений.
  ///
  /// Импорт профиля с четырьмя сотнями фотографий запускал изолят четыреста
  /// раз подряд. Порядок ответов совпадает с порядком [images], а отклонённые
  /// не прерывают остальных.
  Future<List<ImageResult>> addAllFromBytes(List<Uint8List> images) async {
    final results = List<ImageResult?>.filled(images.length, null);

    // Заведомо негодное отсеиваем до изолята — незачем его туда возить.
    final queue = <int>[];
    for (var i = 0; i < images.length; i++) {
      final rejection = _rejectionFor(images[i]);
      if (rejection != null) {
        results[i] = rejection;
      } else {
        queue.add(i);
      }
    }

    for (final chunk in chunked(queue, _processBatchSize)) {
      final batch = [for (final i in chunk) images[i]];
      final processed = await Isolate.run(() => _processImages(batch));
      for (var k = 0; k < chunk.length; k++) {
        final one = processed[k];
        results[chunk[k]] = one == null
            ? const ImageRejected('Не удалось прочитать изображение')
            : await _store(one, null);
      }
    }

    return [for (final r in results) r!];
  }

  /// Почему изображение не примут — или null, если примут.
  ImageRejected? _rejectionFor(Uint8List bytes) {
    if (bytes.length > AppConfig.maxAttachmentBytes) {
      return const ImageRejected('Файл слишком большой');
    }
    if (detectMime(bytes) == null) {
      return const ImageRejected('Неподдерживаемый формат изображения');
    }
    return null;
  }

  /// Дедупликация, запись файлов и строка в базе — общий хвост для одного
  /// изображения и для пачки.
  Future<ImageResult> _store(_Processed processed, String? caption) async {
    final optimized = processed.optimized;
    final thumb = processed.thumb;

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
            width: Value(processed.width),
            height: Value(processed.height),
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
