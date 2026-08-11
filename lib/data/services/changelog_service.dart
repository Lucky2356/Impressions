import 'package:flutter/services.dart' show rootBundle;

/// Раздел истории изменений для одной версии.
///
/// Приложение обновляет себя само, а что именно изменилось, человек нигде не
/// узнавал: список правок жил только на GitHub. Обновление приходило молча и
/// меняло поведение — например, в 1.11.0 у архивирования появилась отмена, а
/// у тегов раздел настроек.
class ChangelogEntry {
  const ChangelogEntry({required this.version, required this.body});

  final String version;

  /// Текст раздела без строки заголовка.
  final String body;
}

/// Читает `CHANGELOG.md` из ресурсов приложения.
class ChangelogService {
  const ChangelogService({this.load = _loadAsset});

  /// Откуда берётся файл. Подменяется в тестах.
  final Future<String> Function() load;

  static Future<String> _loadAsset() => rootBundle.loadString('CHANGELOG.md');

  static const assetPath = 'CHANGELOG.md';

  /// Раздел нужной версии или null, если такого нет.
  Future<ChangelogEntry?> forVersion(String version) async {
    try {
      return sectionOf(await load(), version);
    } catch (_) {
      // Файла нет или он не читается — «Что нового» просто не покажем.
      return null;
    }
  }

  /// Вырезает раздел `## [версия] — дата` до следующего такого заголовка.
  ///
  /// Пустого окна быть не должно: если раздела для версии в файле нет (сборка
  /// из ветки, забытая запись), возвращается null, и показывать нечего.
  static ChangelogEntry? sectionOf(String markdown, String version) {
    final lines = markdown.split('\n');
    final header = RegExp(r'^##\s+\[([^\]]+)\]');

    var start = -1;
    var end = lines.length;
    for (var i = 0; i < lines.length; i++) {
      final match = header.firstMatch(lines[i]);
      if (match == null) continue;
      if (start < 0) {
        if (match.group(1) == version) start = i + 1;
      } else {
        end = i;
        break;
      }
    }
    if (start < 0) return null;

    final body = lines.sublist(start, end).join('\n').trim();
    if (body.isEmpty) return null;
    return ChangelogEntry(version: version, body: body);
  }
}
