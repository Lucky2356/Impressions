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

/// Теги активного профиля вместе с числом помеченных записей.
final tagsWithUsageProvider = FutureProvider<List<({TagRow tag, int count})>>((
  ref,
) async {
  ref.watch(dataRefreshProvider);
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return const [];

  final repo = ref.watch(entryRepositoryProvider);
  final tags = await repo.tagsOfProfile(profile.id);
  final usage = await repo.tagUsage(profile.id);
  return [for (final tag in tags) (tag: tag, count: usage[tag.id] ?? 0)];
});

/// Управление тегами профиля.
///
/// Тег заводится в форме добавления и в карточке записи, а убрать его было
/// неоткуда: опечатка навсегда оставалась в списке фильтров каталога. Здесь
/// тег можно переименовать, слить с уже существующим и удалить.
class TagsSection extends ConsumerWidget {
  const TagsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final tags = ref.watch(tagsWithUsageProvider).value ?? const [];

    Future<void> rename(TagRow tag) async {
      final name = await TextInputDialog.show(
        context,
        title: l10n.tagRename,
        label: l10n.tagNameLabel,
        initial: tag.name,
      );
      if (name == null || name.trim().isEmpty) return;

      final kept = await ref
          .read(entryRepositoryProvider)
          .renameTag(tag.id, name.trim());
      ref.read(dataRefreshProvider.notifier).bump();
      if (!context.mounted) return;

      // Слияние — не то, о чём просили вслух: если тег с таким названием уже
      // был, человек должен узнать, что теперь их один.
      if (kept.id != tag.id) {
        showMessage(context, l10n.tagMerged(kept.name));
      }
    }

    Future<void> remove(TagRow tag, int count) async {
      final ok = await ConfirmDialog.show(
        context,
        title: l10n.tagDeleteTitle,
        message: l10n.tagDeleteMessage(tag.name, count),
        confirmLabel: l10n.tagDelete,
        destructive: true,
      );
      if (!ok) return;
      await ref.read(entryRepositoryProvider).deleteTag(tag.id);
      ref.read(dataRefreshProvider.notifier).bump();
    }

    return SettingsGroup(
      title: l10n.tagsTitle,
      children: [
        Text(
          l10n.tagsHint,
          style: context.text.labelSmall?.copyWith(color: c.textMuted),
        ),
        const SizedBox(height: AppDimens.space12),
        if (tags.isEmpty)
          Text(
            l10n.tagsEmpty,
            style: context.text.bodySmall?.copyWith(color: c.textMuted),
          )
        else
          for (var i = 0; i < tags.length; i++) ...[
            Row(
              children: [
                Icon(Icons.label_outline_rounded, size: 18, color: c.textMuted),
                const SizedBox(width: AppDimens.space12),
                Expanded(
                  child: Text(
                    tags[i].tag.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodyMedium,
                  ),
                ),
                Text(
                  l10n.tagUsage(tags[i].count),
                  style: context.text.labelSmall?.copyWith(color: c.textMuted),
                ),
                IconButton(
                  tooltip: l10n.tagRename,
                  onPressed: () => rename(tags[i].tag),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                ),
                IconButton(
                  tooltip: l10n.tagDelete,
                  onPressed: () => remove(tags[i].tag, tags[i].count),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                ),
              ],
            ),
            if (i != tags.length - 1)
              Divider(height: AppDimens.space12, color: c.divider),
          ],
      ],
    );
  }
}
