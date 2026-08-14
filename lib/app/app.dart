import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../core/config/app_config.dart';
import '../core/l10n/gen/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../data/providers.dart';
import '../data/repositories/settings_repository.dart';
import '../data/services/backup_service.dart';
import '../data/services/changelog_service.dart';
import '../data/services/launch_service.dart';
import '../data/services/update_service.dart';
import '../design_system/design_system.dart';
import '../features/barcode/barcode_scan_sheet.dart';
import '../features/exchange/import_screen.dart';
import '../features/onboarding/app_tour.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/quick_add/quick_add_sheet.dart';
import '../features/settings/network_section.dart';
import '../features/settings/whats_new_dialog.dart';
import '../features/shell/app_shell.dart';
import 'app_state.dart';
import 'locale_controller.dart';
import 'navigation.dart';
import 'data_refresh.dart';
import 'theme_controller.dart';

/// Корневой виджет приложения.
class ImpressionsApp extends ConsumerWidget {
  const ImpressionsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    return MaterialApp(
      onGenerateTitle: (context) => AppConfig.appName,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // null — язык системы; неизвестный системе язык уводит на русский, на
      // котором написан исходный перевод.
      locale: locale,
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

/// Аргументы командной строки этого запуска.
///
/// Двойной щелчок по файлу обмена на Windows приходит именно так. Flutter не
/// отдаёт их сам, поэтому их кладёт сюда `main`.
List<String> launchArguments = const [];

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
  StreamSubscription<LaunchRequest>? _launches;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());

    // Файл, присланный в уже открытое приложение, и быстрое действие со
    // значка приходят сюда же, что и при холодном старте.
    _launches = const LaunchService().incoming.listen(_handleLaunch);
  }

  @override
  void dispose() {
    _launches?.cancel();
    super.dispose();
  }

  /// Открывает то, ради чего приложение и запустили.
  ///
  /// Присланный файл ведёт на предпросмотр импорта — сам импорт не начинается:
  /// решает человек. Быстрое действие со значка открывает форму записи или
  /// сканер.
  void _handleLaunch(LaunchRequest request) {
    if (request.isEmpty || !mounted) return;

    final file = request.file;
    if (file != null) {
      ref.read(pendingImportFileProvider.notifier).set(file);
      ref.read(navProvider.notifier).go(NavIds.import);
      return;
    }

    switch (request.action) {
      case 'add':
        QuickAddSheet.show(context);
      case 'scan':
        BarcodeScanSheet.show(context);
    }
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

  /// Копия по расписанию.
  ///
  /// Стоит до сетевых проверок и в своём `try`: копия — единственное, что
  /// спасает записи при поломке диска, и она не должна зависеть от того,
  /// доступен ли GitHub.
  Future<void> _backupIfDue() async {
    try {
      final created = await BackupService(
        ref.read(appDatabaseProvider),
      ).createScheduled();
      if (created != null && mounted) {
        ref.read(dataRefreshProvider.notifier).bump();
      }
    } catch (_) {
      // Нет места или каталог недоступен — работе это мешать не должно,
      // следующий запуск попробует снова.
    }
  }

  /// Рассказывает, что изменилось, — один раз после смены версии.
  ///
  /// Приложение обновляется само, и поведение меняется молча. Свежая
  /// установка ничего не показывает: там только что прошло обучение, и
  /// «новое» человеку не с чем сравнивать — версия просто запоминается.
  Future<void> _showWhatsNewIfNeeded({
    required bool freshInstall,
    required String version,
  }) async {
    final settings = ref.read(settingsRepositoryProvider);
    final seen = await settings.get(SettingKeys.changelogSeenVersion);
    if (seen == version) return;

    await settings.set(SettingKeys.changelogSeenVersion, version);
    if (freshInstall) return;

    final entry = await const ChangelogService().forVersion(version);
    if (entry == null || !mounted) return;
    await WhatsNewDialog.show(context, entry);
  }

  Future<void> _run() async {
    // Чем открыли приложение: файл обмена или ярлык со значка.
    _handleLaunch(
      await const LaunchService().initial(
        // Аргументы командной строки Flutter не отдаёт напрямую; на Windows их
        // подставляет `main`, а на телефоне их нет вовсе.
        launchArguments,
      ),
    );

    // Считаем до показа обучения: после него отметка уже стоит, и первый
    // запуск стал бы неотличим от обновления.
    final freshInstall = !await ref
        .read(settingsRepositoryProvider)
        .getBool(SettingKeys.tourDone, defaultValue: false);

    // Версия нужна и «Что нового», и проверке обновлений — спрашиваем один раз.
    final version = (await PackageInfo.fromPlatform()).version;

    await _showTourIfNeeded();
    await _showWhatsNewIfNeeded(freshInstall: freshInstall, version: version);

    // Копия и сетевые проверки друг от друга не зависят. Раньше они стояли
    // цепочкой, и обновление ждало, пока допишется zip всей базы: на большом
    // профиле это минуты. Обе стороны глушат свои ошибки сами.
    await Future.wait([_backupIfDue(), _checkNetwork(version)]);
  }

  /// Проверки, которым нужна сеть. Отсутствие сети работе не мешает.
  Future<void> _checkNetwork(String version) async {
    try {
      final service = ref.read(updateServiceProvider);
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
