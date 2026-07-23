import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Поиск сведений о товаре по штрихкоду.
///
/// Это единственная часть приложения, которая обращается в сеть, и только по
/// явному действию пользователя (сканирование или ввод кода) либо по включённому
/// вручную обновлению. Никакой телеметрии не отправляется: наружу уходит только
/// сам штрихкод. Источники опрашиваются по очереди, первый удачный ответ
/// дополняется полями из следующих — так одна база компенсирует пробелы другой.

/// Сведения о товаре, собранные из внешних источников.
class ProductInfo {
  const ProductInfo({
    required this.barcode,
    this.title,
    this.brand,
    this.quantity,
    this.categories = const [],
    this.imageUrl,
    this.country,
    this.source,
  });

  final String barcode;
  final String? title;
  final String? brand;

  /// Фасовка: «400 г», «1 л».
  final String? quantity;
  final List<String> categories;
  final String? imageUrl;
  final String? country;

  /// Название источника, откуда получены данные.
  final String? source;

  bool get isEmpty => (title == null || title!.trim().isEmpty) && brand == null;

  /// Дополняет пустые поля значениями из [other], не затирая заполненные.
  ProductInfo mergeMissing(ProductInfo other) {
    String? pick(String? a, String? b) =>
        (a != null && a.trim().isNotEmpty) ? a : b;
    return ProductInfo(
      barcode: barcode,
      title: pick(title, other.title),
      brand: pick(brand, other.brand),
      quantity: pick(quantity, other.quantity),
      categories: categories.isNotEmpty ? categories : other.categories,
      imageUrl: pick(imageUrl, other.imageUrl),
      country: pick(country, other.country),
      source: source ?? other.source,
    );
  }

  /// Полное название для карточки: бренд + наименование + фасовка.
  String get displayTitle {
    final parts = <String>[];
    if (brand != null && brand!.trim().isNotEmpty) parts.add(brand!.trim());
    if (title != null && title!.trim().isNotEmpty) {
      final t = title!.trim();
      // Не дублируем бренд, если он уже входит в название.
      if (parts.isEmpty ||
          !t.toLowerCase().contains(parts.first.toLowerCase())) {
        parts.add(t);
      } else {
        parts
          ..clear()
          ..add(t);
      }
    }
    if (quantity != null && quantity!.trim().isNotEmpty) {
      parts.add(quantity!.trim());
    }
    return parts.join(', ');
  }
}

/// Описание одного источника данных.
class ProductSource {
  const ProductSource({
    required this.id,
    required this.title,
    required this.urlTemplate,
    required this.parser,
    this.enabledByDefault = true,
  });

  final String id;
  final String title;

  /// Шаблон адреса; `{code}` заменяется на штрихкод.
  final String urlTemplate;

  /// Разбор ответа в [ProductInfo]; возвращает null, если товар не найден.
  final ProductInfo? Function(String body, String barcode) parser;

  final bool enabledByDefault;

  Uri uriFor(String code) =>
      Uri.parse(urlTemplate.replaceAll('{code}', Uri.encodeComponent(code)));
}

/// Разбор ответов семейства Open Food Facts (в том числе Beauty/Pet/Products).
///
/// У этих баз лучшее покрытие товаров, продающихся в России: названия часто
/// заполнены по-русски, поэтому русские поля берутся первыми.
ProductInfo? _parseOpenFacts(String body, String barcode, String source) {
  final json = jsonDecode(body);
  if (json is! Map) return null;
  if (json['status'] != 1) return null;
  final p = json['product'];
  if (p is! Map) return null;

  String? str(String key) {
    final v = p[key];
    if (v is String && v.trim().isNotEmpty) return v.trim();
    return null;
  }

  final title =
      str('product_name_ru') ??
      str('product_name') ??
      str('generic_name_ru') ??
      str('generic_name') ??
      str('abbreviated_product_name');

  final categoriesRaw = str('categories') ?? '';
  final categories = categoriesRaw
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty && !e.contains(':'))
      .toList();

  final info = ProductInfo(
    barcode: barcode,
    title: title,
    brand: str('brands'),
    quantity: str('quantity'),
    categories: categories,
    imageUrl: str('image_front_url') ?? str('image_url'),
    country: str('countries'),
    source: source,
  );
  return info.isEmpty ? null : info;
}

