import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/data_refresh.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../core/utils/dates.dart';
import '../../data/providers.dart';
import '../../app/app_state.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/services/backup_service.dart';
import '../../design_system/design_system.dart';
import '../exchange/file_delivery_report.dart';
import 'backup_password_dialog.dart';

/// Список резервных копий (§28).
final backupsProvider = FutureProvider<List<BackupInfo>>((ref) async {
  ref.watch(dataRefreshProvider);
  return BackupService(ref.watch(appDatabaseProvider)).list();
});

/// Защищены ли новые копии паролем.
final backupEncryptionProvider = FutureProvider<bool>((ref) async {
  ref.watch(dataRefreshProvider);
  return BackupService(ref.watch(appDatabaseProvider)).encryptionEnabled();
});

/// Делает ли приложение копию само.
final backupAutoProvider = FutureProvider<bool>((ref) async {
  ref.watch(dataRefreshProvider);
  return ref
      .watch(settingsRepositoryProvider)
      .getBool(SettingKeys.autoBackupEnabled, defaultValue: true);
});

/// Куда копия кладётся ещё и наружу.
final backupMirrorProvider = FutureProvider<String?>((ref) async {
  ref.watch(dataRefreshProvider);
  final value = await ref
      .watch(settingsRepositoryProvider)
      .get(SettingKeys.backupMirrorDir);
  return value == null || value.isEmpty ? null : value;
});

class BackupsSection extends ConsumerWidget {
  const BackupsSection({super.key});

