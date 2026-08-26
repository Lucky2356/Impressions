import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Что именно изменилось в данных.
///
/// Вид — это про таблицу, а не про экран. Если действие меняет и записи, и
/// состав подборки, оно называет оба вида, а не заводит третий.
enum DataKind {
  /// Записи и всё, что висит на них: оценка, стадия, снимки, посещения, теги
  /// на записи. Счётчики по веткам тоже считаются отсюда — они про записи.
  entries,

  /// Дерево категорий: состав, названия, порядок, обложки веток.
  categories,

  /// Подборки: сами списки и их состав.
  collections,

  /// Справочник тегов: названия и то, какие вообще есть.
  tags,

  /// Профили, устройства и обмен между ними.
  profiles,

  /// Настройки приложения и всё, что лежит в их таблице.
  settings,
}

/// Счётчики изменений по видам данных.
///
/// Провайдеры-запросы наблюдают свой вид через `select`, а операции записи
/// называют изменившееся. Раньше счётчик был один на всё приложение: смена
/// оценки у одной записи заставляла перечитать и дерево категорий, и сводку
/// по месяцам, и список тегов — полтора десятка запросов ради одной цифры.
@immutable
class DataRevision {
  const DataRevision._(this._counts);

  DataRevision.initial() : _counts = List.filled(DataKind.values.length, 0);

  final List<int> _counts;

  int of(DataKind kind) => _counts[kind.index];

  DataRevision bumped(Iterable<DataKind> kinds) {
    final next = List.of(_counts);
    for (final kind in kinds) {
      next[kind.index]++;
    }
    return DataRevision._(next);
  }

  // Равенство по всем счётчикам сразу: кто наблюдает изменения целиком, а не
  // своим видом, по-прежнему просыпается на любое.
  @override
  bool operator ==(Object other) =>
      other is DataRevision && listEquals(_counts, other._counts);

  @override
  int get hashCode => Object.hashAll(_counts);
}

/// Счётчик изменений данных.
///
/// Провайдеры-запросы наблюдают его, а операции записи вызывают [bump],
/// чтобы списки и счётчики перечитались. Простая и предсказуемая замена
/// ручной инвалидации по всему приложению.
class DataRefresh extends Notifier<DataRevision> {
  @override
  DataRevision build() => DataRevision.initial();

  /// Без указания вида изменившимся считается всё.
  ///
  /// Так вызов остаётся безопасным по умолчанию: назвать лишнее значит просто
  /// перечитать лишнее, а забыть назвать — оставить экран со старым. Поэтому
  /// умолчание широкое, а сужается оно по одному виду за раз.
  void bump([Iterable<DataKind>? kinds]) =>
      state = state.bumped(kinds ?? DataKind.values);
}

final dataRefreshProvider = NotifierProvider<DataRefresh, DataRevision>(
  DataRefresh.new,
);

/// Наблюдать изменения одного вида.
///
/// Короче, чем `select` с разбором вручную, и не даёт случайно наблюдать
/// счётчик целиком — а это ровно та ошибка, ради которой всё затевалось.
extension DataRefreshWatch on Ref {
  void watchData(DataKind kind) =>
      watch(dataRefreshProvider.select((r) => r.of(kind)));
}
