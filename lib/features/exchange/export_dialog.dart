import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/db/database.dart';
import '../../core/domain/relation.dart';
import '../../data/providers.dart';
import '../../data/services/readable_export_service.dart';
import '../../data/services/export_service.dart';
import '../categories/category_providers.dart';
import '../collections/collection_providers.dart';

/// Экспорт профиля (§19): состав пакета показывается до сохранения файла.
class ExportDialog extends ConsumerStatefulWidget {
  const ExportDialog({super.key, required this.profile});

  final ProfileRow profile;

  static Future<void> show(BuildContext context, ProfileRow profile) {
    return showDialog(
      context: context,
      builder: (_) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: SizedBox(width: 560, child: ExportDialog(profile: profile)),
      ),
    );
  }

  @override
  ConsumerState<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends ConsumerState<ExportDialog> {
  final _password = TextEditingController();
  bool _includePhotos = true;
  bool _protect = false;
  bool _busy = false;
  ExportSummary? _summary;

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  ExportMode _mode = ExportMode.full;
  String? _branchId;
  String? _collectionId;

  ExportOptions get _options => ExportOptions(
    mode: _mode,
    includePhotos: _includePhotos,
    password: _protect ? _password.text : null,
    categoryId: _mode == ExportMode.branch ? _branchId : null,
    collectionId: _mode == ExportMode.collection ? _collectionId : null,
  );

  Future<void> _loadPreview() async {
    final service = ExportService(ref.read(appDatabaseProvider));
    final summary = await service.preview(widget.profile.id, _options);
    if (!mounted) return;
    setState(() => _summary = summary);
  }

  Future<void> _export() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final service = ExportService(ref.read(appDatabaseProvider));
      final result = await service.export(widget.profile.id, _options);

      final location = await getSaveLocation(
        suggestedName: ExportService.suggestFileName(widget.profile.firstName),
        acceptedTypeGroups: [
          XTypeGroup(
            label: AppConfig.appName,
            extensions: [AppConfig.profileFileExtension],
          ),
        ],
      );
      if (!mounted) return;
      if (location == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.exportCancelled)));
        return;
      }

      await File(location.path).writeAsBytes(result.bytes, flush: true);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.exportSaved(location.path))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Выгрузка в читаемый вид: таблица или текст вместо контейнера обмена.
  ///
  /// Без подписи и вложений — это не формат обмена, а способ открыть свои
  /// записи в таблице или распечатать их.
  Future<void> _exportReadable(ReadableFormat format) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final entries = await ref
          .read(entryRepositoryProvider)
          .entryViews(widget.profile.id);

      String relationLabel(String? name) {
        if (name == null) return '';
        for (final r in Relation.values) {
          if (r.name == name) return r.label(l10n);
        }
        return name;
      }

      const service = ReadableExportService();
      final text = service.build(
        entries: entries,
        format: format,
        profileName: widget.profile.firstName,
        relationLabel: relationLabel,
      );
      final extension = service.extensionFor(format);

      final location = await getSaveLocation(
        suggestedName: 'Впечатления-${widget.profile.firstName}.$extension',
        acceptedTypeGroups: [
          XTypeGroup(label: extension.toUpperCase(), extensions: [extension]),
        ],
      );
      if (!mounted) return;
      if (location == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.exportCancelled)));
        return;
      }

      await File(location.path).writeAsString(text, flush: true);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.exportSaved(location.path))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final summary = _summary;

    // Повторная передача чужого профиля может быть запрещена владельцем (§19).
    final forbidden =
        widget.profile.type != 'myPrimary' &&
        widget.profile.retransmitMode == 'forbidden';

    return Padding(
      padding: const EdgeInsets.all(AppDimens.space20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.exportTitle,
                  style: context.text.headlineSmall,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space8),
          Text(widget.profile.firstName, style: context.text.titleLarge),
          const SizedBox(height: AppDimens.space16),

          if (forbidden)
            Container(
              padding: const EdgeInsets.all(AppDimens.space16),
              decoration: BoxDecoration(
                color: c.surfaceMuted,
                borderRadius: AppDimens.brMd,
              ),
              child: Text(l10n.exportForbidden, style: context.text.bodyMedium),
            )
          else ...[
            // Что экспортировать: весь профиль, ветка категории, подборка (§19).
            _ExportModeSelector(
              profileId: widget.profile.id,
              mode: _mode,
              branchId: _branchId,
              collectionId: _collectionId,
              onChanged: (mode, branchId, collectionId) {
                setState(() {
                  _mode = mode;
                  _branchId = branchId;
                  _collectionId = collectionId;
                });
                _loadPreview();
              },
            ),
            const SizedBox(height: AppDimens.space8),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _includePhotos,
              onChanged: (v) {
                setState(() => _includePhotos = v);
                _loadPreview();
              },
              title: Text(
                l10n.exportIncludePhotos,
                style: context.text.bodyMedium,
              ),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _protect,
              onChanged: (v) => setState(() => _protect = v),
              title: Text(l10n.exportProtect, style: context.text.bodyMedium),
            ),
            if (_protect)
              TextField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(labelText: l10n.exportPassword),
              ),
            const SizedBox(height: AppDimens.space16),

            // Состав пакета до сохранения (§19).
            Text(l10n.exportComposition, style: context.text.titleMedium),
            const SizedBox(height: AppDimens.space8),
            if (summary == null)
              const LinearProgressIndicator()
            else
              Container(
                padding: const EdgeInsets.all(AppDimens.space16),
                decoration: BoxDecoration(
                  color: c.surfaceMuted,
                  borderRadius: AppDimens.brMd,
                ),
                child: Column(
                  children: [
                    _row(l10n.exportEntries, '${summary.entries}'),
                    _row(l10n.exportCategories, '${summary.categories}'),
                    _row(l10n.exportSubcategories, '${summary.subcategories}'),
                    _row(l10n.exportObjects, '${summary.objects}'),
                    _row(l10n.exportRevisions, '${summary.revisions}'),
                    _row(l10n.exportPhotos, '${summary.attachments}'),
                    if (summary.excludedPrivate > 0)
                      _row(
                        l10n.exportExcludedPrivate,
                        '${summary.excludedPrivate}',
                      ),
                  ],
                ),
              ),
            const SizedBox(height: AppDimens.space20),
            PopupMenuButton<ReadableFormat>(
              tooltip: '',
              enabled: !_busy,
              onSelected: _exportReadable,
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: ReadableFormat.csv,
                  height: 40,
                  child: Row(
                    children: [
                      const Icon(Icons.table_chart_rounded, size: 18),
                      const SizedBox(width: AppDimens.space12),
                      Text(l10n.exportCsv),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: ReadableFormat.markdown,
                  height: 40,
                  child: Row(
                    children: [
                      const Icon(Icons.description_rounded, size: 18),
                      const SizedBox(width: AppDimens.space12),
                      Text(l10n.exportMarkdown),
                    ],
                  ),
                ),
              ],
              child: OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.download_rounded, size: 18),
                label: Text(l10n.exportReadable),
              ),
            ),
            const SizedBox(width: AppDimens.space8),
            FilledButton.icon(
              onPressed: _busy ? null : _export,
              icon: const Icon(Icons.upload_rounded, size: 20),
              label: Text(l10n.exportAction),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: context.text.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ),
          Text(value, style: context.text.labelMedium),
        ],
      ),
    );
  }
}

