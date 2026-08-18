import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/app/navigation.dart';
import 'package:impressions/core/l10n/gen/app_localizations.dart';
import 'package:impressions/core/theme/app_theme.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/entry_repository.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/services/seed_service.dart';
import 'package:impressions/features/entry/entry_card_data.dart';
import 'package:impressions/features/shell/app_shell.dart';

import '../db/test_db.dart';

/// Перелёт обложки из списка в карточку записи.
///
/// Метка обязана быть единственной на экране: две одинаковые роняют кадр. На
/// главной одна и та же запись попадает и в «Продолжить начатое», и в
/// «Недавнее» — поэтому там метки нет, и эта проверка следит, чтобы её не
/// поставили по невнимательности.
void main() {
  late AppDatabase db;
  late ProfileRow me;
  late ProviderContainer container;

  setUp(() async {
    db = openTestDb();
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
    await SeedService(db).seedForProfile(me.id);

    final entries = EntryRepository(db);
    final type = (await entries.objectTypes(me.id)).first;
    final object = await entries.createObject(
      typeId: type.id,
      title: 'Твин Пикс',
    );
    await entries.createEntry(profileId: me.id, objectId: object.id, rating: 8);
  });

  tearDown(() => db.close());

  Future<void> pumpShell(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 860);
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
          home: const AppShell(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Сколько меток перелёта на экране и не повторяются ли они.
  List<Object> heroTags(WidgetTester tester) =>
      tester.widgetList<Hero>(find.byType(Hero)).map((h) => h.tag).toList();

  testWidgets('в каталоге у записи есть метка перелёта', (tester) async {
    await pumpShell(tester);
    container.read(navProvider.notifier).go(NavIds.catalog);
    await tester.pumpAndSettle();

    expect(heroTags(tester), contains(entryHeroTag(await _entryId(db))));
  });

  testWidgets('на главной меток нет — там запись встречается дважды', (
    tester,
  ) async {
    await pumpShell(tester);

    final tags = heroTags(tester);
    expect(
      tags.where((t) => t.toString().startsWith('entry-cover-')),
      isEmpty,
      reason: 'на главной одна запись попадает сразу в несколько блоков',
    );
  });

  testWidgets('метки на одном экране не повторяются', (tester) async {
    await pumpShell(tester);

    for (final section in NavIds.all) {
      container.read(navProvider.notifier).go(section);
      await tester.pumpAndSettle();

      final tags = heroTags(tester);
      expect(
        tags.length,
        tags.toSet().length,
        reason: 'раздел «$section»: две одинаковые метки роняют кадр',
      );
      expect(tester.takeException(), isNull, reason: 'раздел «$section»');
    }
  });
}

Future<String> _entryId(AppDatabase db) async {
  final rows = await db.select(db.profileEntries).get();
  return rows.single.id;
}
