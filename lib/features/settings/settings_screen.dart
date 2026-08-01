import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../app/theme_controller.dart';
import '../../core/config/app_config.dart';
import '../../core/domain/hotkeys.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/providers.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/services/backup_service.dart';
import '../../design_system/design_system.dart';
import '../exchange/file_delivery_report.dart';
import '../onboarding/app_tour.dart';
import 'backup_password_dialog.dart';
import 'devices_section.dart';
import 'error_log_section.dart';
import 'network_section.dart';
import 'tags_section.dart';
import 'types_section.dart';

/// Значение настройки «при переносе записей» (§7.4).
final transferModeProvider = FutureProvider<String>((ref) async {
  ref.watch(dataRefreshProvider);
  final value = await ref
      .read(settingsRepositoryProvider)
      .get(SettingKeys.transferMode);
  return value ?? 'suggestMatch';
});

/// Значение настройки «показывать записи из подкатегорий» (§7.5).
final includeSubcategoriesProvider = FutureProvider<bool>((ref) async {
  ref.watch(dataRefreshProvider);
  return ref
      .read(settingsRepositoryProvider)
      .getBool(SettingKeys.catalogIncludeSubcategories, defaultValue: true);
});

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

/// Ширина колонки настроек: формы шире читать неудобно.
const double _settingsMaxWidth = 880;

/// Настройки приложения: оформление, поведение, данные, сведения.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    // Настройки — колонка форм, она уже общей ширины контента. Одна и та же
    // ширина задаётся шапке и содержимому, иначе заголовок и группы стоят с
    // разным отступом слева.
    return ScreenScaffold(
      maxWidth: _settingsMaxWidth,
      header: ScreenHeader(
        title: l10n.navSettings,
        maxWidth: _settingsMaxWidth,
      ),
      // Ширину задаёт сам каркас: он же ставит колонку по общему левому краю.
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space24,
          vertical: AppDimens.space16,
        ),
        // Порядок — по тому, как часто настройку меняют. Сверху то, за чем
        // сюда заходят: вид, поведение списков, сохранность данных и
        // обновления. Ниже — то, что настраивают один раз или никогда:
        // типы объектов, устройства, хранение ключа. Сведения в конце.
        children: const [
          _AppearanceSection(),
          SizedBox(height: AppDimens.space24),
          _BehaviourSection(),
          SizedBox(height: AppDimens.space24),
          _BackupsSection(),
          SizedBox(height: AppDimens.space24),
          NetworkSection(),
          SizedBox(height: AppDimens.space32),
          _AdvancedHeader(),
          SizedBox(height: AppDimens.space16),
          TypesSection(),
          SizedBox(height: AppDimens.space24),
          TagsSection(),
          SizedBox(height: AppDimens.space24),
          DevicesSection(),
          SizedBox(height: AppDimens.space24),
          KeyStorageSection(),
          SizedBox(height: AppDimens.space24),
          ErrorLogSection(),
          SizedBox(height: AppDimens.space24),
          _AboutSection(),
          SizedBox(height: AppDimens.space40),
        ],
      ),
    );
  }
}

/// Граница между тем, что настраивают, и тем, что настраивать не приходится.
class _AdvancedHeader extends StatelessWidget {
  const _AdvancedHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: AppDimens.space24, color: c.divider),
        Text(l10n.settingsAdvanced, style: context.text.titleMedium),
        const SizedBox(height: AppDimens.space2),
        Text(
          l10n.settingsAdvancedHint,
          style: context.text.labelSmall?.copyWith(color: c.textMuted),
        ),
      ],
    );
  }
}

