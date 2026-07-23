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

  static IconData byKey(String? key) =>
      _registry[key ?? fallbackKey] ?? _registry[fallbackKey]!;

  /// Ключи для выбора иконки пользователем.
  static List<String> get allKeys => _registry.keys.toList();
}
