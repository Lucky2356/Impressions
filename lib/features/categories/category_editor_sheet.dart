import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/app_icons.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../app/data_refresh.dart';
import '../../data/db/database.dart';
import '../../data/models/category_tree.dart';
import '../../data/providers.dart';
import '../../data/services/image_service.dart';
import '../../design_system/design_system.dart';
import '../entry/photo_source.dart';
import '../home/home_providers.dart';
import 'category_palette.dart';
import 'category_providers.dart';

/// Оформление ветки: имя, описание, цвет, значок и обложка.
///
/// До 1.16.0 у категории редактировалось только имя и значок, хотя цвет и
/// описание в базе были: цвет вычислялся сам и менялся от того, какой по счёту
/// строкой категория попалась на экран.
class CategoryEditorSheet extends ConsumerStatefulWidget {
  const CategoryEditorSheet({super.key, required this.category});

  final CategoryRow category;

  /// Возвращает `true`, если что-то сохранили.
  static Future<bool> show(BuildContext context, CategoryRow category) async {
    final saved = await showAdaptiveSheet<bool>(
      context,
      width: 520,
      heightFactor: 0.85,
      builder: (_) => CategoryEditorSheet(category: category),
    );
    return saved ?? false;
  }

  @override
  ConsumerState<CategoryEditorSheet> createState() =>
      _CategoryEditorSheetState();
}

class _CategoryEditorSheetState extends ConsumerState<CategoryEditorSheet> {
  late final _name = TextEditingController(text: widget.category.name);
  late final _description = TextEditingController(
    text: widget.category.description ?? '',
  );

  late String? _icon = widget.category.icon;
  late int? _color = widget.category.color;
  late String? _coverId = widget.category.coverAttachmentId;
  late String? _typeId = widget.category.defaultTypeId;

  ImageService get _images => ImageService(ref.read(appDatabaseProvider));

  /// Путь выбранной обложки — только для показа; в базе лежит идентификатор.
  String? _coverPath;
  bool _coverLoaded = false;
  bool _saving = false;

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

  Color get _inheritedTone {
    final all = ref.read(allCategoriesProvider).value ?? const <CategoryRow>[];
    final source = CategoryPalette.inheritedFrom(widget.category, all);
    if (source != null) return Color(source.color!);
    return context.colors.profileColorFor(
      CategoryTree.pathIds(widget.category.path).first,
    );
  }

  Color get _tone => _color == null ? _inheritedTone : Color(_color!);

  Future<void> _pickIcon() async {
    final chosen = await IconPickerSheet.show(
      context,
      title: AppLocalizations.of(context).categoryIcon,
      searchHint: AppLocalizations.of(context).categoryIconSearch,
      selected: _icon,
      tone: _tone,
    );
    if (chosen != null) setState(() => _icon = chosen);
  }

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

