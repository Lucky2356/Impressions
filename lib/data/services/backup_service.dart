import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/config/app_config.dart';
import '../db/database.dart';
import '../repositories/settings_repository.dart';
import 'backup_cipher.dart';
import 'secret_storage.dart';

/// Информация о резервной копии.
class BackupInfo {
  const BackupInfo({
    required this.path,
    required this.createdAt,
    required this.byteSize,
    required this.reason,
    this.encrypted = false,
  });

  final String path;
  final DateTime createdAt;
  final int byteSize;
  final String reason;

  /// Копия защищена паролем.
  final bool encrypted;

  String get fileName => p.basename(path);
}

/// Чем закончилась попытка прочитать копию.
enum BackupCheck {
  ok,

  /// Файла копии нет.
  notFound,

  /// Копия не прошла проверку — восстанавливать нечего.
  corrupted,

  /// Копия зашифрована, а ключа этого устройства к ней нет: сделана на другом
  /// устройстве или до переустановки. Нужен пароль.
  passwordRequired,

  /// Пароль не подошёл.
  wrongPassword,
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

  /// Копия зашифрована и требует пароль.
  passwordRequired,

  /// Пароль не подошёл.
  wrongPassword,
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
  BackupService(this.db, {this.rootOverride, SecretStorage? secrets})
    : _settings = SettingsRepository(db),
      _secrets = secrets ?? const SecretStorage();

  final AppDatabase db;

  /// Каталог хранения для тестов; в приложении используется папка приложения.
  final Directory? rootOverride;

  final SettingsRepository _settings;
  final SecretStorage _secrets;

  static const String _manifestName = 'backup.json';
  static const String _dbEntryName = 'impressions.sqlite';
  static const String _mediaPrefix = 'media/';

  /// Имя ключа копий в хранилище ОС.
  static const String _backupKeyName = 'backup_key';

  /// Расширение зашифрованной копии.
  static const String _encSuffix = '.zip.enc';
  static const String _plainSuffix = '.zip';

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

  // ---- Защита копий паролем ----

  /// Шифруются ли новые копии.
  Future<bool> encryptionEnabled() =>
      _settings.getBool(SettingKeys.backupsEncrypted);

  /// Ключ копий из хранилища ОС. null — ключа нет.
  Future<SecretKey?> _backupKey() async {
    final stored = await _secrets.read(_backupKeyName);
    if (stored == null || stored.isEmpty) return null;
    return SecretKey(base64Decode(stored));
  }

  /// Включает защиту копий паролем либо меняет пароль.
  ///
  /// Ключ копий при смене пароля остаётся прежним, меняется только его
  /// обёртка. Поэтому уже сделанные копии продолжают открываться **старым**
  /// паролем: обёртка лежит в каждом файле и задним числом не меняется.
  ///
  /// Возвращает false, если хранилище ОС недоступно и ключ положить некуда.
  Future<bool> enableEncryption(String password) async {
    var key = await _backupKey();
    if (key == null) {
      key = await BackupCipher.newKey();
      final encoded = base64Encode(await key.extractBytes());
      // Запасного хранения в базе здесь нет намеренно: база целиком попадает
      // в копию, и ключ рядом с зашифрованным им содержимым бесполезен.
      if (!await _secrets.write(_backupKeyName, encoded)) return false;
    }
    final wrapped = await BackupCipher.wrapKey(key, password);
    await _settings.set(SettingKeys.backupKeyWrapped, jsonEncode(wrapped));
    await _settings.setBool(SettingKeys.backupsEncrypted, true);
    return true;
  }

  /// Выключает шифрование новых копий.
  ///
  /// Ключ и обёртка остаются: без них уже сделанные копии не открыть.
  Future<void> disableEncryption() =>
      _settings.setBool(SettingKeys.backupsEncrypted, false);

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

    // Что попадёт в копию: имя внутри архива → файл на диске.
    final sources = <String, File>{};
    if (dbFile.existsSync()) sources[_dbEntryName] = dbFile;
    if (mediaDir.existsSync()) {
      for (final entity in mediaDir.listSync()) {
        if (entity is! File) continue;
        sources['$_mediaPrefix${p.basename(entity.path)}'] = entity;
      }
    }

