/// Порядок сортировки каталога (§15).
enum EntrySort { recent, title, rating, impressionDate }

/// Представление записи для списков и карточек: объединяет запись профиля,
/// объект и путь основной категории. Не сущность БД — только для отображения.
class EntryView {
  const EntryView({
    required this.entryId,
    required this.objectId,
    required this.title,
    required this.typeName,
    this.subtitle,
    this.categoryPath = const [],
    this.relation,
    this.rating,
    this.status,
    this.createdAt,
  });

  final String entryId;
  final String objectId;
  final String title;
  final String typeName;
  final String? subtitle;

  /// Названия категорий от корня к основной категории записи.
  final List<String> categoryPath;

  final String? relation;
  final double? rating;
  final String? status;
  final DateTime? createdAt;

  /// Полный путь с названием объекта: «Продукты / Колбасы / Папа может».
  String get fullPath => [...categoryPath, title].join(' / ');
}

/// Сводка по профилю для главной.
class ProfileStats {
  const ProfileStats({
    required this.entries,
    required this.categories,
    required this.collections,
    required this.wantToTry,
  });

  final int entries;
  final int categories;
  final int collections;
  final int wantToTry;
}
