import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;

import '../../core/config/app_config.dart';
import '../db/database.dart';
import '../repositories/settings_repository.dart';
import 'product_lookup_service.dart';

/// Сведения о доступной версии приложения.
class AppRelease {
  const AppRelease({
    required this.version,
    required this.url,
    this.notes,
    this.installerUrl,
    this.installerSha256,
  });

  final String version;

  /// Страница выпуска.
  final String url;
  final String? notes;

  /// Прямая ссылка на установщик для текущей платформы.
  final String? installerUrl;

  /// Контрольная сумма файла, как её сообщает GitHub. Скачанный файл
  /// запускается, поэтому перед запуском сверяется с ней.
  final String? installerSha256;
}

/// Чем закончилась ручная проверка обновлений.
enum UpdateCheckStatus {
  /// Установлена последняя версия.
  upToDate,

  /// Есть новая версия.
  updateAvailable,

  /// Список выпусков недоступен: репозиторий приватный или его нет.
  unavailable,

  /// Не удалось проверить: нет сети или сервис ответил ошибкой.
  failed,
}

class UpdateCheck {
  const UpdateCheck(this.status, {this.release});
  final UpdateCheckStatus status;
  final AppRelease? release;
}

/// Итог фонового обновления сведений о товарах.
class ProductRefreshReport {
  const ProductRefreshReport({
    required this.checked,
    required this.updated,
    required this.titles,
  });

  final int checked;
  final int updated;

  /// Названия обновлённых товаров — для показа в уведомлении.
  final List<String> titles;
}

/// Проверка обновлений: и самого приложения, и сведений о товарах.
///
/// Обе проверки выключаемы и выполняются не чаще раза в сутки. Наружу уходят
/// только номер версии (в запросе к GitHub он не передаётся вовсе) и штрихкоды
/// товаров — ничего о содержимом записей.
class UpdateService {
  UpdateService(this.db, {http.Client? client, ProductLookupService? lookup})
    : _client = client ?? http.Client(),
      _lookup = lookup ?? ProductLookupService();

  final AppDatabase db;
  final http.Client _client;
  final ProductLookupService _lookup;

  SettingsRepository get _settings => SettingsRepository(db);

  static const _timeout = Duration(seconds: 10);
  static const _minInterval = Duration(hours: 20);

  // ---- Обновление приложения ----

  /// Чем закончилась проверка обновлений, запущенная вручную.
  ///
  /// Нужна, чтобы отличить «всё актуально» от «не смогли проверить». Молчаливое
  /// «актуально» при недоступном репозитории сбивало с толку: приватный
  /// репозиторий отвечает 404, а пользователь думал, что новых версий нет.
  Future<UpdateCheck> checkAppUpdateManually(String currentVersion) async {
    try {
      final response = await _client
          .get(
            Uri.parse(AppConfig.releasesApiUrl),
            headers: const {
              'Accept': 'application/vnd.github+json',
              'User-Agent': 'Impressions',
            },
          )
          .timeout(_timeout);

      // 404 у GitHub значит «репозиторий приватный или его нет»: без токена
      // релизы такого репозитория не видны.
      if (response.statusCode == 404) {
        return const UpdateCheck(UpdateCheckStatus.unavailable);
      }
      if (response.statusCode != 200) {
        return const UpdateCheck(UpdateCheckStatus.failed);
      }

      final release = await _parseRelease(
        response.bodyBytes,
        currentVersion: currentVersion,
      );
      return release == null
          ? const UpdateCheck(UpdateCheckStatus.upToDate)
          : UpdateCheck(UpdateCheckStatus.updateAvailable, release: release);
    } on Object {
      // Нет сети, таймаут, неверный ответ — «не смогли проверить».
      return const UpdateCheck(UpdateCheckStatus.failed);
    }
  }

