import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Локальный журнал аварий.
///
/// Раньше сбоев не было видно вовсе: исключение в дереве виджетов давало серый
/// прямоугольник, а исключение вне дерева терялось молча — пожаловаться было
/// нечем. Внешний сбор аварий сюда не подходит: приложение обещает работать
/// без сети и ничего о себе не сообщать. Поэтому записи ложатся в файл рядом с
/// базой, показываются в настройках и уходят наружу только тем, что человек
/// скопирует их сам.
class ErrorLog {
  const ErrorLog._();

  /// Сколько записей держим. Журнал нужен для разбора недавнего, а не как
  /// история за всё время: старые записи вытесняются новыми.
  static const int maxRecords = 200;

  /// С какого размера журнал подрезается, даже если записей немного.
  ///
  /// Одна авария с длинным сообщением может весить сколько угодно, а счёт
  /// записей этого не заметит.
  static const int _trimAtSize = 1024 * 1024;

  /// Сколько оставляем, когда подрезаем по размеру.
  static const int _keepSize = 256 * 1024;

  /// Сколько аварий записано с последней подрезки.
  ///
  /// Считаем в памяти, а не по файлу: авария в отрисовке повторяется каждый
  /// кадр, и перечитывать журнал целиком на каждую — верный способ добить и
  /// без того сломанное приложение. После перезапуска счёт начинается заново,
  /// поэтому записей до первой подрезки может набраться вдвое больше — на
  /// разбор недавнего это не влияет.
  static int _sinceTrim = 0;

  static const String _fileName = 'errors.log';

  /// Разделитель записей: одна авария занимает несколько строк.
  static const String _separator = '\n=== ';

  /// Путь вычисляется каждый раз, а не кэшируется: журнал пишется редко, зато
  /// каталог мог не существовать или быть удалён между запусками, и файл на
  /// устаревшем пути молча терялся бы.
  static Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    if (!dir.existsSync()) await dir.create(recursive: true);
    return File(p.join(dir.path, _fileName));
  }

  /// Записывает аварию. Никогда не бросает: журнал не должен быть причиной
  /// второго сбоя поверх первого.
  static Future<void> record(
    Object error,
    StackTrace? stack, {
    String? context,
  }) async {
    try {
      final when = DateTime.now().toIso8601String();
      final where = context == null ? '' : ' · $context';
      final trace = stack == null ? '' : '\n${_shortTrace(stack)}';
      final record = '$_separator$when$where ===\n$error$trace\n';

      final file = await _file();
      // Дописываем в конец: раньше каждая авария читала и переписывала весь
      // журнал, и сбой в отрисовке делал это каждый кадр.
      await file.writeAsString(record, mode: FileMode.append, flush: true);

      _sinceTrim++;
      if (_sinceTrim >= maxRecords || await file.length() > _trimAtSize) {
        await file.writeAsString(_trim(await file.readAsString()));
        _sinceTrim = 0;
      }
    } on Object catch (e) {
      // Писать некуда — остаётся консоль отладочной сборки.
      debugPrint('Не удалось записать в журнал ошибок: $e');
    }
  }

  /// Весь журнал одной строкой. Пустая строка, если аварий не было.
  static Future<String> read() async {
    try {
      final file = await _file();
      if (!file.existsSync()) return '';
      return file.readAsString();
    } on Object {
      return '';
    }
  }

  /// Сколько записей в журнале.
  static Future<int> count() async {
    final text = await read();
    if (text.trim().isEmpty) return 0;
    return _separator.allMatches(text).length;
  }

  static Future<void> clear() async {
    try {
      final file = await _file();
      if (file.existsSync()) await file.delete();
    } on Object {
      // Нечего чистить.
    }
  }

  /// Оставляет последние [maxRecords] записей и не больше [_keepSize].
  static String _trim(String text) {
    var kept = text;

    final parts = kept.split(_separator);
    if (parts.length - 1 > maxRecords) {
      kept =
          _separator +
          parts.sublist(parts.length - maxRecords).join(_separator);
    }

    // Двести записей — это ещё не ограничение размера: у одной аварии
    // сообщение может быть длиной в целый файл.
    if (kept.length > _keepSize) {
      final from = kept.indexOf(_separator, kept.length - _keepSize);
      kept = from < 0
          ? kept.substring(kept.length - _keepSize)
          : kept.substring(from);
    }
    return kept;
  }

  /// Первые кадры стека: полный след занимает экран и почти ничего не
  /// добавляет к пониманию, где сломалось.
  static String _shortTrace(StackTrace stack) {
    final lines = stack.toString().split('\n');
    return lines.take(12).join('\n');
  }

  /// Ставит перехват аварий и запускает [body] в защищённой зоне.
  ///
  /// Три источника: ошибки дерева виджетов, ошибки платформы и всё
  /// необработанное в асинхронном коде.
  static void guard(void Function() body) {
    final previous = FlutterError.onError;
    FlutterError.onError = (details) {
      unawaited(record(details.exception, details.stack, context: 'виджет'));
      previous?.call(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      unawaited(record(error, stack, context: 'платформа'));
      return true;
    };

    runZonedGuarded(body, (error, stack) {
      unawaited(record(error, stack, context: 'асинхронно'));
    });
  }
}
