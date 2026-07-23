import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'db/database.dart';
import 'repositories/category_repository.dart';
import 'repositories/collection_repository.dart';
import 'repositories/entry_repository.dart';
import 'repositories/profile_repository.dart';

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
