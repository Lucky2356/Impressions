import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/navigation.dart';
import '../../app/theme_controller.dart';
import '../../core/config/app_config.dart';
import '../../core/domain/hotkeys.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_layout.dart';
import '../../core/theme/theme_context.dart';
import '../../design_system/design_system.dart';
import '../archive/archive_screen.dart';
import '../barcode/barcode_scan_sheet.dart';
import '../catalog/catalog_providers.dart';
import '../catalog/catalog_screen.dart';
import '../categories/categories_screen.dart';
import '../collections/collections_screen.dart';
import '../compare/compare_screen.dart';
import '../exchange/import_screen.dart';
import '../exchange/incoming_screen.dart';
import '../home/home_screen.dart';
import '../insights/insights_screen.dart';
import '../notifications/notifications.dart';
import '../profiles/profiles_screen.dart';
import '../quick_add/quick_add_sheet.dart';
import '../settings/settings_screen.dart';
import '../wishlist/wishlist_screen.dart';

/// Адаптивная оболочка приложения (§4).
///
/// Windows/широкий экран: боковая навигация + верхний заголовок + контент.
/// Android/узкий экран: верхняя панель + нижняя навигация.
/// Раскладка рассчитана на разрешения от Full HD до 4K: ширина боковой панели,
/// отступы и плотность сетки берутся из [AppLayout].
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  /// Фокус поля поиска — для Ctrl+F (§4.1).
  final FocusNode _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchDebounce?.cancel();
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

  void _go(String id) => ref.read(navProvider.notifier).go(id);

  List<NavGroup> _groups(AppLocalizations l10n, int incoming) => [
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
          id: NavIds.wishlist,
          icon: Icons.bookmark_add_rounded,
          label: l10n.wishlistTitle,
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
        NavItemData(
          id: NavIds.incoming,
          icon: Icons.inbox_rounded,
          label: l10n.incomingTitle,
          badge: incoming,
        ),
      ],
    ),
    NavGroup(
      title: l10n.navSectionOther,
      items: [
        NavItemData(
          id: NavIds.insights,
          icon: Icons.insights_rounded,
          label: l10n.insightsTitle,
        ),
        NavItemData(
          id: NavIds.archive,
          icon: Icons.archive_rounded,
          label: l10n.archiveTitle,
        ),
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
    NavIds.incoming => l10n.incomingTitle,
    NavIds.wishlist => l10n.wishlistTitle,
    NavIds.insights => l10n.insightsTitle,
    NavIds.archive => l10n.archiveTitle,
    NavIds.settings => l10n.navSettings,
    _ => AppConfig.appName,
  };

  Widget _body(String id) => switch (id) {
    NavIds.home => const HomeScreen(),
    NavIds.categories => const CategoriesScreen(),
    NavIds.catalog => const CatalogScreen(),
    NavIds.collections => const CollectionsScreen(),
    NavIds.compare => const CompareScreen(),
    NavIds.profiles => const ProfilesScreen(),
    NavIds.import => const ImportScreen(),
    NavIds.incoming => const IncomingScreen(),
    NavIds.wishlist => const WishlistScreen(),
    NavIds.insights => const InsightsScreen(),
    NavIds.archive => const ArchiveScreen(),
    NavIds.settings => const SettingsScreen(),
    _ => const HomeScreen(),
  };

  Timer? _searchDebounce;

  /// Глобальный поиск: подставляет запрос в каталог и открывает его.
  ///
  /// С задержкой: без неё раздел переключался на первой же набранной букве —
  /// экран прыгал прямо под руками.
  void _search(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      ref.read(catalogStateProvider.notifier).setSearch(query);
      if (query.trim().isNotEmpty) _go(NavIds.catalog);
    });
  }

  /// Ввод завершён явно (Enter) — переходим сразу.
  void _searchSubmitted(String query) {
    _searchDebounce?.cancel();
    ref.read(catalogStateProvider.notifier).setSearch(query);
    if (query.trim().isNotEmpty) _go(NavIds.catalog);
  }

  Future<void> _scanBarcode() async {
    final scanned = await BarcodeScanSheet.show(context);
    if (scanned == null || !mounted) return;
    await QuickAddSheet.show(context, prefill: scanned);
  }

  /// Горячие клавиши Windows (§4.1). Escape обрабатывают сами диалоги.
  Map<ShortcutActivator, VoidCallback> _shortcuts() => {
    const SingleActivator(LogicalKeyboardKey.keyN, control: true): () =>
        QuickAddSheet.show(context),
    const SingleActivator(LogicalKeyboardKey.keyB, control: true): _scanBarcode,
    const SingleActivator(LogicalKeyboardKey.keyF, control: true):
        _searchFocus.requestFocus,
    const SingleActivator(LogicalKeyboardKey.keyI, control: true): () =>
        _go(NavIds.import),
    const SingleActivator(LogicalKeyboardKey.keyE, control: true): () =>
        _go(NavIds.profiles),
    const SingleActivator(LogicalKeyboardKey.keyP, control: true): () =>
        _go(NavIds.profiles),
    const SingleActivator(LogicalKeyboardKey.comma, control: true): () =>
        _go(NavIds.settings),
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
            final layout = AppLayout.resolve(constraints.maxWidth);
            return layout.isWide
                ? _wideLayout(l10n, layout)
                : _compactLayout(l10n);
          },
        ),
      ),
    );
  }

  // ---- Широкая раскладка (Windows) ----
  Widget _wideLayout(AppLocalizations l10n, AppLayout layout) {
    final c = context.colors;
    final activeId = ref.watch(navProvider);
    final incoming = ref.watch(incomingCountProvider).value ?? 0;
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: layout.sidebarWidth,
            child: NavSidebar(
              appTitle: AppConfig.appName,
              groups: _groups(l10n, incoming),
              activeId: activeId,
              onSelected: _go,
              footer: const _ThemeToggle(),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                _TopHeader(
                  title: _titleFor(activeId, l10n),
                  wide: true,
                  searchFocus: _searchFocus,
                  onSearch: _search,
                  onSearchSubmitted: _searchSubmitted,
                  onScan: _scanBarcode,
                ),
                Divider(height: 1, color: c.border),
                Expanded(child: _body(activeId)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---- Компактная раскладка (Android) ----
  Widget _compactLayout(AppLocalizations l10n) {
    final activeId = ref.watch(navProvider);
    final selectedIndex = _bottomOrder
        .indexOf(activeId)
        .clamp(0, _bottomOrder.length - 1);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(AppDimens.headerHeightCompact),
        child: _TopHeader(
          title: _titleFor(activeId, l10n),
          wide: false,
          searchFocus: _searchFocus,
          onSearch: _search,
          onSearchSubmitted: _searchSubmitted,
          onScan: _scanBarcode,
        ),
      ),
      body: _body(activeId),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => _go(_bottomOrder[i]),
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

class _TopHeader extends ConsumerWidget {
  const _TopHeader({
    required this.title,
    required this.wide,
    required this.searchFocus,
    required this.onSearch,
    required this.onSearchSubmitted,
    required this.onScan,
  });

  final String title;
  final bool wide;
  final FocusNode searchFocus;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onSearchSubmitted;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context);
    final unread = ref.watch(unreadNotificationsProvider);

    return Container(
      height: wide ? AppDimens.headerHeight : AppDimens.headerHeightCompact,
      color: c.surface,
      padding: EdgeInsets.symmetric(
        horizontal: wide ? AppDimens.space24 : AppDimens.space16,
      ),
      child: Row(
        children: [
          Text(
            title,
            style: wide ? context.text.headlineMedium : context.text.titleLarge,
          ),
          const Spacer(),
          if (wide) ...[
            SizedBox(
              width: 320,
              child: AppSearchField(
                hint: l10n.searchGlobalHint,
                focusNode: searchFocus,
                onChanged: onSearch,
                onSubmitted: onSearchSubmitted,
              ),
            ),
            const SizedBox(width: AppDimens.space12),
            IconActionButton(
              icon: Icons.qr_code_scanner_rounded,
              tooltip: l10n.barcodeScanAction,
              onPressed: onScan,
            ),
            const SizedBox(width: AppDimens.space8),
            FilledButton.icon(
              onPressed: () => QuickAddSheet.show(context),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text(l10n.commonAdd),
            ),
            const SizedBox(width: AppDimens.space8),
            IconActionButton(
              icon: Icons.help_outline_rounded,
              tooltip: l10n.headerHelp,
              onPressed: () => _showHelp(context),
            ),
            const SizedBox(width: AppDimens.space8),
          ] else ...[
            IconActionButton(
              icon: Icons.qr_code_scanner_rounded,
              tooltip: l10n.barcodeScanAction,
              onPressed: onScan,
              size: AppDimens.controlHeightSm,
            ),
            const SizedBox(width: AppDimens.space8),
          ],
          Builder(
            builder: (buttonContext) => IconActionButton(
              icon: unread > 0
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_none_rounded,
              tooltip: l10n.headerNotifications,
              badgeCount: unread,
              size: wide ? AppDimens.controlHeight : AppDimens.controlHeightSm,
              onPressed: () {
                final box = buttonContext.findRenderObject() as RenderBox?;
                if (box == null) return;
                final pos = box.localToGlobal(
                  Offset(box.size.width, box.size.height),
                );
                NotificationPanel.show(
                  context,
                  anchor: pos + const Offset(0, 8),
                );
              },
            ),
          ),
          const SizedBox(width: AppDimens.space12),
          const _ProfileChip(),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.headerHelp),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.hotkeysTitle, style: context.text.titleMedium),
              const SizedBox(height: AppDimens.space12),
              for (final hotkey in appHotkeys(l10n))
                Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.space8),
                  child: Row(
                    children: [
                      SizedBox(width: 96, child: _KeyCap(label: hotkey.keys)),
                      const SizedBox(width: AppDimens.space12),
                      Expanded(child: Text(hotkey.label)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.commonClose),
          ),
        ],
      ),
    );
  }
}

