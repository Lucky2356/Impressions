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
    this.impressionDate,
    this.createdAt,
    this.coverPath,
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

  /// Когда впечатление случилось, а не когда запись завели.
  final DateTime? impressionDate;
  final DateTime? createdAt;

  /// Абсолютный путь к обложке — миниатюре главной фотографии записи.
  ///
  /// Заполняется списками: без него каталог и главная рисовали цветную
  /// заглушку даже там, где фотография есть.
  final String? coverPath;

  /// Полный путь с названием объекта: «Продукты / Колбасы / Папа может».
  String get fullPath => [...categoryPath, title].join(' / ');
}

/// Показанная часть каталога и сколько всего нашлось.
///
/// Каталог подгружается страницами, но подпись «найдено N» считает всё
/// подходящее — иначе число росло бы по мере прокрутки.
class EntryPage {
  const EntryPage({required this.items, required this.total});

  final List<EntryView> items;
  final int total;

  bool get hasMore => items.length < total;
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

/// Развёрнутая статистика профиля (§14).
///
/// Отдельно от [ProfileStats]: та отвечает за плитки на главной и должна
/// считаться быстро, а эта нужна только на своём экране.
class ProfileInsights {
  const ProfileInsights({
    required this.total,
    required this.rated,
    required this.averageRating,
    required this.ratingBuckets,
    required this.byRelation,
    required this.topCategories,
    required this.byMonth,
    required this.withPhotos,
    required this.withNotes,
  });

  /// Всего неархивных записей.
  final int total;

  /// Сколько из них с оценкой.
  final int rated;

  /// Средняя оценка по тем, у кого она есть; null, если оценок нет.
  final double? averageRating;

  /// Распределение оценок по целым баллам: индекс 0 — оценка 1, индекс 9 —
  /// оценка 10. Балл берётся округлением, поэтому 1.4 попадает в «1», а 1.6 —
  /// в «2»; раньше корзина подписывалась на балл больше, чем содержала.
  final List<int> ratingBuckets;

  /// Сколько записей на каждое отношение.
  final Map<String, int> byRelation;

  /// Самые заполненные категории: название и число записей в ветке.
  /// Идентификатор нужен, чтобы со строки статистики можно было перейти в
  /// каталог с этой веткой в фильтре.
  final List<({String id, String name, int count})> topCategories;

  /// Сколько записей добавлено по месяцам, от старых к новым.
  final List<({DateTime month, int count})> byMonth;

  final int withPhotos;
  final int withNotes;

  bool get isEmpty => total == 0;
}
