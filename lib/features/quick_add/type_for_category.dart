import '../../data/db/database.dart';

/// Какой тип объекта подставить, когда запись заводят из ветки категорий.
///
/// В базе тип и категория не связаны, и это намеренно (§7, §9): тип задаёт
/// набор полей, категория — полку в дереве, и одно не обязано следовать из
/// другого. Но стартовый набор создаёт одноимённые корневую категорию и тип,
/// а люди так деревья и строят. Поэтому форма угадывает тип по категории —
/// и всегда показывает, что угадала, чтобы можно было поправить.
///
/// Признаки в порядке надёжности:
///
/// 1. Имя самой категории или её предка совпадает с именем типа: «Места /
///    Парки» — тип «Места». Ближний предок точнее дальнего.
/// 2. Совпадений нет — смотрим, записи какого типа уже лежат в ветке.
///
/// Возвращает `null`, когда угадать нечем: тогда остаётся выбор по умолчанию.
String? typeForCategory({
  required CategoryRow category,
  required List<CategoryRow> categories,
  required List<ObjectTypeRow> types,
  List<String> branchTypeNames = const [],
}) {
  if (types.isEmpty) return null;

  final byId = {for (final row in categories) row.id: row};
  final seen = <String>{};
  CategoryRow? node = category;
  while (node != null && seen.add(node.id)) {
    final current = node;
    final match = types
        .where((t) => t.normalizedName == current.normalizedName)
        .firstOrNull;
    if (match != null) return match.id;
    final parentId = current.parentId;
    node = parentId == null ? null : byId[parentId];
  }

  if (branchTypeNames.isEmpty) return null;

  final counts = <String, int>{};
  for (final name in branchTypeNames) {
    counts[name] = (counts[name] ?? 0) + 1;
  }
  // При равенстве берём тот, что стоит раньше в списке типов: иначе
  // подстановка зависела бы от порядка записей и менялась сама собой.
  ObjectTypeRow? best;
  var bestCount = 0;
  for (final type in types) {
    final count = counts[type.name] ?? 0;
    if (count > bestCount) {
      best = type;
      bestCount = count;
    }
  }
  return best?.id;
}
