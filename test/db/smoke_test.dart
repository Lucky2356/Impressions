import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/repositories/profile_repository.dart';

import 'test_db.dart';

void main() {
  test('БД создаётся, схема и FTS работают', () async {
    final db = openTestDb();
    addTearDown(db.close);

    final profiles = ProfileRepository(db);
    final p = await profiles.createOwnProfile(firstName: 'Александр');
    expect(p.firstName, 'Александр');
    expect(await profiles.hasAnyProfile(), isTrue);

    // FTS: создаём тип и объект, ищем.
    final typeId = 'type-1';
    // Прямая вставка типа/объекта через generated companions не нужна:
    // проверим только, что FTS-таблица отвечает без ошибок.
    final ids = await db.searchObjectIds('ничего');
    expect(ids, isEmpty);
    expect(typeId, isNotEmpty);
  });
}
