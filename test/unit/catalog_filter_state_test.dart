import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/core/l10n/gen/app_localizations.dart';
import 'package:impressions/core/l10n/gen/app_localizations_ru.dart';
import 'package:impressions/features/catalog/catalog_providers.dart';
import 'package:impressions/features/collections/smart_collections.dart';

/// Отбор каталога: что он помнит о себе и как себя называет.
///
/// Отбор переживает перезапуск и становится живой подборкой — оба пути идут
/// через одну запись в JSON, и забытое в ней поле тихо теряется.
void main() {
  final AppLocalizations l10n = AppLocalizationsRu();

  test('«без заметки» переживает запись и чтение', () {
    const filter = CatalogState(withoutNote: true);

    final restored = CatalogState.fromJson(
      filter.toJson(),
      const CatalogState(),
    );

    expect(restored.withoutNote, isTrue);
  });

  test('«без заметки» включает кнопку сброса', () {
    expect(const CatalogState().hasFilters, isFalse);
    expect(const CatalogState(withoutNote: true).hasFilters, isTrue);
  });

  test('живая подборка называет «без заметки» среди условий', () {
    // Подборка, меняющаяся сама по себе и не говорящая почему, читается как
    // сбой: условие обязано быть названо словами.
    final words = smartFilterWords(
      const CatalogState(withoutRating: true, withoutNote: true),
      l10n,
    );

    expect(words, [l10n.catalogWithoutRating, l10n.catalogWithoutNote]);
  });
}
