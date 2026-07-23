import 'package:drift/drift.dart';

import '../../core/utils/ids.dart';
import '../db/database.dart';

/// Репозиторий профилей и связанных локальных настроек (§5).
class ProfileRepository {
  ProfileRepository(this.db);
  final AppDatabase db;

  /// Создаёт профиль и его локальные настройки по умолчанию.
  ///
  /// [type] (§5.1): `myPrimary` — мой основной, `myOtherDevice` — мой профиль
  /// на другом устройстве, `external` — профиль другого человека.
  /// Генерация ключевой пары выполняется на этапе обмена файлами (§22).
  Future<ProfileRow> createOwnProfile({
    required String firstName,
    String? lastName,
    String? nickname,
    String? bio,
    int? color,
    String type = 'myPrimary',
  }) async {
    final id = Ids.newId();
    final now = DateTime.now();
    await db.transaction(() async {
      await db
          .into(db.profiles)
          .insert(
            ProfilesCompanion.insert(
              id: id,
              type: Value(type),
              firstName: firstName,
              lastName: Value(lastName),
              nickname: Value(nickname),
              bio: Value(bio),
              color: Value(color),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.profileLocalSettings)
          .insert(ProfileLocalSettingsCompanion.insert(profileId: id));
    });
    return (await byId(id))!;
  }

  Future<ProfileRow?> byId(String id) {
    return (db.select(
      db.profiles,
    )..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  /// Все профили, не архивированные, отсортированные: сначала собственные.
  Future<List<ProfileRow>> all({bool includeArchived = false}) {
    final q = db.select(db.profiles);
    if (!includeArchived) {
      q.where((p) => p.archivedAt.isNull());
    }
    q.orderBy([(p) => OrderingTerm(expression: p.createdAt)]);
    return q.get();
  }

  Stream<List<ProfileRow>> watchAll() {
    return (db.select(
      db.profiles,
    )..where((p) => p.archivedAt.isNull())).watch();
  }

  /// Существует ли хотя бы один профиль (для onboarding).
  Future<bool> hasAnyProfile() async {
    final row = await (db.selectOnly(
      db.profiles,
    )..addColumns([db.profiles.id.count()])).getSingle();
    return (row.read(db.profiles.id.count()) ?? 0) > 0;
  }

  Future<ProfileLocalSettingRow?> localSettings(String profileId) {
    return (db.select(
      db.profileLocalSettings,
    )..where((s) => s.profileId.equals(profileId))).getSingleOrNull();
  }

  /// Обновляет локальные настройки (§5.3). Не экспортируются и не стираются
  /// при повторном импорте.
  Future<void> updateLocalSettings(
    String profileId, {
    String? localName,
    String? localNote,
    bool? pinned,
    bool? hidden,
  }) async {
    await (db.update(
      db.profileLocalSettings,
    )..where((s) => s.profileId.equals(profileId))).write(
      ProfileLocalSettingsCompanion(
        localName: localName == null ? const Value.absent() : Value(localName),
        localNote: localNote == null ? const Value.absent() : Value(localNote),
        pinned: pinned == null ? const Value.absent() : Value(pinned),
        hidden: hidden == null ? const Value.absent() : Value(hidden),
      ),
    );
  }
}
