import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_context.dart';
import '../../data/services/database_lock_service.dart';

/// Приложение до открытия базы: один экран с полем пароля.
///
/// Тема и язык живут в таблице настроек, то есть внутри самой базы, — здесь
/// их ещё неоткуда взять. Поэтому экран идёт на системных: он показывается
/// секунды и до того, как приложение вообще что-то знает о владельце.
class UnlockApp extends StatelessWidget {
  const UnlockApp({super.key, required this.onUnlocked, this.stale = false});

  /// Что запустить, когда база отперта.
  final VoidCallback onUnlocked;

  /// Запомненный ключ не подошёл — это надо объяснить, а не молча спросить.
  final bool stale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (_) => AppConfig.appName,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: UnlockScreen(onUnlocked: onUnlocked, stale: stale),
    );
  }
}

/// Экран ввода пароля к базе.
class UnlockScreen extends StatefulWidget {
  const UnlockScreen({
    super.key,
    required this.onUnlocked,
    this.stale = false,
    this.lock = const DatabaseLockService(),
  });

  final VoidCallback onUnlocked;
  final bool stale;
  final DatabaseLockService lock;

  @override
  State<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends State<UnlockScreen> {
  final _password = TextEditingController();
  bool _remember = false;
  bool _busy = false;
  bool _wrong = false;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    if (_busy || _password.text.isEmpty) return;
    setState(() {
      _busy = true;
      _wrong = false;
    });

    final ok = await widget.lock.unlock(_password.text, remember: _remember);
    if (!mounted) return;

    if (ok) {
      widget.onUnlocked();
      return;
    }
    setState(() {
      _busy = false;
      _wrong = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.space24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.lock_rounded, size: 48, color: c.accentPrimary),
                const SizedBox(height: AppDimens.space16),
                Text(
                  l10n.lockTitle,
                  textAlign: TextAlign.center,
                  style: context.text.titleLarge,
                ),
                const SizedBox(height: AppDimens.space8),
                Text(
                  widget.stale ? l10n.lockStaleKey : l10n.lockMessage,
                  textAlign: TextAlign.center,
                  style: context.text.bodyMedium?.copyWith(
                    color: c.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimens.space24),
                TextField(
                  controller: _password,
                  autofocus: true,
                  obscureText: true,
                  enabled: !_busy,
                  onSubmitted: (_) => _open(),
                  decoration: InputDecoration(
                    labelText: l10n.lockPasswordLabel,
                    errorText: _wrong ? l10n.lockWrongPassword : null,
                  ),
                ),
                const SizedBox(height: AppDimens.space8),
                // Галочка меняет обещание защиты, поэтому рядом сказано, что
                // именно она ослабляет.
                CheckboxListTile(
                  value: _remember,
                  onChanged: _busy
                      ? null
                      : (v) => setState(() => _remember = v ?? false),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    l10n.lockRemember,
                    style: context.text.bodyMedium,
                  ),
                ),
                const SizedBox(height: AppDimens.space8),
                FilledButton(
                  onPressed: _busy ? null : _open,
                  child: _busy
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.lockOpen),
                ),
                const SizedBox(height: AppDimens.space16),
                Text(
                  l10n.lockForgotWarning,
                  textAlign: TextAlign.center,
                  style: context.text.labelSmall?.copyWith(color: c.textMuted),
                ),
                const SizedBox(height: AppDimens.space8),
                TextButton(
                  onPressed: _busy ? null : () => exit(0),
                  child: Text(l10n.lockQuit),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
