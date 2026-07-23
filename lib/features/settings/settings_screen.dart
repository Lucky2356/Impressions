import 'dart:io';

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
import '../onboarding/app_tour.dart';
import 'devices_section.dart';
import 'network_section.dart';
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
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _settingsMaxWidth),
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.space24,
              vertical: AppDimens.space16,
            ),
            children: const [
              _AppearanceSection(),
              SizedBox(height: AppDimens.space24),
              _BehaviourSection(),
              SizedBox(height: AppDimens.space24),
              NetworkSection(),
              SizedBox(height: AppDimens.space24),
              TypesSection(),
              SizedBox(height: AppDimens.space24),
              DevicesSection(),
              SizedBox(height: AppDimens.space24),
              _BackupsSection(),
              SizedBox(height: AppDimens.space24),
              KeyStorageSection(),
              SizedBox(height: AppDimens.space24),
              _AboutSection(),
              SizedBox(height: AppDimens.space40),
            ],
          ),
        ),
      ),
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
          control: SegmentedToggle<ThemeMode>(
            value: mode,
            onChanged: (m) => ref.read(themeModeProvider.notifier).set(m),
            segments: [
              SegmentData(
                value: ThemeMode.light,
                icon: Icons.light_mode_rounded,
                tooltip: l10n.themeLight,
                label: l10n.themeLight,
              ),
              SegmentData(
                value: ThemeMode.dark,
                icon: Icons.dark_mode_rounded,
                tooltip: l10n.themeDark,
                label: l10n.themeDark,
              ),
              SegmentData(
                value: ThemeMode.system,
                icon: Icons.brightness_auto_rounded,
                tooltip: l10n.themeSystem,
                label: l10n.themeSystem,
              ),
            ],
          ),
          // Переключатель занимает всю ширину, когда стоит на своей строке.
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

    final db = ref.read(appDatabaseProvider);
    final result = await BackupService(
      db,
    ).restore(backup.path, closeDatabase: db.close);
    if (!context.mounted) return;

    if (!result.isOk) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(switch (result.status) {
            RestoreStatus.notFound => l10n.backupRestoreNotFound,
            RestoreStatus.tooNew => l10n.backupRestoreTooNew,
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
            Row(
              children: [
                Icon(Icons.inventory_2_outlined, size: 18, color: c.textMuted),
                const SizedBox(width: AppDimens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat(
                          'd MMMM y, HH:mm',
                          'ru',
                        ).format(backups[i].createdAt),
                        style: context.text.bodySmall,
                      ),
                      Text(
                        '${reasonLabel(backups[i].reason)} · '
                        '${(backups[i].byteSize / 1024).toStringAsFixed(0)} КБ',
                        style: context.text.labelSmall?.copyWith(
                          color: c.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final db = ref.read(appDatabaseProvider);
                    final ok = await BackupService(db).verify(backups[i].path);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ok ? l10n.backupVerifyOk : l10n.backupVerifyFailed,
                        ),
                      ),
                    );
                  },
                  child: Text(l10n.backupVerify),
                ),
                TextButton(
                  onPressed: () => _restore(context, ref, backups[i]),
                  child: Text(l10n.backupRestore),
                ),
              ],
            ),
            if (i != backups.length - 1)
              Divider(height: AppDimens.space20, color: c.divider),
          ],
      ],
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
