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

/// Теги записи (§7.2). Свободные метки без вложенности — отдельный от
/// категорий механизм.
final entryTagsProvider = FutureProvider.family<List<TagRow>, String>((
  ref,
  entryId,
) async {
  ref.watch(dataRefreshProvider);
  return ref.watch(entryRepositoryProvider).tagsOfEntry(entryId);
});

class EntryTags extends ConsumerWidget {
  const EntryTags({super.key, required this.entryId, required this.editable});

  final String entryId;
  final bool editable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final tags =
        ref.watch(entryTagsProvider(entryId)).value ?? const <TagRow>[];

    Future<void> add() async {
      final profile = ref.read(activeProfileProvider);
      if (profile == null) return;
      final name = await TextInputDialog.show(
        context,
        title: l10n.tagAdd,
        label: l10n.tagNameLabel,
      );
      if (name == null) return;
      await ref.read(entryRepositoryProvider).addTag(profile.id, entryId, name);
      ref.read(dataRefreshProvider.notifier).bump();
    }

    Future<void> remove(TagRow tag) async {
      await ref.read(entryRepositoryProvider).removeTag(entryId, tag.id);
      ref.read(dataRefreshProvider.notifier).bump();
    }

    if (tags.isEmpty && !editable) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l10n.tagsLabel, style: context.text.titleMedium),
            const Spacer(),
            if (editable)
              TextButton.icon(
                onPressed: add,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(l10n.tagAdd),
              ),
          ],
        ),
        if (tags.isEmpty)
          Text(
            l10n.tagsHint,
            style: context.text.labelSmall?.copyWith(color: c.textMuted),
          )
        else
          Wrap(
            spacing: AppDimens.space8,
            runSpacing: AppDimens.space8,
            children: [
              for (final tag in tags)
                editable
                    ? InputChip(
                        label: Text(tag.name),
                        onDeleted: () => remove(tag),
                        deleteIcon: const Icon(Icons.close_rounded, size: 16),
                      )
                    : StatusChip(
                        label: tag.name,
                        icon: Icons.label_outline_rounded,
                        compact: true,
                      ),
            ],
          ),
      ],
    );
  }
}

/// Выбор доступности записи (§25).
class PrivacySelector extends ConsumerWidget {
  const PrivacySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    String label(String v) => switch (v) {
      'onlyMe' => l10n.privacyOnlyMe,
      'shareNoNote' => l10n.privacyNoNote,
      'shareNoPhotos' => l10n.privacyNoPhotos,
      'shareBasic' => l10n.privacyBasic,
      _ => l10n.privacyShareable,
    };

    IconData icon(String v) => switch (v) {
      'onlyMe' => Icons.lock_rounded,
      'shareNoNote' => Icons.speaker_notes_off_rounded,
      'shareNoPhotos' => Icons.no_photography_rounded,
      'shareBasic' => Icons.short_text_rounded,
      _ => Icons.share_rounded,
    };

    return Row(
      children: [
        Icon(icon(value), size: 18, color: c.textSecondary),
        const SizedBox(width: AppDimens.space8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.privacyLabel,
                style: context.text.labelSmall?.copyWith(
                  color: c.textSecondary,
                ),
              ),
              Text(label(value), style: context.text.bodyMedium),
            ],
          ),
        ),
        if (onChanged != null)
          PopupMenuButton<String>(
            tooltip: '',
            icon: Icon(Icons.edit_rounded, size: 18, color: c.textSecondary),
            onSelected: onChanged,
            itemBuilder: (_) => [
              for (final v in const [
                'shareable',
                'shareNoNote',
                'shareNoPhotos',
                'shareBasic',
                'onlyMe',
              ])
                PopupMenuItem(
                  value: v,
                  child: Row(
                    children: [
                      Icon(icon(v), size: 18),
                      const SizedBox(width: AppDimens.space12),
                      Expanded(child: Text(label(v))),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
