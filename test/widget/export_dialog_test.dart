import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/services/file_delivery_service.dart';
import 'package:impressions/features/categories/category_providers.dart';
import 'package:impressions/features/collections/collection_providers.dart';
import 'package:impressions/features/exchange/export_dialog.dart';

import '../db/test_db.dart';
import 'screens_test.dart' show app;

/// Выдача файла без настоящего диска: в тесте виджетов ввод-вывод не
/// завершается — время в нём поддельное.
class _Delivery extends FileDeliveryService {
  const _Delivery(this._result);

  final FileDelivery _result;

  @override
  Future<FileDelivery> deliver({
    required String fileName,
    required String typeLabel,
    required String extension,
    required Future<void> Function(File file) write,
  }) async => _result;
}

/// Так ведёт себя `getSaveLocation` на Android: реализации нет.
class _Broken extends FileDeliveryService {
  const _Broken();

  @override
  Future<FileDelivery> deliver({
    required String fileName,
    required String typeLabel,
    required String extension,
    required Future<void> Function(File file) write,
  }) async =>
      throw UnimplementedError('getSavePath() has not been implemented.');
}

void main() {
  late AppDatabase db;
  late ProfileRow profile;

  setUp(() async {
    db = openTestDb();
    profile = await ProfileRepository(db).createOwnProfile(firstName: 'Аня');
  });

  tearDown(() => db.close());

  Future<void> exportReadable(
    WidgetTester tester,
    FileDeliveryService delivery,
  ) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          fileDeliveryProvider.overrideWithValue(delivery),
          // Подписки на базу оставляют после себя таймеры, которых тест не
          // дожидается: выбор объёма экспорта здесь ни при чём.
          allCategoriesProvider.overrideWith((ref) async => []),
          collectionsProvider.overrideWith((ref) async => []),
        ],
        child: app(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => ExportDialog.show(context, profile),
              child: const Text('открыть'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('открыть'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Для чтения'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Таблица CSV'));
    await tester.pumpAndSettle();
  }

  testWidgets('файл, ушедший в «Поделиться», закрывает диалог', (tester) async {
    await exportReadable(tester, const _Delivery(FileDelivery.shared()));

    expect(find.text('Файл готов и передан выбранному приложению'), findsOne);
    expect(find.byType(ExportDialog), findsNothing);
  });

  testWidgets('отказ сохранять оставляет диалог открытым', (tester) async {
    await exportReadable(tester, const _Delivery(FileDelivery.cancelled()));

    expect(find.text('Сохранение отменено'), findsOne);
    expect(find.byType(ExportDialog), findsOne);
  });

  testWidgets('поломка выгрузки видна человеку', (tester) async {
    // Раньше исключение никто не ловил и на телефоне не происходило ничего.
    await exportReadable(tester, const _Broken());

    expect(find.textContaining('Не удалось сохранить'), findsOne);
    expect(find.byType(ExportDialog), findsOne);
  });
}
