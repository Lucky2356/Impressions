import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/data_refresh.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/db/database.dart';
import '../../data/providers.dart';
import '../../data/services/image_service.dart';

/// Фотографии записи (§16): добавление с камеры/галереи на Android, выбором
/// файла и перетаскиванием на Windows; просмотр во весь экран.
class EntryPhotos extends ConsumerStatefulWidget {
  const EntryPhotos({
    super.key,
    required this.entryId,
    required this.revisionId,
  });

  final String entryId;
  final String? revisionId;

  @override
  ConsumerState<EntryPhotos> createState() => _EntryPhotosState();
}

class _EntryPhotosState extends ConsumerState<EntryPhotos> {
  List<AttachmentRow> _photos = const [];
  final Map<String, String> _paths = {};
  bool _dragging = false;
  bool _busy = false;

  bool get _isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(EntryPhotos oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.revisionId != widget.revisionId) _load();
  }

  ImageService get _service => ImageService(ref.read(appDatabaseProvider));

  Future<void> _load() async {
    final revisionId = widget.revisionId;
    if (revisionId == null) {
      setState(() => _photos = const []);
      return;
    }
    final rows = await _service.attachmentsOfRevision(revisionId);
    final paths = <String, String>{};
    for (final row in rows) {
      paths[row.id] = await _service.absolutePath(
        row.thumbPath ?? row.storagePath,
      );
    }
    if (!mounted) return;
    setState(() {
      _photos = rows;
      _paths
        ..clear()
        ..addAll(paths);
    });
  }

  Future<void> _addBytes(Uint8List bytes) async {
    final l10n = AppLocalizations.of(context);
    final revisionId = widget.revisionId;
    if (revisionId == null) return;

    final result = await _service.addFromBytes(bytes);
    if (!mounted) return;

    switch (result) {
      case ImageAdded(attachment: final a):
        await _service.attachToEntry(
          entryId: widget.entryId,
          attachmentId: a.id,
          revisionId: revisionId,
        );
      case ImageDuplicate(attachment: final a):
        await _service.attachToEntry(
          entryId: widget.entryId,
          attachmentId: a.id,
          revisionId: revisionId,
        );
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.photoDuplicate)));
        }
      case ImageRejected(reason: final reason):
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.photoRejected} ($reason)')),
          );
        }
        return;
    }
    ref.read(dataRefreshProvider.notifier).bump();
    await _load();
  }

  Future<void> _pick() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (_isDesktop) {
        const typeGroup = XTypeGroup(
          label: 'Изображения',
          extensions: ['jpg', 'jpeg', 'png', 'webp'],
        );
        final files = await openFiles(acceptedTypeGroups: const [typeGroup]);
        for (final f in files) {
          await _addBytes(await f.readAsBytes());
        }
      } else {
        final picker = ImagePicker();
        final files = await picker.pickMultiImage();
        for (final f in files) {
          await _addBytes(await f.readAsBytes());
        }
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _capture() async {
    final picker = ImagePicker();
    final shot = await picker.pickImage(source: ImageSource.camera);
    if (shot == null) return;
    await _addBytes(await shot.readAsBytes());
  }

  Future<void> _remove(AttachmentRow row) async {
    final revisionId = widget.revisionId;
    if (revisionId == null) return;
    await _service.detach(revisionId, row.id);
    ref.read(dataRefreshProvider.notifier).bump();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l10n.photoSectionTitle, style: context.text.titleMedium),
            const Spacer(),
            if (!_isDesktop)
              IconButton(
                tooltip: l10n.photoAdd,
                onPressed: _busy ? null : _capture,
                icon: const Icon(Icons.photo_camera_outlined),
              ),
            TextButton.icon(
              onPressed: _busy ? null : _pick,
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
              label: Text(l10n.photoAdd),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.space8),
        if (_photos.isEmpty)
          Container(
            height: 96,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _dragging ? c.accentSoft : c.surfaceMuted,
              borderRadius: AppDimens.brMd,
              border: Border.all(color: _dragging ? c.accentPrimary : c.border),
            ),
            child: Text(
              _isDesktop ? l10n.photoDropHint : l10n.photoAdd,
              style: context.text.bodySmall?.copyWith(color: c.textMuted),
            ),
          )
        else
          SizedBox(
            height: 108,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _photos.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: AppDimens.space8),
              itemBuilder: (context, i) {
                final row = _photos[i];
                final path = _paths[row.id];
                return _PhotoThumb(
                  path: path,
                  onRemove: () => _remove(row),
                  onOpen: () => _openFullscreen(i),
                );
              },
            ),
          ),
      ],
    );

    if (!_isDesktop) return content;

    // Перетаскивание изображений на Windows (§16).
    return DropTarget(
      onDragEntered: (_) => setState(() => _dragging = true),
      onDragExited: (_) => setState(() => _dragging = false),
      onDragDone: (details) async {
        setState(() => _dragging = false);
        for (final file in details.files) {
          await _addBytes(await file.readAsBytes());
        }
      },
      child: content,
    );
  }

  Future<void> _openFullscreen(int index) async {
    final fullPaths = <String>[];
    for (final row in _photos) {
      fullPaths.add(await _service.absolutePath(row.storagePath));
    }
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (_) => _FullscreenGallery(paths: fullPaths, initial: index),
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  const _PhotoThumb({
    required this.path,
    required this.onRemove,
    required this.onOpen,
  });

  final String? path;
  final VoidCallback onRemove;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context);
    return Stack(
      children: [
        InkWell(
          onTap: onOpen,
          borderRadius: AppDimens.brMd,
          child: ClipRRect(
            borderRadius: AppDimens.brMd,
            child: SizedBox(
              width: 108,
              height: 108,
              child: path == null || !File(path!).existsSync()
                  ? Container(color: c.surfaceMuted)
                  : Image.file(File(path!), fit: BoxFit.cover),
            ),
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

class _FullscreenGallery extends StatefulWidget {
  const _FullscreenGallery({required this.paths, required this.initial});

  final List<String> paths;
  final int initial;

  @override
  State<_FullscreenGallery> createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<_FullscreenGallery> {
  late final PageController _controller = PageController(
    initialPage: widget.initial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Dialog.fullscreen(
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.paths.length,
            itemBuilder: (context, i) => InteractiveViewer(
              child: Center(child: Image.file(File(widget.paths[i]))),
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
        ],
      ),
    );
  }
}
