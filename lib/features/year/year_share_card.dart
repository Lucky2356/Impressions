import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/providers.dart';
import '../../data/repositories/year_review.dart';
import '../../data/services/file_delivery_service.dart';
import '../../design_system/design_system.dart';

/// Последняя карточка итогов: то, что можно сохранить картинкой.
///
/// Итоги года — единственное в приложении, чем хочется поделиться, а всё
/// местное наружу выходит только файлом. Картинка рисуется тем же деревом
/// виджетов, что и на экране: отдельная разметка «для экспорта» разошлась бы
/// с видимой при первой же правке.
class YearShareCard extends ConsumerStatefulWidget {
  const YearShareCard({super.key, required this.review});

  final YearReview review;

  @override
  ConsumerState<YearShareCard> createState() => _YearShareCardState();
}

class _YearShareCardState extends ConsumerState<YearShareCard> {
  final _boundary = GlobalKey();
  bool _saving = false;

  /// Снимает карточку в PNG и отдаёт человеку.
  ///
  /// `pixelRatio: 3` — чтобы картинка осталась чёткой и на экране телефона, и
  /// при пересылке: `toImage` рисует в логических точках, а не в пикселях
  /// устройства.
  Future<void> _save() async {
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
            fileName: 'impressions-${widget.review.year}.png',
            typeLabel: l10n.yearImageType,
            extension: 'png',
            write: (file) => file.writeAsBytes(bytes, flush: true),
          );

      if (!mounted) return;
      switch (result.status) {
        case FileDeliveryStatus.saved:
        case FileDeliveryStatus.shared:
          showMessage(context, l10n.yearImageSaved);
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: RepaintBoundary(
            key: _boundary,
            child: _Poster(review: widget.review),
          ),
        ),
        const SizedBox(height: AppDimens.space20),
        FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: const Icon(Icons.image_outlined, size: 20),
          label: Text(l10n.yearSaveImage),
        ),
      ],
    );
  }
}

/// Сама картинка: год, число впечатлений и три строки о нём.
class _Poster extends StatelessWidget {
  const _Poster({required this.review});

  final YearReview review;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    final lines = <String>[
      if (review.averageRating != null)
        l10n.yearAverage(
          review.averageRating!.toStringAsFixed(1),
          review.rated,
        ),
      if (review.topCategory case final top?)
        '${l10n.yearTopCategory}: ${top.name}',
      if (review.finished > 0) l10n.yearFinished(review.finished),
    ];

    return Container(
      // Свой фон, а не прозрачный: снимок с прозрачностью в мессенджере
      // ложится на чёрное, и светлая тема читается белым по белому.
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: AppDimens.brLg,
        border: Border.all(color: c.border),
      ),
      padding: const EdgeInsets.all(AppDimens.space32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.yearYours('${review.year}'),
            style: context.text.labelMedium?.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: AppDimens.space8),
          Text('${review.total}', style: context.text.displayLarge),
          Text(
            l10n.yearImpressions(review.total),
            style: context.text.titleMedium?.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: AppDimens.space20),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.space4),
              child: Text(line, style: context.text.bodyMedium),
            ),
        ],
      ),
    );
  }
}
