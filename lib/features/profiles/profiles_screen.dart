import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/db/database.dart';
import '../../data/providers.dart';
import '../../design_system/design_system.dart';
import '../exchange/export_dialog.dart';

/// Локальные настройки профиля (§5.3) — не экспортируются.
final localSettingsProvider =
    FutureProvider.family<ProfileLocalSettingRow?, String>((ref, id) async {
      ref.watch(dataRefreshProvider);
      return ref.watch(profileRepositoryProvider).localSettings(id);
    });

/// Число записей по профилям.
final entryCountsByProfileProvider = FutureProvider<Map<String, int>>((
  ref,
) async {
  ref.watch(dataRefreshProvider);
  final db = ref.watch(appDatabaseProvider);
  final rows = await db
      .customSelect(
        'SELECT profile_id AS pid, COUNT(*) AS cnt FROM profile_entries '
        'WHERE archived_at IS NULL GROUP BY profile_id',
        readsFrom: {db.profileEntries},
      )
      .get();
  return {for (final r in rows) r.read<String>('pid'): r.read<int>('cnt')};
});

/// Экран профилей (§5): список, переключение активного, локальные настройки.
class ProfilesScreen extends ConsumerWidget {
  const ProfilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final profiles = ref.watch(profilesProvider);
    final active = ref.watch(activeProfileProvider);
    final counts = ref.watch(entryCountsByProfileProvider).value ?? const {};

    return profiles.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => Center(child: Text('$e')),
      data: (list) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.space24,
              AppDimens.space20,
              AppDimens.space24,
              AppDimens.space12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.profilesTitle,
                    style: context.text.headlineSmall,
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _createProfile(context, ref),
                  icon: const Icon(Icons.person_add_alt_rounded, size: 20),
                  label: Text(l10n.profileCreate),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: c.border),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppDimens.space20),
              itemCount: list.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppDimens.space12),
              itemBuilder: (context, i) {
                final p = list[i];
                return _ProfileTile(
                  profile: p,
                  isActive: active?.id == p.id,
                  entryCount: counts[p.id] ?? 0,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createProfile(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final name = await TextInputDialog.show(
      context,
      title: l10n.profileCreate,
      label: l10n.onboardingProfileNameLabel,
      confirmLabel: l10n.commonCreate,
    );
    if (name == null) return;

    // Профиль, создаваемый вручную, представляет другого человека (§5.1).
    // Собственный основной профиль создаётся один раз при onboarding.
    final profile = await ref
        .read(profileRepositoryProvider)
        .createOwnProfile(firstName: name, type: 'external');
    await ref.read(seedServiceProvider).seedForProfile(profile.id);
    ref.read(dataRefreshProvider.notifier).bump();
  }
}

class _ProfileTile extends ConsumerWidget {
  const _ProfileTile({
    required this.profile,
    required this.isActive,
    required this.entryCount,
  });

  final ProfileRow profile;
  final bool isActive;
  final int entryCount;

  String _typeLabel(AppLocalizations l10n) => switch (profile.type) {
    'myPrimary' => l10n.profileTypePrimary,
    'myOtherDevice' => l10n.profileTypeOtherDevice,
    'external' => l10n.profileTypeExternal,
    'externalArchived' => l10n.profileTypeExternalArchived,
    _ => l10n.profileTypeExternal,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final local = ref.watch(localSettingsProvider(profile.id)).value;
    final displayName = local?.localName?.isNotEmpty == true
        ? local!.localName!
        : profile.firstName;

    return AppCard(
      selected: isActive,
      child: Row(
        children: [
          ProfileAvatar(
            name: displayName,
            color: c.profileColorFor(profile.id),
            size: AppDimens.avatarLg,
          ),
          const SizedBox(width: AppDimens.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.titleLarge,
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: AppDimens.space8),
                      StatusChip(
                        label: l10n.profileActiveBadge,
                        icon: Icons.check_rounded,
                        compact: true,
                        color: c.accentPrimary,
                      ),
                    ],
                  ],
                ),
                Text(
                  _typeLabel(l10n),
                  style: context.text.bodySmall?.copyWith(
                    color: c.textSecondary,
                  ),
                ),
                if (local?.localName?.isNotEmpty == true)
                  Text(
                    profile.firstName,
                    style: context.text.labelSmall?.copyWith(
                      color: c.textMuted,
                    ),
                  ),
                const SizedBox(height: AppDimens.space4),
                Text(
                  l10n.profileEntriesCount(entryCount),
                  style: context.text.labelSmall?.copyWith(color: c.textMuted),
                ),
              ],
            ),
          ),
          if (!isActive)
            TextButton(
              onPressed: () => ref
                  .read(activeProfileIdProvider.notifier)
                  .setActive(profile.id),
              child: Text(l10n.profileSwitchTo),
            ),
          IconButton(
            tooltip: l10n.exportTitle,
            onPressed: () => ExportDialog.show(context, profile),
            icon: const Icon(Icons.upload_rounded),
          ),
          IconButton(
            tooltip: l10n.profileLocalSettings,
            onPressed: () => _editLocal(context, ref, local),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
    );
  }

  Future<void> _editLocal(
    BuildContext context,
    WidgetRef ref,
    ProfileLocalSettingRow? current,
  ) async {
    final result = await showDialog<({String name, String note})>(
      context: context,
      builder: (_) => _LocalSettingsDialog(current: current),
    );
    if (result == null) return;

    await ref
        .read(profileRepositoryProvider)
        .updateLocalSettings(
          profile.id,
          localName: result.name,
          localNote: result.note,
        );
    ref.read(dataRefreshProvider.notifier).bump();
  }
}

/// Диалог локальных настроек профиля (§5.3). Владеет своими контроллерами.
class _LocalSettingsDialog extends StatefulWidget {
  const _LocalSettingsDialog({required this.current});
  final ProfileLocalSettingRow? current;

  @override
  State<_LocalSettingsDialog> createState() => _LocalSettingsDialogState();
}

class _LocalSettingsDialogState extends State<_LocalSettingsDialog> {
  late final _nameCtrl = TextEditingController(
    text: widget.current?.localName ?? '',
  );
  late final _noteCtrl = TextEditingController(
    text: widget.current?.localNote ?? '',
  );

  @override
  void dispose() {
    _nameCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.profileLocalSettings),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.profileLocalHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppDimens.space16),
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.profileLocalName,
              hintText: l10n.profileLocalNameHint,
            ),
          ),
          const SizedBox(height: AppDimens.space12),
          TextField(
            controller: _noteCtrl,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(labelText: l10n.profileLocalNote),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(
            context,
          ).pop((name: _nameCtrl.text.trim(), note: _noteCtrl.text.trim())),
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
