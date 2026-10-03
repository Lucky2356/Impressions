import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/domain/relation.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../core/utils/dates.dart';
import '../../data/providers.dart';
import '../../data/services/export_service.dart';
import '../../data/services/file_delivery_service.dart';
import '../../design_system/design_system.dart';
import 'entry_providers.dart';

/// Что из записи попадает на картинку.
///
/// Приватность записи решает это, а не желание поделиться: «только мне»
/// значит, что запись не покидает устройство, и картинка — такой же выход
/// наружу, как файл обмена. Поэтому правила здесь те же, что в экспорте, и
/// лежат они отдельно от виджета: проверять их на дереве виджетов значило бы
/// проверять раскладку вместо решения.
class EntryCardContent {
  const EntryCardContent({
    required this.title,
    required this.typeName,
    required this.path,
    this.rating,
    this.relation,
    this.impressionDate,
    this.note,
    this.coverPath,
  });

  /// Собирает содержимое картинки по записи.
  factory EntryCardContent.of(EntryDetail detail) {
    final entry = detail.entry;
    final privacy = entry.privacy;

    // Заметка — то, что человек сказал о впечатлении: короткая, а если её
    // нет — подробная. Пустая строка считается отсутствием: поле стирают, а
    // не убирают.
    String? note;
    if (privacy != ExportService.privacyNoNote) {
      for (final candidate in [entry.shortNote, entry.detailedNote]) {
        final text = candidate?.trim();
        if (text != null && text.isNotEmpty) {
          note = text;
          break;
        }
      }
    }

    return EntryCardContent(
      title: detail.object.title,
      typeName: detail.typeName,
      path: detail.categoryPath,
      rating: entry.rating,
      relation: entry.relation,
      impressionDate: entry.impressionDate,
      note: note == null ? null : _shorten(note),
      coverPath: privacy == ExportService.privacyNoPhotos
          ? null
          : detail.coverPath,
    );
  }

  final String title;
  final String typeName;
  final List<String> path;
  final double? rating;
  final String? relation;
  final DateTime? impressionDate;

  /// Заметка, уже укороченная до того, что читается с картинки.
  final String? note;

  final String? coverPath;

  /// Можно ли вообще делать картинку из такой записи.
  ///
  /// «Только мне» — нельзя: это та же пометка, по которой запись не уходит в
  /// файл обмена.
  static bool allowed(String privacy) => privacy != ExportService.privacyOnlyMe;

  /// Предел длины заметки на картинке.
  ///
  /// Картинку смотрят, а не читают: длинная заметка превращает её в страницу
  /// текста, набранную мелким кеглем.
  static const int noteLimit = 240;

  static String _shorten(String note) {
    final single = note.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (single.length <= noteLimit) return single;
    // Режем по последнему пробелу: обрывок посреди слова читается как сбой.
    final cut = single.substring(0, noteLimit);
    final space = cut.lastIndexOf(' ');
    return '${space > noteLimit ~/ 2 ? cut.substring(0, space) : cut}…';
  }

  /// Имя файла картинки.
  ///
  /// Название записи попадает в имя файла, но не целиком и без того, что
  /// файловая система за имя не считает: слэш в «AC/DC» создал бы вложенную
  /// папку, а то и обрубил бы путь.
  String get fileName {
    final safe = title
        .replaceAll(RegExp(r'[^\p{L}\p{N} _-]', unicode: true), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final short = safe.length <= 40 ? safe : safe.substring(0, 40).trim();
    return '${AppConfig.appName}-${short.isEmpty ? 'card' : short}.png';
  }
}

/// Карточка записи картинкой — то, что можно показать.
///
/// Приложение местное, и единственный способ показать кому-то одну запись —
/// картинка: файл обмена несёт профиль целиком и открывается только этим же
/// приложением. Рисуется тем же деревом виджетов, что и видно в диалоге:
/// отдельная разметка «для экспорта» разошлась бы с видимой при первой же
/// правке.
class EntryShareCard extends ConsumerStatefulWidget {
  const EntryShareCard({super.key, required this.detail});

  final EntryDetail detail;

  static Future<void> show(BuildContext context, EntryDetail detail) {
    return showDialog<void>(
      context: context,
      builder: (_) => EntryShareCard(detail: detail),
    );
  }

