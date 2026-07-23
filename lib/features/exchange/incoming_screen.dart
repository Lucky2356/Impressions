import 'package:drift/drift.dart' show OrderingMode, OrderingTerm, Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/data_refresh.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_layout.dart';
import '../../core/theme/theme_context.dart';
import '../../data/db/database.dart';
import '../../data/providers.dart';
import '../../design_system/design_system.dart';
import '../entry/entry_detail_sheet.dart';

/// Одна строка списка входящих изменений вместе с названием затронутой сущности.
class IncomingItem {
  const IncomingItem({
    required this.change,
    required this.label,
    required this.profileName,
  });

  final IncomingChangeRow change;

  /// Название записи, объекта или категории.
  final String label;
  final String profileName;
}

/// Входящие изменения из импортированных профилей (§23).
final incomingChangesProvider = FutureProvider<List<IncomingItem>>((ref) async {
  ref.watch(dataRefreshProvider);
  final db = ref.watch(appDatabaseProvider);

  final changes =
      await (db.select(db.incomingChanges)..orderBy([
            (c) =>
                OrderingTerm(expression: c.receivedAt, mode: OrderingMode.desc),
          ]))
          .get();
  if (changes.isEmpty) return const [];

  final profiles = await db.select(db.profiles).get();
  final profileNames = {for (final p in profiles) p.id: p.firstName};

  // Названия подтягиваем пакетно и только для затронутых сущностей: по одному
  // запросу на строку — это сотни обращений к базе, а выборка целиком —
  // загрузка всего каталога ради нескольких заголовков.
  final idsByKind = <String, Set<String>>{};
  for (final change in changes) {
    (idsByKind[change.entityKind] ??= <String>{}).add(change.entityId);
  }

  final entryIds = idsByKind['entry'] ?? const <String>{};
  final entries = entryIds.isEmpty
      ? <ProfileEntryRow>[]
      : await (db.select(
          db.profileEntries,
        )..where((e) => e.id.isIn(entryIds))).get();

  final objectIds = {
    ...?idsByKind['object'],
    ...entries.map((e) => e.objectId),
  };
  final objects = {
    for (final o
        in objectIds.isEmpty
            ? <ObjectRow>[]
            : await (db.select(
                db.objects,
              )..where((o) => o.id.isIn(objectIds))).get())
      o.id: o.title,
  };

  final categoryIds = idsByKind['category'] ?? const <String>{};
  final categories = {
    for (final c
        in categoryIds.isEmpty
            ? <CategoryRow>[]
            : await (db.select(
                db.categories,
              )..where((c) => c.id.isIn(categoryIds))).get())
      c.id: c.name,
  };

  final entryTitles = {
    for (final e in entries) e.id: objects[e.objectId] ?? e.id,
  };

  return [
    for (final change in changes)
      IncomingItem(
        change: change,
        label: switch (change.entityKind) {
          'entry' => entryTitles[change.entityId] ?? change.entityId,
          'object' => objects[change.entityId] ?? change.entityId,
          'category' => categories[change.entityId] ?? change.entityId,
          _ => change.entityId,
        },
        profileName: profileNames[change.profileId] ?? change.profileId,
      ),
  ];
});

/// Экран входящих изменений: что нового пришло с обновлённым профилем.
///
/// Ничего не применяется автоматически — импорт уже прошёл, здесь показывается
/// журнал, чтобы человек увидел, что именно изменилось, и мог открыть запись.
class IncomingScreen extends ConsumerWidget {
  const IncomingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final items = ref.watch(incomingChangesProvider);

    Future<void> markSeen(String? id) async {
      final db = ref.read(appDatabaseProvider);
      final query = db.update(db.incomingChanges);
      if (id != null) query.where((t) => t.id.equals(id));
      await query.write(const IncomingChangesCompanion(seen: Value(true)));
      ref.read(dataRefreshProvider.notifier).bump();
    }

    return items.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => ErrorState(error: e),
      data: (list) {
        if (list.isEmpty) {
          return EmptyState(
            icon: Icons.inbox_rounded,
            title: l10n.incomingEmptyTitle,
            message: l10n.incomingEmptyMessage,
          );
        }

        final unseen = list.where((i) => !i.change.seen).length;
        final dateFormat = DateFormat('d MMMM yyyy, HH:mm', 'ru');

        return ScreenScaffold(
          header: ScreenHeader(
            title: l10n.incomingTitle,
            subtitle: l10n.incomingSubtitle,
            actions: [
              if (unseen > 0)
                OutlinedButton.icon(
                  onPressed: () => markSeen(null),
                  icon: const Icon(Icons.done_all_rounded, size: 18),
                  label: Text(l10n.incomingMarkAllSeen),
                ),
            ],
          ),
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(
              context.layout.gutter,
              AppDimens.space16,
              context.layout.gutter,
              AppDimens.space40,
            ),
            itemCount: list.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppDimens.space8),
            itemBuilder: (context, i) {
              final item = list[i];
              final change = item.change;
              final kind = switch (change.entityKind) {
                'entry' => l10n.incomingKindEntry,
                'object' => l10n.incomingKindObject,
                'category' => l10n.incomingKindCategory,
                _ => change.entityKind,
              };
              final icon = switch (change.entityKind) {
                'entry' => Icons.article_rounded,
                'object' => Icons.inventory_2_rounded,
                'category' => Icons.account_tree_rounded,
                _ => Icons.change_circle_rounded,
              };

              return AppCard(
                elevated: false,
                onTap: change.entityKind == 'entry'
                    ? () => EntryDetailSheet.show(context, change.entityId)
                    : null,
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: change.seen ? c.surfaceMuted : c.accentSoft,
                        borderRadius: AppDimens.brSm,
                      ),
                      child: Icon(
                        icon,
                        size: 19,
                        color: change.seen ? c.textSecondary : c.accentPrimary,
                      ),
                    ),
                    const SizedBox(width: AppDimens.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  item.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.text.titleMedium,
                                ),
                              ),
                              if (!change.seen) ...[
                                const SizedBox(width: AppDimens.space8),
                                StatusChip(
                                  label: l10n.incomingNewBadge,
                                  compact: true,
                                  color: c.accentPrimary,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: AppDimens.space2),
                          Text(
                            '$kind · ${item.profileName} · '
                            '${l10n.incomingReceivedAt(dateFormat.format(change.receivedAt))}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.labelSmall?.copyWith(
                              color: c.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!change.seen)
                      AppIconButton(
                        icon: Icons.check_rounded,
                        tooltip: l10n.incomingMarkSeen,
                        onPressed: () => markSeen(change.id),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
