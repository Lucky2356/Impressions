import 'package:flutter/material.dart';

/// Реестр иконок для типов, категорий и подборок.
///
/// В базе хранится строковый ключ, а не кодовая точка — так иконки не ломают
/// tree-shaking и остаются стабильными между версиями.
class AppIcons {
  const AppIcons._();

  static const String fallbackKey = 'folder';

  static const Map<String, IconData> _registry = {
    'folder': Icons.folder_rounded,
    'grocery': Icons.local_grocery_store_rounded,
    'dish': Icons.restaurant_rounded,
    'place': Icons.place_rounded,
    'city': Icons.location_city_rounded,
    'movie': Icons.movie_rounded,
    'series': Icons.live_tv_rounded,
    'music': Icons.music_note_rounded,
    'book': Icons.menu_book_rounded,
    'game': Icons.sports_esports_rounded,
    'goods': Icons.shopping_bag_rounded,
    'other': Icons.category_rounded,
    'cafe': Icons.local_cafe_rounded,
    'drink': Icons.local_drink_rounded,
    'sweets': Icons.cake_rounded,
    'dairy': Icons.icecream_rounded,
    'sausage': Icons.kebab_dining_rounded,
    'cheese': Icons.breakfast_dining_rounded,
    'park': Icons.park_rounded,
    'star': Icons.star_rounded,
    'heart': Icons.favorite_rounded,
    'bookmark': Icons.bookmark_rounded,
  };

  /// Слова, по которым значок находится в выборе.
  ///
  /// Это не строки интерфейса, а таблица сопоставления: сам значок ничего не
  /// подписывает, и искать его надо на обоих языках сразу — человек с
  /// английским интерфейсом всё равно может набрать «кафе». Поэтому не в
  /// `.arb`, а здесь.
  static const Map<String, List<String>> _searchTerms = {
    'folder': ['папка', 'ветка', 'folder'],
    'grocery': ['продукты', 'магазин', 'еда', 'grocery', 'food', 'shop'],
    'dish': ['блюдо', 'еда', 'ресторан', 'dish', 'food', 'restaurant'],
    'place': ['место', 'точка', 'place', 'pin'],
    'city': ['город', 'city', 'town'],
    'movie': ['фильм', 'кино', 'movie', 'film'],
    'series': ['сериал', 'телевизор', 'series', 'tv'],
    'music': ['музыка', 'песня', 'music', 'song'],
    'book': ['книга', 'чтение', 'book', 'reading'],
    'game': ['игра', 'приставка', 'game', 'console'],
    'goods': ['товар', 'покупка', 'goods', 'shopping'],
    'other': ['другое', 'разное', 'other', 'misc'],
    'cafe': ['кафе', 'кофе', 'cafe', 'coffee'],
    'drink': ['напиток', 'питьё', 'drink', 'beverage'],
    'sweets': ['сладости', 'торт', 'десерт', 'sweets', 'cake', 'dessert'],
    'dairy': ['молочное', 'мороженое', 'dairy', 'icecream'],
    'sausage': ['колбаса', 'мясо', 'sausage', 'meat'],
    'cheese': ['сыр', 'выпечка', 'cheese', 'bread'],
    'park': ['парк', 'природа', 'park', 'nature'],
    'star': ['звезда', 'избранное', 'star', 'favourite'],
    'heart': ['сердце', 'любимое', 'heart', 'love'],
    'bookmark': ['закладка', 'метка', 'bookmark', 'tag'],
  };

  static IconData byKey(String? key) =>
      _registry[key ?? fallbackKey] ?? _registry[fallbackKey]!;

  /// Ключи для выбора иконки пользователем.
  static List<String> get allKeys => _registry.keys.toList();

  /// Ключи, подходящие под запрос. Пустой запрос — все.
  static List<String> search(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return allKeys;
    return [
      for (final entry in _searchTerms.entries)
        if (entry.key.contains(needle) ||
            entry.value.any((word) => word.contains(needle)))
          entry.key,
    ];
  }
}
