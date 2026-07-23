import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/config/app_config.dart';
import '../../core/utils/hashing.dart';
import '../db/database.dart';

/// Информация о резервной копии.
class BackupInfo {
  const BackupInfo({
    required this.path,
    required this.createdAt,
    required this.byteSize,
    required this.reason,
  });

  final String path;
  final DateTime createdAt;
  final int byteSize;
  final String reason;

  String get fileName => p.basename(path);
}

/// Чем закончилась попытка восстановления.
enum RestoreStatus {
  ok,

  /// Файла копии нет.
  notFound,

  /// Копия не прошла проверку контрольных сумм — восстанавливать нечего.
  corrupted,

  /// Копия сделана более новой версией приложения: её схему текущая версия
  /// прочитать не сможет.
  tooNew,
}

/// Итог восстановления.
class RestoreResult {
  const RestoreResult(this.status, {this.backupOfPrevious});

  final RestoreStatus status;

  /// Копия того состояния, которое было заменено (§28).
  final BackupInfo? backupOfPrevious;

  bool get isOk => status == RestoreStatus.ok;
}

/// Резервные копии (§28).
///
/// Копия создаётся перед импортом, восстановлением и миграцией, а также
/// вручную. Хранятся последние [AppConfig.autoBackupRetention] автоматических
/// копий. Копия включает файл SQLite, изображения и метаданные с контрольной
/// суммой для проверки целостности.
class BackupService {
  BackupService(this.db, {this.rootOverride});

  final AppDatabase db;

  /// Каталог хранения для тестов; в приложении используется папка приложения.
  final Directory? rootOverride;

  static const String _manifestName = 'backup.json';
  static const String _dbEntryName = 'impressions.sqlite';
  static const String _mediaPrefix = 'media/';

  Future<Directory> _appDir() async {
    final override = rootOverride;
    if (override != null) {
      if (!override.existsSync()) await override.create(recursive: true);
      return override;
    }
    return getApplicationSupportDirectory();
  }

  Future<Directory> backupsDir() async {
    final base = await _appDir();
    final dir = Directory(p.join(base.path, 'backups'));
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }

  /// Создаёт резервную копию текущего состояния.
  ///
  /// [reason] — почему копия создана: `beforeImport`, `beforeRestore`,
  /// `manual`, `beforeMigration`.
  Future<BackupInfo> create({required String reason}) async {
    // Сбрасываем WAL, чтобы файл базы был самодостаточным.
    await db.customStatement('PRAGMA wal_checkpoint(FULL)');

    final base = await _appDir();
    final dbFile = File(p.join(base.path, 'impressions.sqlite'));
    final mediaDir = Directory(p.join(base.path, 'media'));

    final archive = Archive();

    if (dbFile.existsSync()) {
      final bytes = await dbFile.readAsBytes();
      archive.add(ArchiveFile(_dbEntryName, bytes.length, bytes));
    }

    if (mediaDir.existsSync()) {
      for (final entity in mediaDir.listSync()) {
        if (entity is! File) continue;
        final bytes = await entity.readAsBytes();
        archive.add(
          ArchiveFile(
            '$_mediaPrefix${p.basename(entity.path)}',
            bytes.length,
            bytes,
          ),
        );
      }
    }

    final createdAt = DateTime.now();
    final manifest = <String, Object?>{
      'createdAt': createdAt.toUtc().toIso8601String(),
      'reason': reason,
      'schemaVersion': db.schemaVersion,
      'appVersion': AppConfig.payloadVersion,
      'files': {
        for (final f in archive.files)
          f.name: Hashing.sha256Hex(f.content as List<int>),
      },
    };
    final manifestBytes = utf8.encode(jsonEncode(manifest));
    archive.add(
      ArchiveFile(_manifestName, manifestBytes.length, manifestBytes),
    );

    final bytes = ZipEncoder().encode(archive);
    final dir = await backupsDir();
    final stamp = createdAt
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final file = File(p.join(dir.path, 'backup_${reason}_$stamp.zip'));

    // Атомарная запись.
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsBytes(bytes, flush: true);
    await tmp.rename(file.path);

    await _pruneOld();

    return BackupInfo(
      path: file.path,
      createdAt: createdAt,
      byteSize: bytes.length,
      reason: reason,
    );
  }

  /// Список копий, от новых к старым.
  Future<List<BackupInfo>> list() async {
    final dir = await backupsDir();
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.zip'))
        .toList();

    final infos = <BackupInfo>[];
    for (final f in files) {
      final stat = f.statSync();
      infos.add(
        BackupInfo(
          path: f.path,
          createdAt: stat.modified,
          byteSize: stat.size,
          reason: _reasonFromName(p.basename(f.path)),
        ),
      );
    }
    infos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return infos;
  }

  static String _reasonFromName(String name) {
    final parts = name.split('_');
    return parts.length > 1 ? parts[1] : 'manual';
  }

