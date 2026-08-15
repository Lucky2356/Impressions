import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/repositories/category_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';

import 'test_db.dart';

/// Возврат ветки из архива (§24).
///
/// Архивирование опускало всё поддерево, а возврат поднимал только сам узел:
/// после «Вернуть» ветка оказывалась пустой, а её подкатегории оставались в
/// архиве. Ветка под архивным родителем к тому же нигде не показывалась.
void main() {
  late AppDatabase db;
  late CategoryRepository cats;
  late String profileId;

  setUp(() async {
    db = openTestDb();
    cats = CategoryRepository(db);
    profileId = (await ProfileRepository(
      db,
    ).createOwnProfile(firstName: 'Я')).id;
  });
  tearDown(() => db.close());

  Future<CategoryRow> reload(String id) =>
      (db.select(db.categories)..where((c) => c.id.equals(id))).getSingle();

  test('возврат поднимает поддерево целиком', () async {
    final root = await cats.createRoot(profileId, 'Продукты');
    final kid = await cats.createChild(root.id, 'Колбасы');
    final grandKid = await cats.createChild(kid.id, 'Варёные');

    await cats.archive(root.id);
    expect((await reload(grandKid.id)).archivedAt, isNotNull);

    await cats.restore(root.id);

    expect((await reload(root.id)).archivedAt, isNull);
    expect((await reload(kid.id)).archivedAt, isNull);
    expect((await reload(grandKid.id)).archivedAt, isNull);
  });

  test('возврат ветки поднимает и её предков', () async {
    // Иначе восстановленная ветка висела бы под архивным родителем — её нет
    // ни в дереве, ни в архиве, и добраться до неё нечем.
    final root = await cats.createRoot(profileId, 'Продукты');
    final kid = await cats.createChild(root.id, 'Колбасы');
    await cats.archive(root.id);

    await cats.restore(kid.id);

    expect((await reload(root.id)).archivedAt, isNull);
    expect((await reload(kid.id)).archivedAt, isNull);
  });

  test('можно вернуть только сам узел, не трогая поддерево', () async {
    final root = await cats.createRoot(profileId, 'Продукты');
    final kid = await cats.createChild(root.id, 'Колбасы');
    await cats.archive(root.id);

    await cats.restore(root.id, withSubtree: false);

    expect((await reload(root.id)).archivedAt, isNull);
    expect((await reload(kid.id)).archivedAt, isNotNull);
  });

  test('возврат несуществующей ветки ничего не ломает', () async {
    await cats.restore('нет-такой');
  });
}