/// Клавиша в подсказке по горячим клавишам.
class _KeyCap extends StatelessWidget {
  const _KeyCap({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space8,
        vertical: AppDimens.space4,
      ),
      decoration: BoxDecoration(
        color: c.surfaceMuted,
        borderRadius: AppDimens.brSm,
        border: Border.all(color: c.border),
      ),
      alignment: Alignment.center,
      child: Text(label, style: context.text.labelMedium),
    );
  }
}

/// Профиль в шапке. Меню открывается всегда, даже когда профиль один: раньше
/// нажатие просто ничего не делало.
class _ProfileChip extends ConsumerWidget {
  const _ProfileChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(activeProfileProvider);
    if (profile == null) return const SizedBox.shrink();

    final name = profile.nickname?.isNotEmpty == true
        ? profile.nickname!
        : profile.firstName;
    final wide = context.layout.isWide;
    final profiles = ref.watch(profilesProvider).value ?? const [];

    final chip = Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.space4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProfileAvatar(
            name: name,
            color: c.profileColorFor(profile.id),
            size: wide ? AppDimens.avatarMd : AppDimens.avatarSm,
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
                        ? l10n.profileTypePrimary
                        : l10n.profileTypeExternal,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.labelSmall?.copyWith(
                      color: c.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimens.space4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: c.textMuted,
              size: 20,
            ),
          ],
        ],
      ),
    );

    return PopupMenuButton<String>(
      tooltip: '',
      offset: const Offset(0, 52),
      position: PopupMenuPosition.under,
      onSelected: (value) {
        switch (value) {
          case 'manage':
            ref.read(navProvider.notifier).go(NavIds.profiles);
          case 'settings':
            ref.read(navProvider.notifier).go(NavIds.settings);
          default:
            ref.read(activeProfileIdProvider.notifier).setActive(value);
        }
      },
      itemBuilder: (_) => [
        // Список профилей показывается, только когда есть между чем выбирать.
        if (profiles.length > 1) ...[
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
          const PopupMenuDivider(),
        ],
        PopupMenuItem(
          value: 'manage',
          child: Row(
            children: [
              Icon(Icons.people_alt_rounded, size: 18, color: c.textSecondary),
              const SizedBox(width: AppDimens.space12),
              Text(l10n.profileMenuManage),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings_rounded, size: 18, color: c.textSecondary),
              const SizedBox(width: AppDimens.space12),
              Text(l10n.profileMenuSettings),
            ],
          ),
        ),
      ],
      child: chip,
    );
  }
}

class _ThemeToggle extends ConsumerWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mode = ref.watch(themeModeProvider);
    return SegmentedToggle<ThemeMode>(
      value: mode,
      expand: true,
      onChanged: (m) => ref.read(themeModeProvider.notifier).set(m),
      segments: [
        SegmentData(
          value: ThemeMode.light,
          icon: Icons.light_mode_rounded,
          tooltip: l10n.themeLight,
        ),
        SegmentData(
          value: ThemeMode.dark,
          icon: Icons.dark_mode_rounded,
          tooltip: l10n.themeDark,
        ),
        SegmentData(
          value: ThemeMode.system,
          icon: Icons.brightness_auto_rounded,
          tooltip: l10n.themeSystem,
        ),
      ],
    );
  }
}