  @override
  ConsumerState<EntryShareCard> createState() => _EntryShareCardState();
}

class _EntryShareCardState extends ConsumerState<EntryShareCard> {
  final _boundary = GlobalKey();
  bool _saving = false;

  /// Снимает карточку в PNG и отдаёт человеку.
  ///
  /// `pixelRatio: 3` — чтобы картинка осталась чёткой и на экране телефона, и
  /// при пересылке: `toImage` рисует в логических точках, а не в пикселях
  /// устройства.
  Future<void> _save(EntryCardContent content) async {
    final l10n = AppLocalizations.of(context);
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final boundary =
          _boundary.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (data == null || !mounted) return;

      final bytes = data.buffer.asUint8List();
      final result = await ref
          .read(fileDeliveryProvider)
          .deliver(
            fileName: content.fileName,
            typeLabel: l10n.yearImageType,
            extension: 'png',
            write: (file) => file.writeAsBytes(bytes, flush: true),
          );

      if (!mounted) return;
      switch (result.status) {
        case FileDeliveryStatus.saved:
        case FileDeliveryStatus.shared:
          showMessage(context, l10n.entryCardSaved);
        case FileDeliveryStatus.cancelled:
          break;
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final content = EntryCardContent.of(widget.detail);

    return AlertDialog(
      title: Text(l10n.entryCardTitle),
      content: SingleChildScrollView(
        child: RepaintBoundary(
          key: _boundary,
          child: _Poster(content: content),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.commonClose),
        ),
        FilledButton.icon(
          onPressed: _saving ? null : () => _save(content),
          icon: const Icon(Icons.image_outlined, size: 20),
          label: Text(l10n.yearSaveImage),
        ),
      ],
    );
  }
}

/// Сама картинка.
class _Poster extends StatelessWidget {
  const _Poster({required this.content});

  final EntryCardContent content;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final relation = Relation.values
        .where((r) => r.name == content.relation)
        .firstOrNull;

    return Container(
      // Свой фон, а не прозрачный: снимок с прозрачностью в мессенджере
      // ложится на чёрное, и светлая тема читается белым по белому.
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: AppDimens.brLg,
        border: Border.all(color: c.border),
      ),
      padding: const EdgeInsets.all(AppDimens.space24),
      width: 360,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (content.coverPath case final cover?) ...[
            ClipRRect(
              borderRadius: AppDimens.brSm,
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: CoverImage(title: content.title, imagePath: cover),
              ),
            ),
            const SizedBox(height: AppDimens.space16),
          ],
          Text(
            [content.typeName, ...content.path].join(' · '),
            style: context.text.labelSmall?.copyWith(color: c.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimens.space4),
          Text(content.title, style: context.text.headlineSmall),
          const SizedBox(height: AppDimens.space12),
          Row(
            children: [
              if (content.rating case final rating?) ...[
                Icon(Icons.star_rounded, size: 18, color: c.accentPrimary),
                const SizedBox(width: AppDimens.space4),
                Text(
                  rating.toStringAsFixed(1),
                  style: context.text.titleMedium,
                ),
                const SizedBox(width: AppDimens.space12),
              ],
              if (relation != null)
                Text(
                  relation.label(l10n),
                  style: context.text.bodyMedium?.copyWith(
                    color: c.textSecondary,
                  ),
                ),
            ],
          ),
          if (content.note case final note?) ...[
            const SizedBox(height: AppDimens.space16),
            Text(note, style: context.text.bodyMedium),
          ],
          if (content.impressionDate case final date?) ...[
            const SizedBox(height: AppDimens.space16),
            Text(
              localeDate(context, 'd MMMM y').format(date),
              style: context.text.labelSmall?.copyWith(color: c.textMuted),
            ),
          ],
          const SizedBox(height: AppDimens.space16),
          // Подпись приложения — чтобы картинка объясняла, откуда она. Имя
          // берётся из AppConfig: оно рабочее и однажды поменяется.
          Text(
            AppConfig.appName,
            style: context.text.labelSmall?.copyWith(color: c.textMuted),
          ),
        ],
      ),
    );
  }
}
