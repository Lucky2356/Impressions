import 'package:drift/drift.dart' show OrderingMode, OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../app/navigation.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/providers.dart';
import '../../data/repositories/settings_repository.dart';

/// Что за событие показывает уведомление.
enum NotificationKind { incoming, appUpdate, products, import, backup }

/// Событие для центра уведомлений.
class AppNotification {
  const AppNotification({
    required this.kind,
    required this.title,
    required this.body,
    required this.icon,
    required this.at,
    this.unread = true,
    this.target,
  });

  final NotificationKind kind;
  final String title;
  final String body;
  final IconData icon;
  final DateTime at;
  final bool unread;

  /// Раздел, куда ведёт уведомление.
  final String? target;
}

/// Момент, до которого уведомления считаются прочитанными.
const _seenKey = 'notifications_seen_at';

/// Собирает уведомления из уже существующих данных: непросмотренных входящих
/// изменений, найденного обновления, журналов импорта и резервных копий.
/// Отдельной таблицы для этого не заводим — иначе одни и те же события пришлось
/// бы записывать дважды.
final notificationsProvider = FutureProvider<List<AppNotification>>((
  ref,
) async {
  ref.watch(dataRefreshProvider);
  final db = ref.watch(appDatabaseProvider);
  final settings = ref.watch(settingsRepositoryProvider);
  final profile = ref.watch(activeProfileProvider);

  final seenRaw = await settings.get(_seenKey);
  final seenAt = seenRaw == null ? null : DateTime.tryParse(seenRaw);
  bool unread(DateTime at) => seenAt == null || at.isAfter(seenAt);

  final result = <AppNotification>[];

  // Входящие изменения из импортированных профилей (§23).
  final incoming = await (db.select(
    db.incomingChanges,
  )..where((c) => c.seen.equals(false))).get();
  if (incoming.isNotEmpty) {
    final latest = incoming
        .map((c) => c.receivedAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    result.add(
      AppNotification(
        kind: NotificationKind.incoming,
        title: '',
        body: '',
        icon: Icons.inbox_rounded,
        at: latest,
        unread: true,
        target: NavIds.incoming,
      ),
    );
  }

  // Найденное обновление приложения.
  final latestVersion = await settings.get(SettingKeys.appUpdateLatest);
  final dismissed = await settings.get(SettingKeys.appUpdateDismissed);
  if (latestVersion != null &&
      latestVersion.isNotEmpty &&
      latestVersion != dismissed) {
    final checkedRaw = await settings.get(SettingKeys.appUpdateCheckedAt);
    result.add(
      AppNotification(
        kind: NotificationKind.appUpdate,
        title: latestVersion,
        body: '',
        icon: Icons.system_update_rounded,
        at: DateTime.tryParse(checkedRaw ?? '') ?? DateTime.now(),
        target: NavIds.settings,
      ),
    );
  }

  // Последний импорт.
  final lastImport =
      await (db.select(db.importBatches)
            ..orderBy([
              (b) => OrderingTerm(
                expression: b.importedAt,
                mode: OrderingMode.desc,
              ),
            ])
            ..limit(1))
          .getSingleOrNull();
  if (lastImport != null) {
    result.add(
      AppNotification(
        kind: NotificationKind.import,
        title: '',
        body: '',
        icon: Icons.download_done_rounded,
        at: lastImport.importedAt,
        unread: unread(lastImport.importedAt),
        target: NavIds.profiles,
      ),
    );
  }

  // Обновлённые сведения о товарах.
  if (profile != null) {
    final productsAt = await settings.get(SettingKeys.productAutoUpdateAt);
    final at = DateTime.tryParse(productsAt ?? '');
    if (at != null) {
      result.add(
        AppNotification(
          kind: NotificationKind.products,
          title: '',
          body: '',
          icon: Icons.inventory_2_rounded,
          at: at,
          unread: unread(at),
          target: NavIds.catalog,
        ),
      );
    }
  }

  result.sort((a, b) => b.at.compareTo(a.at));
  return result;
});

/// Число непрочитанных — для значка на колокольчике.
final unreadNotificationsProvider = Provider<int>((ref) {
  final list = ref.watch(notificationsProvider).value ?? const [];
  return list.where((n) => n.unread).length;
});

/// Панель уведомлений, раскрывающаяся из шапки.
class NotificationPanel extends ConsumerWidget {
  const NotificationPanel({super.key});

  /// Показывает панель рядом с кнопкой в шапке.
  static Future<void> show(BuildContext context, {required Offset anchor}) {
    return showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (ctx) => Stack(
        children: [
          Positioned(
            top: anchor.dy,
            right: MediaQuery.sizeOf(ctx).width - anchor.dx,
            child: const Material(
              color: Colors.transparent,
              child: NotificationPanel(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final items = ref.watch(notificationsProvider).value ?? const [];

    String titleOf(AppNotification n) => switch (n.kind) {
      NotificationKind.incoming => l10n.notificationIncomingTitle,
      NotificationKind.appUpdate => l10n.notificationUpdateTitle,
      NotificationKind.products => l10n.notificationProductsTitle,
      NotificationKind.import => l10n.notificationImportTitle,
      NotificationKind.backup => l10n.notificationBackupTitle,
    };

    final dateFormat = DateFormat('d MMMM, HH:mm', 'ru');

    String bodyOf(AppNotification n) => switch (n.kind) {
      NotificationKind.incoming => l10n.notificationIncomingBody(
        ref.watch(incomingCountProvider).value ?? 0,
      ),
      NotificationKind.appUpdate => l10n.notificationUpdateBody(n.title),
      NotificationKind.products => l10n.notificationProductsBody(
        ref.watch(lastProductUpdateCountProvider).value ?? 0,
      ),
      NotificationKind.import => l10n.notificationImportBody(
        dateFormat.format(n.at),
      ),
      NotificationKind.backup => l10n.notificationBackupBody(
        dateFormat.format(n.at),
      ),
    };

    return Container(
      width: 380,
      constraints: const BoxConstraints(maxHeight: 460),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: AppDimens.brLg,
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
            color: c.shadow,
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.space16,
              AppDimens.space12,
              AppDimens.space8,
              AppDimens.space8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.notificationsTitle,
                    style: context.text.titleMedium,
                  ),
                ),
                if (items.any((n) => n.unread))
                  TextButton(
                    onPressed: () async {
                      await ref
                          .read(settingsRepositoryProvider)
                          .set(_seenKey, DateTime.now().toIso8601String());
                      ref.read(dataRefreshProvider.notifier).bump();
                    },
                    child: Text(l10n.notificationsMarkAllRead),
                  ),
              ],
            ),
          ),
          Divider(height: 1, color: c.divider),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppDimens.space32),
              child: Column(
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 36,
                    color: c.textMuted,
                  ),
                  const SizedBox(height: AppDimens.space12),
                  Text(
                    l10n.notificationsEmpty,
                    style: context.text.titleMedium,
                  ),
                  const SizedBox(height: AppDimens.space4),
                  Text(
                    l10n.notificationsEmptyHint,
                    textAlign: TextAlign.center,
                    style: context.text.bodySmall?.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    Divider(height: 1, color: c.divider),
                itemBuilder: (context, i) {
                  final n = items[i];
                  return InkWell(
                    onTap: n.target == null
                        ? null
                        : () {
                            ref.read(navProvider.notifier).go(n.target!);
                            Navigator.of(context).pop();
                          },
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.space16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: n.unread ? c.accentSoft : c.surfaceMuted,
                              borderRadius: AppDimens.brSm,
                            ),
                            child: Icon(
                              n.icon,
                              size: 18,
                              color: n.unread
                                  ? c.accentPrimary
                                  : c.textSecondary,
                            ),
                          ),
                          const SizedBox(width: AppDimens.space12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  titleOf(n),
                                  style: context.text.labelLarge,
                                ),
                                const SizedBox(height: AppDimens.space2),
                                Text(
                                  bodyOf(n),
                                  style: context.text.bodySmall?.copyWith(
                                    color: c.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (n.unread)
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: c.accentPrimary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// Число непросмотренных входящих изменений.
final incomingCountProvider = FutureProvider<int>((ref) async {
  ref.watch(dataRefreshProvider);
  final db = ref.watch(appDatabaseProvider);
  final rows = await (db.select(
    db.incomingChanges,
  )..where((c) => c.seen.equals(false))).get();
  return rows.length;
});

/// Сколько карточек товаров дополнено при последнем обновлении.
final lastProductUpdateCountProvider = FutureProvider<int>((ref) async {
  ref.watch(dataRefreshProvider);
  final raw = await ref
      .watch(settingsRepositoryProvider)
      .get('product_auto_update_count');
  return int.tryParse(raw ?? '') ?? 0;
});
