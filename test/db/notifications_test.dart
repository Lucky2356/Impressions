import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/features/notifications/notifications.dart';

import 'test_db.dart';

/// «Отметить всё прочитанным» должно гасить все уведомления.
///
/// Уведомления о входящих изменениях и о новой версии были жёстко помечены как
/// непрочитанные: общая отметка на них не действовала, и счётчик на
/// колокольчике висел вечно.
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = openTestDb();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        // Профиль нужен только уведомлению о товарах; здесь он не участвует.
        activeProfileProvider.overrideWithValue(null),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// Непросмотренное входящее изменение — самый частый повод для счётчика.
  Future<void> addIncoming(DateTime at) async {
    await db
        .into(db.incomingChanges)
        .insert(
          IncomingChangesCompanion.insert(
            id: 'inc-1',
            profileId: 'p1',
            entityKind: 'entry',
            entityId: 'e1',
            revisionId: 'r1',
            receivedAt: at,
            seen: const Value(false),
          ),
        );
  }

  test('до отметки уведомление непрочитано', () async {
    await addIncoming(DateTime.now().subtract(const Duration(minutes: 5)));

    final list = await container.read(notificationsProvider.future);
    expect(list.where((n) => n.unread), isNotEmpty);
  });

  test('после отметки прочитанным счётчик обнуляется', () async {
    await addIncoming(DateTime.now().subtract(const Duration(minutes: 5)));

    // То же, что делает кнопка «Отметить всё прочитанным».
    await container
        .read(settingsRepositoryProvider)
        .set('notifications_seen_at', DateTime.now().toIso8601String());
    container.invalidate(notificationsProvider);

    final list = await container.read(notificationsProvider.future);
    expect(list, isNotEmpty, reason: 'само событие остаётся в списке');
    expect(list.where((n) => n.unread), isEmpty);
  });

  test('уведомление о новой версии тоже гасится отметкой', () async {
    final settings = container.read(settingsRepositoryProvider);
    await settings.set('app_update_latest', '9.9.9');
    await settings.set(
      'app_update_checked_at',
      DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
    );

    var list = await container.read(notificationsProvider.future);
    expect(list.where((n) => n.unread), isNotEmpty);

    await settings.set(
      'notifications_seen_at',
      DateTime.now().toIso8601String(),
    );
    container.invalidate(notificationsProvider);

    list = await container.read(notificationsProvider.future);
    expect(list.where((n) => n.unread), isEmpty);
  });

  test('событие новее отметки снова непрочитано', () async {
    await container
        .read(settingsRepositoryProvider)
        .set(
          'notifications_seen_at',
          DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        );
    await addIncoming(DateTime.now());

    final list = await container.read(notificationsProvider.future);
    expect(list.where((n) => n.unread), isNotEmpty);
  });
}
