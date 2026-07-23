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

  /// Оставляет только последние N автоматических копий (§28).
  Future<void> _pruneOld() async {
    final all = await list();
    final auto = all
        .where((b) => b.reason != 'manual')
        .toList(); // ручные не удаляем
    if (auto.length <= AppConfig.autoBackupRetention) return;
    for (final old in auto.skip(AppConfig.autoBackupRetention)) {
      final file = File(old.path);
      if (file.existsSync()) await file.delete();
    }
  }
}
