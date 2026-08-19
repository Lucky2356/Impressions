import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../design_system/design_system.dart';

/// Один снимок для полноэкранного просмотра.
typedef ViewerPhoto = ({String id, String path, String? caption});

/// Просмотр снимков во весь экран с подписями (§16).
///
/// Вынесен из [EntryPhotos]: с подписями файл перевалил за четыреста строк, а
/// чистку файлов-переростков откатывать нельзя.
///
/// Подпись правится прямо здесь, а не в списке миниатюр: подписывают снимок,
/// глядя на него, а не на плитку в сто точек.
class PhotoViewer extends StatefulWidget {
  const PhotoViewer({
    super.key,
    required this.photos,
    required this.initial,
    this.onCaption,
  });

  final List<ViewerPhoto> photos;
  final int initial;

  /// null — снимки чужие, подписывать их нельзя.
  final Future<void> Function(String id, String caption)? onCaption;

  @override
  State<PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> {
  late final PageController _controller = PageController(
    initialPage: widget.initial,
  );
  late List<ViewerPhoto> _photos = widget.photos;
  late int _index = widget.initial;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _editCaption() async {
    final onCaption = widget.onCaption;
    if (onCaption == null) return;
    final l10n = AppLocalizations.of(context);
    final photo = _photos[_index];

    final text = await TextInputDialog.show(
      context,
      title: l10n.photoCaption,
      hint: l10n.photoCaptionHint,
      initial: photo.caption ?? '',
      // Пустая подпись — это «подписи нет», а не отказ от правки.
      allowEmpty: true,
    );
    if (text == null) return;
    await onCaption(photo.id, text);
    if (!mounted) return;
    setState(() {
      _photos = [
        for (final p in _photos)
          if (p.id == photo.id)
            (id: p.id, path: p.path, caption: text.trim().isEmpty ? null : text)
          else
            p,
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final caption = _photos[_index].caption;

    return Dialog.fullscreen(
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _index = i),
            itemCount: _photos.length,
            itemBuilder: (context, i) => InteractiveViewer(
              child: Center(child: Image.file(File(_photos[i].path))),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: IconButton(
              tooltip: l10n.commonClose,
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded),
            ),
          ),
          // Подпись поверх снимка внизу: она относится к тому, что видно, и
          // уводить её на отдельную полосу значит разорвать эту связь.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: c.surface.withValues(alpha: 0.9),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space20,
                vertical: AppDimens.space12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      caption ?? l10n.photoCaptionEmpty,
                      style: context.text.bodyMedium?.copyWith(
                        color: caption == null ? c.textMuted : c.textPrimary,
                      ),
                    ),
                  ),
                  if (widget.onCaption != null)
                    IconButton(
                      tooltip: l10n.photoCaption,
                      onPressed: _editCaption,
                      icon: const Icon(Icons.edit_rounded, size: 18),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
