import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_layout.dart';
import '../../core/theme/theme_context.dart';
import '../../data/models/entry_view.dart';
import '../../data/providers.dart';
import '../../data/repositories/collection_repository.dart';
import '../../design_system/design_system.dart';
import '../entry/entry_detail_sheet.dart';
import 'collection_entry_picker.dart';

/// Подборки активного профиля с числом записей.
final collectionsProvider = FutureProvider<List<CollectionView>>((ref) async {
  ref.watch(dataRefreshProvider);
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return const [];
  return ref.watch(collectionRepositoryProvider).listWithCounts(profile.id);
});

/// Записи выбранной подборки.
final collectionEntriesProvider =
    FutureProvider.family<List<EntryView>, String>((ref, collectionId) async {
      ref.watch(dataRefreshProvider);
      final profile = ref.watch(activeProfileProvider);
      if (profile == null) return const [];
      final entries = ref.watch(entryRepositoryProvider);
      return ref
          .watch(collectionRepositoryProvider)
          .entriesOf(
            collectionId,
            profile.id,
            allEntriesLoader: () => entries.entryViews(profile.id),
          );
    });

/// Экран подборок (§27): ручные списки записей внутри профиля.
/// Подборки не заменяют категории.
class CollectionsScreen extends ConsumerStatefulWidget {
  const CollectionsScreen({super.key});

