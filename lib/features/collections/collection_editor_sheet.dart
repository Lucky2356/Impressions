import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/data_refresh.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/db/database.dart';
import '../../data/providers.dart';
import '../../data/services/image_service.dart';
import '../../design_system/design_system.dart';
import '../entry/photo_source.dart';
import 'collection_providers.dart';
import 'smart_collections.dart';

/// Оформление подборки: имя, описание, цвет и обложка.
///
/// Все четыре столбца были в схеме с самого начала, и ни один не редактировался
/// ниоткуда: подборка умела называться и больше ничего. Цвет при этом на экране
/// был — он брался по номеру карточки в списке, и от появления новой подборки
/// все остальные перекрашивались.
class CollectionEditorSheet extends ConsumerStatefulWidget {
  const CollectionEditorSheet({super.key, required this.collection});

  final CollectionRow collection;

  /// Возвращает `true`, если что-то сохранили.
  static Future<bool> show(
    BuildContext context,
    CollectionRow collection,
  ) async {
    final saved = await showAdaptiveSheet<bool>(
      context,
      width: 520,
      heightFactor: 0.85,
      builder: (_) => CollectionEditorSheet(collection: collection),
    );
    return saved ?? false;
  }

  @override
  ConsumerState<CollectionEditorSheet> createState() =>
      _CollectionEditorSheetState();
}

class _CollectionEditorSheetState extends ConsumerState<CollectionEditorSheet> {
  late final _name = TextEditingController(text: widget.collection.name);
  late final _description = TextEditingController(
    text: widget.collection.description ?? '',
  );

  late int? _color = widget.collection.color;
  late String? _coverId = widget.collection.coverAttachmentId;

  String? _coverPath;
  bool _coverLoaded = false;
  bool _saving = false;

  ImageService get _images => ImageService(ref.read(appDatabaseProvider));

