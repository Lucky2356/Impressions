import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../core/domain/entry_status.dart';
import '../../core/domain/relation.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_layout.dart';
import '../../core/theme/theme_context.dart';
import '../../data/models/entry_view.dart';
import '../../data/providers.dart';
import '../../design_system/design_system.dart';
import '../entry/entry_detail_sheet.dart';
import '../quick_add/quick_add_sheet.dart';

/// Записи на стадии «Задумано».
///
/// Раньше отбирались по отношению «Хочу попробовать»: отношение подменяло
/// собой стадию, и запись не могла быть одновременно начатой и без мнения.
final wishlistProvider = FutureProvider<List<EntryView>>((ref) async {
  ref.watch(dataRefreshProvider);
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return const [];
  return ref
      .watch(entryRepositoryProvider)
      .entryViews(profile.id, status: EntryStatus.planned);
});

/// Список «Хочу попробовать» — то, ради чего заметку и заводят.
///
/// Задуманное считалось на главной, но работать с ним было негде: чтобы
/// отметить попробованное, приходилось искать запись в каталоге и менять всё
/// руками.
class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final layout = context.layout;
    final items = ref.watch(wishlistProvider).value ?? const <EntryView>[];

    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.bookmark_add_rounded,
        title: l10n.wishlistEmptyTitle,
        message: l10n.wishlistEmptyMessage,
        action: FilledButton.icon(
          onPressed: () => QuickAddSheet.show(context),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: Text(l10n.commonAdd),
        ),
      );
    }

    return ScreenScaffold(
      header: ScreenHeader(
        title: l10n.wishlistTitle,
        subtitle: l10n.wishlistSubtitle(items.length),
        actions: [
          FilledButton.icon(
            onPressed: () => QuickAddSheet.show(context),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: Text(l10n.commonAdd),
          ),
        ],
      ),
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(
          layout.gutter,
          AppDimens.space16,
          layout.gutter,
          AppDimens.space40,
        ),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppDimens.space8),
        itemBuilder: (context, i) => Appear(
          index: i,
          child: WishlistTile(entry: items[i]),
        ),
      ),
    );
  }
}

/// Строка списка «Хочу попробовать».
///
/// Публичная, потому что тот же список показывает главная: раньше там была
/// своя копия строки — и в ней ничего не нажималось.
class WishlistTile extends ConsumerWidget {
  const WishlistTile({super.key, required this.entry});
  final EntryView entry;

  /// Отмечает попробованное и сразу спрашивает оценку: без неё запись просто
  /// исчезла бы из списка, не оставив следа.
  Future<void> _markTried(BuildContext context, WidgetRef ref) async {
    final rating = await RatingDialog.show(context, title: entry.title);
    if (rating == null) return;

    await ref
        .read(entryRepositoryProvider)
        .updateEntry(
          entry.entryId,
          relation: rating >= 7
              ? Relation.love.name
              : (rating >= 5 ? Relation.like.name : Relation.dislike.name),
          rating: rating,
          // Ключ завершающей стадии общий для всех типов, поэтому список может
          // быть разнородным: «Прочитал» и «Попробовал» — одно и то же «done».
          status: EntryStatus.doneKey,
          impressionDate: DateTime.now(),
        );
    ref.read(dataRefreshProvider.notifier).bump();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    return AppCard(
      onTap: () => EntryDetailSheet.show(context, entry.entryId),
      child: Row(
        children: [
          EntryThumb(
            icon: Icons.bookmark_add_rounded,
            color: c.lavender,
            imagePath: entry.coverPath,
          ),
          const SizedBox(width: AppDimens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleMedium,
                ),
                Text(
                  entry.categoryPath.isEmpty
                      ? entry.typeName
                      : entry.categoryPath.join(' / '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.labelSmall?.copyWith(color: c.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.space12),
          FilledButton.icon(
            onPressed: () => _markTried(context, ref),
            icon: const Icon(Icons.check_rounded, size: 18),
            label: Text(l10n.wishlistMarkTried),
          ),
        ],
      ),
    );
  }
}