/// Выбор объёма экспорта: весь профиль, ветка категории или подборка (§19).
class _ExportModeSelector extends ConsumerWidget {
  const _ExportModeSelector({
    required this.profileId,
    required this.mode,
    required this.branchId,
    required this.collectionId,
    required this.onChanged,
  });

  final String profileId;
  final ExportMode mode;
  final String? branchId;
  final String? collectionId;
  final void Function(ExportMode mode, String? branchId, String? collectionId)
  onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final categories = ref.watch(allCategoriesProvider).value ?? const [];
    final collections = ref.watch(collectionsProvider).value ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.exportModeLabel, style: context.text.labelSmall),
        const SizedBox(height: AppDimens.space8),
        Wrap(
          spacing: AppDimens.space8,
          children: [
            ChoiceChip(
              selected: mode == ExportMode.full,
              onSelected: (_) => onChanged(ExportMode.full, null, null),
              label: Text(l10n.exportModeFull),
            ),
            if (categories.isNotEmpty)
              ChoiceChip(
                selected: mode == ExportMode.branch,
                onSelected: (_) => onChanged(
                  ExportMode.branch,
                  branchId ?? categories.first.id,
                  null,
                ),
                label: Text(l10n.exportModeBranch),
              ),
            if (collections.isNotEmpty)
              ChoiceChip(
                selected: mode == ExportMode.collection,
                onSelected: (_) => onChanged(
                  ExportMode.collection,
                  null,
                  collectionId ?? collections.first.collection.id,
                ),
                label: Text(l10n.exportModeCollection),
              ),
          ],
        ),
        if (mode == ExportMode.branch && categories.isNotEmpty) ...[
          const SizedBox(height: AppDimens.space8),
          DropdownButtonFormField<String>(
            initialValue: branchId ?? categories.first.id,
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.exportModeBranch),
            items: [
              for (final cat in categories)
                DropdownMenuItem(
                  value: cat.id,
                  child: Text('${'  ' * cat.level}${cat.name}'),
                ),
            ],
            onChanged: (v) => onChanged(ExportMode.branch, v, null),
          ),
        ],
        if (mode == ExportMode.collection && collections.isNotEmpty) ...[
          const SizedBox(height: AppDimens.space8),
          DropdownButtonFormField<String>(
            initialValue: collectionId ?? collections.first.collection.id,
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.exportModeCollection),
            items: [
              for (final v in collections)
                DropdownMenuItem(
                  value: v.collection.id,
                  child: Text(v.collection.name),
                ),
            ],
            onChanged: (v) => onChanged(ExportMode.collection, null, v),
          ),
        ],
      ],
    );
  }
}
