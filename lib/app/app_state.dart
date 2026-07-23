import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/database.dart';
import '../data/providers.dart';
import '../data/repositories/settings_repository.dart';
import '../data/services/seed_service.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(appDatabaseProvider));
});

final seedServiceProvider = Provider<SeedService>((ref) {
  return SeedService(ref.watch(appDatabaseProvider));
});

/// Все неархивные профили, реактивно.
final profilesProvider = StreamProvider<List<ProfileRow>>((ref) {
  return ref.watch(profileRepositoryProvider).watchAll();
});

/// Нужен ли onboarding (нет ни одного профиля).
final needsOnboardingProvider = Provider<bool>((ref) {
  final profiles = ref.watch(profilesProvider);
  return profiles.maybeWhen(data: (list) => list.isEmpty, orElse: () => false);
});

/// Идентификатор активного профиля, сохраняется в настройках.
class ActiveProfileController extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    return ref
        .watch(settingsRepositoryProvider)
        .get(SettingKeys.activeProfileId);
  }

  Future<void> setActive(String profileId) async {
    await ref
        .read(settingsRepositoryProvider)
        .set(SettingKeys.activeProfileId, profileId);
    state = AsyncData(profileId);
  }
}

final activeProfileIdProvider =
    AsyncNotifierProvider<ActiveProfileController, String?>(
      ActiveProfileController.new,
    );

/// Активный профиль: сохранённый, иначе первый доступный.
final activeProfileProvider = Provider<ProfileRow?>((ref) {
  final profiles = ref.watch(profilesProvider).value ?? const [];
  if (profiles.isEmpty) return null;
  final savedId = ref.watch(activeProfileIdProvider).value;
  for (final p in profiles) {
    if (p.id == savedId) return p;
  }
  return profiles.first;
});
