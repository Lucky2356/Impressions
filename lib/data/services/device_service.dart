import 'dart:io';

import 'package:drift/drift.dart';

import '../../core/utils/ids.dart';
import '../db/database.dart';
import '../repositories/settings_repository.dart';

/// Устройства профиля (§5.2).
///
/// Профиль и устройство — разные сущности: один профиль может существовать на
/// нескольких устройствах. Технические идентификаторы в обычном интерфейсе не
/// показываются, пользователь видит человекочитаемое название.
class DeviceService {
  DeviceService(this.db) : _settings = SettingsRepository(db);

  final AppDatabase db;
  final SettingsRepository _settings;

  /// Тип текущего устройства.
  static String get currentType {
    if (Platform.isAndroid || Platform.isIOS) return 'mobile';
    return 'desktop';
  }

  /// Операционная система без точных версий и идентификаторов.
  static String get currentOs {
    if (Platform.isWindows) return 'Windows';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isIOS) return 'iOS';
    return 'Неизвестно';
  }

  /// Название по умолчанию — понятное человеку, без технических данных.
  static String get defaultName {
    if (Platform.isAndroid) return 'Телефон';
    if (Platform.isIOS) return 'Телефон';
    if (Platform.isWindows) return 'Компьютер';
    return currentOs;
  }

  /// Регистрирует текущее устройство для профиля, если оно ещё не заведено.
  Future<ProfileDeviceRow> ensureCurrentDevice(String profileId) async {
    final savedId = await _settings.get(SettingKeys.currentDeviceId);
    if (savedId != null) {
      final existing = await (db.select(
        db.profileDevices,
      )..where((d) => d.id.equals(savedId))).getSingleOrNull();
      if (existing != null && existing.profileId == profileId) return existing;
    }

    // Уже есть устройство этого профиля с такой же ОС и названием?
    final sameProfile = await (db.select(
      db.profileDevices,
    )..where((d) => d.profileId.equals(profileId))).get();
    final match = sameProfile
        .where((d) => d.os == currentOs && d.name == defaultName)
        .firstOrNull;
    if (match != null) {
      await _settings.set(SettingKeys.currentDeviceId, match.id);
      return match;
    }

    final id = Ids.newId();
    await db
        .into(db.profileDevices)
        .insert(
          ProfileDevicesCompanion.insert(
            id: id,
            profileId: profileId,
            name: defaultName,
            deviceType: Value(currentType),
            os: Value(currentOs),
            registeredAt: DateTime.now(),
            trusted: const Value(true),
          ),
        );
    await _settings.set(SettingKeys.currentDeviceId, id);

    return (db.select(
      db.profileDevices,
    )..where((d) => d.id.equals(id))).getSingle();
  }

  Future<String?> currentDeviceId() =>
      _settings.get(SettingKeys.currentDeviceId);

  Future<List<ProfileDeviceRow>> devicesOf(String profileId) {
    return (db.select(db.profileDevices)
          ..where((d) => d.profileId.equals(profileId))
          ..orderBy([(d) => OrderingTerm(expression: d.registeredAt)]))
        .get();
  }

  Future<void> rename(String deviceId, String name) {
    return (db.update(db.profileDevices)..where((d) => d.id.equals(deviceId)))
        .write(ProfileDevicesCompanion(name: Value(name)));
  }

  /// Отмечает время последнего экспорта/импорта для устройства.
  Future<void> markExport(String deviceId) {
    return (db.update(db.profileDevices)..where((d) => d.id.equals(deviceId)))
        .write(ProfileDevicesCompanion(lastExportAt: Value(DateTime.now())));
  }

  Future<void> markImport(String deviceId) {
    return (db.update(db.profileDevices)..where((d) => d.id.equals(deviceId)))
        .write(ProfileDevicesCompanion(lastImportAt: Value(DateTime.now())));
  }
}
