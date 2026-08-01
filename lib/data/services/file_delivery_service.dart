import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Чем закончилась выдача готового файла.
enum FileDeliveryStatus {
  /// Файл записан по выбранному человеком пути — путь лежит в [FileDelivery.path].
  saved,

  /// Файл отдан системному «Поделиться»: куда он попал, приложение не знает.
  shared,

  /// Человек закрыл диалог, ничего не выбрав.
  cancelled,
}

/// Итог выдачи файла.
class FileDelivery {
  const FileDelivery._(this.status, this.path);

  const FileDelivery.saved(String path)
    : this._(FileDeliveryStatus.saved, path);
  const FileDelivery.shared() : this._(FileDeliveryStatus.shared, null);
  const FileDelivery.cancelled() : this._(FileDeliveryStatus.cancelled, null);

  final FileDeliveryStatus status;

  /// Путь готового файла — только для [FileDeliveryStatus.saved].
  final String? path;
}

/// Как отдать человеку готовый файл: диалогом сохранения или «Поделиться».
///
/// На Windows работает обычный диалог сохранения. На Android его нет вовсе: в
/// `file_selector_android` реализованы только открытие файла и выбор папки, а
/// `getSaveLocation` там уходит в заглушку платформенного слоя и бросает
/// `UnimplementedError`. Поэтому на телефоне файл пишется в свою временную
/// папку и отдаётся системному «Поделиться» — оттуда его сохраняют в
/// «Загрузки», кладут в облако или отправляют себе.
///
/// Писать напрямую в общую память нельзя: с Android 11 приложение не создаёт
/// файлы по произвольному пути, а собственная папка приложения из проводника
/// не видна — забрать оттуда файл человек не сможет.
class FileDeliveryService {
  const FileDeliveryService({this.share, this.stagingDirectory});

  /// Подменяется в тестах: настоящий вызов открывает системное окно.
  final SharePlus? share;

  /// Подменяется в тестах: `path_provider` в тестах недоступен.
  final Directory? stagingDirectory;

  /// Спрашивать место обычным диалогом умеют только настольные системы.
  static bool get hasSaveDialog =>
      defaultTargetPlatform != TargetPlatform.android &&
      defaultTargetPlatform != TargetPlatform.iOS;

  /// Записать файл туда, куда скажет человек.
  ///
  /// [write] вызывается уже с готовым местом назначения, поэтому содержимое
  /// собирается один раз и не зависит от способа выдачи.
  Future<FileDelivery> deliver({
    required String fileName,
    required String typeLabel,
    required String extension,
    required Future<void> Function(File file) write,
  }) async {
    if (!hasSaveDialog) return _shareFile(fileName, write);

    final location = await getSaveLocation(
      suggestedName: fileName,
      acceptedTypeGroups: [
        XTypeGroup(label: typeLabel, extensions: [extension]),
      ],
    );
    if (location == null) return const FileDelivery.cancelled();

    await write(File(location.path));
    return FileDelivery.saved(location.path);
  }

  Future<FileDelivery> _shareFile(
    String fileName,
    Future<void> Function(File file) write,
  ) async {
    final dir = await _staging();
    final file = File(p.join(dir.path, fileName));
    await write(file);

    final result = await (share ?? SharePlus.instance).share(
      ShareParams(files: [XFile(file.path)], fileNameOverrides: [fileName]),
    );
    // На Android «поделился» и «выбрал приложение» неразличимы, известен только
    // отказ. Всё остальное считаем успехом, иначе успешный экспорт молчал бы.
    return result.status == ShareResultStatus.dismissed
        ? const FileDelivery.cancelled()
        : const FileDelivery.shared();
  }

  /// Папка для файла на время передачи.
  ///
  /// Чистится перед каждой выдачей, а не после: принимающее приложение читает
  /// файл уже после того, как «Поделиться» вернуло управление.
  Future<Directory> _staging() async {
    final base = stagingDirectory ?? await getTemporaryDirectory();
    final dir = Directory(p.join(base.path, 'export'));
    if (dir.existsSync()) await dir.delete(recursive: true);
    await dir.create(recursive: true);
    return dir;
  }
}