    // Контрольные суммы считаются потоково: файл не поднимается в память
    // целиком даже ради хеша.
    final checksums = <String, String>{};
    for (final entry in sources.entries) {
      checksums[entry.key] = await _sha256OfFile(entry.value);
    }

    final createdAt = DateTime.now();
    final manifest = <String, Object?>{
      'createdAt': createdAt.toUtc().toIso8601String(),
      'reason': reason,
      'schemaVersion': db.schemaVersion,
      'appVersion': AppConfig.payloadVersion,
      'files': checksums,
    };
    final manifestBytes = utf8.encode(jsonEncode(manifest));

    final dir = await backupsDir();
    final stamp = createdAt
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final stem = p.join(dir.path, 'backup_${reason}_$stamp');
    final tmp = File('$stem.building');

    // Архив пишется сразу в файл. Раньше он собирался в памяти целиком, а
    // затем ещё раз кодировался в неё же — то есть база и все фотографии
    // держались в оперативной памяти в двух экземплярах. На телефоне с большой
    // медиатекой это заканчивалось нехваткой памяти.
    final encoder = ZipFileEncoder();
    encoder.create(tmp.path);
    try {
      for (final entry in sources.entries) {
        await encoder.addFile(entry.value, entry.key);
      }
      encoder.addArchiveFile(ArchiveFile.bytes(_manifestName, manifestBytes));
    } finally {
      await encoder.close();
    }

    var encrypt = await encryptionEnabled();
    final key = encrypt ? await _backupKey() : null;
    final wrapped = encrypt
        ? await _settings.get(SettingKeys.backupKeyWrapped)
        : null;

    // Настройки говорят «шифровать», а ключа нет. Так бывает после
    // восстановления копии с другого устройства: она приносит с собой чужие
    // настройки, а ключ остаётся здешний — или его вовсе не было. Прежний
    // ключ восстановить нечем, новый завернуть не во что (пароля нам никто не
    // говорил), поэтому копию делаем открытой и честно выключаем защиту:
    // несделанная копия хуже незашифрованной, а молчать об этом нельзя.
    if (encrypt && (key == null || wrapped == null)) {
      encrypt = false;
      await disableEncryption();
    }

    final file = File('$stem${encrypt ? _encSuffix : _plainSuffix}');

    if (encrypt) {
      final sealed = File('$stem.sealing');
      await BackupCipher.encryptFile(
        tmp,
        sealed,
        key: key!,
        wrappedKey: jsonDecode(wrapped!) as Map<String, Object?>,
      );
      await tmp.delete();
      // Атомарная замена: незавершённая копия не должна выглядеть готовой.
      await sealed.rename(file.path);
    } else {
      await tmp.rename(file.path);
    }

    // Размер снимаем до очистки: она может удалить и эту копию, если предел
    // хранения уже достигнут, и тогда файла к моменту ответа не будет.
    final byteSize = await file.length();
    await _pruneOld();

