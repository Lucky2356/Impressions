import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/gen/app_localizations.dart';
import '../data/repositories/settings_repository.dart';
import 'app_state.dart';

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

  /// Все разделы — для проверки сохранённого значения.
  static const all = [
    home,
    categories,
    catalog,
    collections,
    wishlist,
    compare,
    profiles,
    import,
    incoming,
    insights,
    archive,
    settings,
  ];
}

/// Активный раздел. Вынесен в провайдер, чтобы любой экран мог перевести
/// пользователя в другой раздел (например, из категории — в каталог с
/// подставленным фильтром), не пробрасывая колбэки через дерево виджетов.
///
/// Раздел запоминается между запусками: приложение всегда открывалось на
/// главной, даже если человек не выходил из каталога неделю.
class NavController extends Notifier<String> {
  @override
  String build() {
    _restore();
    return NavIds.home;
  }

  Future<void> _restore() async {
    final saved = await ref
        .read(settingsRepositoryProvider)
        .get(SettingKeys.lastSection);
    // Настройку могли дочитать уже после того, как провайдер выбросили —
    // например, при смене профиля.
    if (!ref.mounted) return;
    // Сохранённое значение сверяем со списком: раздел мог исчезнуть, и
    // открывать пустой экран из-за старой настройки незачем.
    if (saved != null && NavIds.all.contains(saved)) state = saved;
  }

  void go(String id) {
    state = id;
    ref.read(settingsRepositoryProvider).set(SettingKeys.lastSection, id);
  }
}

final navProvider = NotifierProvider<NavController, String>(NavController.new);

/// Название раздела и его значок — в одном месте.
///
/// Раньше и то и другое перечислялось внутри оболочки, а палитре команд нужны
/// те же самые: два списка неминуемо разошлись бы, как когда-то справка и
/// настройки по горячим клавишам.
String navTitle(AppLocalizations l10n, String id) => switch (id) {
  NavIds.home => l10n.homeTitle,
  NavIds.categories => l10n.categoriesTitle,
  NavIds.catalog => l10n.navCatalog,
  NavIds.collections => l10n.navCollections,
  NavIds.compare => l10n.navCompare,
  NavIds.profiles => l10n.navProfiles,
  NavIds.import => l10n.navImport,
  NavIds.incoming => l10n.incomingTitle,
  NavIds.wishlist => l10n.wishlistTitle,
  NavIds.insights => l10n.insightsTitle,
  NavIds.archive => l10n.archiveTitle,
  NavIds.settings => l10n.navSettings,
  _ => l10n.homeTitle,
};

IconData navIcon(String id) => switch (id) {
  NavIds.home => Icons.home_rounded,
  NavIds.categories => Icons.account_tree_rounded,
  NavIds.catalog => Icons.grid_view_rounded,
  NavIds.collections => Icons.collections_bookmark_rounded,
  NavIds.compare => Icons.compare_arrows_rounded,
  NavIds.profiles => Icons.people_alt_rounded,
  NavIds.import => Icons.download_rounded,
  NavIds.incoming => Icons.inbox_rounded,
  NavIds.wishlist => Icons.bookmark_add_rounded,
  NavIds.insights => Icons.insights_rounded,
  NavIds.archive => Icons.archive_rounded,
  NavIds.settings => Icons.settings_rounded,
  _ => Icons.circle_outlined,
};
