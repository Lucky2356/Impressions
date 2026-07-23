import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/db/database.dart';
import '../../data/providers.dart';
import '../../data/services/device_service.dart';
import '../../design_system/design_system.dart';

/// Устройства активного профиля; текущее регистрируется при первом обращении.
final devicesProvider = FutureProvider<List<ProfileDeviceRow>>((ref) async {
  ref.watch(dataRefreshProvider);
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return const [];
  final service = DeviceService(ref.watch(appDatabaseProvider));
  await service.ensureCurrentDevice(profile.id);
  return service.devicesOf(profile.id);
});

final currentDeviceIdProvider = FutureProvider<String?>((ref) async {
  ref.watch(dataRefreshProvider);
  return DeviceService(ref.watch(appDatabaseProvider)).currentDeviceId();
});

/// Устройства профиля (§5.2). Технические идентификаторы не показываются —
/// только человекочитаемое название, тип и ОС.
class DevicesSection extends ConsumerWidget {
  const DevicesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final devices = ref.watch(devicesProvider).value ?? const [];
    final currentId = ref.watch(currentDeviceIdProvider).value;

    Future<void> rename(ProfileDeviceRow device) async {
      final name = await TextInputDialog.show(
        context,
        title: l10n.deviceRename,
        label: l10n.deviceNameLabel,
        initial: device.name,
      );
      if (name == null) return;
      await DeviceService(
        ref.read(appDatabaseProvider),
      ).rename(device.id, name);
      ref.read(dataRefreshProvider.notifier).bump();
    }

    return SettingsGroup(
      title: l10n.devicesTitle,
      children: [
        if (devices.isEmpty)
          Text(
            l10n.deviceEmpty,
            style: context.text.bodySmall?.copyWith(color: c.textMuted),
          )
        else
          for (var i = 0; i < devices.length; i++) ...[
            Row(
              children: [
                Icon(
                  devices[i].deviceType == 'mobile'
                      ? Icons.smartphone_rounded
                      : Icons.desktop_windows_rounded,
                  size: 20,
                  color: c.textSecondary,
                ),
                const SizedBox(width: AppDimens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              devices[i].name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.bodyMedium,
                            ),
                          ),
                          if (devices[i].id == currentId) ...[
                            const SizedBox(width: AppDimens.space8),
                            StatusChip(
                              label: l10n.deviceThis,
                              icon: Icons.check_rounded,
                              compact: true,
                              color: c.accentPrimary,
                            ),
                          ],
                        ],
                      ),
                      Text(
                        '${devices[i].os ?? ''} · '
                        '${l10n.deviceRegisteredAt(DateFormat('d MMMM y', 'ru').format(devices[i].registeredAt))}',
                        style: context.text.labelSmall?.copyWith(
                          color: c.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l10n.deviceRename,
                  onPressed: () => rename(devices[i]),
                  icon: const Icon(Icons.edit_rounded, size: 18),
                ),
              ],
            ),
            if (i != devices.length - 1)
              Divider(height: AppDimens.space16, color: c.divider),
          ],
      ],
    );
  }
}
