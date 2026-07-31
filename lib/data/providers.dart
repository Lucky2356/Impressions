import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'db/database.dart';
import 'repositories/category_repository.dart';
import 'repositories/collection_repository.dart';
import 'repositories/draft_repository.dart';
import 'repositories/entry_repository.dart';
import 'repositories/profile_repository.dart';
import 'services/barcode_decoder.dart';
import 'services/key_service.dart';
import 'services/product_lookup_service.dart';
import 'services/update_service.dart';

/// Единый экземпляр базы данных приложения на время жизни процесса.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(appDatabaseProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.watch(appDatabaseProvider));
});

final entryRepositoryProvider = Provider<EntryRepository>((ref) {
  return EntryRepository(ref.watch(appDatabaseProvider));
});

final collectionRepositoryProvider = Provider<CollectionRepository>((ref) {
  return CollectionRepository(ref.watch(appDatabaseProvider));
});

/// Черновики форм (§11).
final draftRepositoryProvider = Provider<DraftRepository>((ref) {
  return DraftRepository(ref.watch(appDatabaseProvider));
});

/// Ключи и подпись профиля (§22).
final keyServiceProvider = Provider<KeyService>((ref) {
  return KeyService(ref.watch(appDatabaseProvider));
});

/// Распознавание кодов из изображений — чистые вычисления, без состояния.
final barcodeDecoderProvider = Provider<BarcodeDecoder>((ref) {
  return const BarcodeDecoder();
});

/// Поиск товара по штрихкоду во внешних базах.
final productLookupProvider = Provider<ProductLookupService>((ref) {
  final service = ProductLookupService();
  ref.onDispose(service.dispose);
  return service;
});

/// Проверка обновлений приложения и сведений о товарах.
final updateServiceProvider = Provider<UpdateService>((ref) {
  final service = UpdateService(ref.watch(appDatabaseProvider));
  ref.onDispose(service.dispose);
  return service;
});