  /// Сравнивает версии вида `1.2.3`. Возвращает true, если [candidate] новее.
  static bool isNewer(String candidate, String current) {
    List<int> parse(String v) => v
        .replaceAll(RegExp(r'^v'), '')
        .split(RegExp(r'[.+-]'))
        .map((p) => int.tryParse(p) ?? 0)
        .toList();
    final a = parse(candidate);
    final b = parse(current);
    for (var i = 0; i < 3; i++) {
      final x = i < a.length ? a[i] : 0;
      final y = i < b.length ? b[i] : 0;
      if (x != y) return x > y;
    }
    return false;
  }

  /// Запрашивает последний выпуск с GitHub. Возвращает null, если приложение
  /// уже актуально или проверка недоступна.
  Future<AppRelease?> checkAppUpdate({
    required String currentVersion,
    bool force = false,
  }) async {
    if (!await _settings.getBool(
      SettingKeys.appUpdateCheck,
      defaultValue: true,
    )) {
      return null;
    }
    if (!force && !await _dueFor(SettingKeys.appUpdateCheckedAt)) return null;

    try {
      final response = await _client
          .get(
            Uri.parse(AppConfig.releasesApiUrl),
            headers: const {
              'Accept': 'application/vnd.github+json',
              'User-Agent': 'Impressions',
            },
          )
          .timeout(_timeout);
      if (response.statusCode != 200) return null;

      return _parseRelease(response.bodyBytes, currentVersion: currentVersion);
    } catch (_) {
      return null;
    }
  }

  /// Разбирает ответ GitHub и запоминает найденный выпуск.
  Future<AppRelease?> _parseRelease(
    List<int> bytes, {
    required String currentVersion,
  }) async {
    final json = jsonDecode(utf8.decode(bytes));
    if (json is! Map) return null;
    final tag = json['tag_name'];
    if (tag is! String) return null;

    await _settings.set(
      SettingKeys.appUpdateCheckedAt,
      DateTime.now().toIso8601String(),
    );

    final version = tag.replaceAll(RegExp(r'^v'), '');
    if (!isNewer(version, currentVersion)) {
      await _settings.set(SettingKeys.appUpdateLatest, '');
      return null;
    }

    // Ищем файл для текущей платформы. Раньше искали только `.exe`, поэтому
    // на телефоне обновление предлагало скачать установщик для Windows.
    String? installer;
    String? digest;
    final assets = json['assets'];
    if (assets is List) {
      for (final a in assets) {
        if (a is! Map) continue;
        final name = a['name'];
        final url = a['browser_download_url'];
        if (name is String &&
            url is String &&
            name.toLowerCase().endsWith(installerExtension)) {
          installer = url;
          // GitHub отдаёт сумму в виде `sha256:<hex>`.
          final raw = a['digest'];
          if (raw is String && raw.startsWith('sha256:')) {
            digest = raw.substring('sha256:'.length).toLowerCase();
          }
          break;
        }
      }
    }

    final pageUrl = json['html_url'] as String? ?? AppConfig.releasesPageUrl;
    await _settings.set(SettingKeys.appUpdateLatest, version);
    await _settings.set(SettingKeys.appUpdateUrl, installer ?? pageUrl);

    return AppRelease(
      version: version,
      url: pageUrl,
      notes: json['body'] as String?,
      installerUrl: installer,
      installerSha256: digest,
    );
  }

  // ---- Скачивание и установка обновления ----

  /// Расширение файла обновления для текущей платформы.
  ///
  /// Windows ставится установщиком, Android — пакетом приложения. Файл выпуска
  /// выбирается по этому расширению, и по нему же проверяется ссылка.
  static String get installerExtension => Platform.isAndroid ? '.apk' : '.exe';

  /// Умеет ли платформа поставить обновление сама, без браузера.
  static bool get canInstallInPlace => Platform.isWindows || Platform.isAndroid;