  Future<void> _coverFromBranch() async {
    final l10n = AppLocalizations.of(context);
    final all = await ref.read(allCategoriesProvider.future);
    final photos = await ref
        .read(entryRepositoryProvider)
        .branchPhotos(CategoryTree.branchIds(all, widget.category.id));
    if (!mounted) return;
    if (photos.isEmpty) {
      showMessage(context, l10n.categoryCoverNone);
      return;
    }

    final picked =
        await showAdaptiveSheet<({String attachmentId, String path})>(
          context,
          width: 520,
          heightFactor: 0.7,
          builder: (sheetContext) => _BranchPhotoPicker(photos: photos),
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

    final repo = ref.read(categoryRepositoryProvider);
    final name = _name.text.trim();
    if (name.isNotEmpty && name != widget.category.name) {
      await repo.rename(widget.category.id, name);
    }
    final description = _description.text.trim();
    await repo.updateAppearance(
      widget.category.id,
      icon: _icon,
      color: _color,
      description: description.isEmpty ? null : description,
      coverAttachmentId: _coverId,
      defaultTypeId: _typeId,
    );
    ref.read(dataRefreshProvider.notifier).bump();
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    return Padding(
      padding: const EdgeInsets.all(AppDimens.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.categoryAppearance,
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
                _preview(l10n),
                const SizedBox(height: AppDimens.space20),
                TextField(
                  key: const Key('category-name'),
                  controller: _name,
                  decoration: InputDecoration(
                    labelText: l10n.categoryNameLabel,
                  ),
                ),
                const SizedBox(height: AppDimens.space16),
                TextField(
                  key: const Key('category-description'),
                  controller: _description,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: l10n.categoryDescriptionLabel,
                    hintText: l10n.categoryDescriptionHint,
                  ),
                ),
                const SizedBox(height: AppDimens.space20),
                SectionHeader(title: l10n.categoryDefaultType),
                const SizedBox(height: AppDimens.space12),
                _defaultTypeField(l10n),
                const SizedBox(height: AppDimens.space20),
                SectionHeader(title: l10n.categoryColor),
                const SizedBox(height: AppDimens.space12),
                ColorSwatches(
                  value: _color == null ? null : Color(_color!),
                  inheritLabel: l10n.categoryColorInherit,
                  inheritedColor: _inheritedTone,
                  onChanged: (v) => setState(() => _color = v?.toARGB32()),
                ),
                const SizedBox(height: AppDimens.space20),
                SectionHeader(title: l10n.categoryCover),
                const SizedBox(height: AppDimens.space12),
                Wrap(
                  spacing: AppDimens.space8,
                  runSpacing: AppDimens.space8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _coverFromBranch,
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

  /// Тип по умолчанию и подсказка по содержимому ветки.
  ///
  /// Подсказку показываем, а не применяем сами: раньше «самый частый тип в
  /// ветке» подставлялся молча, и объяснить, почему форма предложила именно
  /// его, было нечем.
  Widget _defaultTypeField(AppLocalizations l10n) {
    final types =
        ref.watch(objectTypesProvider).value ?? const <ObjectTypeRow>[];
    final counts =
        ref.watch(branchTypeCountsProvider(widget.category.id)).value ??
        const <String, int>{};

    // Перевес считает база и отдаёт по имени типа: сами записи ветки редактору
    // не нужны.
    ObjectTypeRow? popular;
    var best = 0;
    for (final type in types) {
      final count = counts[type.name] ?? 0;
      if (count > best) {
        popular = type;
        best = count;
      }
    }
    final suggest = popular != null && popular.id != _typeId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppDropdown<String?>(
          label: l10n.categoryDefaultType,
          value: types.any((t) => t.id == _typeId) ? _typeId : null,
          showLabel: false,
          icon: Icons.category_rounded,
          expand: true,
          onChanged: (v) => setState(() => _typeId = v),
          items: [
            DropdownMenuItem(
              value: null,
              child: Text(l10n.categoryDefaultTypeNone),
            ),
            for (final type in types)
              DropdownMenuItem(value: type.id, child: Text(type.name)),
          ],
        ),
        const SizedBox(height: AppDimens.space8),
        Text(
          l10n.categoryDefaultTypeHint,
          style: context.text.labelSmall?.copyWith(
            color: context.colors.textMuted,
          ),
        ),
        if (suggest) ...[
          const SizedBox(height: AppDimens.space8),
          Wrap(
            spacing: AppDimens.space8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                l10n.categoryDefaultTypeSuggest(popular.name),
                style: context.text.labelSmall?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _typeId = popular!.id),
                child: Text(l10n.categoryDefaultTypeApply),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// Как ветка будет выглядеть: значок, цвет и обложка сразу вместе.
  Widget _preview(AppLocalizations l10n) {
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
                InkWell(
                  borderRadius: AppDimens.brMd,
                  onTap: _pickIcon,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: AppDimens.brMd,
                      border: Border.all(color: tone, width: 1.5),
                    ),
                    child: Icon(AppIcons.byKey(_icon), size: 26, color: tone),
                  ),
                ),
                const SizedBox(width: AppDimens.space16),
                Expanded(
                  child: Text(
                    _name.text.trim().isEmpty
                        ? widget.category.name
                        : _name.text.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleLarge,
                  ),
                ),
                TextButton(
                  onPressed: _pickIcon,
                  child: Text(l10n.categoryIcon),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Выбор обложки из фотографий, уже лежащих в ветке.
class _BranchPhotoPicker extends StatelessWidget {
  const _BranchPhotoPicker({required this.photos});

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
