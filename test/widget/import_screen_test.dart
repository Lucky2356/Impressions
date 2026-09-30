import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/profile_repository.dart';
import 'package:impressions/data/services/export_service.dart';
import 'package:impressions/features/exchange/import_screen.dart';

import '../db/test_db.dart';
import 'screens_test.dart' show app;

/// Провайдер присланного файла с заранее положенным путём.
///
/// Экран забирает файл в первом же кадре, поэтому подставить путь после
/// построения дерева уже поздно.
class _Pending extends PendingImportFile {
  _Pending(this.path);

  final String? path;

  @override
  String? build() => path;
}

void main() {
  late Directory dir;
  late AppDatabase target;
  late File plain;
  late File broken;

  /// Настоящий файл обмена: профиль «Марина» из отдельной базы-источника.
  Future<File> exportProfile(String name, {String? password}) async {
    final source = openTestDb();
    final me = await ProfileRepository(
      source,
    ).createOwnProfile(firstName: name);
    final exported = await ExportService(
      source,
    ).export(me.id, ExportOptions(password: password));
    await source.close();

    final file = File('${dir.path}/$name${password ?? ''}.impressions');
    await file.writeAsBytes(Uint8List.fromList(exported.bytes));
    return file;
  }

  // Диск, подпись и экспорт — только здесь: в setUp время настоящее, а в теле
  // testWidgets оно поддельное, и настоящий ввод-вывод в нём не доезжает
  // вовсе — тест не падает, а висит.
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('impressions-import');
    target = openTestDb();
    plain = await exportProfile('Марина');
    broken = File('${dir.path}/битый.impressions');
    await broken.writeAsBytes(List<int>.filled(64, 0));
  });

  tearDown(() async {
    await target.close();
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  /// Прогоняет разбор пакета.
  ///
  /// Чтение файла и проверка подписи — настоящий ввод-вывод: он доезжает
  /// только в окне [WidgetTester.runAsync]. Продолжение каждого ожидания при
  /// этом становится микрозадачей поддельной зоны, и запускает её именно
  /// `pump()`. Поэтому окна и кадры чередуются, а не идут одним куском.
  Future<void> settle(WidgetTester tester, {Finder? until}) async {
    for (var i = 0; i < 40; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 25)),
      );
      await tester.pump();
      if (until != null && until.evaluate().isNotEmpty) return;
    }
  }

  Future<void> openScreen(
    WidgetTester tester,
    String? pendingPath, {
    Widget? Function(WidgetRef ref)? watcher,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(target),
          pendingImportFileProvider.overrideWith(() => _Pending(pendingPath)),
        ],
        child: app(
          watcher == null
              ? const ImportScreen()
              : Consumer(builder: (_, ref, _) => watcher(ref)!),
        ),
      ),
    );
  }

  testWidgets('присланный файл разбирается сам', (tester) async {
    await openScreen(tester, plain.path);
    await settle(tester, until: find.text('Предварительный просмотр'));

    expect(find.text('Предварительный просмотр'), findsOneWidget);
    expect(find.text('Профиль: Марина'), findsOneWidget);
    expect(
      find.text('Импортировать'),
      findsOneWidget,
      reason: 'предпросмотр без кнопки применения — тупик',
    );
    expect(
      find.text('Импорт не выполнен'),
      findsNothing,
      reason: 'исправный файл — не повод для ошибки',
    );
  });

  testWidgets('незнакомый профиль отмечается как незнакомый', (tester) async {
    // Доверие профилю решает человек, и спросить его надо явно.
    await openScreen(tester, plain.path);
    await settle(tester, until: find.text('Предварительный просмотр'));

    expect(find.text('Новый профиль. Доверять этому профилю?'), findsOneWidget);
    expect(
      find.text('Профиль подтверждён, подпись файла корректна'),
      findsNothing,
    );
  });

  testWidgets('разобранный файл не разбирается второй раз', (tester) async {
    late WidgetRef captured;
    await openScreen(
      tester,
      plain.path,
      watcher: (ref) {
        captured = ref;
        return const ImportScreen();
      },
    );
    await settle(tester, until: find.text('Предварительный просмотр'));

    expect(
      captured.read(pendingImportFileProvider),
      isNull,
      reason: 'иначе тот же файл разберётся снова при следующем открытии',
    );
  });

  testWidgets('несуществующий путь молча пропускается', (tester) async {
    await openScreen(tester, '${dir.path}/нет-такого.impressions');
    await settle(tester);

    expect(find.text('Импорт не выполнен'), findsNothing);
    expect(find.text('Предварительный просмотр'), findsNothing);
    expect(
      find.text('Выбрать файл'),
      findsOneWidget,
      reason: 'экран остаётся рабочим: файл можно выбрать руками',
    );
  });

  testWidgets('битый файл показывает ошибку, а не падает', (tester) async {
    await openScreen(tester, broken.path);
    await settle(tester, until: find.text('Импорт не выполнен'));

    expect(find.text('Импорт не выполнен'), findsOneWidget);
    expect(find.text('Предварительный просмотр'), findsNothing);
  });
}
