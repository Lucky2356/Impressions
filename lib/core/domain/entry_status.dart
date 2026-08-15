import 'dart:convert';

import '../utils/normalize.dart';

/// Статус записи (§10): на какой стадии впечатление.
///
/// Отношение отвечает на вопрос «понравилось ли», статус — «дошли ли вы до
/// этого вообще». Раньше стадию изображало отношение «Хочу попробовать», и
/// из-за этого нельзя было сказать «уже смотрю, но пока без мнения».
class EntryStatus {
  const EntryStatus({required this.key, required this.name, this.done = false});

  /// Ключ, общий для всех типов: по нему работают отборы.
  final String key;

  /// Название у каждого типа своё: «Прочитал» и «Попробовал» — про разное.
  final String name;

  /// Завершающий статус — тот, после которого впечатление уже состоялось.
  final bool done;

  /// Задумано, но ещё не начато.
  static const String planned = 'planned';

  /// В процессе.
  static const String inProgress = 'inProgress';

  /// Завершено.
  static const String doneKey = 'done';

  Map<String, Object?> toJson() => {'key': key, 'name': name, 'done': done};

  static EntryStatus? fromJson(Object? value) {
    if (value is! Map) return null;
    final key = value['key'];
    final name = value['name'];
    if (key is! String || key.isEmpty || name is! String) return null;
    return EntryStatus(key: key, name: name, done: value['done'] == true);
  }

  /// Разбирает набор статусов типа. Повреждённый JSON — это «статусов нет»,
  /// а не авария: тип должен открываться и без них.
  static List<EntryStatus> decode(String? json) {
    if (json == null || json.isEmpty) return const [];
    try {
      final parsed = jsonDecode(json);
      if (parsed is! List) return const [];
      return [for (final item in parsed) ?fromJson(item)];
    } on FormatException {
      return const [];
    }
  }

  static String? encode(List<EntryStatus> statuses) => statuses.isEmpty
      ? null
      : jsonEncode([for (final s in statuses) s.toJson()]);

  @override
  String toString() => 'EntryStatus($key, $name, done: $done)';
}

/// Что тип знает про стадии: набор статусов и в чём мерить прогресс.
typedef StatusDefaults = ({List<EntryStatus> statuses, String? progressUnit});

/// Стартовые наборы статусов встроенных типов (§8, §10).
///
/// Лежат в домене, а не в `SeedService`: их проставляет и первый запуск, и
/// обновление базы до схемы 7 — у профилей, заведённых раньше, статусов не
/// было вовсе.
class BuiltInStatuses {
  const BuiltInStatuses._();

  /// «Задумано → в процессе → сделано» с названиями под конкретный тип.
  ///
  /// Ключи одни и те же у всех типов: иначе отбор «что сейчас в процессе»
  /// пришлось бы задавать отдельно для книг, фильмов и продуктов. У продукта
  /// промежуточной стадии нет — попробовал или нет.
  static List<EntryStatus> stages(
    String planned,
    String? inProgress,
    String done,
  ) => [
    EntryStatus(key: EntryStatus.planned, name: planned),
    if (inProgress != null)
      EntryStatus(key: EntryStatus.inProgress, name: inProgress),
    EntryStatus(key: EntryStatus.doneKey, name: done, done: true),
  ];

  /// Ключ — нормализованное название встроенного типа (`Normalize.name`).
  static final Map<String, StatusDefaults> byTypeName = {
    'продукты': (
      statuses: stages('Хочу попробовать', null, 'Попробовал'),
      progressUnit: null,
    ),
    'блюда': (
      statuses: stages('Хочу попробовать', null, 'Попробовал'),
      progressUnit: null,
    ),
    'места': (
      statuses: stages('Хочу побывать', null, 'Был'),
      progressUnit: null,
    ),
    'города': (
      statuses: stages('Хочу побывать', null, 'Был'),
      progressUnit: null,
    ),
    'фильмы': (
      statuses: stages('Хочу посмотреть', 'Смотрю', 'Посмотрел'),
      progressUnit: null,
    ),
    'сериалы': (
      statuses: stages('Хочу посмотреть', 'Смотрю', 'Посмотрел'),
      progressUnit: 'серия',
    ),
    'музыка': (
      statuses: stages('Хочу послушать', null, 'Послушал'),
      progressUnit: null,
    ),
    'книги': (
      statuses: stages('Хочу прочитать', 'Читаю', 'Прочитал'),
      progressUnit: 'страница',
    ),
    'игры': (
      statuses: stages('Хочу поиграть', 'Играю', 'Прошёл'),
      progressUnit: 'час',
    ),
    'товары': (
      statuses: stages('Хочу купить', null, 'Купил'),
      progressUnit: null,
    ),
    'другое': (
      statuses: stages('Хочу попробовать', null, 'Попробовал'),
      progressUnit: null,
    ),
  };

  /// Набор для типа по его названию. Пользовательские типы статусов не
  /// получают: угаданный набор был бы навязанным, а не подсказкой.
  static StatusDefaults? forTypeName(String name) =>
      byTypeName[Normalize.name(name)];
}
