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
class ArchiveScreen extends ConsumerStatefulWidget {
  const ArchiveScreen({super.key});

  @override
  ConsumerState<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends ConsumerState<ArchiveScreen> {
  /// Отмеченные записи.
  ///
  /// Разбирать архив приходилось по одной: десять записей — десять нажатий
  /// «Вернуть», а удаление насовсем спрашивало подтверждение на каждую.
  final _selected = <String>{};

  void _toggle(String entryId) => setState(() {
    if (!_selected.remove(entryId)) _selected.add(entryId);
  });

  Future<void> _restoreSelected() async {
    final l10n = AppLocalizations.of(context);
    final ids = _selected.toList();
    await ref.read(entryRepositoryProvider).restoreEntries(ids);
    ref.read(dataRefreshProvider.notifier).bump();
    if (!mounted) return;
    setState(_selected.clear);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.archiveRestoredMany(ids.length))),
    );
  }

  /// Удаление насовсем: подтверждение одно на всю пачку, а не на каждую запись.
  Future<void> _purgeSelected() async {
    final l10n = AppLocalizations.of(context);
    final ids = _selected.toList();
    final ok = await ConfirmDialog.show(
      context,
      title: l10n.archivePurgeConfirmMany(ids.length),
      message: l10n.purgeConfirmMessage,
      confirmLabel: l10n.purgeAction,
      destructive: true,
    );
    if (!ok || !mounted) return;

    await PurgeService(ref.read(appDatabaseProvider)).purgeEntries(ids);
    ref.read(dataRefreshProvider.notifier).bump();
    if (!mounted) return;
    setState(_selected.clear);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.purgeDone)));
  }

  @override
  Widget build(BuildContext context) {
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

    // Список собирается построителями, а не готовыми виджетами: архив на
    // тысячу записей строился целиком на каждый кадр, хотя на экране помещается
    // десяток строк. Отметить запись — значит перестроить весь список.
    final rows = <WidgetBuilder>[];

    if (entries.isNotEmpty) {
      rows.add(
        (_) => Row(
          children: [
            Expanded(child: SectionHeader(title: l10n.archiveEntries)),
            if (_selected.isEmpty)
              TextButton(
                onPressed: () => setState(
                  () => _selected.addAll(entries.map((e) => e.entryId)),
                ),
                child: Text(l10n.bulkSelectAll),
              ),
          ],
        ),
      );
      if (_selected.isNotEmpty) {
        rows.add(
          (_) => Padding(
            padding: const EdgeInsets.only(top: AppDimens.space8),
            child: _ArchiveSelectionBar(
              count: _selected.length,
              onClear: () => setState(_selected.clear),
              onRestore: _restoreSelected,
              onPurge: _purgeSelected,
            ),
          ),
        );
      }
      rows.add((_) => const SizedBox(height: AppDimens.space12));
      for (final entry in entries) {
        rows.add(
          (context) => _ArchivedTile(
            icon: Icons.article_rounded,
            title: entry.title,
            subtitle: entry.categoryPath.isEmpty
                ? entry.typeName
                : entry.categoryPath.join(' / '),
            selected: _selected.contains(entry.entryId),
            onSelect: () => _toggle(entry.entryId),
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
        );
      }
      rows.add((_) => const SizedBox(height: AppDimens.space32));
    }

    if (categories.isNotEmpty) {
      rows.add((_) => SectionHeader(title: l10n.archiveCategories));
      rows.add((_) => const SizedBox(height: AppDimens.space12));
      for (final category in categories) {
        rows.add(
          (context) => _ArchivedTile(
            icon: AppIcons.byKey(category.icon),
            title: category.name,
            subtitle: l10n.archiveCategoryLevel(category.level + 1),
            onRestore: () async {
              await ref.read(categoryRepositoryProvider).restore(category.id);
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
        );
      }
      rows.add((_) => const SizedBox(height: AppDimens.space32));
    }

    if (collections.isNotEmpty) {
      rows.add((_) => SectionHeader(title: l10n.archiveCollections));
      rows.add((_) => const SizedBox(height: AppDimens.space12));
      for (final collection in collections) {
        rows.add(
          (context) => _ArchivedTile(
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
        );
      }
    }

    return ScreenScaffold(
      header: ScreenHeader(
        title: l10n.archiveTitle,
        subtitle: l10n.archiveSubtitle(total),
      ),
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          layout.gutter,
          AppDimens.space16,
          layout.gutter,
          AppDimens.space40,
        ),
        itemCount: rows.length,
        itemBuilder: (context, i) => rows[i](context),
      ),
    );
  }
}

/// Панель действий над отмеченными записями архива.
class _ArchiveSelectionBar extends StatelessWidget {
  const _ArchiveSelectionBar({
    required this.count,
    required this.onClear,
    required this.onRestore,
    required this.onPurge,
  });

  final int count;
  final VoidCallback onClear;
  final VoidCallback onRestore;
  final VoidCallback onPurge;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    return Material(
      color: c.accentSoft,
      borderRadius: AppDimens.brSm,
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space8),
        child: Wrap(
          spacing: AppDimens.space8,
          runSpacing: AppDimens.space8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            AppIconButton(
              icon: Icons.close_rounded,
              tooltip: l10n.bulkCancel,
              onPressed: onClear,
            ),
            Text(l10n.bulkSelected(count), style: context.text.labelLarge),
            OutlinedButton.icon(
              onPressed: onRestore,
              icon: const Icon(Icons.restore_rounded, size: 18),
              label: Text(l10n.commonRestore),
            ),
            // Подтверждение остаётся: после настоящего удаления возвращать
            // нечем — но спрашивается один раз на всю пачку.
            OutlinedButton.icon(
              onPressed: onPurge,
              icon: const Icon(Icons.delete_forever_rounded, size: 18),
              label: Text(l10n.purgeAction),
            ),
          ],
        ),
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
    this.selected = false,
    this.onSelect,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onRestore;
  final VoidCallback onPurge;

  /// Отмечена ли строка. Отметки есть только у записей: категорию и подборку
  /// возвращают поштучно, и у них свои правила удаления.
  final bool selected;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    final info = Row(
      children: [
        if (onSelect != null)
          Padding(
            padding: const EdgeInsets.only(right: AppDimens.space4),
            child: Checkbox(value: selected, onChanged: (_) => onSelect!()),
          ),
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
