import 'package:intl/intl.dart';

import '../models/entry_view.dart';

/// В каком виде выгружать записи для чтения человеком.
enum ReadableFormat { csv, markdown }

/// Выгрузка записей в читаемый вид.
///
/// Основной формат обмена — подписанный контейнер `*.impressions`: он полный,
/// проверяемый и предназначен для другого экземпляра приложения. Но открыть
/// его в таблице или распечатать нельзя, поэтому рядом есть простая выгрузка
/// без подписи и без вложений — только текст.
class ReadableExportService {
  const ReadableExportService();

  static final _date = DateFormat('dd.MM.yyyy');

  /// Заголовки колонок — они же порядок полей.
  static const csvHeaders = [
    'Название',
    'Тип',
    'Категория',
    'Отношение',
    'Оценка',
    'Дата впечатления',
    'Добавлено',
  ];

  String build({
    required List<EntryView> entries,
    required ReadableFormat format,
    required String profileName,
    required String Function(String? relation) relationLabel,
  }) {
    return switch (format) {
      ReadableFormat.csv => _csv(entries, relationLabel),
      ReadableFormat.markdown => _markdown(entries, profileName, relationLabel),
    };
  }

  String extensionFor(ReadableFormat format) =>
      format == ReadableFormat.csv ? 'csv' : 'md';

  // ---- CSV ----

  /// Разделитель — точка с запятой: русский Excel по умолчанию понимает
  /// именно её, а запятая внутри чисел ломала бы колонки.
  static const _separator = ';';

  String _csv(List<EntryView> entries, String Function(String?) relationLabel) {
    final buffer = StringBuffer()
      // BOM: без него Excel открывает файл в системной кодировке и портит
      // кириллицу.
      ..write('﻿')
      ..writeln(csvHeaders.map(_cell).join(_separator));

    for (final e in entries) {
      buffer.writeln(
        [
          e.title,
          e.typeName,
          e.categoryPath.join(' / '),
          relationLabel(e.relation),
          e.rating == null ? '' : e.rating!.toStringAsFixed(1),
          e.impressionDate == null ? '' : _date.format(e.impressionDate!),
          e.createdAt == null ? '' : _date.format(e.createdAt!),
        ].map(_cell).join(_separator),
      );
    }
    return buffer.toString();
  }

  /// Экранирование по RFC 4180: кавычки удваиваются, поле берётся в кавычки,
  /// если содержит разделитель, кавычку или перенос строки.
  String _cell(String value) {
    final escaped = value.replaceAll('"', '""');
    final needsQuotes =
        value.contains(_separator) ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r');
    return needsQuotes ? '"$escaped"' : escaped;
  }

  // ---- Markdown ----

  String _markdown(
    List<EntryView> entries,
    String profileName,
    String Function(String?) relationLabel,
  ) {
    final buffer = StringBuffer()
      ..writeln('# $profileName')
      ..writeln()
      ..writeln(
        'Записей: ${entries.length}. Выгружено ${_date.format(DateTime.now())}.',
      )
      ..writeln();

    // Группируем по основной категории — так список читается как оглавление,
    // а не как сплошная таблица.
    final byCategory = <String, List<EntryView>>{};
    for (final e in entries) {
      final key = e.categoryPath.isEmpty
          ? 'Без категории'
          : e.categoryPath.join(' / ');
      (byCategory[key] ??= []).add(e);
    }

    final keys = byCategory.keys.toList()..sort();
    for (final key in keys) {
      buffer
        ..writeln('## $key')
        ..writeln();
      for (final e in byCategory[key]!) {
        final marks = <String>[
          if (e.relation != null) relationLabel(e.relation),
          if (e.rating != null) '${e.rating!.toStringAsFixed(1)} из 10',
        ];
        buffer.writeln(
          marks.isEmpty
              ? '- ${_escape(e.title)}'
              : '- ${_escape(e.title)} — ${marks.join(', ')}',
        );
      }
      buffer.writeln();
    }
    return buffer.toString();
  }

  /// Экранирует символы, которые Markdown принял бы за разметку.
  String _escape(String value) =>
      value.replaceAllMapped(RegExp(r'([*_\[\]`])'), (m) => '\\${m[1]}');
}