  @override
  void initState() {
    super.initState();
    _loadCoverPath();
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _loadCoverPath() async {
    final id = _coverId;
    if (id == null) {
      setState(() => _coverLoaded = true);
      return;
    }
    final path = await _images.pathOfAttachment(id);
    if (!mounted) return;
    setState(() {
      _coverPath = path;
      _coverLoaded = true;
    });
  }

  Color get _tone => _color == null
      ? context.colors.profileColorFor(widget.collection.id)
      : Color(_color!);

  Future<void> _coverFromFile() async {
    final files = await PhotoSource.pick();
    if (files.isEmpty || !mounted) return;
    final images = _images;
    final result = await images.addFromBytes(files.first);
    if (!mounted) return;
    switch (result) {
      case ImageAdded(attachment: final a):
      case ImageDuplicate(attachment: final a):
        final path = await images.pathOfAttachment(a.id);
        if (!mounted) return;
        setState(() {
          _coverId = a.id;
          _coverPath = path;
        });
      case ImageRejected(reason: final reason):
        showMessage(context, reason);
    }
  }

  /// Обложка из фотографий самой подборки — как у ветки категорий.
  Future<void> _coverFromEntries() async {
    final l10n = AppLocalizations.of(context);
    final entries = await ref.read(
      collectionEntriesProvider(widget.collection.id).future,
    );
    if (!mounted) return;

    final photos = await ref.read(entryRepositoryProvider).photosOfEntries([
      for (final e in entries) e.entryId,
    ]);
    if (!mounted) return;
    if (photos.isEmpty) {
      showMessage(context, l10n.collectionCoverNone);
      return;
    }

    final picked =
        await showAdaptiveSheet<({String attachmentId, String path})>(
          context,
          width: 520,
          heightFactor: 0.7,
          builder: (_) => _PhotoPicker(photos: photos),
        );
    if (picked == null || !mounted) return;
    setState(() {
      _coverId = picked.attachmentId;
      _coverPath = picked.path;
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    final repo = ref.read(collectionRepositoryProvider);
    final name = _name.text.trim();
    if (name.isNotEmpty && name != widget.collection.name) {
      await repo.rename(widget.collection.id, name);
    }
    final description = _description.text.trim();
    await repo.updateAppearance(
      widget.collection.id,
      description: description.isEmpty ? null : description,
      color: _color,
      coverAttachmentId: _coverId,
    );
    ref.read(dataRefreshProvider.notifier).bump();
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final smart = smartFilterOf(widget.collection) != null;

    return Padding(
      padding: const EdgeInsets.all(AppDimens.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.collectionAppearance,
                  style: context.text.titleLarge,
                ),
              ),
              AppIconButton(
                icon: Icons.close_rounded,
                tooltip: l10n.commonCancel,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space16),
          Expanded(
            child: ListView(
              children: [
                _preview(),
                const SizedBox(height: AppDimens.space20),
                TextField(
                  key: const Key('collection-name'),
                  controller: _name,
                  decoration: InputDecoration(
                    labelText: l10n.collectionNameLabel,
                  ),
                ),
                const SizedBox(height: AppDimens.space16),
                TextField(
                  key: const Key('collection-description'),
                  controller: _description,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: l10n.collectionDescriptionLabel,
                    hintText: l10n.collectionDescriptionHint,
                  ),
                ),
                const SizedBox(height: AppDimens.space20),
                SectionHeader(title: l10n.collectionColor),
                const SizedBox(height: AppDimens.space12),
                ColorSwatches(
                  value: _color == null ? null : Color(_color!),
                  inheritLabel: l10n.collectionColorAuto,
                  inheritedColor: c.profileColorFor(widget.collection.id),
                  onChanged: (v) => setState(() => _color = v?.toARGB32()),
                ),
                const SizedBox(height: AppDimens.space20),
                SectionHeader(title: l10n.collectionCover),
                const SizedBox(height: AppDimens.space12),
                Wrap(
                  spacing: AppDimens.space8,
                  runSpacing: AppDimens.space8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _coverFromEntries,
                      icon: const Icon(Icons.photo_library_rounded, size: 18),
                      label: Text(l10n.categoryCoverFromEntry),
                    ),
                    OutlinedButton.icon(
                      onPressed: _coverFromFile,
                      icon: const Icon(Icons.folder_open_rounded, size: 18),
                      label: Text(l10n.categoryCoverFromFile),
                    ),
                    if (_coverId != null)
                      TextButton.icon(
                        onPressed: () => setState(() {
                          _coverId = null;
                          _coverPath = null;
                        }),
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: c.coral,
                        ),
                        label: Text(
                          l10n.categoryCoverRemove,
                          style: TextStyle(color: c.coral),
                        ),
                      ),
                  ],
                ),
                // Условие живой подборки правится там, где его и собирают, —
                // в каталоге. Второй набор фильтров здесь разошёлся бы с ним
                // при первом же новом отборе.
                if (smart) ...[
                  const SizedBox(height: AppDimens.space20),
                  Text(
                    l10n.collectionSmartEditHint,
                    style: context.text.labelSmall?.copyWith(
                      color: c.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppDimens.space16),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
  }

  Widget _preview() {
    final c = context.colors;
    final tone = _tone;
    return Container(
      height: 96,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: AppDimens.brLg,
        border: Border.all(color: c.border),
        color: tone.withValues(alpha: 0.12),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_coverLoaded && _coverPath != null)
            Opacity(
              opacity: 0.45,
              child: Image.file(
                File(_coverPath!),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppDimens.space16),
            child: Row(
              children: [
                Icon(
                  smartFilterOf(widget.collection) != null
                      ? Icons.auto_awesome_rounded
                      : Icons.collections_bookmark_rounded,
                  size: 26,
                  color: tone,
                ),
                const SizedBox(width: AppDimens.space16),
                Expanded(
                  child: Text(
                    _name.text.trim().isEmpty
                        ? widget.collection.name
                        : _name.text.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleLarge,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Выбор обложки из фотографий, уже лежащих в подборке.
class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({required this.photos});

  final List<({String attachmentId, String path})> photos;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppDimens.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.categoryCoverPick, style: context.text.titleMedium),
          const SizedBox(height: AppDimens.space16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: AppDimens.space8,
                crossAxisSpacing: AppDimens.space8,
                childAspectRatio: 3 / 4,
              ),
              itemCount: photos.length,
              itemBuilder: (context, i) {
                final photo = photos[i];
                return InkWell(
                  borderRadius: AppDimens.brMd,
                  onTap: () => Navigator.of(context).pop(photo),
                  child: ClipRRect(
                    borderRadius: AppDimens.brMd,
                    child: Image.file(
                      File(photo.path),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
