import 'dart:convert';

/// Тип значения пользовательского поля (§9).
enum FieldKind { text, number, date, boolean, choice }

/// Описание одного пользовательского поля типа объекта.
///
/// Схема полей хранится в `object_types.fields_schema` как JSON, значения —
/// в `objects.custom_fields`. Так добавление поля не требует миграции базы, а
/// экспорт переносит и схему, и значения одним куском.
class CustomField {
  const CustomField({
    required this.key,
    required this.name,
    required this.kind,
    this.choices = const [],
  });

  /// Стабильный идентификатор поля: переименование не теряет значения.
  final String key;
  final String name;
  final FieldKind kind;

  /// Варианты для [FieldKind.choice].
  final List<String> choices;

  CustomField copyWith({String? name, FieldKind? kind, List<String>? choices}) {
    return CustomField(
      key: key,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      choices: choices ?? this.choices,
    );
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'name': name,
    'kind': kind.name,
    if (choices.isNotEmpty) 'choices': choices,
  };

  static CustomField? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final key = raw['key'];
    final name = raw['name'];
    if (key is! String || name is! String) return null;
    final kindName = raw['kind'];
    final kind = FieldKind.values.firstWhere(
      (k) => k.name == kindName,
      orElse: () => FieldKind.text,
    );
    final choicesRaw = raw['choices'];
    return CustomField(
      key: key,
      name: name,
      kind: kind,
      choices: choicesRaw is List
          ? choicesRaw.whereType<String>().toList()
          : const [],
    );
  }

  /// Разбирает схему полей типа. Повреждённая схема не должна ронять экран,
  /// поэтому при любой ошибке возвращается пустой список.
  static List<CustomField> decodeSchema(String? json) {
    if (json == null || json.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(json);
      if (decoded is! List) return const [];
      return [for (final item in decoded) ?fromJson(item)];
    } catch (_) {
      return const [];
    }
  }

  static String encodeSchema(List<CustomField> fields) =>
      jsonEncode([for (final f in fields) f.toJson()]);

  /// Значения полей объекта.
  static Map<String, String> decodeValues(String? json) {
    if (json == null || json.trim().isEmpty) return {};
    try {
      final decoded = jsonDecode(json);
      if (decoded is! Map) return {};
      return {
        for (final entry in decoded.entries)
          if (entry.key is String && entry.value != null)
            entry.key as String: '${entry.value}',
      };
    } catch (_) {
      return {};
    }
  }

  static String encodeValues(Map<String, String> values) {
    final cleaned = {
      for (final e in values.entries)
        if (e.value.trim().isNotEmpty) e.key: e.value.trim(),
    };
    return jsonEncode(cleaned);
  }
}
