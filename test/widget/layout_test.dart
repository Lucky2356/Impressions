import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/app/navigation.dart';
import 'package:impressions/app/ui_scale_controller.dart';
import 'package:impressions/core/domain/relation.dart';
import 'package:impressions/core/l10n/gen/app_localizations.dart';
import 'package:impressions/core/theme/app_dimens.dart';
import 'package:impressions/core/theme/app_theme.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/category_repository.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/repositories/settings_repository.dart';
import 'package:impressions/data/services/seed_service.dart';
import 'package:impressions/design_system/design_system.dart';
import 'package:impressions/features/shell/app_shell.dart';

import '../db/test_db.dart';

/// Приложение открывается одинаково на любом экране.
///
/// Проверка идёт по ширинам, а не по одному подозрительному размеру: до 1.21.0
/// раскладку покрывали ровно два — 400×860 и 1400×900, — и всё, что между 640
/// и 1200, а также вся ветка 4K не проверялись вовсе.
void main() {
  late AppDatabase db;
  late ProfileRow me;
  late ProviderContainer container;

  /// Ширины, на которых приложение действительно открывают.
  ///
  /// 360 — телефон; 640 — граница панели значков; 900 — половина Full HD и
  /// планшет; 1200 — граница подписей; 1600 — Full HD в полный экран;
  /// 2560 — 4K при 150 % масштабе Windows; 3840 — он же при 100 %.
  const widths = [360.0, 640.0, 900.0, 1200.0, 1600.0, 2560.0, 3840.0];

  setUp(() async {
    db = openTestDb();
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Александр');
    await SeedService(db).seedForProfile(me.id);

    final entries = EntryRepository(db);
    final type = (await entries.objectTypes(me.id)).first;
    final category = (await CategoryRepository(db).allOf(me.id)).first;
    // Записей заметно больше, чем колонок на 4K: иначе «сетка занимает окно»
    // не отличить от «записей просто не хватило на второй ряд».
    for (var i = 0; i < 40; i++) {
      final object = await entries.createObject(
        typeId: type.id,
        title: 'Впечатление номер $i',
      );
      await entries.createEntry(
        profileId: me.id,
        objectId: object.id,
        primaryCategoryId: category.id,
        rating: 7,
        relation: Relation.like.name,
      );
    }
  });

  tearDown(() => db.close());

  Future<void> pumpShell(
    WidgetTester tester, {
    required double width,
    double height = 900,
    UiScale scale = UiScale.auto,
  }) async {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Масштаб кладём в базу, а не в провайдер: контроллер читает настройку
    // сам, и подменённое мимо базы значение он бы затёр восстановлением.
    await SettingsRepository(db).set(SettingKeys.uiScale, scale.name);

    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        activeProfileProvider.overrideWithValue(me),
        profilesProvider.overrideWith((ref) => Stream.value([me])),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ru'),
          theme: AppTheme.light(),
          // Та же обёртка, что и в самом приложении: если собрать её здесь
          // своими руками, проверка перестанет замечать перестановку
          // множителя и предела местами.
          builder: appTextScaleBuilder,
          home: const AppShell(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> go(WidgetTester tester, String section) async {
    container.read(navProvider.notifier).go(section);
    await tester.pumpAndSettle();
  }

  for (final width in widths) {
    testWidgets('ни один раздел не переполняется при ширине $width', (
      tester,
    ) async {
      await pumpShell(tester, width: width);
      for (final section in NavIds.all) {
        await go(tester, section);
        expect(
          tester.takeException(),
          isNull,
          reason: 'раздел «$section» при ширине $width',
        );
      }
    });

    testWidgets('навигация соответствует ширине $width', (tester) async {
      await pumpShell(tester, width: width);

      if (width < AppDimens.breakpointCompact) {
        expect(find.byType(NavSidebar), findsNothing);
        expect(find.byType(NavigationBar), findsOneWidget);
        return;
      }

      expect(
        find.byType(NavigationBar),
        findsNothing,
        reason:
            'на $width точек нижняя панель прячет восемь разделов из '
            'двенадцати, хотя места хватает на все',
      );
      final sidebar = tester.widget<NavSidebar>(find.byType(NavSidebar));
      expect(
        sidebar.collapsed,
        width < AppDimens.breakpointExpanded,
        reason: 'подписи в панели появляются с 1200 точек',
      );
    });
  }

  testWidgets('сетки занимают окно, а текст остаётся колонкой', (tester) async {
    // 4K при 100 %: на такой ширине разница между «во всю ширину» и «колонкой»
    // видна лучше всего — до 1.21.0 каталог здесь показывал ровно столько же
    // карточек, сколько на пятнадцатидюймовом ноутбуке.
    await pumpShell(tester, width: 3840);

    await go(tester, NavIds.catalog);
    expect(
      find.byKey(contentColumnKey),
      findsNothing,
      reason: 'каталог — сетка, он занимает всё окно',
    );
    final grid = tester.getSize(
      find.byKey(const PageStorageKey('catalog-grid')),
    );
    expect(
      grid.width,
      greaterThan(AppDimens.readingWidth * 2),
      reason: 'сетка каталога должна расти вместе с окном',
    );

    await go(tester, NavIds.insights);
    final column = tester.getSize(find.byKey(contentColumnKey).first);
    expect(
      column.width,
      lessThan(grid.width / 2),
      reason: 'сводку читают строками — она остаётся колонкой',
    );
    // Колонка растёт только вместе с кеглем, и предел кегля — 1.6.
    expect(column.width, lessThanOrEqualTo(AppDimens.readingWidth * 1.6 + 1));
  });

  testWidgets('на 4K интерфейс сам становится крупнее', (tester) async {
    await pumpShell(tester, width: 1600);
    final onFullHd = tester.firstWidget<Text>(find.text('Главная')).style!;

    await pumpShell(tester, width: 3840);
    final on4k = tester.firstWidget<Text>(find.text('Главная')).style!;

    expect(
      on4k.fontSize,
      onFullHd.fontSize,
      reason: 'кегль в точках тот же — крупнее его делает textScaler',
    );
    expect(
      tester.binding.platformDispatcher.textScaleFactor,
      1.0,
      reason: 'система шрифт не увеличивала — весь рост от масштаба окна',
    );
    final scaler = MediaQuery.textScalerOf(
      tester.element(find.byType(AppShell)),
    );
    expect(
      scaler.scale(10),
      greaterThan(10),
      reason: 'на 4K поле scale наконец работает, а не лежит мёртвым',
    );
  });

  testWidgets('ручной масштаб перебивает автоматический', (tester) async {
    await pumpShell(tester, width: 3840, scale: UiScale.s100);
    final scaler = MediaQuery.textScalerOf(
      tester.element(find.byType(AppShell)),
    );
    expect(
      scaler.scale(10),
      10,
      reason: 'выбрали 100 % — значит 100 %, даже на 4K',
    );
  });

  testWidgets('масштаб интерфейса не пробивает общий предел', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpShell(tester, width: 1600, scale: UiScale.s125);
    // Множитель стоит снаружи зажима: 1.5 × 1.25 = 1.875, а такой размер не
    // выдержит ни одна плотная раскладка. Последнее слово за пределом.
    final scaler = MediaQuery.textScalerOf(
      tester.element(find.byType(AppShell)),
    );
    expect(scaler.scale(10), lessThanOrEqualTo(15.0));
  });

  testWidgets('колонка для чтения растёт вместе с кеглем', (tester) async {
    await pumpShell(tester, width: 3840, scale: UiScale.s100);
    await go(tester, NavIds.insights);
    final plain = tester.getSize(find.byKey(contentColumnKey).first).width;

    await pumpShell(tester, width: 3840, scale: UiScale.s125);
    await go(tester, NavIds.insights);
    final scaled = tester.getSize(find.byKey(contentColumnKey).first).width;

    expect(
      scaled,
      greaterThan(plain),
      reason: 'иначе крупный шрифт помещает в строку меньше слов, чем мелкий',
    );
  });
}
