import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/category_repository.dart';
import 'package:impressions/data/repositories/collection_repository.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/features/quick_add/quick_add_sheet.dart';

import '../db/test_db.dart';
import 'screens_test.dart' show app;

void main() {
  late AppDatabase db;
  late ProfileRow me;
  late EntryRepository entries;
  late CollectionRepository collections;

  setUp(() async {
    db = openTestDb();
    entries = EntryRepository(db);
    collections = CollectionRepository(db);
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    await entries.createObjectType(me.id, 'Продукты');
  });

  tearDown(() => db.close());

  /// Форма прокручивается: с подробностями она выше окна, и слепой tap
  /// промахивается мимо кнопки.
  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> openSheet(WidgetTester tester, {CategoryRow? initial}) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // Пустое дерево между открытиями. Без него `pumpWidget` с той же формой
    // не создаёт её заново, а обновляет прежнюю: состояние остаётся жить, и
    // повторное открытие в тесте перестаёт быть повторным.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activeProfileProvider.overrideWithValue(me),
        ],
        child: app(QuickAddSheet(initialCategory: initial)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('запись сохраняется вместе с тегом', (tester) async {
    await openSheet(tester);

    await tester.enterText(find.byType(TextFormField).first, 'Хлеб');
    await tapVisible(tester, find.text('Добавить подробности'));

    // Тег заводится прямо из формы: раньше за ним приходилось открывать
    // уже сохранённую запись.
    await tapVisible(tester, find.text('Добавить тег'));
    await tester.enterText(find.byType(TextField).last, 'Завтрак');
    await tester.tap(find.widgetWithText(FilledButton, 'Сохранить').last);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(InputChip, 'Завтрак'), findsOneWidget);

    await tapVisible(tester, find.widgetWithText(FilledButton, 'Сохранить'));

    final saved = await entries.entryViews(me.id);
    expect(saved.single.title, 'Хлеб');
    final tags = await entries.tagsOfEntry(saved.single.entryId);
    expect(tags.map((t) => t.name), ['Завтрак']);
  });

  testWidgets('запись сразу попадает в выбранную подборку', (tester) async {
    final collection = await collections.create(me.id, 'На выходные');
    await openSheet(tester);

    await tester.enterText(find.byType(TextFormField).first, 'Сыр');
    await tapVisible(tester, find.text('Добавить подробности'));

    // Список подборок — единственное поле с необязательным значением.
    await tapVisible(tester, find.byType(DropdownButtonFormField<String?>));
    await tester.tap(find.text('На выходные').last);
    await tester.pumpAndSettle();

    await tapVisible(tester, find.widgetWithText(FilledButton, 'Сохранить'));

    final inCollection = await collections.entriesOf(
      collection.id,
      me.id,
      entriesLoader: (ids) => entries.entryViews(me.id, entryIds: ids),
    );
    expect(inCollection.single.title, 'Сыр');
  });

  /// Тип, подставленный формой: то, что показано в поле «Тип».
  ///
  /// Название типа встречается ещё и в раскрывающемся списке, поэтому ищем
  /// именно внутри поля, а не по всему экрану.
  String shownType(WidgetTester tester) {
    final field = find.byType(DropdownButtonFormField<String>);
    return tester
        .widgetList<Text>(
          find.descendant(of: field, matching: find.byType(Text)),
        )
        .map((t) => t.data)
        .whereType<String>()
        .first;
  }

  testWidgets('тип подставляется по ветке, а не первым из списка', (
    tester,
  ) async {
    // «Продукты» заведены в setUp и идут первыми — раньше форма предлагала их
    // и в «Местах», просто потому что этот тип создан раньше.
    await entries.createObjectType(me.id, 'Места', sortOrder: 1);
    final categories = CategoryRepository(db);
    final places = await categories.createRoot(me.id, 'Места');
    final parks = await categories.createChild(places.id, 'Парки');

    await openSheet(tester, initial: parks);

    expect(shownType(tester), 'Места');
    expect(find.text('Парки'), findsOneWidget);
  });

  testWidgets('выбранный человеком тип не перебивается подсказкой', (
    tester,
  ) async {
    await entries.createObjectType(me.id, 'Места', sortOrder: 1);
    final categories = CategoryRepository(db);
    final places = await categories.createRoot(me.id, 'Места');

    await openSheet(tester, initial: places);
    expect(shownType(tester), 'Места');

    await tapVisible(tester, find.byType(DropdownButtonFormField<String>));
    await tester.tap(find.text('Продукты').last);
    await tester.pumpAndSettle();

    expect(shownType(tester), 'Продукты');
  });

  testWidgets('в своей категории тип берётся у соседних записей', (
    tester,
  ) async {
    // Имя ветки не совпадает ни с одним типом — тогда смотрим, что в ней уже
    // лежит. «Отпуск» с местами внутри должен предлагать «Места».
    final places = await entries.createObjectType(me.id, 'Места', sortOrder: 1);
    final vacation = await CategoryRepository(db).createRoot(me.id, 'Отпуск');
    final object = await entries.createObject(
      typeId: places.id,
      title: 'Красная поляна',
    );
    await entries.createEntry(
      profileId: me.id,
      objectId: object.id,
      primaryCategoryId: vacation.id,
    );

    await openSheet(tester, initial: vacation);
    await tester.pumpAndSettle();

    expect(shownType(tester), 'Места');
  });

  testWidgets('без категории тип остаётся первым из списка', (tester) async {
    await entries.createObjectType(me.id, 'Места', sortOrder: 1);

    await openSheet(tester);

    expect(shownType(tester), 'Продукты');
  });

  testWidgets('без подробностей запись сохраняется как прежде', (tester) async {
    await openSheet(tester);

    await tester.enterText(find.byType(TextFormField).first, 'Молоко');
    await tapVisible(tester, find.widgetWithText(FilledButton, 'Сохранить'));

    final saved = await entries.entryViews(me.id);
    expect(saved.single.title, 'Молоко');
    expect(await entries.tagsOfEntry(saved.single.entryId), isEmpty);
  });

  group('черновик формы', () {
    /// Форма живёт в модальном окне и до «Сохранить» не хранилась нигде:
    /// Android выгружает приложение, пока человек выбирает фотографию, и всё
    /// набранное пропадало. Здесь закрытие формы играет роль такой выгрузки.
    testWidgets('недописанная форма возвращается при следующем открытии', (
      tester,
    ) async {
      await openSheet(tester);
      await tester.enterText(find.byType(TextFormField).first, 'Хлеб бородин');
      // Черновик пишется с задержкой — ждём её.
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      await openSheet(tester);

      expect(find.text('Хлеб бородин'), findsOneWidget);
      expect(find.text('Продолжаем недописанное'), findsOneWidget);
    });

    testWidgets('«Начать заново» очищает форму и черновик', (tester) async {
      await openSheet(tester);
      await tester.enterText(find.byType(TextFormField).first, 'Хлеб бородин');
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      await openSheet(tester);
      await tapVisible(tester, find.text('Начать заново'));
      expect(find.text('Хлеб бородин'), findsNothing);

      // И в следующий раз предлагать уже нечего.
      await openSheet(tester);
      expect(find.text('Продолжаем недописанное'), findsNothing);
    });

    testWidgets('сохранённая запись не оставляет черновика', (tester) async {
      await openSheet(tester);
      await tester.enterText(find.byType(TextFormField).first, 'Молоко');
      await tester.pump(const Duration(seconds: 1));
      await tapVisible(tester, find.widgetWithText(FilledButton, 'Сохранить'));

      await openSheet(tester);

      expect(find.text('Продолжаем недописанное'), findsNothing);
      expect(find.text('Молоко'), findsNothing);
    });

    testWidgets('пустая форма черновика не заводит', (tester) async {
      await openSheet(tester);
      // Ничего не набирали — только раскрыли подробности.
      await tapVisible(tester, find.text('Добавить подробности'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      await openSheet(tester);

      expect(find.text('Продолжаем недописанное'), findsNothing);
    });
  });

  /// Enter в названии сохраняет запись.
  ///
  /// Поле автофокусится, но не отвечало ни на что: на телефоне после набора
  /// надо было убирать клавиатуру и тянуться к кнопке внизу, на компьютере
  /// Enter не делал ничего — в самой частой форме приложения.
  testWidgets('Enter в названии сохраняет запись', (tester) async {
    await openSheet(tester);

    await tester.enterText(find.byType(TextFormField).first, 'Кефир');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final saved = await entries.entryViews(me.id);
    expect(saved.single.title, 'Кефир');
  });

  group('форма помнит, куда клали', () {
    testWidgets('категория подставляется из прошлой записи', (tester) async {
      final categories = CategoryRepository(db);
      final food = await categories.createRoot(me.id, 'Еда');
      final sausages = await categories.createChild(food.id, 'Колбасы');

      await openSheet(tester, initial: sausages);
      await tester.enterText(find.byType(TextFormField).first, 'Докторская');
      await tapVisible(tester, find.widgetWithText(FilledButton, 'Сохранить'));

      // Вторая запись подряд обычно ложится туда же — а форма, открытая не из
      // ветки, каждый раз спрашивала категорию заново.
      await openSheet(tester);
      expect(find.text('Колбасы'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).first, 'Краковская');
      await tapVisible(tester, find.widgetWithText(FilledButton, 'Сохранить'));

      final saved = await entries.entryViews(me.id);
      final krakow = saved.firstWhere((e) => e.title == 'Краковская');
      expect(krakow.categoryPath.last, 'Колбасы');
    });

    testWidgets('черновик важнее привычки', (tester) async {
      final categories = CategoryRepository(db);
      final sausages = await categories.createRoot(me.id, 'Колбасы');

      await openSheet(tester, initial: sausages);
      await tester.enterText(find.byType(TextFormField).first, 'Докторская');
      await tapVisible(tester, find.widgetWithText(FilledButton, 'Сохранить'));

      // Незаконченная работа — не привычка: начатую без категории запись
      // подстановка перебивать не должна.
      await openSheet(tester);
      await tapVisible(tester, find.text('Колбасы'));
      await tester.tap(find.text('Без категории').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'Сулугуни');
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      await openSheet(tester);

      expect(find.text('Продолжаем недописанное'), findsOneWidget);
      expect(find.text('Колбасы'), findsNothing);
    });
  });

  /// Форма закрывалась после каждой записи.
  ///
  /// Заводя пять записей подряд, её открывали пять раз — при том что категория
  /// и тип уже подставляются сами.
  testWidgets('«И ещё» оставляет форму открытой для следующей записи', (
    tester,
  ) async {
    final categories = CategoryRepository(db);
    final sausages = await categories.createRoot(me.id, 'Колбасы');
    await openSheet(tester, initial: sausages);

    await tester.enterText(find.byType(TextFormField).first, 'Докторская');
    await tapVisible(tester, find.widgetWithText(OutlinedButton, 'И ещё'));

    // Форма на месте, название очищено, а место осталось прежним.
    expect(find.text('Заведена 1 запись подряд'), findsOneWidget);
    expect(find.text('Докторская'), findsNothing);
    expect(find.text('Колбасы'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'Краковская');
    await tapVisible(tester, find.widgetWithText(FilledButton, 'Сохранить'));

    final saved = await entries.entryViews(me.id);
    expect(
      saved.map((e) => e.title),
      containsAll(['Докторская', 'Краковская']),
    );
    for (final view in saved) {
      expect(view.categoryPath.last, 'Колбасы');
    }
  });

  /// Диалог дублей показывал список, а брал первого из него.
  ///
  /// «Чай зелёный» от двух производителей — человек имел в виду второй, а
  /// запись молча привязывалась к первому, и заметить это можно было только
  /// потом, в карточке.
  testWidgets('дубль берётся выбранный, а не первый', (tester) async {
    final type = (await entries.objectTypes(me.id)).single;
    final ahmad = await entries.createObject(
      typeId: type.id,
      title: 'Чай зелёный',
      creator: 'Ахмад',
    );
    final lipton = await entries.createObject(
      typeId: type.id,
      title: 'Чай зелёный',
      creator: 'Липтон',
    );

    await openSheet(tester);
    await tester.enterText(find.byType(TextFormField).first, 'Чай зелёный');

    // Пока форма ждёт ответа про дубли, кнопка «Сохранить» крутит индикатор:
    // `pumpAndSettle` такого не дожидается, поэтому кадры отсчитываем сами.
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Сохранить'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Сохранить'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Возможные дубли'), findsOneWidget);
    // Без выбора связывать не с чем: кнопка неактивна.
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Использовать существующий'),
    );
    expect(button.onPressed, isNull);

    await tester.tap(find.widgetWithText(RadioListTile<String>, 'Липтон'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(
      find.widgetWithText(FilledButton, 'Использовать существующий'),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final saved = await entries.entryViews(me.id);
    expect(saved.single.objectId, lipton.id);
    expect(saved.single.objectId, isNot(ahmad.id));
  });
}