/// Разбор ответа UPCitemdb (пробный доступ без ключа).
ProductInfo? _parseUpcItemDb(String body, String barcode) {
  final json = jsonDecode(body);
  if (json is! Map) return null;
  final items = json['items'];
  if (items is! List || items.isEmpty) return null;
  final it = items.first;
  if (it is! Map) return null;

  String? str(String key) {
    final v = it[key];
    if (v is String && v.trim().isNotEmpty) return v.trim();
    return null;
  }

  final images = it['images'];
  final info = ProductInfo(
    barcode: barcode,
    title: str('title'),
    brand: str('brand'),
    quantity: str('size'),
    categories: [if (str('category') != null) str('category')!],
    imageUrl: images is List && images.isNotEmpty && images.first is String
        ? images.first as String
        : null,
    source: 'UPCitemdb',
  );
  return info.isEmpty ? null : info;
}

/// Разбор ответа OpenGTINDB — простой текст вида `ключ=значение`.
ProductInfo? _parseOpenGtinDb(String body, String barcode) {
  final map = <String, String>{};
  for (final line in const LineSplitter().convert(body)) {
    final i = line.indexOf('=');
    if (i <= 0) continue;
    map[line.substring(0, i).trim()] = line.substring(i + 1).trim();
  }
  if (map['error'] != null && map['error'] != '0') return null;
  final name = map['name'];
  if (name == null || name.isEmpty) return null;
  return ProductInfo(
    barcode: barcode,
    title: name,
    brand: map['vendor'],
    quantity: map['detailname'],
    source: 'OpenGTINDB',
  );
}

/// Реестр источников. Порядок важен: сверху те, что лучше знают российский
/// ассортимент.
class ProductSources {
  const ProductSources._();

  static const openFoodFactsRu = ProductSource(
    id: 'off_ru',
    title: 'Open Food Facts (русская витрина)',
    urlTemplate:
        'https://ru.openfoodfacts.org/api/v2/product/{code}.json'
        '?fields=product_name,product_name_ru,generic_name,generic_name_ru,'
        'brands,quantity,categories,image_front_url,image_url,countries',
    parser: _offRu,
  );

  static const openFoodFacts = ProductSource(
    id: 'off',
    title: 'Open Food Facts',
    urlTemplate: 'https://world.openfoodfacts.org/api/v2/product/{code}.json',
    parser: _off,
  );

  static const openBeautyFacts = ProductSource(
    id: 'obf',
    title: 'Open Beauty Facts (косметика и бытовая химия)',
    urlTemplate: 'https://world.openbeautyfacts.org/api/v2/product/{code}.json',
    parser: _obf,
  );

  static const openPetFoodFacts = ProductSource(
    id: 'opff',
    title: 'Open Pet Food Facts (корма)',
    urlTemplate:
        'https://world.openpetfoodfacts.org/api/v2/product/{code}.json',
    parser: _opff,
  );

  static const openProductsFacts = ProductSource(
    id: 'opf',
    title: 'Open Products Facts (непродовольственные товары)',
    urlTemplate:
        'https://world.openproductsfacts.org/api/v2/product/{code}.json',
    parser: _opf,
  );

  static const upcItemDb = ProductSource(
    id: 'upcitemdb',
    title: 'UPCitemdb',
    urlTemplate: 'https://api.upcitemdb.com/prod/trial/lookup?upc={code}',
    parser: _parseUpcItemDb,
  );

  static const openGtinDb = ProductSource(
    id: 'opengtindb',
    title: 'OpenGTINDB',
    urlTemplate:
        'https://opengtindb.org/?ean={code}&cmd=query&queryid=400000000',
    parser: _parseOpenGtinDb,
    enabledByDefault: false,
  );

