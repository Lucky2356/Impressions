import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config.dart';
import '../core/l10n/gen/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/shell/app_shell.dart';
import 'app_state.dart';
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
      data: (list) =>
          list.isEmpty ? const OnboardingScreen() : const AppShell(),
    );
  }
}
