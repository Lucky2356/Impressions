import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Идентификаторы разделов навигации.
class NavIds {
  const NavIds._();
  static const home = 'home';
  static const categories = 'categories';
  static const catalog = 'catalog';
  static const collections = 'collections';
  static const wishlist = 'wishlist';
  static const compare = 'compare';
  static const profiles = 'profiles';
  static const import = 'import';
  static const incoming = 'incoming';
  static const insights = 'insights';
  static const archive = 'archive';
  static const settings = 'settings';
}

/// Активный раздел. Вынесен в провайдер, чтобы любой экран мог перевести
/// пользователя в другой раздел (например, из категории — в каталог с
/// подставленным фильтром), не пробрасывая колбэки через дерево виджетов.
class NavController extends Notifier<String> {
  @override
  String build() => NavIds.home;

  void go(String id) => state = id;
}

final navProvider = NotifierProvider<NavController, String>(NavController.new);