  /// Проверка целостности копии (§28).
  ///
  /// Если копия сделана на другом устройстве, ключа к ней здесь нет — тогда
  /// спрашиваем пароль и пробуем ещё раз.
  Future<void> _verify(
    BuildContext context,
    WidgetRef ref,
    BackupInfo backup,
  ) async {
    final l10n = AppLocalizations.of(context);
    final service = BackupService(ref.read(appDatabaseProvider));

    var check = await service.verify(backup.path);
    if (check == BackupCheck.passwordRequired) {
      if (!context.mounted) return;
      final password = await BackupPasswordDialog.show(
        context,
        title: l10n.backupUnlockTitle,
        message: l10n.backupUnlockMessage,
      );
      if (password == null) return;
      check = await service.verify(backup.path, password: password);
    }
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(switch (check) {
          BackupCheck.ok => l10n.backupVerifyOk,
          BackupCheck.wrongPassword => l10n.backupWrongPassword,
          BackupCheck.notFound => l10n.backupRestoreNotFound,
          _ => l10n.backupVerifyFailed,
        }),
      ),
    );
  }

  /// Копии лежат в приватном каталоге приложения: снесли приложение — копий не
  /// стало, а на телефоне их и не видно ниоткуда. Эта кнопка выкладывает копию
  /// туда, где человек её найдёт.
  ///
  /// Файл копируется, а не читается в память: она бывает в сотни мегабайт.
  Future<void> _saveToFile(
    BuildContext context,
    WidgetRef ref,
    BackupInfo backup,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      final delivery = await ref
          .read(fileDeliveryProvider)
          .deliver(
            fileName: backup.fileName,
            typeLabel: l10n.backupsTitle,
            extension: backup.encrypted ? 'enc' : 'zip',
            write: (destination) async =>
                File(backup.path).copy(destination.path),
          );
      if (!context.mounted) return;
      reportDelivery(context, delivery);
    } catch (error) {
      if (!context.mounted) return;
      reportDeliveryFailure(context, error);
    }
  }

  /// Восстановление из копии, сохранённой куда-то к себе.
  ///
  /// Отдельно от списка внутренних копий: после переустановки приложения или на
  /// новом телефоне список пуст, и восстанавливаться было бы неоткуда.
  Future<void> _restoreFromFile(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);

    // Типы заданы и расширениями, и MIME: Android строит фильтр из MIME-типов,
    // а `.zip.enc` ни в один не превращается — без явного `octet-stream`
    // зашифрованную копию не было бы видно в списке файлов.
    final file = await openFile(
      acceptedTypeGroups: [
        XTypeGroup(
          label: l10n.backupsTitle,
          extensions: const ['zip', 'enc'],
          mimeTypes: const ['application/zip', 'application/octet-stream'],
        ),
      ],
    );
    if (file == null || !context.mounted) return;

    final ok = await ConfirmDialog.show(
      context,
      title: l10n.backupRestoreConfirmTitle,
      message: l10n.backupRestoreFileConfirmMessage(file.name),
      confirmLabel: l10n.backupRestore,
      destructive: true,
    );
    if (!ok || !context.mounted) return;

    await _restorePath(context, ref, file.path);
  }

  /// Восстановление из копии (§28).
  ///
  /// База закрывается прямо посреди работы приложения, поэтому дальше можно
  /// только перезапуститься: половина экранов уже держит закрытое подключение.
  Future<void> _restore(
    BuildContext context,
    WidgetRef ref,
    BackupInfo backup,
  ) async {
    final l10n = AppLocalizations.of(context);
    final date = localeDate(
      context,
      'd MMMM y, HH:mm',
    ).format(backup.createdAt);

    final ok = await ConfirmDialog.show(
      context,
      title: l10n.backupRestoreConfirmTitle,
      message: l10n.backupRestoreConfirmMessage(date),
      confirmLabel: l10n.backupRestore,
      destructive: true,
    );
    if (!ok || !context.mounted) return;

    await _restorePath(context, ref, backup.path);
  }

  /// Общая часть восстановления: подтверждение уже получено, дальше путь
  /// неважно откуда — из списка своих копий или из выбранного файла.
  Future<void> _restorePath(
    BuildContext context,
    WidgetRef ref,
    String path,
  ) async {
    final l10n = AppLocalizations.of(context);
    final db = ref.read(appDatabaseProvider);
    var result = await BackupService(db).restore(path, closeDatabase: db.close);

    // Копия с другого устройства: ключа здесь нет, но пароль знает владелец.
    if (result.status == RestoreStatus.passwordRequired) {
      if (!context.mounted) return;
      final password = await BackupPasswordDialog.show(
        context,
        title: l10n.backupUnlockTitle,
        message: l10n.backupUnlockMessage,
      );
      if (password == null) return;
      result = await BackupService(
        db,
      ).restore(path, closeDatabase: db.close, password: password);
    }
    if (!context.mounted) return;

    if (!result.isOk) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(switch (result.status) {
            RestoreStatus.notFound => l10n.backupRestoreNotFound,
            RestoreStatus.tooNew => l10n.backupRestoreTooNew,
            RestoreStatus.wrongPassword => l10n.backupWrongPassword,
            _ => l10n.backupVerifyFailed,
          }),
        ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.backupRestoreDoneTitle),
        content: Text(l10n.backupRestoreDoneMessage),
        actions: [
          FilledButton(
            onPressed: () => exit(0),
            child: Text(l10n.backupRestoreQuit),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final backups = ref.watch(backupsProvider).value ?? const <BackupInfo>[];

    String reasonLabel(String reason) => switch (reason) {
      'auto' => l10n.backupReasonAuto,
      'beforeImport' => l10n.backupReasonBeforeImport,
      'beforeRestore' => l10n.backupReasonBeforeRestore,
      'beforeEncrypt' => l10n.backupReasonBeforeEncrypt,
      _ => l10n.backupReasonManual,
    };

    return SettingsGroup(
      title: l10n.backupsTitle,
      trailing: FilledButton.icon(
        onPressed: () async {
          final db = ref.read(appDatabaseProvider);
          await BackupService(db).create(reason: 'manual');
          ref.read(dataRefreshProvider.notifier).bump();
          if (!context.mounted) return;
          showMessage(context, l10n.backupCreated);
        },
        icon: const Icon(Icons.save_rounded, size: 18),
        label: Text(l10n.backupCreate),
      ),
      children: [
        Text(
          l10n.backupRetentionHint,
          style: context.text.labelSmall?.copyWith(color: c.textMuted),
        ),
        const SizedBox(height: AppDimens.space8),
        Text(
          l10n.backupOutsideHint,
          style: context.text.labelSmall?.copyWith(color: c.textMuted),
        ),
        const SizedBox(height: AppDimens.space12),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => _restoreFromFile(context, ref),
            icon: const Icon(Icons.folder_open_rounded, size: 18),
            label: Text(l10n.backupRestoreFromFile),
          ),
        ),
        const SizedBox(height: AppDimens.space16),
        const _BackupAutoRow(),
        const SizedBox(height: AppDimens.space16),
        const _BackupMirrorRow(),
        const SizedBox(height: AppDimens.space16),
        const _BackupEncryptionRow(),
        if (backups.isNotEmpty)
          Divider(height: AppDimens.space24, color: c.divider),
        if (backups.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppDimens.space12),
            child: Text(
              l10n.backupEmpty,
              style: context.text.bodySmall?.copyWith(color: c.textMuted),
            ),
          )
        else
          for (var i = 0; i < backups.length; i++) ...[
            _BackupRow(
              backup: backups[i],
              reasonLabel: reasonLabel(backups[i].reason),
              onVerify: () => _verify(context, ref, backups[i]),
              onSave: () => _saveToFile(context, ref, backups[i]),
              onRestore: () => _restore(context, ref, backups[i]),
            ),
            if (i != backups.length - 1)
              Divider(height: AppDimens.space20, color: c.divider),
          ],
      ],
    );
  }
}

