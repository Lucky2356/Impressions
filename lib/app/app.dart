import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../core/config/app_config.dart';
import '../core/l10n/gen/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../data/providers.dart';
import '../features/onboarding/onboarding_screen.dart';
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
      home: const _RootGate(),
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
      error: (e, _) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('$e', textAlign: TextAlign.center),
          ),
        ),
      ),
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

  Future<void> _run() async {
    try {
      final service = ref.read(updateServiceProvider);
      final version = (await PackageInfo.fromPlatform()).version;
      await service.checkAppUpdate(currentVersion: version);

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