  /// Ссылка ведёт на выпуск нашего же репозитория.
  ///
  /// Проверка обязательна: файл после скачивания запускается, поэтому адрес,
  /// пришедший из ответа сервера, нельзя принимать на веру.
  static bool isTrustedInstallerUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https') return false;
    const hosts = {
      'github.com',
      'objects.githubusercontent.com',
      'release-assets.githubusercontent.com',
    };
    if (!hosts.contains(uri.host)) return false;
    // Только файл для своей платформы: подсунутый .exe на телефоне бесполезен,
    // а .apk на Windows — тем более.
    if (!uri.path.toLowerCase().endsWith(installerExtension)) return false;
    // Прямые ссылки на файлы выпуска идут через redirect на CDN, поэтому
    // проверяем принадлежность репозиторию только там, где путь её содержит.
    if (uri.host == 'github.com' &&
        !uri.path.startsWith('/Lucky2356/Impressions/')) {
      return false;
    }
    return true;
  }

  /// Скачивает установщик во временный каталог.
  ///
  /// [onProgress] получает долю от 0 до 1; если сервер не сообщил размер,
  /// вызывается с -1.
  Future<File> downloadInstaller(
    String url, {
    void Function(double progress)? onProgress,
    String? expectedSha256,
  }) async {
    if (!isTrustedInstallerUrl(url)) {
      throw ArgumentError('Недоверенный адрес установщика: $url');
    }

    final response = await _client
        .send(http.Request('GET', Uri.parse(url))..followRedirects = true)
        .timeout(const Duration(minutes: 5));
    if (response.statusCode != 200) {
      throw StateError('Сервер ответил ${response.statusCode}');
    }

    final dir = await Directory.systemTemp.createTemp('impressions_update');
    final file = File(p.join(dir.path, 'Impressions-setup$installerExtension'));
    final sink = file.openWrite();
    final total = response.contentLength ?? 0;
    var received = 0;

    try {
      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        onProgress?.call(total > 0 ? received / total : -1);
      }
    } finally {
      await sink.close();
    }

    // Файл сейчас будет запущен, поэтому мало доверять адресу: сверяем с
    // контрольной суммой, которую сообщил GitHub. Не сошлось — удаляем, не
    // оставляя на диске исполняемый файл неизвестного происхождения.
    if (expectedSha256 != null && expectedSha256.isNotEmpty) {
      final actual = await _sha256OfFile(file);
      if (actual != expectedSha256.toLowerCase()) {
        await file.delete();
        throw StateError(
          'Контрольная сумма скачанного файла не совпала с заявленной',
        );
      }
    }
    return file;
  }

  /// SHA-256 файла без чтения его целиком в память.
  static Future<String> _sha256OfFile(File file) async {
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString().toLowerCase();
  }

  /// Ставит скачанное обновление.
  ///
  /// Windows: установщик запускается тихо, сам закрывает работающую копию
  /// (`/CLOSEAPPLICATIONS`) и поднимает её обратно — от человека не требуется
  /// ничего. Android: пакет отдаётся системному установщику, который спросит
  /// одно подтверждение; тише поставить приложение, установленное не из
  /// магазина, нельзя в принципе.
  Future<void> runInstaller(File installer) async {
    if (Platform.isAndroid) {
      final result = await OpenFilex.open(
        installer.path,
        type: 'application/vnd.android.package-archive',
      );
      if (result.type != ResultType.done) {
        throw StateError(result.message);
      }
      return;
    }
    await Process.start(installer.path, const [
      '/SILENT',
      '/CLOSEAPPLICATIONS',
      '/RESTARTAPPLICATIONS',
      '/NORESTART',
    ], mode: ProcessStartMode.detached);
  }

  // ---- Обновление сведений о товарах ----

  /// Дополняет объекты со штрихкодом сведениями из товарных баз.
  ///
  /// Пользовательские данные не затираются: обновляются только пустые поля и
  /// только у объектов, название которых совпадает со штрихкодом или пусто.
  /// Название, введённое человеком, всегда важнее ответа базы.
  Future<ProductRefreshReport> refreshProducts({
    bool force = false,
    int limit = 40,
  }) async {
    if (!force &&
        !await _settings.getBool(
          SettingKeys.productAutoUpdate,
          defaultValue: false,
        )) {
      return const ProductRefreshReport(checked: 0, updated: 0, titles: []);
    }
    if (!force && !await _dueFor(SettingKeys.productAutoUpdateAt)) {
      return const ProductRefreshReport(checked: 0, updated: 0, titles: []);
    }

    final sources = await enabledSources();
    // Отбираем только неполные карточки прямо в запросе. Иначе ограничение по
    // количеству каждый раз забирало одни и те же первые строки, и до
    // остальных товаров очередь не доходила никогда.
    final candidates =
        await (db.select(db.objects)
              ..where(
                (o) =>
                    o.barcode.isNotNull() &
                    o.barcode.equals('').not() &
                    (o.creator.isNull() |
                        o.creator.equals('') |
                        o.summary.isNull() |
                        o.summary.equals('') |
                        o.title.equalsExp(o.barcode)),
              )
              ..limit(limit))
            .get();

    var updated = 0;
    final titles = <String>[];

    for (final object in candidates) {
      final code = object.barcode;
      if (code == null || code.isEmpty) continue;

      // Обновляем только неполные карточки: заполненное человеком не трогаем.
      final needsTitle = object.title.trim() == code || object.title.isEmpty;
      final needsCreator = object.creator == null || object.creator!.isEmpty;
      final needsSummary = object.summary == null || object.summary!.isEmpty;
      if (!needsTitle && !needsCreator && !needsSummary) continue;

      final result = await _lookup.lookup(code, enabledSourceIds: sources);
      final info = result.info;
      if (info == null) continue;

      final companion = ObjectsCompanion(
        title: needsTitle && info.displayTitle.isNotEmpty
            ? Value(info.displayTitle)
            : const Value.absent(),
        creator: needsCreator && info.brand != null
            ? Value(info.brand)
            : const Value.absent(),
        summary: needsSummary && info.categories.isNotEmpty
            ? Value(info.categories.take(3).join(', '))
            : const Value.absent(),
      );
      if (companion.title.present ||
          companion.creator.present ||
          companion.summary.present) {
        await (db.update(
          db.objects,
        )..where((o) => o.id.equals(object.id))).write(companion);
        updated++;
        titles.add(
          needsTitle && info.displayTitle.isNotEmpty
              ? info.displayTitle
              : object.title,
        );
      }
    }

    await _settings.set(
      SettingKeys.productAutoUpdateAt,
      DateTime.now().toIso8601String(),
    );
    return ProductRefreshReport(
      checked: candidates.length,
      updated: updated,
      titles: titles,
    );
  }

  /// Включённые источники товарных данных.
  Future<Set<String>> enabledSources() async {
    final raw = await _settings.get(SettingKeys.barcodeSources);
    if (raw == null) {
      return {
        for (final s in ProductSources.all)
          if (s.enabledByDefault) s.id,
      };
    }
    return raw.split(',').where((e) => e.trim().isNotEmpty).toSet();
  }

  Future<void> setSourceEnabled(String id, bool enabled) async {
    final current = await enabledSources();
    if (enabled) {
      current.add(id);
    } else {
      current.remove(id);
    }
    await _settings.set(SettingKeys.barcodeSources, current.join(','));
  }

  /// Прошло ли достаточно времени с прошлой проверки.
  Future<bool> _dueFor(String key) async {
    final raw = await _settings.get(key);
    if (raw == null || raw.isEmpty) return true;
    final last = DateTime.tryParse(raw);
    if (last == null) return true;
    return DateTime.now().difference(last) >= _minInterval;
  }

  void dispose() {
    _client.close();
    _lookup.dispose();
  }
}