/// Переключатель копий по расписанию.
///
/// До этого копия появлялась только перед импортом, перед восстановлением или
/// по кнопке: у человека, который ничего из этого не делает, копий не было
/// вовсе, хотя все записи лежат на одном устройстве.
class _BackupAutoRow extends ConsumerWidget {
  const _BackupAutoRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final enabled = ref.watch(backupAutoProvider).value ?? true;

    Future<void> toggle(bool value) async {
      await ref
          .read(settingsRepositoryProvider)
          .setBool(SettingKeys.autoBackupEnabled, value);
      ref.read(dataRefreshProvider.notifier).bump();
      if (!context.mounted) return;
      showMessage(context, value ? l10n.backupAutoOn : l10n.backupAutoOff);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              Icons.schedule_rounded,
              size: 18,
              color: enabled ? c.accentPrimary : c.textMuted,
            ),
            const SizedBox(width: AppDimens.space12),
            Expanded(
              child: Text(l10n.backupAutoTitle, style: context.text.bodySmall),
            ),
            Switch(value: enabled, onChanged: toggle),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: AppDimens.space4),
          child: Text(
            l10n.backupAutoHint,
            style: context.text.labelSmall?.copyWith(color: c.textMuted),
          ),
        ),
      ],
    );
  }
}

/// Куда класть копию, кроме папки приложения.
class _BackupMirrorRow extends ConsumerWidget {
  const _BackupMirrorRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final target = ref.watch(backupMirrorProvider).value;

    Future<void> save(String? path) async {
      await ref
          .read(settingsRepositoryProvider)
          .set(SettingKeys.backupMirrorDir, path ?? '');
      ref.read(dataRefreshProvider.notifier).bump();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              Icons.drive_file_move_rounded,
              size: 18,
              color: target == null ? c.textMuted : c.accentPrimary,
            ),
            const SizedBox(width: AppDimens.space12),
            Expanded(
              child: Text(
                l10n.backupMirrorTitle,
                style: context.text.bodySmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.space4),
        Text(
          target ?? l10n.backupMirrorOff,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.text.labelSmall?.copyWith(
            color: target == null ? c.textMuted : c.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimens.space8),
        Wrap(
          spacing: AppDimens.space8,
          runSpacing: AppDimens.space8,
          children: [
            OutlinedButton.icon(
              onPressed: () async {
                final picked = await getDirectoryPath();
                if (picked == null) return;
                await save(picked);
              },
              icon: const Icon(Icons.folder_open_rounded, size: 18),
              label: Text(l10n.backupMirrorChoose),
            ),
            if (target != null)
              TextButton(
                onPressed: () => save(null),
                child: Text(l10n.backupMirrorClear),
              ),
          ],
        ),
        const SizedBox(height: AppDimens.space4),
        Text(
          l10n.backupMirrorHint,
          style: context.text.labelSmall?.copyWith(color: c.textMuted),
        ),
      ],
    );
  }
}

/// Переключатель защиты копий паролем.
///
/// Пароль защищает не содержимое напрямую, а ключ копий, который лежит в
/// хранилище ОС. Иначе копию нельзя было бы создать перед импортом или
/// восстановлением — там спросить пароль негде.
class _BackupEncryptionRow extends ConsumerWidget {
  const _BackupEncryptionRow();

