import 'package:intl/intl.dart';

import '../models/entry_view.dart';
import 'csv_text.dart';
import 'readable_export_service.dart';

/// Подписи выгрузки статистики.
///
/// Приходят снаружи, а не пишутся здесь: в файле должны стоять те же слова,
/// что человек видел на экране, и на том же языке, что интерфейс.
typedef StatsExportLabels = ({
  String title,
  String scope,
  String exported,
  String metric,
  String value,
  String entries,
  String total,
  String rated,
  String average,
  String withPhotos,
  String withNotes,
  String ratings,
  String rating,
  String relations,
  String categories,
  String category,
  String months,
  String month,
});

/// Выгрузка статистики — таблицей или текстом.
///
/// Экран отвечает на вопрос «каковы мои вкусы» картинками: полосами и
/// столбиками. Посчитать по ним что-то своё нельзя, а числа за ними — те же
/// самые. Выгрузка отдаёт именно их: CSV открывается в таблице, Markdown
/// читается и печатается.
///
/// Выгружается показанный срез, а не весь профиль: на экране выбран год или
/// ветка, и файл обязан совпадать с тем, что перед глазами.
class StatsExportService {
  const StatsExportService();

  static final _date = DateFormat('dd.MM.yyyy');
  static final _month = DateFormat('MM.yyyy');

  String build({
    required ProfileInsights data,
    required ReadableFormat format,
    required String profileName,
    required String scope,
    required StatsExportLabels labels,
    required String Function(String? relation) relationLabel,
    DateTime? now,
  }) {
    final at = now ?? DateTime.now();
    return switch (format) {
      ReadableFormat.csv => _csv(
        data,
        profileName,
        scope,
        labels,
        relationLabel,
        at,
      ),
      ReadableFormat.markdown => _markdown(
        data,
        profileName,
        scope,
        labels,
        relationLabel,
        at,
      ),
    };
  }

  /// Пары «показатель — значение»: то же, что в строке чисел над графиками.
  ///
  /// Средняя оценка попадает в выгрузку только когда оценки есть: ноль в этой
  /// строке читался бы как «всё плохо», а не как «не оценивал».
  List<(String, String)> _summary(ProfileInsights d, StatsExportLabels l) => [
    (l.total, '${d.total}'),
    (l.rated, '${d.rated}'),
    if (d.averageRating != null)
      (l.average, d.averageRating!.toStringAsFixed(1)),
    (l.withPhotos, '${d.withPhotos}'),
    (l.withNotes, '${d.withNotes}'),
  ];

  /// Распределение оценок: индекс 0 — балл 1, индекс 9 — балл 10.
  List<(String, int)> _ratings(ProfileInsights d) => [
    for (var i = 0; i < d.ratingBuckets.length; i++)
      ('${i + 1}', d.ratingBuckets[i]),
  ];

  // ---- CSV ----

  String _csv(
    ProfileInsights d,
    String profileName,
    String scope,
    StatsExportLabels l,
    String Function(String?) relationLabel,
    DateTime at,
  ) {
    final buffer = StringBuffer()
      ..write(csvBom)
      ..writeln(csvRow([l.title, profileName]))
      ..writeln(csvRow([l.scope, scope]))
      ..writeln(csvRow([l.exported, _date.format(at)]))
      ..writeln()
      ..writeln(csvRow([l.metric, l.value]));

    for (final (name, value) in _summary(d, l)) {
      buffer.writeln(csvRow([name, value]));
    }

    void section(String header, List<(String, int)> rows) {
      if (rows.isEmpty) return;
      buffer
        ..writeln()
        ..writeln(csvRow([header, l.entries]));
      for (final (name, count) in rows) {
        buffer.writeln(csvRow([name, '$count']));
      }
    }

    section(l.rating, _ratings(d));
    section(l.relations, [
      for (final e in d.byRelation.entries) (relationLabel(e.key), e.value),
    ]);
    section(l.category, [for (final c in d.topCategories) (c.name, c.count)]);
    section(l.month, [
      for (final m in d.byMonth) (_month.format(m.month), m.count),
    ]);

    return buffer.toString();
  }

  // ---- Markdown ----

  String _markdown(
    ProfileInsights d,
    String profileName,
    String scope,
    StatsExportLabels l,
    String Function(String?) relationLabel,
    DateTime at,
  ) {
    final buffer = StringBuffer()
      ..writeln('# ${l.title} — $profileName')
      ..writeln()
      ..writeln('${l.scope}: $scope')
      ..writeln()
      ..writeln('${l.exported}: ${_date.format(at)}')
      ..writeln();

    void table(String title, String header, List<(String, int)> rows) {
      if (rows.isEmpty) return;
      buffer
        ..writeln('## $title')
        ..writeln()
        ..writeln('| $header | ${l.entries} |')
        ..writeln('| --- | --- |');
      for (final (name, count) in rows) {
        buffer.writeln('| ${_escape(name)} | $count |');
      }
      buffer.writeln();
    }

    for (final (name, value) in _summary(d, l)) {
      buffer.writeln('- $name: $value');
    }
    buffer.writeln();

    table(l.ratings, l.rating, _ratings(d));
    table(l.relations, l.relations, [
      for (final e in d.byRelation.entries) (relationLabel(e.key), e.value),
    ]);
    table(l.categories, l.category, [
      for (final c in d.topCategories) (c.name, c.count),
    ]);
    table(l.months, l.month, [
      for (final m in d.byMonth) (_month.format(m.month), m.count),
    ]);

    return buffer.toString();
  }

  /// Экранирует то, что Markdown принял бы за разметку, и вертикальную черту:
  /// без неё название с чертой разваливает таблицу на лишние колонки.
  String _escape(String value) => value
      .replaceAllMapped(RegExp(r'([*_\[\]`])'), (m) => '\\${m[1]}')
      .replaceAll('|', r'\|');
}
