import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/theme_controller.dart';
import '../../core/config/app_config.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../design_system/design_system.dart';
import '../catalog/catalog_screen.dart';
import '../categories/categories_screen.dart';
import '../collections/collections_screen.dart';
import '../compare/compare_screen.dart';
import '../exchange/import_screen.dart';
import '../home/home_screen.dart';
import '../profiles/profiles_screen.dart';
import '../quick_add/quick_add_sheet.dart';
import '../settings/settings_screen.dart';

/// Идентификаторы разделов навигации.
class NavIds {
  static const home = 'home';
  static const categories = 'categories';
  static const catalog = 'catalog';
  static const collections = 'collections';
  static const compare = 'compare';
  static const profiles = 'profiles';
  static const import = 'import';
  static const settings = 'settings';
}

/// Адаптивная оболочка приложения (§4).
///
/// Windows/широкий экран: боковая навигация + верхний заголовок + контент.
/// Android/узкий экран: верхняя панель + нижняя навигация.
/// Раскладка рассчитана на разрешения от Full HD до 4K: фиксированная боковая
/// панель в логических пикселях (масштабируется вместе с DPI), гибкий контент
/// с ограничением максимальной ширины.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  String _activeId = NavIds.home;

  /// Фокус поля поиска — для Ctrl+F (§4.1).
  final FocusNode _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  static const _bottomOrder = [
    NavIds.home,
    NavIds.categories,
    NavIds.catalog,
    NavIds.collections,
    NavIds.settings,
  ];

  List<NavGroup> _groups(AppLocalizations l10n) => [
    NavGroup(
      title: l10n.navSectionMain,
      items: [
        NavItemData(
          id: NavIds.home,
          icon: Icons.home_rounded,
          label: l10n.navHome,
        ),
        NavItemData(
          id: NavIds.categories,
          icon: Icons.account_tree_rounded,
          label: l10n.categoriesTitle,
        ),
        NavItemData(
          id: NavIds.catalog,
          icon: Icons.grid_view_rounded,
          label: l10n.navCatalog,
        ),
        NavItemData(
          id: NavIds.collections,
          icon: Icons.collections_bookmark_rounded,
          label: l10n.navCollections,
        ),
        NavItemData(
          id: NavIds.compare,
          icon: Icons.compare_arrows_rounded,
          label: l10n.navCompare,
        ),
      ],
    ),
    NavGroup(
      title: l10n.navSectionProfiles,
      items: [
        NavItemData(
          id: NavIds.profiles,
          icon: Icons.people_alt_rounded,
          label: l10n.navProfiles,
        ),
        NavItemData(
          id: NavIds.import,
          icon: Icons.download_rounded,
          label: l10n.navImport,
        ),
      ],
    ),
    NavGroup(
      title: l10n.navSectionOther,
      items: [
        NavItemData(
          id: NavIds.settings,
          icon: Icons.settings_rounded,
          label: l10n.navSettings,
        ),
      ],
    ),
  ];

  String _titleFor(String id, AppLocalizations l10n) => switch (id) {
    NavIds.home => l10n.homeTitle,
    NavIds.categories => l10n.categoriesTitle,
    NavIds.catalog => l10n.navCatalog,
    NavIds.collections => l10n.navCollections,
    NavIds.compare => l10n.navCompare,
    NavIds.profiles => l10n.navProfiles,
    NavIds.import => l10n.navImport,
    NavIds.settings => l10n.navSettings,
    _ => AppConfig.appName,
  };

  Widget _body(String id) {
    if (id == NavIds.home) return const HomeScreen();
    if (id == NavIds.categories) return const CategoriesScreen();
    if (id == NavIds.catalog) return const CatalogScreen();
    if (id == NavIds.collections) return const CollectionsScreen();
    if (id == NavIds.compare) return const CompareScreen();
    if (id == NavIds.profiles) return const ProfilesScreen();
    if (id == NavIds.import) return const ImportScreen();
    if (id == NavIds.settings) return const SettingsScreen();
    final l10n = AppLocalizations.of(context);
    return EmptyState(
      icon: Icons.construction_rounded,
      title: l10n.comingSoonTitle,
      message: l10n.comingSoonMessage,
    );
  }

  /// Горячие клавиши Windows (§4.1). Escape обрабатывают сами диалоги.
  Map<ShortcutActivator, VoidCallback> _shortcuts() => {
    const SingleActivator(LogicalKeyboardKey.keyN, control: true): () =>
        QuickAddSheet.show(context),
    const SingleActivator(LogicalKeyboardKey.keyF, control: true): () =>
        _searchFocus.requestFocus(),
    const SingleActivator(LogicalKeyboardKey.keyI, control: true): () =>
        setState(() => _activeId = NavIds.import),
    const SingleActivator(LogicalKeyboardKey.keyE, control: true): () =>
        setState(() => _activeId = NavIds.profiles),
    const SingleActivator(LogicalKeyboardKey.keyP, control: true): () =>
        setState(() => _activeId = NavIds.profiles),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return CallbackShortcuts(
      bindings: _shortcuts(),
      child: Focus(
        autofocus: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= AppDimens.breakpointExpanded;
            return wide ? _wideLayout(l10n) : _compactLayout(l10n);
          },
        ),
      ),
    );
  }

  // ---- Широкая раскладка (Windows) ----
  Widget _wideLayout(AppLocalizations l10n) {
    final c = context.colors;
    return Scaffold(
      body: Row(
        children: [
          NavSidebar(
            appTitle: AppConfig.appName,
            groups: _groups(l10n),
            activeId: _activeId,
            onSelected: (id) => setState(() => _activeId = id),
            footer: _ThemeToggle(),
          ),
          Expanded(
            child: Column(
              children: [
                _TopHeader(
                  title: _titleFor(_activeId, l10n),
                  wide: true,
                  searchFocus: _searchFocus,
                ),
                Divider(height: 1, color: c.border),
                Expanded(child: _body(_activeId)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---- Компактная раскладка (Android) ----
  Widget _compactLayout(AppLocalizations l10n) {
    final selectedIndex = _bottomOrder
        .indexOf(_activeId)
        .clamp(0, _bottomOrder.length - 1);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: _TopHeader(
          title: _titleFor(_activeId, l10n),
          wide: false,
          searchFocus: _searchFocus,
        ),
      ),
      body: _body(_activeId),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) =>
            setState(() => _activeId = _bottomOrder[i]),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_tree_outlined),
            selectedIcon: const Icon(Icons.account_tree_rounded),
            label: l10n.categoriesTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.grid_view_outlined),
            selectedIcon: const Icon(Icons.grid_view_rounded),
            label: l10n.navCatalog,
          ),
          NavigationDestination(
            icon: const Icon(Icons.collections_bookmark_outlined),
            selectedIcon: const Icon(Icons.collections_bookmark_rounded),
            label: l10n.navCollections,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings_rounded),
            label: l10n.navSettings,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => QuickAddSheet.show(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader({
    required this.title,
    required this.wide,
    required this.searchFocus,
  });

  final String title;
  final bool wide;
  final FocusNode searchFocus;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context);
    return Container(
      height: wide ? 72 : 64,
      color: c.surface,
      padding: EdgeInsets.symmetric(
        horizontal: wide ? AppDimens.space32 : AppDimens.space16,
      ),
      child: Row(
        children: [
          Text(title, style: context.text.headlineMedium),
          const Spacer(),
          if (wide) ...[
            SizedBox(
              width: 320,
              child: _SearchField(
                hint: l10n.headerSearchHint,
                focusNode: searchFocus,
              ),
            ),
            const SizedBox(width: AppDimens.space16),
            FilledButton.icon(
              onPressed: () => QuickAddSheet.show(context),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text(l10n.commonAdd),
            ),
            const SizedBox(width: AppDimens.space12),
            _IconCircle(
              icon: Icons.help_outline_rounded,
              tooltip: l10n.headerHelp,
            ),
            const SizedBox(width: AppDimens.space8),
          ],
          _IconCircle(
            icon: Icons.notifications_none_rounded,
            tooltip: '',
            badge: true,
          ),
          const SizedBox(width: AppDimens.space12),
          const _ProfileChip(),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.hint, required this.focusNode});
  final String hint;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      height: 44,
      child: TextField(
        focusNode: focusNode,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(Icons.search_rounded, color: c.textMuted, size: 20),
          isDense: true,
        ),
        style: context.text.bodyMedium,
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  const _IconCircle({
    required this.icon,
    required this.tooltip,
    this.badge = false,
  });
  final IconData icon;
  final String tooltip;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final btn = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: c.surface,
        shape: BoxShape.circle,
        border: Border.all(color: c.border),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(icon, size: 20, color: c.textSecondary),
          if (badge)
            Positioned(
              top: 11,
              right: 12,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: c.accentPrimary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
    return tooltip.isEmpty ? btn : Tooltip(message: tooltip, child: btn);
  }
}

class _ProfileChip extends ConsumerWidget {
  const _ProfileChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final profile = ref.watch(activeProfileProvider);
    if (profile == null) return const SizedBox.shrink();

    final name = profile.nickname?.isNotEmpty == true
        ? profile.nickname!
        : profile.firstName;
    final wide =
        MediaQuery.sizeOf(context).width >= AppDimens.breakpointExpanded;
    final profiles = ref.watch(profilesProvider).value ?? const [];

    final chip = Row(
      children: [
        ProfileAvatar(
          name: name,
          color: c.profileColorFor(profile.id),
          size: AppDimens.avatarMd,
        ),
        if (wide) ...[
          const SizedBox(width: AppDimens.space8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.labelMedium,
                ),
                Text(
                  profile.type == 'myPrimary'
                      ? 'Мой основной профиль'
                      : profile.firstName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.labelSmall?.copyWith(color: c.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.space4),
          Icon(Icons.keyboard_arrow_down_rounded, color: c.textMuted, size: 20),
        ],
      ],
    );

    if (profiles.length < 2) return chip;

    // Верхний переключатель активного профиля (§4.2).
    return PopupMenuButton<String>(
      tooltip: '',
      offset: const Offset(0, 48),
      onSelected: (id) =>
          ref.read(activeProfileIdProvider.notifier).setActive(id),
      itemBuilder: (_) => [
        for (final p in profiles)
          PopupMenuItem(
            value: p.id,
            child: Row(
              children: [
                ProfileAvatar(
                  name: p.firstName,
                  color: c.profileColorFor(p.id),
                  size: AppDimens.avatarSm,
                ),
                const SizedBox(width: AppDimens.space12),
                Expanded(child: Text(p.firstName)),
                if (p.id == profile.id)
                  Icon(Icons.check_rounded, size: 18, color: c.accentPrimary),
              ],
            ),
          ),
      ],
      child: chip,
    );
  }
}

class _ThemeToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context);
    final mode = ref.watch(themeModeProvider);
    Widget seg(IconData icon, ThemeMode m, String tip) {
      final active = mode == m;
      return Expanded(
        child: Tooltip(
          message: tip,
          child: Material(
            color: active ? c.navActiveBg : Colors.transparent,
            borderRadius: AppDimens.brSm,
            child: InkWell(
              borderRadius: AppDimens.brSm,
              onTap: () => ref.read(themeModeProvider.notifier).set(m),
              child: SizedBox(
                height: 36,
                child: Icon(
                  icon,
                  size: 18,
                  color: active ? c.navActiveFg : c.textMuted,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.surfaceMuted,
        borderRadius: AppDimens.brMd,
      ),
      child: Row(
        children: [
          seg(Icons.light_mode_rounded, ThemeMode.light, l10n.themeLight),
          seg(Icons.dark_mode_rounded, ThemeMode.dark, l10n.themeDark),
          seg(
            Icons.brightness_auto_rounded,
            ThemeMode.system,
            l10n.themeSystem,
          ),
        ],
      ),
    );
  }
}