  Future<void> _enable(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final enabled = ref.read(backupEncryptionProvider).value ?? false;

    final password = await BackupPasswordDialog.show(
      context,
      title: l10n.backupPasswordTitle,
      message: l10n.backupPasswordMessage,
      note: enabled ? l10n.backupPasswordChangedNote : null,
      confirmPassword: true,
    );
    if (password == null || !context.mounted) return;

    final ok = await BackupService(
      ref.read(appDatabaseProvider),
    ).enableEncryption(password);
    ref.read(dataRefreshProvider.notifier).bump();
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? l10n.backupEncryptionOn : l10n.backupEncryptionUnavailable,
        ),
      ),
    );
  }

  Future<void> _disable(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await ConfirmDialog.show(
      context,
      title: l10n.backupDisableTitle,
      message: l10n.backupDisableMessage,
    );
    if (!ok || !context.mounted) return;

    await BackupService(ref.read(appDatabaseProvider)).disableEncryption();
    ref.read(dataRefreshProvider.notifier).bump();
    if (!context.mounted) return;
    showMessage(context, l10n.backupEncryptionOff);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final enabled = ref.watch(backupEncryptionProvider).value ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              enabled ? Icons.lock_rounded : Icons.lock_open_rounded,
              size: 18,
              color: enabled ? c.accentPrimary : c.textMuted,
            ),
            const SizedBox(width: AppDimens.space12),
            Expanded(
              child: Text(
                l10n.backupEncryptionTitle,
                style: context.text.bodySmall,
              ),
            ),
            if (enabled)
              TextButton(
                onPressed: () => _enable(context, ref),
                child: Text(l10n.backupEncryptionChange),
              ),
            Switch(
              value: enabled,
              onChanged: (value) =>
                  value ? _enable(context, ref) : _disable(context, ref),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: AppDimens.space4),
          child: Text(
            l10n.backupEncryptionHint,
            style: context.text.labelSmall?.copyWith(color: c.textMuted),
          ),
        ),
      ],
    );
  }
}

/// Строка резервной копии: когда сделана, чем и сколько весит, плюс действия.
///
/// «Проверить целостность» и «Восстановить» вместе занимают больше трёхсот
/// точек. На телефоне они выдавливали дату в колонку шириной в один символ, и
/// она печаталась по букве в строку. Поэтому на узкой ширине кнопки уходят под
/// текст, а не встают рядом с ним.
class _BackupRow extends StatelessWidget {
  const _BackupRow({
    required this.backup,
    required this.reasonLabel,
    required this.onVerify,
    required this.onSave,
    required this.onRestore,
  });

  final BackupInfo backup;
  final String reasonLabel;
  final VoidCallback onVerify;
  final VoidCallback onSave;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context);

    final info = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          backup.encrypted ? Icons.lock_rounded : Icons.inventory_2_outlined,
          size: 18,
          color: backup.encrypted ? c.accentPrimary : c.textMuted,
        ),
        const SizedBox(width: AppDimens.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                localeDate(context, 'd MMMM y, HH:mm').format(backup.createdAt),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodySmall,
              ),
              Text(
                '$reasonLabel · '
                '${l10n.backupSizeLabel((backup.byteSize / 1024).toStringAsFixed(0))}'
                '${backup.encrypted ? ' · ${l10n.backupEncryptedBadge}' : ''}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.labelSmall?.copyWith(color: c.textMuted),
              ),
            ],
          ),
        ),
      ],
    );

    final actions = [
      TextButton(onPressed: onVerify, child: Text(l10n.backupVerify)),
      TextButton(onPressed: onSave, child: Text(l10n.backupSaveToFile)),
      TextButton(onPressed: onRestore, child: Text(l10n.backupRestore)),
    ];

    return LayoutBuilder(
      builder: (context, cns) {
        // Трём кнопкам нужно около 470 точек; тексту — хотя бы 160, иначе дата
        // всё равно превратится в лесенку.
        if (cns.maxWidth >= 640) {
          return Row(
            children: [
              Expanded(child: info),
              ...actions,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            info,
            Wrap(spacing: AppDimens.space8, children: actions),
          ],
        );
      },
    );
  }
}
