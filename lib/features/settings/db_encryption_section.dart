import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/db/database_cipher.dart';
import '../../data/providers.dart';
import '../../data/services/backup_service.dart';
import '../../data/services/database_lock_service.dart';
import '../../design_system/design_system.dart';
import 'backup_password_dialog.dart';

/// Зашифрована ли база сейчас.
final dbEncryptedProvider = FutureProvider<bool>((ref) async {
  final cipher = await const DatabaseLockService().cipher();
  return (await cipher.readState()).encrypted;
});

/// Спрашивают ли пароль на этом устройстве.
final dbKeyRememberedProvider = FutureProvider<bool>((ref) async {
  return const DatabaseLockService().isRemembered();
});

/// Шифрование базы паролем (§32).
///
/// Все три действия — включить, сменить пароль, выключить — переписывают файл
/// базы целиком. Поэтому каждое начинается с резервной копии, заканчивается
/// проверкой и требует перезапуска: половина экранов уже держит подключение,
/// которое пришлось закрыть.
class DbEncryptionSection extends ConsumerStatefulWidget {
  const DbEncryptionSection({super.key});

  @override
  ConsumerState<DbEncryptionSection> createState() =>
      _DbEncryptionSectionState();
}

class _DbEncryptionSectionState extends ConsumerState<DbEncryptionSection> {
  bool _busy = false;

  /// Общая часть: копия, закрытие базы, само действие, проверка.
  ///
  /// [operation] возвращает ключ, которым база закрыта после него, или null,
  /// если пароль не подошёл и ничего не менялось.
  Future<void> _run(
    Future<List<int>?> Function(DatabaseCipher cipher) operation, {
    required String doneMessage,
  }) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);

    try {
      final db = ref.read(appDatabaseProvider);
      // Копия до всего: если перешифровка не удастся, разворачивать будет что.
      await BackupService(db).create(reason: 'beforeEncrypt');

      final cipher = await const DatabaseLockService().cipher();
      await db.close();

      final key = await operation(cipher);
      if (key == null && await cipher.readState().then((s) => s.encrypted)) {
        // Пароль не подошёл — база осталась прежней.
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.backupWrongPassword)),
        );
        return;
      }

      await cipher.dropSideFiles();
      if (!await cipher.verify(key)) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.dbEncryptionFailed)),
        );
        return;
      }

      // Запомненный ключ теперь от прежней базы — он больше не подойдёт.
      await const DatabaseLockService().forget();

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: Text(doneMessage),
          content: Text(l10n.dbEncryptionRestartMessage),
          actions: [
            FilledButton(
              onPressed: () => exit(0),
              child: Text(l10n.backupRestoreQuit),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _enable() async {
    final l10n = AppLocalizations.of(context);

    final agreed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.dbEncryptionConfirmTitle),
        content: Text(l10n.dbEncryptionConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.dbEncryptionConfirmAccept),
          ),
        ],
      ),
    );
    if (agreed != true || !mounted) return;

    final password = await BackupPasswordDialog.show(
      context,
      title: l10n.dbEncryptionTitle,
      message: l10n.dbEncryptionConfirmMessage,
      confirmPassword: true,
    );
    if (password == null || !mounted) return;

    await _run(
      (cipher) => cipher.encrypt(password),
      doneMessage: l10n.dbEncryptionDone,
    );
  }

  Future<void> _disable() async {
    final l10n = AppLocalizations.of(context);

    final agreed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.dbEncryptionDisableTitle),
        content: Text(l10n.dbEncryptionDisableMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.dbEncryptionDisable),
          ),
        ],
      ),
    );
    if (agreed != true || !mounted) return;

    final password = await BackupPasswordDialog.show(
      context,
      title: l10n.lockPasswordLabel,
    );
    if (password == null || !mounted) return;

    await _run(
      (cipher) async => await cipher.decrypt(password) ? const <int>[] : null,
      doneMessage: l10n.dbEncryptionOffDone,
    );
  }

  Future<void> _change() async {
    final l10n = AppLocalizations.of(context);

    final oldPassword = await BackupPasswordDialog.show(
      context,
      title: l10n.lockPasswordLabel,
      message: l10n.lockMessage,
    );
    if (oldPassword == null || !mounted) return;

    final newPassword = await BackupPasswordDialog.show(
      context,
      title: l10n.dbEncryptionChange,
      note: l10n.backupPasswordMessage,
      confirmPassword: true,
    );
    if (newPassword == null || !mounted) return;

    await _run(
      (cipher) => cipher.changePassword(oldPassword, newPassword),
      doneMessage: l10n.dbEncryptionDone,
    );
  }

  /// Запомнить ключ на этом устройстве или забыть его.
  Future<void> _setRemember(bool remember) async {
    final l10n = AppLocalizations.of(context);
    const lock = DatabaseLockService();

    if (!remember) {
      await lock.forget();
      ref.invalidate(dbKeyRememberedProvider);
      return;
    }

    // Ключ выводится из пароля, а пароля у нас нет — спрашиваем.
    final password = await BackupPasswordDialog.show(
      context,
      title: l10n.lockPasswordLabel,
      message: l10n.dbEncryptionRememberHint,
    );
    if (password == null || !mounted) return;

    final cipher = await lock.cipher();
    final state = await cipher.readState();
    final key = await DatabaseCipher.deriveKey(password, state.salt);
    if (!await cipher.opens(key)) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.backupWrongPassword)));
      return;
    }

    await lock.remember(key);
    ref.invalidate(dbKeyRememberedProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final encrypted = ref.watch(dbEncryptedProvider).value ?? false;
    final remembered = ref.watch(dbKeyRememberedProvider).value ?? false;

    return SettingsGroup(
      title: l10n.dbEncryptionTitle,
      children: [
        Text(
          l10n.dbEncryptionHint,
          style: context.text.labelSmall?.copyWith(color: c.textMuted),
        ),
        const SizedBox(height: AppDimens.space12),
        Row(
          children: [
            Expanded(
              child: Text(
                encrypted ? l10n.dbEncryptionOn : l10n.dbEncryptionOff,
                style: context.text.bodyMedium,
              ),
            ),
            if (_busy)
              const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (encrypted)
              Wrap(
                spacing: AppDimens.space8,
                children: [
                  OutlinedButton(
                    onPressed: _change,
                    child: Text(l10n.dbEncryptionChange),
                  ),
                  OutlinedButton(
                    onPressed: _disable,
                    child: Text(l10n.dbEncryptionDisable),
                  ),
                ],
              )
            else
              FilledButton(
                onPressed: _enable,
                child: Text(l10n.dbEncryptionEnable),
              ),
          ],
        ),
        if (encrypted) ...[
          Divider(height: AppDimens.space24, color: c.divider),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.dbEncryptionRememberTitle,
                      style: context.text.bodyMedium,
                    ),
                    const SizedBox(height: AppDimens.space4),
                    Text(
                      l10n.dbEncryptionRememberHint,
                      style: context.text.labelSmall?.copyWith(
                        color: c.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: remembered,
                onChanged: _busy ? null : _setRemember,
              ),
            ],
          ),
        ],
      ],
    );
  }
}
