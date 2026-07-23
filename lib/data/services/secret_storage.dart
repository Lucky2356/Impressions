import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Где лежит секрет, которым шифруется закрытый ключ профиля.
enum SecretLocation {
  /// Защита средствами операционной системы: DPAPI на Windows,
  /// песочница приложения на Android.
  operatingSystem,

  /// Таблица настроек в базе приложения — запасной вариант.
  database,
}

/// Хранилище секретов вне базы данных.
///
/// Раньше секрет шифрования лежал в таблице настроек рядом с зашифрованным
/// закрытым ключом, то есть защищал скорее от случайного взгляда, чем от
/// копирования файла базы. Теперь он хранится отдельным файлом:
///
/// * Windows — содержимое зашифровано DPAPI (`CryptProtectData`) на учётную
///   запись пользователя: скопированный на другой компьютер файл бесполезен.
/// * Android — файл лежит в приватном каталоге приложения и исключён из
///   резервных копий (`allowBackup=false`).
///
/// Готовый плагин для этого не подошёл: его реализация под Windows требует ATL
/// из состава Visual Studio, которого может не быть на машине сборки. Прямой
/// вызов DPAPI через FFI не требует ничего, кроме системной crypt32.dll.
class SecretStorage {
  const SecretStorage({this.directoryOverride});

  /// Каталог для хранения — задаётся в тестах.
  final String? directoryOverride;

  Future<String> _fileFor(String key) async {
    final dir =
        directoryOverride ?? (await getApplicationSupportDirectory()).path;
    await Directory(dir).create(recursive: true);
    return p.join(dir, 'secret_$key.bin');
  }

  /// Доступна ли защита средствами ОС.
  bool get osProtected => Platform.isWindows;

  Future<String?> read(String key) async {
    try {
      final file = File(await _fileFor(key));
      if (!file.existsSync()) return null;
      final raw = await file.readAsBytes();
      final clear = osProtected ? _Dpapi.unprotect(raw) : raw;
      if (clear == null) return null;
      return utf8.decode(clear);
    } catch (_) {
      return null;
    }
  }

  /// Возвращает true, если запись удалась.
  Future<bool> write(String key, String value) async {
    try {
      final bytes = Uint8List.fromList(utf8.encode(value));
      final payload = osProtected ? _Dpapi.protect(bytes) : bytes;
      if (payload == null) return false;
      final file = File(await _fileFor(key));
      // Пишем через временный файл: оборванная запись не должна оставить
      // повреждённый секрет, иначе ключ профиля станет нечитаемым.
      final tmp = File('${file.path}.tmp');
      await tmp.writeAsBytes(payload, flush: true);
      await tmp.rename(file.path);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> delete(String key) async {
    try {
      final file = File(await _fileFor(key));
      if (file.existsSync()) await file.delete();
    } catch (_) {
      // Нечего удалять — не ошибка.
    }
  }
}

/// Обёртка над Windows Data Protection API.
class _Dpapi {
  static DynamicLibrary? _lib;

  static DynamicLibrary? get _crypt32 {
    if (!Platform.isWindows) return null;
    try {
      return _lib ??= DynamicLibrary.open('crypt32.dll');
    } catch (_) {
      return null;
    }
  }

  static Uint8List? protect(Uint8List data) => _call(data, encrypt: true);

  static Uint8List? unprotect(Uint8List data) => _call(data, encrypt: false);

  static Uint8List? _call(Uint8List data, {required bool encrypt}) {
    final lib = _crypt32;
    if (lib == null) return null;

    // Обе функции имеют одинаковую форму вызова; отличается лишь тип второго
    // аргумента, а мы всегда передаём туда nullptr, поэтому описываем его как
    // нетипизированный указатель и обходимся одной сигнатурой.
    final fn = lib.lookupFunction<_CryptNative, _CryptDart>(
      encrypt ? 'CryptProtectData' : 'CryptUnprotectData',
    );

    final input = calloc<_DataBlob>();
    final output = calloc<_DataBlob>();
    final buffer = calloc<Uint8>(data.length);
    try {
      buffer.asTypedList(data.length).setAll(0, data);
      input.ref.cbData = data.length;
      input.ref.pbData = buffer;

      final ok = fn(input, nullptr, nullptr, nullptr, nullptr, 0, output);
      if (ok == 0) return null;

      final result = Uint8List.fromList(
        output.ref.pbData.asTypedList(output.ref.cbData),
      );
      _localFree(output.ref.pbData);
      return result;
    } catch (_) {
      return null;
    } finally {
      calloc
        ..free(buffer)
        ..free(input)
        ..free(output);
    }
  }

  static void _localFree(Pointer<Uint8> ptr) {
    if (ptr == nullptr) return;
    try {
      final kernel32 = DynamicLibrary.open('kernel32.dll');
      final free = kernel32
          .lookupFunction<
            Pointer<Void> Function(Pointer<Void>),
            Pointer<Void> Function(Pointer<Void>)
          >('LocalFree');
      free(ptr.cast());
    } catch (_) {
      // Утечка одного небольшого буфера предпочтительнее падения.
    }
  }
}

final class _DataBlob extends Struct {
  @Uint32()
  external int cbData;
  external Pointer<Uint8> pbData;
}

typedef _CryptNative =
    Int32 Function(
      Pointer<_DataBlob> dataIn,
      Pointer<Void> description,
      Pointer<_DataBlob> optionalEntropy,
      Pointer<Void> reserved,
      Pointer<Void> promptStruct,
      Uint32 flags,
      Pointer<_DataBlob> dataOut,
    );
typedef _CryptDart =
    int Function(
      Pointer<_DataBlob> dataIn,
      Pointer<Void> description,
      Pointer<_DataBlob> optionalEntropy,
      Pointer<Void> reserved,
      Pointer<Void> promptStruct,
      int flags,
      Pointer<_DataBlob> dataOut,
    );
