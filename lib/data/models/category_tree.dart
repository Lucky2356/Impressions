import '../db/database.dart';

/// Работа с деревом категорий по уже загруженному списку.
///
/// Дерево хранится как adjacency list плюс материализованный путь: `path` —
/// это идентификаторы от корня до самой категории через `/`, включая её
/// собственный. Отсюда два правила, которыми пользуется весь код:
/// ветка — это префикс пути, предки — это его сегменты.
///
/// Правила были расписаны заново в пяти местах — в репозитории, в провайдерах
/// категорий, в каталоге, в статистике и в выгрузке, — и каждое писало их
/// чуть по-своему. Разъехаться им было негде только потому, что никто их не
/// трогал; здесь они лежат один раз.
class CategoryTree {
  const CategoryTree._();

  /// Разделитель сегментов в [CategoryRow.path].
  static const String separator = '/';

  /// Идентификаторы от корня до самой категории включительно.
  static List<String> pathIds(String path) => path.split(separator);

  static Map<String, CategoryRow> byId(Iterable<CategoryRow> all) => {
    for (final c in all) c.id: c,
  };

  /// Ветка целиком: сама категория и всё, что под ней.
  ///
  /// Пустой список, если такой категории в [all] нет: ветка несуществующего
  /// узла — это ничто, а не «весь профиль».
  static List<CategoryRow> branchOf(Iterable<CategoryRow> all, String rootId) {
    final root = all.where((c) => c.id == rootId).firstOrNull;
    if (root == null) return const [];

    final prefix = '${root.path}$separator';
    return [root, ...all.where((c) => c.path.startsWith(prefix))];
  }

  static List<String> branchIds(Iterable<CategoryRow> all, String rootId) => [
    for (final c in branchOf(all, rootId)) c.id,
  ];

  /// Предки в порядке от корня к родителю, без самой категории.
  static List<CategoryRow> ancestorsOf(
    Iterable<CategoryRow> all,
    CategoryRow node,
  ) {
    final ids = pathIds(node.path)..removeLast();
    if (ids.isEmpty) return const [];
    final map = byId(all);
    return [for (final id in ids) ?map[id]];
  }

  /// Путь от корня к самой категории — то, из чего строятся хлебные крошки.
  static List<CategoryRow> breadcrumbOf(
    Iterable<CategoryRow> all,
    CategoryRow node,
  ) => [...ancestorsOf(all, node), node];

  /// Непосредственные дети. `null` — корневые категории профиля.
  static List<CategoryRow> childrenOf(
    Iterable<CategoryRow> all,
    String? parentId,
  ) => [
    for (final c in all)
      if (c.parentId == parentId) c,
  ];

  /// Тип по умолчанию для новой записи в этой ветке — и ветка, откуда он взят.
  ///
  /// Ищется вверх по дереву: у самой категории, потом у родителя и так до
  /// корня. Ближний предок точнее дальнего — «Места / Парки» получает тип от
  /// «Парков», если он там задан, и только иначе от «Мест».
  ///
  /// До 1.16.0 тип угадывался по совпадению названий категории и типа. Правило
  /// работало ровно потому, что первый запуск заводит одноимённую пару, но
  /// жило в коде: увидеть его было негде, поправить — тоже. Теперь это поле
  /// ветки, а «откуда взят» возвращается вместе с ним, чтобы форма могла это
  /// показать.
  static ({String typeId, CategoryRow from})? defaultTypeFor(
    Iterable<CategoryRow> all,
    CategoryRow category,
  ) {
    for (final node in breadcrumbOf(all, category).reversed) {
      if (node.defaultTypeId case final typeId?) {
        return (typeId: typeId, from: node);
      }
    }
    return null;
  }
}
