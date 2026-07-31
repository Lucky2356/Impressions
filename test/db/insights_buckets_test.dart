import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';

import 'test_db.dart';

/// Столбики оценок подписаны тем баллом, который содержат.
///
/// Корзина `i` собирала оценки от `i` до `i+1`, а подписывалась числом `i+1`:
/// оценка 1.0 показывалась в столбике «2», а 0 — в столбике «1». Гистограмма
/// целиком была смещена на балл.
void main() {
  late AppDatabase db;
  late EntryRepository entries;
  late ProfileRow me;
  late ObjectTypeRow type;

  setUp(() async {
    db = openTestDb();
    entries = EntryRepository(db);
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    type = await entries.createObjectType(me.id, 'Продукты');
  });

  tearDown(() => db.close());

  Future<void> rate(double rating) async {
    final object = await entries.createObject(
      typeId: type.id,
      title: 'Оценка $rating',
    );
    await entries.createEntry(
      profileId: me.id,
      objectId: object.id,
      rating: rating,
    );
  }

  test('оценка попадает в столбик со своим баллом', () async {
    await rate(1);
    await rate(7);
    await rate(10);

    final buckets = (await entries.insights(me.id)).ratingBuckets;
    // Индекс 0 — столбик «1», индекс 9 — столбик «10».
    expect(buckets[0], 1);
    expect(buckets[6], 1);
    expect(buckets[9], 1);
    expect(buckets.fold<int>(0, (a, b) => a + b), 3);
  });

  test('половинки округляются к ближайшему баллу', () async {
    await rate(6.5);
    await rate(7.4);

    final buckets = (await entries.insights(me.id)).ratingBuckets;
    // 6.5 → 7, 7.4 → 7: оба в столбике «7».
    expect(buckets[6], 2);
  });

  test('в самые высокие столбики попадает только заслуженное', () async {
    await rate(9);
    await rate(9.5);

    final buckets = (await entries.insights(me.id)).ratingBuckets;
    expect(buckets[8], 1, reason: 'девятка — в столбике «9»');
    expect(buckets[9], 1, reason: '9.5 округляется до десяти');
  });
}