    return BackupInfo(
      path: file.path,
      createdAt: createdAt,
      byteSize: byteSize,
      reason: reason,
      encrypted: encrypt,
    );
  }

  /// SHA-256 файла без чтения его целиком в память.
  static Future<String> _sha256OfFile(File file) async {
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString();
  }

  /// Список копий, от новых к старым.
  Future<List<BackupInfo>> list() async {
    final dir = await backupsDir();
    final files = dir
        .listSync()
        .whereType<File>()
        .where(
          (f) => f.path.endsWith(_plainSuffix) || f.path.endsWith(_encSuffix),
        )
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
          encrypted: f.path.endsWith(_encSuffix),
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

  /// Готовит копию к чтению: зашифрованную расшифровывает во временный файл.
  ///
  /// Порядок попыток: сначала ключ этого устройства, и только если его нет или
  /// он не подошёл — пароль. Поэтому свои копии восстанавливаются без лишних
  /// вопросов, а чужие спрашивают пароль.
  Future<_OpenedBackup> _open(String path, {String? password}) async {
    final file = File(path);
    if (!file.existsSync()) {
      return const _OpenedBackup.failed(BackupCheck.notFound);
    }

    final header = await BackupCipher.readHeader(file);
    if (header == null) return _OpenedBackup.ready(path);

    SecretKey? key;
    if (password != null) {
      key = await BackupCipher.unwrapKey(header, password);
      if (key == null) {
        return const _OpenedBackup.failed(BackupCheck.wrongPassword);
      }
    } else {
      key = await _backupKey();
      if (key == null) {
        return const _OpenedBackup.failed(BackupCheck.passwordRequired);
      }
    }

    final plain = File('$path.opened');
    if (!await BackupCipher.decryptFile(file, plain, key: key)) {
      // Ключ этого устройства не подошёл — копия сделана на другом.
      return _OpenedBackup.failed(
        password == null ? BackupCheck.passwordRequired : BackupCheck.corrupted,
      );
    }
    return _OpenedBackup.ready(plain.path, temporary: true);
  }

  /// Манифест копии, прочитанный без распаковки остального.
  Future<Map<String, Object?>?> _readManifest(String zipPath) async {
    InputFileStream? input;
    try {
      input = InputFileStream(zipPath);
      final archive = ZipDecoder().decodeStream(input);
      final entry = archive.files
          .where((f) => f.name == _manifestName)
          .firstOrNull;
      final bytes = entry?.readBytes();
      if (bytes == null) return null;
      return jsonDecode(utf8.decode(bytes)) as Map<String, Object?>;
    } on Object {
      return null;
    } finally {
      await input?.close();
    }
  }

  /// Проверка целостности копии по контрольным суммам (§28).
  ///
  /// Для [password] см. [_open]: он нужен только копиям с другого устройства.
  Future<BackupCheck> verify(String path, {String? password}) async {
    final opened = await _open(path, password: password);
    final zipPath = opened.zipPath;
    if (zipPath == null) return opened.check;
    try {
      return await _verifyZip(zipPath) ? BackupCheck.ok : BackupCheck.corrupted;
    } finally {
      await opened.dispose();
    }
  }

  /// Сверка контрольных сумм внутри обычного зипа.
  ///
  /// Архив читается с диска по мере надобности, а сумма записи считается прямо
  /// во время распаковки: содержимое не собирается целиком ни в памяти, ни во
  /// временном файле. Раньше здесь был `readAsBytes`, и копия с медиатекой
  /// поднималась в память вся сразу.
  Future<bool> _verifyZip(String zipPath) async {
    InputFileStream? input;
    try {
      input = InputFileStream(zipPath);
      final archive = ZipDecoder().decodeStream(input);
      final manifestEntry = archive.files
          .where((f) => f.name == _manifestName)
          .firstOrNull;
      final manifestBytes = manifestEntry?.readBytes();
      if (manifestBytes == null) return false;

      final manifest =
          jsonDecode(utf8.decode(manifestBytes)) as Map<String, Object?>;
      final expected = manifest['files'];
      if (expected is! Map) return false;

      for (final f in archive.files) {
        if (f.name == _manifestName || !f.isFile) continue;
        final want = expected[f.name];
        if (want == null) return false;
        final sink = _Sha256OutputStream();
        f.writeContent(sink);
        if (sink.hex != want) return false;
      }
      return true;
    } on Object {
      return false;
    } finally {
      await input?.close();
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
    String? password,
  }) async {
    // Зашифрованная копия расшифровывается один раз на всю операцию: и на
    // проверку сумм, и на распаковку.
    final opened = await _open(path, password: password);
    final zipPath = opened.zipPath;
    if (zipPath == null) {
      return RestoreResult(switch (opened.check) {
        BackupCheck.notFound => RestoreStatus.notFound,
        BackupCheck.passwordRequired => RestoreStatus.passwordRequired,
        BackupCheck.wrongPassword => RestoreStatus.wrongPassword,
        _ => RestoreStatus.corrupted,
      });
    }

    try {
      final manifest = await _readManifest(zipPath);
      if (manifest == null) return const RestoreResult(RestoreStatus.corrupted);

      // Копию из будущего читать нечем: миграции идут только вперёд.
      final schema = manifest['schemaVersion'];
      if (schema is int && schema > db.schemaVersion) {
        return const RestoreResult(RestoreStatus.tooNew);
      }

      if (!await _verifyZip(zipPath)) {
        return const RestoreResult(RestoreStatus.corrupted);
      }

      final backupOfPrevious = await create(reason: 'beforeRestore');
      await closeDatabase();

      final base = await _appDir();
      final dbTarget = File(p.join(base.path, 'impressions.sqlite'));
      final mediaDir = Directory(p.join(base.path, 'media'));

      InputFileStream? input;
      try {
        input = InputFileStream(zipPath);
        final archive = ZipDecoder().decodeStream(input);

        for (final entry in archive.files) {
          if (entry.name == _manifestName || !entry.isFile) continue;

          if (entry.name == _dbEntryName) {
            await _replaceAtomic(dbTarget, entry);
            continue;
          }
          if (!entry.name.startsWith(_mediaPrefix)) continue;

          if (!mediaDir.existsSync()) await mediaDir.create(recursive: true);
          // Только имя файла: путь из архива к файловой системе не применяем.
          final name = p.basename(entry.name);
          if (name.isEmpty) continue;
          await _replaceAtomic(File(p.join(mediaDir.path, name)), entry);
        }
      } finally {
        // Пока дескриптор архива открыт, Windows не даст переименовать файлы.
        await input?.close();
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
      return RestoreResult(
        RestoreStatus.ok,
        backupOfPrevious: backupOfPrevious,
      );
    } finally {
      await opened.dispose();
    }
  }

  /// Распаковывает запись архива поверх файла, не поднимая её в память.
  ///
  /// Сначала во временное имя рядом, затем переименование: прерванное
  /// восстановление не оставит полуразобранный файл на месте настоящего.
  Future<void> _replaceAtomic(File target, ArchiveFile entry) async {
    final tmp = File('${target.path}.restore-tmp');
    final out = OutputFileStream(tmp.path);
    try {
      entry.writeContent(out);
    } finally {
      await out.close();
    }
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

/// Копия, готовая к чтению как обычный зип.
///
/// Для зашифрованной это временный расшифрованный файл, который [dispose]
/// убирает за собой.
class _OpenedBackup {
  const _OpenedBackup.ready(this.zipPath, {this.temporary = false})
    : check = BackupCheck.ok;

  const _OpenedBackup.failed(this.check) : zipPath = null, temporary = false;

  final String? zipPath;
  final bool temporary;
  final BackupCheck check;

  Future<void> dispose() async {
    if (!temporary || zipPath == null) return;
    final file = File(zipPath!);
    if (file.existsSync()) await file.delete();
  }
}

/// Приёмник распаковки, считающий SHA-256 по мере поступления байтов.
///
/// `ArchiveFile.writeContent` разжимает запись прямо в этот поток, поэтому для
/// проверки контрольной суммы содержимое нигде не накапливается.
class _Sha256OutputStream extends OutputStream {
  _Sha256OutputStream() : super(byteOrder: ByteOrder.littleEndian);

  final _digest = _DigestHolder();
  late final ByteConversionSink _sink = sha256.startChunkedConversion(_digest);
  int _length = 0;

  /// Итоговая сумма. После вызова дописывать в поток уже нельзя.
  String get hex {
    _sink.close();
    return _digest.value.toString();
  }

  @override
  int get length => _length;

  @override
  void writeByte(int value) {
    _sink.add([value]);
    _length++;
  }

  @override
  void writeBytes(List<int> bytes, {int? length}) {
    final count = length ?? bytes.length;
    _sink.add(count == bytes.length ? bytes : bytes.sublist(0, count));
    _length += count;
  }

  @override
  void writeStream(InputStream stream) {
    // Записи без сжатия приходят сюда потоком — читаем их частями.
    const chunk = 1024 * 1024;
    var left = stream.length;
    while (left > 0) {
      final take = left > chunk ? chunk : left;
      writeBytes(stream.readBytes(take).toUint8List());
      left -= take;
    }
  }

  @override
  void clear() {}

  @override
  void flush() {}

  @override
  Uint8List subset(int start, [int? end]) => Uint8List(0);
}

class _DigestHolder implements Sink<Digest> {
  late Digest value;

  @override
  void add(Digest data) => value = data;

  @override
  void close() {}
}
