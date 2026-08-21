import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/models/entry_view.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/design_system/design_system.dart';
import 'package:impressions/features/archive/archive_screen.dart';
import 'package:impressions/features/home/home_providers.dart';
import 'package:impressions/features/home/home_screen.dart';
import 'package:impressions/features/wishlist/wishlist_screen.dart';

import '../db/test_db.dart';
import 'screens_test.dart' show app;

/// Отказ базы не выдаётся за отсутствие записей.
///
/// До 1.21.0 экраны читали провайдеры как `.value ?? const []`: главная на
/// сбое чтения предлагала завести первую запись человеку, у которого их
/// тысяча, а архив и «Хочу попробовать» сообщали, что там пусто.
void main() {
  late AppDatabase db;
  late ProfileRow me;

  setUp(() async {
    db = openTestDb();
    me = await ProfileRepository(db).createOwnProfile(firstName: 'Я');
  });

  tearDown(() => db.close());

  /// Список подмен собирается на месте вызова: его тип Riverpod 3 наружу не
  /// выводит, и назвать его в сигнатуре нечем.
  Future<void> pump(
    WidgetTester tester,
    Widget screen,
    ProviderContainer container,
  ) async {
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: app(screen)),
    );
    await tester.pumpAndSettle();
  }

  Future<List<EntryView>> broken(Ref ref) =>
      Future<List<EntryView>>.error(StateError('база недоступна'));

  testWidgets('главная показывает сбой, а не «записей пока нет»', (
    tester,
  ) async {
    await pump(
      tester,
      const HomeScreen(),
      ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activeProfileProvider.overrideWithValue(me),
          recentEntriesProvider.overrideWith(broken),
        ],
      ),
    );

    expect(find.byType(ErrorState), findsOneWidget);
    expect(
      find.byType(EmptyState),
      findsNothing,
      reason: 'предлагать завести первую запись при сбое чтения — неправда',
    );
    expect(find.text('Повторить'), findsOneWidget);
  });

  testWidgets('«Хочу попробовать» не выдаёт сбой за пустой список', (
    tester,
  ) async {
    await pump(
      tester,
      const WishlistScreen(),
      ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activeProfileProvider.overrideWithValue(me),
          wishlistProvider.overrideWith(broken),
        ],
      ),
    );

    expect(find.byType(ErrorState), findsOneWidget);
    expect(find.byType(EmptyState), findsNothing);
  });

  testWidgets('архив не выдаёт сбой за пустоту', (tester) async {
    await pump(
      tester,
      const ArchiveScreen(),
      ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activeProfileProvider.overrideWithValue(me),
          archivedEntriesProvider.overrideWith(broken),
        ],
      ),
    );

    expect(find.byType(ErrorState), findsOneWidget);
    expect(find.byType(EmptyState), findsNothing);
  });

  testWidgets('«Повторить» перечитывает то, что не прочиталось', (
    tester,
  ) async {
    var attempts = 0;
    await pump(
      tester,
      const WishlistScreen(),
      ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activeProfileProvider.overrideWithValue(me),
          wishlistProvider.overrideWith((ref) {
            attempts++;
            return Future<List<EntryView>>.error(StateError('база недоступна'));
          }),
        ],
      ),
    );
    expect(attempts, 1);

    await tester.tap(find.text('Повторить'));
    await tester.pumpAndSettle();
    expect(attempts, 2, reason: 'из ошибки должен быть выход, кроме ухода');
  });
}
