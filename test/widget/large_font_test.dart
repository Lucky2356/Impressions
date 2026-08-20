import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/app/navigation.dart';
import 'package:impressions/core/l10n/gen/app_localizations.dart';
import 'package:impressions/core/domain/entry_status.dart';
import 'package:impressions/core/domain/relation.dart';
import 'package:impressions/core/theme/app_theme.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/category_repository.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/services/seed_service.dart';
import 'package:impressions/features/entry/entry_detail_sheet.dart';
import 'package:impressions/features/quick_add/quick_add_sheet.dart';
import 'package:impressions/features/shell/app_shell.dart';

import '../db/test_db.dart';

/// Крупный системный шрифт не ломает ни один раздел.
///
/// Проверка проходит по всем разделам подряд, а не по одному подозрительному:
/// подобранные вручную высоты и таблетки, сжатые под содержимое, заводятся
/// поодиночке в разных местах, и находить их по жалобе — значит находить по
/// одной. «Огромный» шрифт Android — это примерно 1.6 к обычному.
void main() {
  late AppDatabase db;
  late ProfileRow me;
  late ProviderContainer container;

  setUp(() async {
    db = openTestDb();
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Александр');
    // Разделы проверяются с содержимым, а не пустыми: пустое состояние —
    // самая короткая из возможных страниц, и на ней не переполняется ничего.
    await SeedService(db).seedForProfile(me.id);

    final entries = EntryRepository(db);
    final type = (await entries.objectTypes(me.id)).first;
    final category = (await CategoryRepository(db).allOf(me.id)).first;
    for (var i = 0; i < 5; i++) {
      final object = await entries.createObject(
        typeId: type.id,
        title: 'Довольно длинное название впечатления номер $i',
      );
      await entries.createEntry(
        profileId: me.id,
        objectId: object.id,
        primaryCategoryId: category.id,
        rating: 7,
        relation: Relation.like.name,
        status: EntryStatus.inProgress,
      );
    }
  });

  tearDown(() => db.close());

  Future<void> pumpShell(
    WidgetTester tester,
    double textScale, {
    Size size = const Size(400, 860),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: const AppShell(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('в каждом разделе есть настоящая прокрутка', (tester) async {
    await pumpShell(tester, 1.0);

    for (final section in NavIds.all) {
      container.read(navProvider.notifier).go(section);
      await tester.pumpAndSettle();

      // Вложенные сетки — тоже Scrollable, но с выключенной физикой: они
      // рассчитывают на чужую прокрутку. Раздел, где таких только и есть,
      // обрезан по высоте экрана — ровно этим болели корневые полки категорий.
      // Смотрим на физику, а не на то, набралось ли уже содержимое: раздел с
      // парой записей помещается в экран и прокручиваться ему пока нечем.
      final scrollable = tester
          .stateList<ScrollableState>(find.byType(Scrollable))
          .where((s) => s.position.physics is! NeverScrollableScrollPhysics);
      expect(
        scrollable,
        isNotEmpty,
        reason: 'раздел «$section» ничем не прокручивается',
      );
    }
  });

  testWidgets('разделы не переполняются на широком экране', (tester) async {
    // Раскладка Windows — другая ветка кода: боковая панель, две колонки в
    // категориях и настройках. Проверяли её только глазами.
    await pumpShell(tester, 1.0, size: const Size(1400, 900));

    for (final section in NavIds.all) {
      container.read(navProvider.notifier).go(section);
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'раздел «$section» на широком экране',
      );
    }
  });

  for (final scale in [1.0, 1.6]) {
    testWidgets('листы не переполняются при масштабе шрифта $scale', (
      tester,
    ) async {
      // Проверка разделов до листов не доходит: они живут своими маршрутами,
      // а именно в них самая свежая вёрстка — карточка записи, форма
      // добавления, повторные впечатления.
      await pumpShell(tester, scale);

      final entryId = (await db.select(db.profileEntries).get()).first.id;
      await EntryRepository(db).addVisit(
        entryId: entryId,
        occurredAt: DateTime(2026, 3, 1),
        rating: 7,
        note: 'Во второй раз показалось лучше',
      );

      final context = tester.element(find.byType(AppShell));
      unawaited(EntryDetailSheet.show(context, entryId));
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'карточка записи при масштабе шрифта $scale',
      );

      await tester.tap(find.byIcon(Icons.close_rounded).first);
      await tester.pumpAndSettle();

      unawaited(QuickAddSheet.show(context));
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'форма добавления при масштабе шрифта $scale',
      );
    });

    testWidgets('разделы не переполняются при масштабе шрифта $scale', (
      tester,
    ) async {
      await pumpShell(tester, scale);

      for (final section in NavIds.all) {
        container.read(navProvider.notifier).go(section);
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: 'раздел «$section» при масштабе шрифта $scale',
        );
      }
    });
  }
}
