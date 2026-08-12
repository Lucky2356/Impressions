import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/locale_controller.dart';
import 'package:impressions/core/l10n/gen/app_localizations.dart';

/// Переводы интерфейса: полнота, совпадение подстановок и выбор языка.
///
/// Тест нужен не ради сегодняшнего состояния, а ради завтрашнего: строка,
/// добавленная в русский файл и забытая в английском, показалась бы
/// англоязычному человеку по-русски — и заметить это было бы некому.
void main() {
  Map<String, Object?> load(String locale) {
    final file = File('lib/core/l10n/arb/app_$locale.arb');
    return jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
  }

  /// Ключи сообщений без служебных: `@@locale` и описания вида `@ключ`.
  Set<String> keysOf(Map<String, Object?> arb) =>
      arb.keys.where((k) => !k.startsWith('@')).toSet();

  /// Подстановки, объявленные для ключа в шаблоне.
  ///
  /// Берём их из описания `@ключ`, а не из текста: в тексте попадаются ветки
  /// множественного числа (`=0{nothing}`), неотличимые от подстановки на вид.
  Set<String> declaredPlaceholders(Map<String, Object?> arb, String key) {
    final meta = arb['@$key'];
    if (meta is! Map) return const {};
    final placeholders = meta['placeholders'];
    if (placeholders is! Map) return const {};
    return placeholders.keys.cast<String>().toSet();
  }

  late Map<String, Object?> ru;
  late Map<String, Object?> en;

  setUp(() {
    ru = load('ru');
    en = load('en');
  });

  test('в английском файле есть все строки русского', () {
    expect(keysOf(ru).difference(keysOf(en)), isEmpty);
  });

  test('в английском файле нет строк, которых нет в русском', () {
    expect(keysOf(en).difference(keysOf(ru)), isEmpty);
  });

  test('перевод использует все подстановки строки', () {
    for (final key in keysOf(ru)) {
      final target = en[key]! as String;
      for (final name in declaredPlaceholders(ru, key)) {
        expect(
          target.contains('{$name}') || target.contains('{$name,'),
          isTrue,
          reason: 'В переводе строки $key потеряна подстановка {$name}',
        );
      }
    }
  });

  test('ни одна строка не осталась непереведённой', () {
    // Совпадение допустимо только там, где перевод и не нужен: названия
    // языков, разделители, имена собственные.
    const sameOnPurpose = {
      'settingsLanguageRu',
      'settingsLanguageEn',
      'breadcrumbObjectSeparator',
      'a11yCategoryShelf',
      'a11ySummaryItem',
      'exportCsv',
      'exportMarkdown',
    };
    final cyrillic = RegExp(r'[а-яё]', caseSensitive: false);

    for (final key in keysOf(en)) {
      if (sameOnPurpose.contains(key)) continue;
      expect(
        cyrillic.hasMatch(en[key]! as String),
        isFalse,
        reason: 'Строка $key осталась на русском',
      );
    }
  });

  test('английский перевод загружается и отдаёт строки', () async {
    final strings = await AppLocalizations.delegate.load(const Locale('en'));

    expect(strings.navCatalog, 'Catalogue');
    expect(strings.catalogFound(1), '1 entry found');
    expect(strings.catalogFound(5), '5 entries found');
  });

  group('выбор языка', () {
    test('известный язык распознаётся', () {
      expect(LocaleController.parse('ru'), const Locale('ru'));
      expect(LocaleController.parse('en'), const Locale('en'));
    });

    test('пустое значение означает язык системы', () {
      expect(LocaleController.parse(''), isNull);
      expect(LocaleController.parse(null), isNull);
    });

    test('язык без перевода не выбирается', () {
      // Так выглядит откат на версию, где перевода ещё нет.
      expect(LocaleController.parse('fr'), isNull);
    });
  });
}
