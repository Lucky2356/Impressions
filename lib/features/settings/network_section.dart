import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../core/config/app_config.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/providers.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/services/product_lookup_service.dart';
import '../../data/services/secret_storage.dart';
import '../../data/services/update_service.dart';
import '../../design_system/design_system.dart';

/// Текущая версия приложения из манифеста сборки.
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
});

/// Включённые источники товарных данных.
final enabledSourcesProvider = FutureProvider<Set<String>>((ref) async {
  ref.watch(dataRefreshProvider);
  return ref.watch(updateServiceProvider).enabledSources();
});

final _boolSettingProvider = FutureProvider.family<bool, (String, bool)>((
  ref,
  args,
) async {
  ref.watch(dataRefreshProvider);
  return ref
      .watch(settingsRepositoryProvider)
      .getBool(args.$1, defaultValue: args.$2);
});

/// Товарные базы и обновления — единственные сетевые возможности приложения.
class NetworkSection extends ConsumerStatefulWidget {
  const NetworkSection({super.key});

  @override
  ConsumerState<NetworkSection> createState() => _NetworkSectionState();
}

class _NetworkSectionState extends ConsumerState<NetworkSection> {
  bool _busy = false;

  Future<void> _toggle(String key, bool value) async {
    await ref.read(settingsRepositoryProvider).setBool(key, value);
    ref.read(dataRefreshProvider.notifier).bump();
  }

  Future<void> _refreshProducts() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final report = await ref
          .read(updateServiceProvider)
          .refreshProducts(force: true);
      await ref
          .read(settingsRepositoryProvider)
          .set('product_auto_update_count', '${report.updated}');
      ref.read(dataRefreshProvider.notifier).bump();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.settingsProductRefreshed(report.checked, report.updated),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _checkAppUpdate() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final version = await ref.read(appVersionProvider.future);
      final result = await ref
          .read(updateServiceProvider)
          .checkAppUpdateManually(version);
      ref.read(dataRefreshProvider.notifier).bump();
      if (!mounted) return;

      switch (result.status) {
        case UpdateCheckStatus.updateAvailable:
          final release = result.release!;
          await showUpdateDialog(
            context,
            release.version,
            release.installerUrl ?? release.url,
          );
        case UpdateCheckStatus.upToDate:
          _notify(l10n.settingsUpToDate);
        case UpdateCheckStatus.unavailable:
          _notify(l10n.settingsUpdateUnavailable);
        case UpdateCheckStatus.failed:
          _notify(l10n.settingsUpdateFailed);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _notify(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final lookup =
        ref
            .watch(
              _boolSettingProvider((SettingKeys.barcodeLookupEnabled, true)),
            )
            .value ??
        true;
    final autoProducts =
        ref
            .watch(_boolSettingProvider((SettingKeys.productAutoUpdate, false)))
            .value ??
        false;
    final appCheck =
        ref
            .watch(_boolSettingProvider((SettingKeys.appUpdateCheck, true)))
            .value ??
        true;
    final enabled = ref.watch(enabledSourcesProvider).value ?? const <String>{};

    return SettingsGroup(
      title: l10n.settingsNetworkTitle,
      children: [
        Text(
          l10n.settingsNetworkHint,
          style: context.text.labelSmall?.copyWith(color: c.textMuted),
        ),
        const SizedBox(height: AppDimens.space16),

        _SwitchRow(
          label: l10n.settingsBarcodeLookup,
          value: lookup,
          onChanged: (v) => _toggle(SettingKeys.barcodeLookupEnabled, v),
        ),
        Divider(height: AppDimens.space24, color: c.divider),

        Text(l10n.settingsBarcodeSources, style: context.text.titleMedium),
        const SizedBox(height: AppDimens.space8),
        for (final source in ProductSources.all)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.space4),
            child: Row(
              children: [
                Expanded(
                  child: Text(source.title, style: context.text.bodySmall),
                ),
                Switch(
                  value: enabled.contains(source.id),
                  onChanged: lookup
                      ? (v) async {
                          await ref
                              .read(updateServiceProvider)
                              .setSourceEnabled(source.id, v);
                          ref.read(dataRefreshProvider.notifier).bump();
                        }
                      : null,
                ),
              ],
            ),
          ),
        Divider(height: AppDimens.space24, color: c.divider),

        _SwitchRow(
          label: l10n.settingsProductAutoUpdate,
          hint: l10n.settingsProductAutoUpdateHint,
          value: autoProducts,
          onChanged: (v) => _toggle(SettingKeys.productAutoUpdate, v),
        ),
        const SizedBox(height: AppDimens.space8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: _busy ? null : _refreshProducts,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(l10n.settingsProductRefreshNow),
          ),
        ),
        Divider(height: AppDimens.space24, color: c.divider),

        _SwitchRow(
          label: l10n.settingsAppUpdateCheck,
          value: appCheck,
          onChanged: (v) => _toggle(SettingKeys.appUpdateCheck, v),
        ),
        const SizedBox(height: AppDimens.space8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: _busy ? null : _checkAppUpdate,
            icon: const Icon(Icons.system_update_rounded, size: 18),
            label: Text(l10n.settingsAppUpdateNow),
          ),
        ),
        if (_busy) ...[
          const SizedBox(height: AppDimens.space12),
          const LinearProgressIndicator(minHeight: 3),
        ],
      ],
    );
  }
}

/// Где хранится секрет, которым зашифрован закрытый ключ профиля.
final secretLocationProvider = FutureProvider<SecretLocation>((ref) async {
  ref.watch(dataRefreshProvider);
  return ref.watch(keyServiceProvider).secretLocation();
});