  @override
  ConsumerState<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends ConsumerState<CollectionsScreen> {
  String? _openId;

  void _bump() => ref.read(dataRefreshProvider.notifier).bump();

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context);
    final profile = ref.read(activeProfileProvider);
    if (profile == null) return;
    final name = await _askName(l10n.collectionCreate);
    if (name == null) return;
    await ref.read(collectionRepositoryProvider).create(profile.id, name);
    _bump();
  }

  Future<String?> _askName(String title, {String? initial}) {
    final l10n = AppLocalizations.of(context);
    return TextInputDialog.show(
      context,
      title: title,
      label: l10n.collectionNameLabel,
      initial: initial,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final collections = ref.watch(collectionsProvider);

    if (_openId != null) {
      return _CollectionDetail(
        collectionId: _openId!,
        onBack: () => setState(() => _openId = null),
      );
    }

    return collections.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => Center(child: Text('$e')),
      data: (list) {
        if (list.isEmpty) {
          return EmptyState(
            icon: Icons.collections_bookmark_rounded,
            title: l10n.collectionEmptyTitle,
            message: l10n.collectionEmptyMessage,
            action: FilledButton.icon(
              onPressed: _create,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text(l10n.collectionCreate),
            ),
          );
        }

        return ScreenScaffold(
          header: ScreenHeader(
            title: l10n.collectionsTitle,
            actions: [
              FilledButton.icon(
                onPressed: _create,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(l10n.collectionCreate),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, cns) {
              final cols = (cns.maxWidth / 300).floor().clamp(1, 5);
              final palette = c.profilePalette;
              return GridView.builder(
                padding: EdgeInsets.fromLTRB(
                  context.layout.gutter,
                  AppDimens.space16,
                  context.layout.gutter,
                  AppDimens.space40,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  mainAxisSpacing: AppDimens.space16,
                  crossAxisSpacing: AppDimens.space16,
                  childAspectRatio: 1.9,
                ),
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final view = list[i];
                  final color = palette[i % palette.length];
                  return CollectionCard(
                    title: view.collection.name,
                    tagLabel: l10n.collectionEntriesCount(view.entryCount),
                    tagColor: color,
                    tagIcon: Icons.collections_bookmark_rounded,
                    progress: view.entryCount == 0 ? 0 : 1,
                    progressLabel: view.collection.description ?? '',
                    onTap: () => setState(() => _openId = view.collection.id),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _CollectionDetail extends ConsumerWidget {
  const _CollectionDetail({required this.collectionId, required this.onBack});

  final String collectionId;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final entries = ref.watch(collectionEntriesProvider(collectionId));
    final collection = ref
        .watch(collectionsProvider)
        .value
        ?.where((v) => v.collection.id == collectionId)
        .firstOrNull;

    return ScreenScaffold(
      header: ScreenHeader(
        title: collection?.collection.name ?? l10n.collectionsTitle,
        subtitle: collection?.collection.description,
        leading: AppIconButton(
          icon: Icons.arrow_back_rounded,
          tooltip: l10n.commonBack,
          onPressed: onBack,
        ),
        actions: [
          FilledButton.icon(
            onPressed: () => CollectionEntryPicker.show(context, collectionId),
            icon: const Icon(Icons.playlist_add_rounded, size: 20),
            label: Text(l10n.collectionPickTitle),
          ),
          PopupMenuButton<String>(
            tooltip: '',
            icon: Icon(Icons.more_horiz_rounded, color: c.textSecondary),
            onSelected: (v) async {
              final repo = ref.read(collectionRepositoryProvider);
              if (v == 'rename') {
                final name = await TextInputDialog.show(
                  context,
                  title: l10n.collectionRename,
                  label: l10n.collectionNameLabel,
                  initial: collection?.collection.name,
                );
                if (name == null) return;
                await repo.rename(collectionId, name);
                ref.read(dataRefreshProvider.notifier).bump();
              } else if (v == 'archive') {
                await repo.archive(collectionId);
                ref.read(dataRefreshProvider.notifier).bump();
                onBack();
                if (!context.mounted) return;
                showUndoSnackBar(
                  context,
                  message: l10n.collectionArchived,
                  onUndo: () async {
                    await repo.restore(collectionId);
                    ref.read(dataRefreshProvider.notifier).bump();
                  },
                );
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'rename',
                height: 40,
                child: Row(
                  children: [
                    const Icon(Icons.edit_rounded, size: 18),
                    const SizedBox(width: AppDimens.space12),
                    Text(l10n.collectionRename),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'archive',
                height: 40,
                child: Row(
                  children: [
                    Icon(Icons.archive_rounded, size: 18, color: c.coral),
                    const SizedBox(width: AppDimens.space12),
                    Text(
                      l10n.collectionArchive,
                      style: TextStyle(color: c.coral),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      child: entries.when(
        loading: () => const SizedBox.shrink(),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.playlist_add_rounded,
              title: l10n.collectionOpenEmpty,
              message: l10n.collectionEmptyMessage,
              action: FilledButton.icon(
                onPressed: () =>
                    CollectionEntryPicker.show(context, collectionId),
                icon: const Icon(Icons.playlist_add_rounded, size: 20),
                label: Text(l10n.collectionPickTitle),
              ),
            );
          }
          // Порядок в подборке ручной (§27): его хранит sortOrder, но задать
          // его до сих пор было нечем — список просто выводился как есть.
          return ReorderableListView.builder(
            padding: EdgeInsets.fromLTRB(
              context.layout.gutter,
              AppDimens.space16,
              context.layout.gutter,
              AppDimens.space40,
            ),
            itemCount: list.length,
            // onReorderItem уже учитывает сдвиг из-за изъятого элемента,
            // поэтому индекс поправлять вручную не нужно.
            onReorderItem: (oldIndex, newIndex) async {
              final reordered = [...list];
              reordered.insert(newIndex, reordered.removeAt(oldIndex));
              await ref.read(collectionRepositoryProvider).reorder(
                collectionId,
                [for (final e in reordered) e.entryId],
              );
              ref.read(dataRefreshProvider.notifier).bump();
            },
            itemBuilder: (context, i) {
              final e = list[i];
              return Padding(
                key: ValueKey(e.entryId),
                padding: const EdgeInsets.only(bottom: AppDimens.space8),
                child: Row(
                  children: [
                    ReorderableDragStartListener(
                      index: i,
                      child: Padding(
                        padding: const EdgeInsets.only(right: AppDimens.space8),
                        child: Icon(
                          Icons.drag_indicator_rounded,
                          size: 20,
                          color: c.textMuted,
                        ),
                      ),
                    ),
                    Expanded(
                      child: EntryCardCompact(
                        data: EntryCardData(
                          title: e.title,
                          subtitle: e.subtitle,
                          categoryPath: e.categoryPath,
                          rating: e.rating,
                          seedColor: c.profileColorFor(e.objectId),
                        ),
                        onTap: () => EntryDetailSheet.show(context, e.entryId),
                      ),
                    ),
                    AppIconButton(
                      icon: Icons.playlist_remove_rounded,
                      tooltip: l10n.collectionRemoveFrom,
                      onPressed: () async {
                        await ref
                            .read(collectionRepositoryProvider)
                            .removeEntry(collectionId, e.entryId);
                        ref.read(dataRefreshProvider.notifier).bump();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
