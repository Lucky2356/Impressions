import '../db/database.dart';
import '../repositories/category_repository.dart';
import '../repositories/entry_repository.dart';

/// Описание встроенного типа для стартового набора (§8).
class StarterType {
  const StarterType(this.name, this.iconKey, this.starterChildren);
  final String name;
  final String iconKey;

  /// Необязательные стартовые подкатегории.
  final List<String> starterChildren;
}

/// Создание стартовых типов и категорий при первом запуске (§8).
///
/// Все созданные сущности — обычные редактируемые записи: их можно
/// переименовать, скрыть, поменять иконку/цвет/порядок или удалить.
/// Пользователь может отказаться от стартовой структуры подкатегорий.
class SeedService {
  SeedService(this.db)
    : _cats = CategoryRepository(db),
      _entries = EntryRepository(db);

  final AppDatabase db;
  final CategoryRepository _cats;
  final EntryRepository _entries;

  /// Базовый набор основных типов (§8). Подкатегории предлагаются умеренно.
  static const List<StarterType> starterTypes = [
    StarterType('Продукты', 'grocery', [
      'Колбасы',
      'Сыры',
      'Напитки',
      'Сладости',
      'Молочные продукты',
    ]),
    StarterType('Блюда', 'dish', []),
    StarterType('Места', 'place', ['Кафе', 'Рестораны', 'Парки']),
    StarterType('Города', 'city', []),
    StarterType('Фильмы', 'movie', []),
    StarterType('Сериалы', 'series', []),
    StarterType('Музыка', 'music', []),
    StarterType('Книги', 'book', []),
    StarterType('Игры', 'game', []),
    StarterType('Товары', 'goods', []),
    StarterType('Другое', 'other', []),
  ];

  /// Создаёт типы объектов и одноимённые корневые категории профиля.
  ///
  /// [withStarterSubcategories] — создавать ли предложенные подкатегории.
  /// Выполняется одной транзакцией.
  Future<void> seedForProfile(
    String profileId, {
    bool withStarterSubcategories = true,
    List<String>? onlyTypes,
  }) async {
    await db.transaction(() async {
      var order = 0;
      for (final type in starterTypes) {
        if (onlyTypes != null && !onlyTypes.contains(type.name)) continue;

        await _entries.createObjectType(
          profileId,
          type.name,
          icon: type.iconKey,
          builtIn: true,
          sortOrder: order,
        );

        final root = await _cats.createRoot(
          profileId,
          type.name,
          icon: type.iconKey,
          sortOrder: order,
        );

        if (withStarterSubcategories) {
          var childOrder = 0;
          for (final child in type.starterChildren) {
            await _cats.createChild(root.id, child, sortOrder: childOrder);
            childOrder++;
          }
        }
        order++;
      }
    });
  }
}
