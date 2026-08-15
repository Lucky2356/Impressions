import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/core/domain/entry_status.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';

import 'test_db.dart';

/// Отбор по стадии и подпись стадии в карточке (§10).
///
/// Колонка `profile_entries.status` была в базе с самого начала: она
/// заполнялась и не читалась ни одним экраном, а стадию изображало отношение
/// «Хочу попробовать».
void main() {
  late AppDatabase db;
  late EntryRepository entries;
  late ProfileRow me;
  late ObjectTypeRow books;
  late ObjectTypeRow food;

  setUp(() async {
    db = openTestDb();
    entries = EntryRepository(db);
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    books = await entries.createObjectType(
      me.id,
      'Книги',
      statusesJson: EntryStatus.encode(
        BuiltInStatuses.forTypeName('Книги')!.statuses,
      ),
      progressUnit: 'страница',
    );
    food = await entries.createObjectType(
      me.id,
      'Продукты',
      statusesJson: EntryStatus.encode(
        BuiltInStatuses.forTypeName('Продукты')!.statuses,
      ),
    );
  });

  tearDown(() => db.close());

  Future<ProfileEntryRow> add(
    ObjectTypeRow type,
    String title, {
    String? status,
    int? progressCurrent,
    int? progressTotal,
  }) async {
    final object = await entries.createObject(typeId: type.id, title: title);
    return entries.createEntry(
      profileId: me.id,
      objectId: object.id,
      status: status,
      progressCurrent: progressCurrent,
      progressTotal: progressTotal,
    );
  }

  Future<List<String>> titlesWith(String? status) async {
    final views = await entries.entryViews(me.id, status: status);
    return [for (final v in views) v.title];
  }

  test('отбор по стадии не зависит от типа записи', () async {
    await add(books, 'Война и мир', status: EntryStatus.inProgress);
    await add(food, 'Сыр с плесенью', status: EntryStatus.inProgress);
    await add(books, 'Идиот', status: EntryStatus.planned);
    await add(food, 'Хлеб', status: EntryStatus.doneKey);

    // Ключи стадий общие для всех типов — ради этого они и общие: иначе
    // «что сейчас в процессе» пришлось бы спрашивать отдельно про книги и
    // отдельно про продукты.
    expect(
      await titlesWith(EntryStatus.inProgress),
      unorderedEquals(['Война и мир', 'Сыр с плесенью']),
    );
    expect(await titlesWith(EntryStatus.planned), ['Идиот']);
    expect(await titlesWith(null), hasLength(4));
  });

  test('страница каталога считает найденное с учётом стадии', () async {
    for (var i = 0; i < 5; i++) {
      await add(books, 'Задумка $i', status: EntryStatus.planned);
    }
    await add(books, 'Дочитано', status: EntryStatus.doneKey);

    final page = await entries.entryPage(
      me.id,
      status: EntryStatus.planned,
      limit: 2,
    );
    expect(page.total, 5);
    expect(page.items, hasLength(2));
  });

  test('карточка подписывает стадию названием из своего типа', () async {
    await add(books, 'Идиот', status: EntryStatus.doneKey);
    await add(food, 'Хлеб', status: EntryStatus.doneKey);

    final views = await entries.entryViews(me.id);
    final byTitle = {for (final v in views) v.title: v};

    // Ключ один, а названия у типов свои: «Прочитал» и «Попробовал» — про
    // разное, и подставлять одно вместо другого нельзя.
    expect(byTitle['Идиот']!.statusLabel, 'Прочитал');
    expect(byTitle['Хлеб']!.statusLabel, 'Попробовал');
  });

  test('стадия без названия у типа остаётся ключом без подписи', () async {
    // Тип завели сами, стадий у него нет, а ключ у записи есть — так бывает
    // после массовой смены стадии по разнородному выделению.
    final custom = await entries.createObjectType(me.id, 'Настолки');
    await add(custom, 'Каркассон', status: EntryStatus.inProgress);

    final view = (await entries.entryViews(me.id)).single;
    expect(view.status, EntryStatus.inProgress);
    expect(
      view.statusLabel,
      isNull,
      reason: 'подписать нечем — и не подписываем',
    );
  });

  test('прогресс приезжает в карточку вместе с единицей типа', () async {
    await add(
      books,
      'Идиот',
      status: EntryStatus.inProgress,
      progressCurrent: 120,
      progressTotal: 640,
    );
    await add(food, 'Хлеб', status: EntryStatus.doneKey);

    final views = await entries.entryViews(me.id);
    final byTitle = {for (final v in views) v.title: v};

    expect(byTitle['Идиот']!.progressCurrent, 120);
    expect(byTitle['Идиот']!.progressTotal, 640);
    expect(byTitle['Идиот']!.progressUnit, 'страница');
    // У продуктов считать нечего — и единицы нет.
    expect(byTitle['Хлеб']!.progressUnit, isNull);
  });

  test('массовая смена стадии проходит по разнородному выделению', () async {
    final one = await add(books, 'Идиот');
    final two = await add(food, 'Хлеб');

    await entries.updateEntries([one.id, two.id], status: EntryStatus.doneKey);

    expect(await titlesWith(EntryStatus.doneKey), hasLength(2));

    // Стадию можно и снять: «стадии нет» — законное состояние записи.
    await entries.updateEntries([one.id], status: null);
    expect(await titlesWith(EntryStatus.doneKey), ['Хлеб']);
  });
}