class _AppearanceSection extends ConsumerWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final mode = ref.watch(themeModeProvider);

    // Переключатель с тремя подписями шире, чем остаётся места рядом с
    // заголовком на телефоне: там он наезжал на слово «Тема», разбивая его
    // по букве на строку. На узком экране он встаёт под заголовок.
    return SettingsGroup(
      title: l10n.settingsAppearance,
      children: [
        SettingsRow(
          label: l10n.settingsTheme,
          // Переключатель занимает ровно отведённую ширину и делит её поровну.
          // Раньше он держал свою естественную ширину и на телефоне вылезал
          // за края карточки; совсем узкой строке подписи не нужны — остаются
          // значки с подсказками.
          control: LayoutBuilder(
            builder: (context, cns) {
              final withLabels = cns.maxWidth >= 300;
              return SegmentedToggle<ThemeMode>(
                value: mode,
                expand: true,
                onChanged: (m) => ref.read(themeModeProvider.notifier).set(m),
                segments: [
                  SegmentData(
                    value: ThemeMode.light,
                    icon: Icons.light_mode_rounded,
                    tooltip: l10n.themeLight,
                    label: withLabels ? l10n.themeLight : null,
                  ),
                  SegmentData(
                    value: ThemeMode.dark,
                    icon: Icons.dark_mode_rounded,
                    tooltip: l10n.themeDark,
                    label: withLabels ? l10n.themeDark : null,
                  ),
                  SegmentData(
                    value: ThemeMode.system,
                    icon: Icons.brightness_auto_rounded,
                    tooltip: l10n.themeSystem,
                    label: withLabels ? l10n.themeSystem : null,
                  ),
                ],
              );
            },
          ),
          minControlWidth: 330,
        ),
        Divider(height: AppDimens.space24, color: c.divider),
        SettingsRow(
          label: l10n.settingsLanguage,
          control: Text(
            l10n.settingsLanguageRu,
            style: context.text.labelMedium?.copyWith(color: c.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _BehaviourSection extends ConsumerWidget {
  const _BehaviourSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final settings = ref.read(settingsRepositoryProvider);
    final includeSub = ref.watch(includeSubcategoriesProvider).value ?? true;
    final transferMode =
        ref.watch(transferModeProvider).value ?? 'suggestMatch';

    String label(String mode) => switch (mode) {
      'autoCreate' => l10n.settingsTransferAutoCreate,
      'alwaysAsk' => l10n.settingsTransferAlwaysAsk,
      'noCategory' => l10n.settingsTransferNoCategory,
      _ => l10n.settingsTransferSuggest,
    };

    return SettingsGroup(
      title: l10n.settingsBehaviour,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.settingsShowSubcategoriesDefault,
                style: context.text.bodyMedium,
              ),
            ),
            Switch.adaptive(
              value: includeSub,
              onChanged: (v) async {
                await settings.setBool(
                  SettingKeys.catalogIncludeSubcategories,
                  v,
                );
                ref.read(dataRefreshProvider.notifier).bump();
              },
            ),
          ],
        ),
        Divider(height: AppDimens.space24, color: c.divider),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.settingsTransferMode,
                    style: context.text.bodyMedium,
                  ),
                  const SizedBox(height: AppDimens.space4),
                  Text(
                    label(transferMode),
                    style: context.text.labelSmall?.copyWith(
                      color: c.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: '',
              icon: Icon(Icons.edit_rounded, size: 18, color: c.textSecondary),
              onSelected: (v) async {
                await settings.set(SettingKeys.transferMode, v);
                ref.read(dataRefreshProvider.notifier).bump();
              },
              itemBuilder: (_) => [
                for (final mode in const [
                  'suggestMatch',
                  'autoCreate',
                  'alwaysAsk',
                  'noCategory',
                ])
                  PopupMenuItem(value: mode, child: Text(label(mode))),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _BackupsSection extends ConsumerWidget {
  const _BackupsSection();

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
    final date = DateFormat('d MMMM y, HH:mm', 'ru').format(backup.createdAt);

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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.backupCreated)));
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(value ? l10n.backupAutoOn : l10n.backupAutoOff)),
      );
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.backupEncryptionOff)));
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
                DateFormat('d MMMM y, HH:mm', 'ru').format(backup.createdAt),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodySmall,
              ),
              Text(
                '$reasonLabel · '
                '${(backup.byteSize / 1024).toStringAsFixed(0)} КБ'
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

class _AboutSection extends ConsumerWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: context.text.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ),
          Text(value, style: context.text.labelMedium),
        ],
      ),
    );

    return SettingsGroup(
      title: l10n.settingsAbout,
      children: [
        row(l10n.settingsVersion, ref.watch(appVersionProvider).value ?? '—'),
        row('Формат обмена', AppConfig.profileFileExtensionDotted),
        row('Профилей максимум', '${AppConfig.maxProfiles}'),
        row('Глубина категорий', '${AppConfig.defaultMaxCategoryDepth}'),
        Divider(height: AppDimens.space24, color: c.divider),
        // Обучение показывается один раз при первом запуске — но забыть его
        // содержание проще, чем найти, где оно было.
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => AppTour.show(context),
            icon: const Icon(Icons.school_outlined, size: 18),
            label: Text(l10n.tourRepeat),
          ),
        ),
        const SizedBox(height: AppDimens.space16),
        Text(
          l10n.settingsPrivacyNote,
          style: context.text.bodySmall?.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: AppDimens.space16),
        const _HotkeysHint(),
      ],
    );
  }
}

class _HotkeysHint extends StatelessWidget {
  const _HotkeysHint();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final wide =
        MediaQuery.sizeOf(context).width >= AppDimens.breakpointExpanded;
    if (!wide) return const SizedBox.shrink();

    Widget key(String combo, String label) => Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.space4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: c.surfaceMuted,
              borderRadius: AppDimens.brSm,
              border: Border.all(color: c.border),
            ),
            child: Text(combo, style: context.text.labelSmall),
          ),
          const SizedBox(width: AppDimens.space12),
          Text(
            label,
            style: context.text.labelSmall?.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.hotkeysTitle, style: context.text.titleMedium),
        const SizedBox(height: AppDimens.space8),
        for (final hotkey in appHotkeys(l10n)) key(hotkey.keys, hotkey.label),
      ],
    );
  }
}