  static ProductInfo? _offRu(String b, String c) =>
      _parseOpenFacts(b, c, 'Open Food Facts');
  static ProductInfo? _off(String b, String c) =>
      _parseOpenFacts(b, c, 'Open Food Facts');
  static ProductInfo? _obf(String b, String c) =>
      _parseOpenFacts(b, c, 'Open Beauty Facts');
  static ProductInfo? _opff(String b, String c) =>
      _parseOpenFacts(b, c, 'Open Pet Food Facts');
  static ProductInfo? _opf(String b, String c) =>
      _parseOpenFacts(b, c, 'Open Products Facts');

  static const List<ProductSource> all = [
    openFoodFactsRu,
    openFoodFacts,
    openBeautyFacts,
    openPetFoodFacts,
    openProductsFacts,
    upcItemDb,
    openGtinDb,
  ];

  static ProductSource? byId(String id) {
    for (final s in all) {
      if (s.id == id) return s;
    }
    return null;
  }
}

/// Результат поиска: найденные сведения и отчёт по каждому источнику.
class LookupResult {
  const LookupResult({
    required this.info,
    required this.tried,
    this.errors = const {},
  });

  final ProductInfo? info;

  /// Идентификаторы опрошенных источников.
  final List<String> tried;

  /// Ошибки по источникам — показываются, чтобы «не найдено» отличалось
  /// от «нет сети».
  final Map<String, String> errors;

  bool get found => info != null;
}

/// Опрашивает источники и собирает сведения о товаре.
class ProductLookupService {
  ProductLookupService({http.Client? client, List<ProductSource>? sources})
    : _client = client ?? http.Client(),
      _sources = sources ?? ProductSources.all;

  final http.Client _client;
  final List<ProductSource> _sources;

  static const _timeout = Duration(seconds: 8);

  /// Проверяет, что строка похожа на товарный код (EAN-8/13, UPC-A, ITF-14).
  static bool isGtin(String value) {
    final digits = value.trim();
    if (!RegExp(r'^\d{8}$|^\d{12,14}$').hasMatch(digits)) return false;
    // Контрольная сумма GTIN: сумма с чередующимися весами кратна 10.
    final d = digits.split('').map(int.parse).toList();
    var sum = 0;
    for (var i = 0; i < d.length - 1; i++) {
      final fromRight = d.length - 2 - i;
      sum += d[i] * (fromRight.isEven ? 3 : 1);
    }
    final check = (10 - (sum % 10)) % 10;
    return check == d.last;
  }

  /// Российские товары начинаются с префикса 460–469 (GS1 Russia).
  static bool isRussianGtin(String code) {
    if (code.length < 3) return false;
    final prefix = int.tryParse(code.substring(0, 3));
    return prefix != null && prefix >= 460 && prefix <= 469;
  }

  /// Ищет товар, опрашивая включённые источники по очереди.
  ///
  /// Останавливается, как только собраны название и бренд; иначе продолжает,
  /// дополняя недостающие поля из следующих баз.
  Future<LookupResult> lookup(
    String barcode, {
    Set<String>? enabledSourceIds,
  }) async {
    final code = barcode.trim();
    final tried = <String>[];
    final errors = <String, String>{};
    ProductInfo? merged;

    for (final source in _sources) {
      final enabled =
          enabledSourceIds?.contains(source.id) ?? source.enabledByDefault;
      if (!enabled) continue;

      tried.add(source.id);
      try {
        final response = await _client
            .get(
              source.uriFor(code),
              headers: const {
                // Open Food Facts просит представляться; иначе ограничивает.
                'User-Agent': 'Impressions/1.1 (local personal library)',
                'Accept': 'application/json, text/plain',
              },
            )
            .timeout(_timeout);

        if (response.statusCode != 200) {
          errors[source.id] = 'HTTP ${response.statusCode}';
          continue;
        }
        final info = source.parser(utf8.decode(response.bodyBytes), code);
        if (info == null) continue;
        merged = merged == null ? info : merged.mergeMissing(info);
        if (merged.title != null && merged.brand != null) break;
      } on TimeoutException {
        errors[source.id] = 'превышено время ожидания';
      } catch (e) {
        errors[source.id] = e.toString();
      }
    }

    return LookupResult(info: merged, tried: tried, errors: errors);
  }

  void dispose() => _client.close();
}
