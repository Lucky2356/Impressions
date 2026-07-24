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
      final existing = file.existsSync() ? await file.readAsString() : '';
      await file.writeAsString(_trim(existing + record));
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

  /// Оставляет последние [maxRecords] записей.
  static String _trim(String text) {
    final parts = text.split(_separator);
    if (parts.length - 1 <= maxRecords) return text;
    final kept = parts.sublist(parts.length - maxRecords);
    return _separator + kept.join(_separator);
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
