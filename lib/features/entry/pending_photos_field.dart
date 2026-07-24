import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import 'photo_source.dart';

/// Фотографии, выбранные до сохранения записи.
///
/// Вложения привязываются к версии записи, а её до сохранения ещё нет —
/// поэтому снимки лежат в памяти формы и попадают в базу одним махом после
/// создания записи. Первый из них становится обложкой.
class PendingPhotosField extends StatefulWidget {
  const PendingPhotosField({
    super.key,
    required this.photos,
    required this.onChanged,
    this.enabled = true,
  });

  final List<Uint8List> photos;
  final ValueChanged<List<Uint8List>> onChanged;
  final bool enabled;

  @override
  State<PendingPhotosField> createState() => _PendingPhotosFieldState();
}

class _PendingPhotosFieldState extends State<PendingPhotosField> {
  bool _dragging = false;
  bool _busy = false;

  Future<void> _pick() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final picked = await PhotoSource.pick();
      if (picked.isNotEmpty) _add(picked);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _capture() async {
    final shot = await PhotoSource.capture();
    if (shot != null) _add([shot]);
  }

  void _add(List<Uint8List> bytes) =>
      widget.onChanged([...widget.photos, ...bytes]);

  void _removeAt(int index) => widget.onChanged([
    for (var i = 0; i < widget.photos.length; i++)
      if (i != index) widget.photos[i],
  ]);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final enabled = widget.enabled && !_busy;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l10n.photoSectionTitle, style: context.text.titleMedium),
            const Spacer(),
            if (!PhotoSource.isDesktop)
              IconButton(
                tooltip: l10n.photoAdd,
                onPressed: enabled ? _capture : null,
                icon: const Icon(Icons.photo_camera_outlined),
              ),
            TextButton.icon(
              onPressed: enabled ? _pick : null,
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
              label: Text(l10n.photoAdd),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.space8),
        if (widget.photos.isEmpty)
          Container(
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _dragging ? c.accentSoft : c.surfaceMuted,
              borderRadius: AppDimens.brMd,
              border: Border.all(color: _dragging ? c.accentPrimary : c.border),
            ),
            child: Text(
              PhotoSource.isDesktop ? l10n.photoDropHint : l10n.photoAdd,
              style: context.text.bodySmall?.copyWith(color: c.textMuted),
            ),
          )
        else
          SizedBox(
            height: 84,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.photos.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: AppDimens.space8),
              itemBuilder: (context, i) => _PendingThumb(
                bytes: widget.photos[i],
                // Обложкой станет первый снимок — это видно сразу, а не
                // выясняется после сохранения.
                isCover: i == 0,
                onRemove: () => _removeAt(i),
              ),
            ),
          ),
      ],
    );

    if (!PhotoSource.isDesktop) return content;

    return DropTarget(
      onDragEntered: (_) => setState(() => _dragging = true),
      onDragExited: (_) => setState(() => _dragging = false),
      onDragDone: (details) async {
        setState(() => _dragging = false);
        final bytes = <Uint8List>[];
        for (final file in details.files) {
          bytes.add(await file.readAsBytes());
        }
        if (bytes.isNotEmpty) _add(bytes);
      },
      child: content,
    );
  }
}

class _PendingThumb extends StatelessWidget {
  const _PendingThumb({
    required this.bytes,
    required this.isCover,
    required this.onRemove,
  });

  final Uint8List bytes;
  final bool isCover;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context);
    return Stack(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            borderRadius: AppDimens.brMd,
            border: isCover
                ? Border.all(color: c.accentPrimary, width: 2)
                : null,
          ),
          clipBehavior: Clip.antiAlias,
          // Здесь лежит исходный снимок целиком — на телефоне это 12 Мп.
          // Без cacheWidth Flutter развернул бы его в память в полном размере
          // ради квадратика 84×84.
          child: Image.memory(
            bytes,
            fit: BoxFit.cover,
            cacheWidth: 168,
            filterQuality: FilterQuality.low,
          ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: Tooltip(
            message: l10n.photoRemove,
            child: Material(
              color: c.surface.withValues(alpha: 0.85),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onRemove,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: c.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