  /// Проверка целостности копии по контрольным суммам (§28).
  Future<bool> verify(String path) async {
    final file = File(path);
    if (!file.existsSync()) return false;
    try {
      final archive = ZipDecoder().decodeBytes(await file.readAsBytes());
      final manifestFile = archive.files
          .where((f) => f.name == _manifestName)
          .firstOrNull;
      if (manifestFile == null) return false;

      final manifest =
          jsonDecode(utf8.decode(manifestFile.content as List<int>))
              as Map<String, Object?>;
      final expected = manifest['files'];
      if (expected is! Map) return false;

      for (final f in archive.files) {
        if (f.name == _manifestName) continue;
        final want = expected[f.name];
        if (want == null) return false;
        if (Hashing.sha256Hex(f.content as List<int>) != want) return false;
      }
      return true;
    } on Object {
      return false;
    }
  }

  /// Восстанавливает состояние из копии (§28).
  ///
  /// Перед заменой делается копия текущего состояния: если восстановили не то,
  /// вернуться будет куда. Файлы пишутся во временные имена рядом и только
  /// потом переименовываются — прерванное восстановление не оставит
  /// полуразобранную базу.
  ///
  /// База должна быть закрыта вызывающей стороной после того, как копия
  /// текущего состояния снята: пока файл открыт, Windows не даст его заменить.
  Future<RestoreResult> restore(
    String path, {
    required Future<void> Function() closeDatabase,
  }) async {
    final file = File(path);
    if (!file.existsSync()) return const RestoreResult(RestoreStatus.notFound);

    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(await file.readAsBytes());
    } on Object {
      return const RestoreResult(RestoreStatus.corrupted);
    }

    final manifestFile = archive.files
        .where((f) => f.name == _manifestName)
        .firstOrNull;
    if (manifestFile == null) {
      return const RestoreResult(RestoreStatus.corrupted);
    }

    // Копию из будущего читать нечем: миграции идут только вперёд.
    try {
      final manifest =
          jsonDecode(utf8.decode(manifestFile.content as List<int>))
              as Map<String, Object?>;
      final schema = manifest['schemaVersion'];
      if (schema is int && schema > db.schemaVersion) {
        return const RestoreResult(RestoreStatus.tooNew);
      }
    } on Object {
      return const RestoreResult(RestoreStatus.corrupted);
    }

    if (!await verify(path)) {
      return const RestoreResult(RestoreStatus.corrupted);
    }

    final backupOfPrevious = await create(reason: 'beforeRestore');
    await closeDatabase();

    final base = await _appDir();
    final dbTarget = File(p.join(base.path, 'impressions.sqlite'));
    final mediaDir = Directory(p.join(base.path, 'media'));

    for (final entry in archive.files) {
      if (entry.name == _manifestName || !entry.isFile) continue;
      final bytes = entry.content as List<int>;

      if (entry.name == _dbEntryName) {
        await _replaceAtomic(dbTarget, bytes);
        continue;
      }
      if (!entry.name.startsWith(_mediaPrefix)) continue;

      if (!mediaDir.existsSync()) await mediaDir.create(recursive: true);
      // Только имя файла: путь из архива к файловой системе не применяем.
      final name = p.basename(entry.name);
      if (name.isEmpty) continue;
      await _replaceAtomic(File(p.join(mediaDir.path, name)), bytes);
    }

    // Журнал упреждающей записи остался от прежней базы. Если его не убрать,
    // SQLite накатит чужие страницы на восстановленный файл и испортит его.
    for (final suffix in const ['-wal', '-shm']) {
      final side = File('${dbTarget.path}$suffix');
      if (side.existsSync()) await side.delete();
    }

    // Изображения, которых в копии не было, остаются на диске: база на них
    // больше не ссылается, а удалять чужие файлы при восстановлении опаснее,
    // чем оставить лишние.
    return RestoreResult(RestoreStatus.ok, backupOfPrevious: backupOfPrevious);
  }

  Future<void> _replaceAtomic(File target, List<int> bytes) async {
    final tmp = File('${target.path}.restore-tmp');
    await tmp.writeAsBytes(bytes, flush: true);
    if (target.existsSync()) await target.delete();
    await tmp.rename(target.path);
  }

  /// Оставляет только последние копии каждого вида (§28).
  ///
  /// Автоматические и ручные считаются отдельно: автоматических делается много
  /// и они одноразовые, ручные создают осознанно.
  Future<void> _pruneOld() async {
    final all = await list();
    await _pruneKind(
      all.where((b) => b.reason != 'manual'),
      AppConfig.autoBackupRetention,
    );
    await _pruneKind(
      all.where((b) => b.reason == 'manual'),
      AppConfig.manualBackupRetention,
    );
  }

  Future<void> _pruneKind(Iterable<BackupInfo> backups, int keep) async {
    for (final old in backups.skip(keep)) {
      final file = File(old.path);
      if (file.existsSync()) await file.delete();
    }
  }
}
