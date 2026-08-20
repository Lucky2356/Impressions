import 'dart:typed_data';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/data_refresh.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/db/database.dart';
import '../../design_system/design_system.dart';
import '../../data/providers.dart';
import '../../data/services/image_service.dart';
import 'entry_card_data.dart';
import 'entry_photo_thumb.dart';
import 'entry_photo_viewer.dart';
import 'photo_section_header.dart';
import 'photo_source.dart';

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

  /// Какой снимок сейчас обложка записи.
  String? _primaryId;

  /// Полный путь обложки — для крупной полосы над миниатюрами.
  String? _coverPath;
  bool _dragging = false;
  bool _busy = false;

  bool get _isDesktop => PhotoSource.isDesktop;

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
      setState(() {
        _photos = const [];
        _coverPath = null;
      });
      return;
    }
    final rows = await _service.attachmentsOfRevision(revisionId);
    final paths = <String, String>{};
    for (final row in rows) {
      paths[row.id] = await _service.absolutePath(
        row.thumbPath ?? row.storagePath,
      );
    }
    final primary = await _service.primaryAttachmentId(revisionId);
    final primaryRow = rows.where((r) => r.id == primary).firstOrNull;
    final cover = primaryRow == null
        ? null
        : await _service.absolutePath(primaryRow.storagePath);
    if (!mounted) return;
    setState(() {
      _photos = rows;
      _primaryId = primary;
      _coverPath = cover;
      _paths
        ..clear()
        ..addAll(paths);
    });
  }

  Future<void> _makeCover(AttachmentRow row) async {
    final revisionId = widget.revisionId;
    if (revisionId == null) return;
    await _service.setPrimaryAttachment(
      revisionId: revisionId,
      attachmentId: row.id,
    );
    // Обложка видна в каталоге и на главной — их нужно перерисовать.
    ref.read(dataRefreshProvider.notifier).bump();
    await _load();
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
          showMessage(context, l10n.photoDuplicate);
        }
      case ImageRejected(reason: final reason):
        if (mounted) {
          showMessage(context, '${l10n.photoRejected} ($reason)');
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
      for (final bytes in await PhotoSource.pick()) {
        await _addBytes(bytes);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _capture() async {
    final shot = await PhotoSource.capture();
    if (shot != null) await _addBytes(shot);
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
        // Обложка крупно — и потому, что §3 просит выразительных фотографий, и
        // потому, что перелёту из списка нужно куда прилетать. Без снимка
        // полосы нет: типографическая заглушка во всю ширину — это много
        // пустоты, а перелетать было бы нечему.
        if (_coverPath case final path?) ...[
          CoverImage(
            title: '',
            imagePath: path,
            aspectRatio: 16 / 9,
            heroTag: entryHeroTag(widget.entryId),
          ),
          const SizedBox(height: AppDimens.space16),
        ],
        PhotoSectionHeader(
          onPick: _busy ? null : _pick,
          onCapture: _busy ? null : _capture,
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
            // Порядок задаёт человек: до 1.19.0 он был порядком добавления, и
            // поменять его было нечем. Перетаскивание, а не «влево-вправо» по
            // шагу: разложить пять снимков шагами — двадцать нажатий.
            child: ReorderableListView.builder(
              scrollDirection: Axis.horizontal,
              buildDefaultDragHandles: false,
              itemCount: _photos.length,
              // onReorderItem уже учитывает сдвиг из-за изъятого элемента —
              // так же, как порядок записей в подборке.
              onReorderItem: _reorder,
              itemBuilder: (context, i) {
                final row = _photos[i];
                final path = _paths[row.id];
                return Padding(
                  key: ValueKey(row.id),
                  padding: const EdgeInsets.only(right: AppDimens.space8),
                  child: ReorderableDelayedDragStartListener(
                    index: i,
                    child: PhotoThumb(
                      path: path,
                      caption: row.caption,
                      isCover: row.id == _primaryId,
                      onRemove: () => _remove(row),
                      onOpen: () => _openFullscreen(i),
                      onMakeCover: row.id == _primaryId
                          ? null
                          : () => _makeCover(row),
                    ),
                  ),
                );
              },
            ),
          ),
        if (_photos.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: AppDimens.space4),
            child: Text(
              l10n.photoReorderHint,
              style: context.text.labelSmall?.copyWith(color: c.textMuted),
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
    final photos = <ViewerPhoto>[];
    for (final row in _photos) {
      photos.add((
        id: row.id,
        path: await _service.absolutePath(row.storagePath),
        caption: row.caption,
      ));
    }
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (_) =>
          PhotoViewer(photos: photos, initial: index, onCaption: _setCaption),
    );
    // Подпись могли поменять — перечитываем, иначе следующий просмотр покажет
    // прежнюю.
    await _load();
  }

  Future<void> _setCaption(String attachmentId, String caption) async {
    await _service.setCaption(attachmentId, caption);
  }

  /// Новый порядок снимков после перетаскивания.
  ///
  /// Список считается здесь целиком и уходит в базу одним куском: сдвиг «на
  /// одну позицию» пришлось бы описывать дважды — здесь и там.
  Future<void> _reorder(int oldIndex, int newIndex) async {
    final revisionId = widget.revisionId;
    if (revisionId == null) return;

    final next = [..._photos];
    next.insert(newIndex, next.removeAt(oldIndex));
    setState(() => _photos = next);

    await _service.reorderAttachments(
      revisionId: revisionId,
      orderedAttachmentIds: [for (final row in next) row.id],
    );
    // Обложка выбирается по пометке, а при её отсутствии — по порядку: список
    // мог поменяться и в каталоге.
    ref.read(dataRefreshProvider.notifier).bump();
    await _load();
  }
}
