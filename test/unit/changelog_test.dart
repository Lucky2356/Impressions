import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/services/changelog_service.dart';

/// Разбор `CHANGELOG.md` для окна «Что нового».
///
/// Приложение обновляет себя само, а что изменилось, человек нигде не узнавал:
/// список правок жил только на GitHub.
void main() {
  const markdown = '''
# История изменений

Формат — по мотивам Keep a Changelog.

## [1.12.0] — 2026-08-11

Десять мест, где приложение требовало лишних движений.

### Исправлено

- **Архивирование не спрашивает «точно?»** — рядом сразу «Вернуть».

## [1.11.0] — 2026-08-02

Восемь мест, где данные уходили не туда.

- **Копия выходит из телефона.**
''';

  test('по версии берётся её раздел', () {
    final entry = ChangelogService.sectionOf(markdown, '1.12.0')!;

    expect(entry.version, '1.12.0');
    expect(entry.body, contains('Десять мест'));
    expect(entry.body, contains('Архивирование не спрашивает'));
    // Соседний раздел не прилипает: рассказ про 1.11.0 человек уже видел.
    expect(entry.body, isNot(contains('Восемь мест')));
  });

  test('последний раздел читается до конца файла', () {
    final entry = ChangelogService.sectionOf(markdown, '1.11.0')!;

    expect(entry.body, contains('Копия выходит из телефона'));
  });

  test('для неизвестной версии возвращается null', () {
    // Сборка из ветки или забытая запись в файле: показывать нечего, и пустое
    // окно тут хуже, чем ничего.
    expect(ChangelogService.sectionOf(markdown, '9.9.9'), isNull);
  });

  test('пустой раздел не считается разделом', () {
    const empty =
        '## [2.0.0] — 2026-09-01\n\n## [1.9.0] — 2026-08-01\n\nТекст.';

    expect(ChangelogService.sectionOf(empty, '2.0.0'), isNull);
  });

  test('нечитаемый файл не роняет показ', () async {
    const service = ChangelogService(load: _throwing);

    expect(await service.forVersion('1.12.0'), isNull);
  });

  test('в поставляемой истории есть раздел текущей версии', () {
    // В сборку едет не весь CHANGELOG.md, а свежая часть, собранная
    // scripts/changelog_asset.py. Пересобрать её после правки истории легко
    // забыть, и тогда окно «Что нового» после обновления молчит — а заметить
    // это можно только обновившись.
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(
      r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)',
      multiLine: true,
    ).firstMatch(pubspec)!.group(1)!;

    final full = File('CHANGELOG.md').readAsStringSync();
    final shipped = File(ChangelogService.assetPath).readAsStringSync();

    expect(
      ChangelogService.sectionOf(shipped, version),
      isNotNull,
      reason:
          'нет раздела [$version] в ${ChangelogService.assetPath} — '
          'пересоберите: python3 scripts/changelog_asset.py',
    );
    expect(
      ChangelogService.sectionOf(full, version),
      isNotNull,
      reason: 'нет раздела [$version] в CHANGELOG.md',
    );
    // Свежая часть не должна незаметно снова стать полной историей: ради
    // этого всё и затевалось.
    expect(shipped.length, lessThan(full.length));
  });
}

Future<String> _throwing() => Future.error(Exception('нет файла'));
