import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../core/config/app_config.dart';
import '../core/l10n/gen/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../data/providers.dart';
import '../data/repositories/settings_repository.dart';
import '../data/services/update_service.dart';
import '../design_system/design_system.dart';
import '../features/onboarding/app_tour.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/settings/network_section.dart';
import '../features/shell/app_shell.dart';
import 'app_state.dart';
import 'data_refresh.dart';
import 'theme_controller.dart';

/// Корневой виджет приложения.
class ImpressionsApp extends ConsumerWidget {
  const ImpressionsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      onGenerateTitle: (context) => AppConfig.appName,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ru'),
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      // Крупный системный шрифт приложение держит: карточки и поля растут
      // вместе с ним. Но Android разрешает увеличивать текст вдвое, а такой
      // размер не выдержит ни одна плотная раскладка — выше 1.5 не идём.
      builder: (context, child) =>
          MediaQuery.withClampedTextScaling(maxScaleFactor: 1.5, child: child!),
      home: const _SystemBars(child: _RootGate()),
    );
  }
}

/// Прозрачные системные панели Android с читаемыми значками.
///
/// Цвет значков зависит от темы приложения, а не от системной: на светлой теме
/// белые часы поверх светлой шапки не видно.
class _SystemBars extends StatelessWidget {
  const _SystemBars({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final icons = dark ? Brightness.light : Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: icons,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: icons,
      ),
      child: child,
    );
  }
}

/// Решает, что показать: онбординг (нет профилей) или основную оболочку.
class _RootGate extends ConsumerWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(profilesProvider);
    return profiles.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: ErrorState(error: e)),
      data: (list) => list.isEmpty
          ? const OnboardingScreen()
          : const _StartupTasks(child: AppShell()),
    );
  }
}

/// Фоновые проверки при запуске: обновление приложения и сведений о товарах.
///
/// Обе выключаемы и сами ограничивают частоту, поэтому здесь достаточно один
/// раз их позвать. Ошибки намеренно проглатываются: отсутствие сети не должно
/// мешать работе с локальными данными.
class _StartupTasks extends ConsumerStatefulWidget {
  const _StartupTasks({required this.child});
  final Widget child;

  @override
  ConsumerState<_StartupTasks> createState() => _StartupTasksState();
}

class _StartupTasksState extends ConsumerState<_StartupTasks> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  /// Обучение показывается один раз — сразу после первого запуска.
  ///
  /// Отдельно от онбординга: тот объясняет модель до создания профиля, а это —
  /// где что лежит, когда уже есть куда смотреть.
  Future<void> _showTourIfNeeded() async {
    final settings = ref.read(settingsRepositoryProvider);
    final done = await settings.getBool(
      SettingKeys.tourDone,
      defaultValue: false,
    );
    if (done || !mounted) return;
    await AppTour.show(context);
  }

  /// Предлагает обновиться сразу при запуске.
  ///
  /// Раньше найденная версия только оседала в колокольчике уведомлений: чтобы
  /// обновиться, надо было догадаться зайти в настройки и нажать «Проверить».
  /// Теперь предложение приходит само, а «Пропустить эту версию» запоминается,
  /// чтобы не спрашивать про неё при каждом запуске.
  Future<void> _offerUpdate(AppRelease release) async {
    final settings = ref.read(settingsRepositoryProvider);
    final dismissed = await settings.get(SettingKeys.appUpdateDismissed);
    if (dismissed == release.version || !mounted) return;
    await showUpdateDialog(
      context,
      release.version,
      release.installerUrl ?? release.url,
      sha256: release.installerSha256,
    );
  }

  Future<void> _run() async {
    await _showTourIfNeeded();
    try {
      final service = ref.read(updateServiceProvider);
      final version = (await PackageInfo.fromPlatform()).version;
      final release = await service.checkAppUpdate(currentVersion: version);
      if (release != null && mounted) await _offerUpdate(release);

      final report = await service.refreshProducts();
      if (report.updated > 0) {
        await ref
            .read(settingsRepositoryProvider)
            .set('product_auto_update_count', '${report.updated}');
      }
      if (mounted) ref.read(dataRefreshProvider.notifier).bump();
    } catch (_) {
      // Нет сети или недоступен источник — молча продолжаем работу.
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