/// Хранение закрытого ключа (§22).
class KeyStorageSection extends ConsumerWidget {
  const KeyStorageSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final location = ref.watch(secretLocationProvider).value;
    final inOs = location == SecretLocation.operatingSystem;

    return SettingsGroup(
      title: l10n.keyStorageTitle,
      children: [
        Row(
          children: [
            Icon(
              inOs ? Icons.verified_user_rounded : Icons.lock_outline_rounded,
              size: 20,
              color: inOs ? c.sage : c.textSecondary,
            ),
            const SizedBox(width: AppDimens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    inOs ? l10n.keyStorageOs : l10n.keyStorageDb,
                    style: context.text.bodyMedium,
                  ),
                  const SizedBox(height: AppDimens.space2),
                  Text(
                    inOs
                        ? (Platform.isWindows
                              ? l10n.keyStorageOsWindows
                              : l10n.keyStorageOsMobile)
                        : l10n.keyStorageDbHint,
                    style: context.text.labelSmall?.copyWith(
                      color: c.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (!inOs && location != null)
              TextButton(
                onPressed: () async {
                  final moved = await ref
                      .read(keyServiceProvider)
                      .moveSecretToOs();
                  ref.read(dataRefreshProvider.notifier).bump();
                  if (!context.mounted) return;
                  // Сообщаем и об отказе: молчащая кнопка выглядит сломанной.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        moved
                            ? l10n.keyStorageMoved
                            : l10n.keyStorageMoveFailed,
                      ),
                    ),
                  );
                },
                child: Text(l10n.keyStorageMove),
              ),
          ],
        ),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.hint,
  });

  final String label;
  final String? hint;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: context.text.bodyMedium),
              if (hint != null) ...[
                const SizedBox(height: AppDimens.space2),
                Text(
                  hint!,
                  style: context.text.labelSmall?.copyWith(color: c.textMuted),
                ),
              ],
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

/// Предложение обновиться: на Windows скачивает и ставит, иначе открывает
/// страницу выпуска.
Future<void> showUpdateDialog(
  BuildContext context,
  String version,
  String url,
) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _UpdateDialog(version: version, url: url),
  );
}

class _UpdateDialog extends ConsumerStatefulWidget {
  const _UpdateDialog({required this.version, required this.url});

  final String version;
  final String url;

  @override
  ConsumerState<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends ConsumerState<_UpdateDialog> {
  double _progress = 0;
  bool _downloading = false;
  String? _error;

  /// Поставить прямо из приложения можно там, где есть подходящий файл выпуска:
  /// установщик на Windows, пакет приложения на Android.
  bool get _canInstall =>
      UpdateService.canInstallInPlace &&
      UpdateService.isTrustedInstallerUrl(widget.url);

  Future<void> _installNow() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _downloading = true;
      _error = null;
      _progress = 0;
    });
    try {
      final service = ref.read(updateServiceProvider);
      final file = await service.downloadInstaller(
        widget.url,
        onProgress: (p) {
          if (mounted) setState(() => _progress = p);
        },
      );
      await service.runInstaller(file);
      // Установщик закроет приложение сам; окно убираем сразу, чтобы не
      // казалось, что ничего не произошло.
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _downloading = false;
          _error = '${l10n.updateFailed}: $e';
        });
      }
    }
  }

  /// Больше не предлагать именно эту версию.
  Future<void> _skipVersion() async {
    await ref
        .read(settingsRepositoryProvider)
        .set(SettingKeys.appUpdateDismissed, widget.version);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _openPage() => _openExternally(AppConfig.releasesPageUrl);

  /// Там, где своего установщика нет, скачивание отдаётся браузеру.
  Future<void> _downloadInBrowser() => _openExternally(widget.url);

  Future<void> _openExternally(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    return AlertDialog(
      icon: const Icon(Icons.system_update_rounded),
      title: Text(l10n.updateTitle),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.updateAvailable(widget.version)),
            if (_canInstall && !_downloading) ...[
              const SizedBox(height: AppDimens.space8),
              Text(
                // На Android приложение не может поставить себя молча:
                // установку подтверждает система. Обещать «закроется и
                // обновится само» там было бы неправдой.
                Platform.isAndroid
                    ? l10n.updateInstallHintAndroid
                    : l10n.updateInstallHint,
                style: context.text.labelSmall?.copyWith(color: c.textMuted),
              ),
            ],
            if (_downloading) ...[
              const SizedBox(height: AppDimens.space20),
              LinearProgressIndicator(
                value: _progress >= 0 ? _progress : null,
                minHeight: 6,
                borderRadius: AppDimens.brPill,
              ),
              const SizedBox(height: AppDimens.space8),
              Text(
                _progress >= 0
                    ? l10n.updateDownloading((_progress * 100).round())
                    : l10n.updateDownloadingUnknown,
                style: context.text.labelSmall?.copyWith(color: c.textMuted),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: AppDimens.space16),
              Text(
                _error!,
                style: context.text.bodySmall?.copyWith(color: c.coral),
              ),
            ],
          ],
        ),
      ),
      actions: _downloading
          ? const []
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.updateLater),
              ),
              // Предложение приходит само при запуске, поэтому должен быть
              // способ сказать «эту версию не предлагай».
              TextButton(onPressed: _skipVersion, child: Text(l10n.updateSkip)),
              TextButton(
                onPressed: _openPage,
                child: Text(l10n.updateOpenPage),
              ),
              FilledButton(
                onPressed: _canInstall ? _installNow : _downloadInBrowser,
                child: Text(
                  _canInstall ? l10n.updateInstallNow : l10n.updateDownload,
                ),
              ),
            ],
    );
  }
}
