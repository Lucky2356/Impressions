import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/services/compare_service.dart';

import 'test_db.dart';

void main() {
  test('режимы сравнения профилей (§13)', () async {
    final db = openTestDb();
    addTearDown(db.close);
    final profiles = ProfileRepository(db);
    final entries = EntryRepository(db);
    final compare = CompareService(db);

    final a = await profiles.createOwnProfile(firstName: 'Александр');
    final b = await profiles.createOwnProfile(firstName: 'Лариса');
    final type = await entries.createObjectType(a.id, 'Фильмы');

    // Общий объект с разными мнениями.
    final shared = await entries.createObject(
      typeId: type.id,
      title: 'Интерстеллар',
    );
    await entries.createEntry(
      profileId: a.id,
      objectId: shared.id,
      relation: 'love',
      rating: 9.5,
    );
    await entries.createEntry(
      profileId: b.id,
      objectId: shared.id,
      relation: 'neutral',
      rating: 6.0,
    );

    // Есть только у A, с положительным отношением.
    final onlyA = await entries.createObject(typeId: type.id, title: 'Дюна');
    await entries.createEntry(
      profileId: a.id,
      objectId: onlyA.id,
      relation: 'like',
      rating: 8.0,
    );

    // Есть только у B.
    final onlyB = await entries.createObject(typeId: type.id, title: 'Начало');
    await entries.createEntry(profileId: b.id, objectId: onlyB.id);

    // Нравится обоим.
    final liked = await entries.createObject(
      typeId: type.id,
      title: 'Гравитация',
    );
    await entries.createEntry(
      profileId: a.id,
      objectId: liked.id,
      relation: 'like',
      rating: 8.0,
    );
    await entries.createEntry(
      profileId: b.id,
      objectId: liked.id,
      relation: 'love',
      rating: 9.0,
    );

    Future<List<String>> titles(CompareMode mode) async {
      final rows = await compare.compare(
        firstProfileId: a.id,
        secondProfileId: b.id,
        mode: mode,
      );
      return rows.map((r) => r.title).toList();
    }

    expect(await titles(CompareMode.onlyFirst), ['Дюна']);
    expect(await titles(CompareMode.onlySecond), ['Начало']);
    expect((await titles(CompareMode.both))..sort(), [
      'Гравитация',
      'Интерстеллар',
    ]);
    expect(await titles(CompareMode.bothLike), ['Гравитация']);
    // 9.5 против 6.0 — разница 3.5 ≥ порога.
    expect(await titles(CompareMode.ratingDiffers), ['Интерстеллар']);
    expect(await titles(CompareMode.recommendedNotAdded), ['Дюна']);
  });

  test(
    'сравнение показывает мнения обоих профилей по общему объекту',
    () async {
      final db = openTestDb();
      addTearDown(db.close);
      final profiles = ProfileRepository(db);
      final entries = EntryRepository(db);
      final compare = CompareService(db);

      final a = await profiles.createOwnProfile(firstName: 'A');
      final b = await profiles.createOwnProfile(firstName: 'B');
      final type = await entries.createObjectType(a.id, 'Фильмы');
      final obj = await entries.createObject(typeId: type.id, title: 'Фильм');
      await entries.createEntry(
        profileId: a.id,
        objectId: obj.id,
        relation: 'love',
        rating: 10,
      );
      await entries.createEntry(
        profileId: b.id,
        objectId: obj.id,
        relation: 'dislike',
        rating: 3,
      );

      final rows = await compare.compare(
        firstProfileId: a.id,
        secondProfileId: b.id,
        mode: CompareMode.both,
      );
      expect(rows.length, 1);
      expect(rows.first.left!.rating, 10);
      expect(rows.first.right!.rating, 3);
      expect(rows.first.left!.relation, 'love');
      expect(rows.first.right!.relation, 'dislike');
    },
  );
}
