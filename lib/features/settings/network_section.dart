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
      final release = await ref
          .read(updateServiceProvider)
          .checkAppUpdate(currentVersion: version, force: true);
      ref.read(dataRefreshProvider.notifier).bump();
      if (!mounted) return;
      if (release == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.settingsUpToDate)));
        return;
      }
      await showUpdateDialog(
        context,
        release.version,
        release.installerUrl ?? release.url,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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
                  if (!context.mounted || !moved) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l10n.keyStorageMoved)));
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

/// Предложение обновиться с прямой ссылкой на установщик.
Future<void> showUpdateDialog(
  BuildContext context,
  String version,
  String url,
) async {
  final l10n = AppLocalizations.of(context);
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.system_update_rounded),
      title: Text(l10n.updateTitle),
      content: Text(l10n.updateAvailable(version)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(l10n.updateLater),
        ),
        TextButton(
          onPressed: () async {
            await launchUrl(
              Uri.parse(AppConfig.releasesPageUrl),
              mode: LaunchMode.externalApplication,
            );
            if (ctx.mounted) Navigator.of(ctx).pop();
          },
          child: Text(l10n.updateOpenPage),
        ),
        FilledButton(
          onPressed: () async {
            await launchUrl(
              Uri.parse(url),
              mode: LaunchMode.externalApplication,
            );
            if (ctx.mounted) Navigator.of(ctx).pop();
          },
          child: Text(l10n.updateDownload),
        ),
      ],
    ),
  );
}
