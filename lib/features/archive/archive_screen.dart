import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../core/domain/app_icons.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_layout.dart';
import '../../core/theme/theme_context.dart';
import '../../data/db/database.dart';
import '../../data/models/entry_view.dart';
import '../../data/providers.dart';
import '../../data/services/purge_service.dart';
import '../../design_system/design_system.dart';
import '../categories/category_providers.dart';

/// Архивные записи активного профиля.
final archivedEntriesProvider = FutureProvider<List<EntryView>>((ref) async {
  ref.watch(dataRefreshProvider);
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return const [];
  return ref
      .watch(entryRepositoryProvider)
      .entryViews(profile.id, archived: true);
});

/// Архивные подборки активного профиля.
final archivedCollectionsProvider = FutureProvider<List<CollectionRow>>((
  ref,
) async {
  ref.watch(dataRefreshProvider);
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return const [];
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.collections)
        ..where((c) => c.profileId.equals(profile.id))
        ..where((c) => c.archivedAt.isNotNull()))
      .get();
});

/// Спрашивает подтверждение и удаляет насовсем.
///
/// Возврата не будет: об этом и говорится в подтверждении, чтобы «удалить» не
/// путали с «архивировать».
Future<void> _confirmPurge(
  BuildContext context,
  WidgetRef ref, {
  required String title,
  required Future<void> Function() purge,
}) async {
  final l10n = AppLocalizations.of(context);
  final ok = await ConfirmDialog.show(
    context,
    title: l10n.purgeConfirmTitle(title),
    message: l10n.purgeConfirmMessage,
    confirmLabel: l10n.purgeAction,
    destructive: true,
  );
  if (!ok) return;

  try {
    await purge();
  } on PurgeException catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(switch (e.reason) {
          PurgeRefusal.categoryHasChildren => l10n.purgeCategoryHasChildren,
        }),
      ),
    );
    return;
  }
  ref.read(dataRefreshProvider.notifier).bump();
  if (!context.mounted) return;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(l10n.purgeDone)));
}

/// Архив (§24): всё, что убрано из работы, но не удалено.
///
/// Приложение обещает, что ничего не пропадает молча, — архивирование заменяет
/// удаление. Но вернуть убранное было нельзя: восстановление существовало в
/// репозиториях и не было подключено ни к одному экрану.
class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final layout = context.layout;

    final entries = ref.watch(archivedEntriesProvider).value ?? const [];
    final categories = ref.watch(archivedCategoriesProvider).value ?? const [];
    final collections =
        ref.watch(archivedCollectionsProvider).value ?? const [];

    final total = entries.length + categories.length + collections.length;

    if (total == 0) {
      return EmptyState(
        icon: Icons.archive_outlined,
        title: l10n.archiveEmptyTitle,
        message: l10n.archiveEmptyMessage,
      );
    }

    return ScreenScaffold(
      header: ScreenHeader(
        title: l10n.archiveTitle,
        subtitle: l10n.archiveSubtitle(total),
      ),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          layout.gutter,
          AppDimens.space16,
          layout.gutter,
          AppDimens.space40,
        ),
        children: [
          if (entries.isNotEmpty) ...[
            SectionHeader(title: l10n.archiveEntries),
            const SizedBox(height: AppDimens.space12),
            for (final entry in entries)
              _ArchivedTile(
                icon: Icons.article_rounded,
                title: entry.title,
                subtitle: entry.categoryPath.isEmpty
                    ? entry.typeName
                    : entry.categoryPath.join(' / '),
                onRestore: () async {
                  await ref
                      .read(entryRepositoryProvider)
                      .restoreEntry(entry.entryId);
                  ref.read(dataRefreshProvider.notifier).bump();
                },
                onPurge: () => _confirmPurge(
                  context,
                  ref,
                  title: entry.title,
                  purge: () => PurgeService(
                    ref.read(appDatabaseProvider),
                  ).purgeEntry(entry.entryId),
                ),
              ),
            const SizedBox(height: AppDimens.space32),
          ],
          if (categories.isNotEmpty) ...[
            SectionHeader(title: l10n.archiveCategories),
            const SizedBox(height: AppDimens.space12),
            for (final category in categories)
              _ArchivedTile(
                icon: AppIcons.byKey(category.icon),
                title: category.name,
                subtitle: l10n.archiveCategoryLevel(category.level + 1),
                onRestore: () async {
                  await ref
                      .read(categoryRepositoryProvider)
                      .restore(category.id);
                  ref.read(dataRefreshProvider.notifier).bump();
                },
                onPurge: () => _confirmPurge(
                  context,
                  ref,
                  title: category.name,
                  purge: () => PurgeService(
                    ref.read(appDatabaseProvider),
                  ).purgeCategory(category.id),
                ),
              ),
            const SizedBox(height: AppDimens.space32),
          ],
          if (collections.isNotEmpty) ...[
            SectionHeader(title: l10n.archiveCollections),
            const SizedBox(height: AppDimens.space12),
            for (final collection in collections)
              _ArchivedTile(
                icon: Icons.collections_bookmark_rounded,
                title: collection.name,
                subtitle: collection.description ?? '',
                onRestore: () async {
                  await ref
                      .read(collectionRepositoryProvider)
                      .restore(collection.id);
                  ref.read(dataRefreshProvider.notifier).bump();
                },
                onPurge: () => _confirmPurge(
                  context,
                  ref,
                  title: collection.name,
                  purge: () => PurgeService(
                    ref.read(appDatabaseProvider),
                  ).purgeCollection(collection.id),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _ArchivedTile extends StatelessWidget {
  const _ArchivedTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onRestore,
    required this.onPurge,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onRestore;
  final VoidCallback onPurge;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    final info = Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: c.surfaceMuted,
            borderRadius: AppDimens.brSm,
          ),
          child: Icon(icon, size: 19, color: c.textMuted),
        ),
        const SizedBox(width: AppDimens.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.titleMedium?.copyWith(
                  color: c.textSecondary,
                ),
              ),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
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
      OutlinedButton.icon(
        onPressed: onRestore,
        icon: const Icon(Icons.restore_rounded, size: 18),
        label: Text(l10n.commonRestore),
      ),
      const SizedBox(width: AppDimens.space8),
      // Отмены здесь нет намеренно: обещать «Вернуть» после настоящего
      // удаления было бы враньём.
      AppIconButton(
        icon: Icons.delete_forever_rounded,
        tooltip: l10n.purgeAction,
        onPressed: onPurge,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.space8),
      child: AppCard(
        elevated: false,
        // «Вернуть» и удаление вместе занимают около 160 точек. На телефоне они
        // выдавливали название за край карточки, поэтому там уходят под него.
        child: LayoutBuilder(
          builder: (context, cns) {
            if (cns.maxWidth >= 420) {
              return Row(
                children: [
                  Expanded(child: info),
                  const SizedBox(width: AppDimens.space12),
                  ...actions,
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                info,
                const SizedBox(height: AppDimens.space8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
