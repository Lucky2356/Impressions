import 'dart:io';
import 'dart:typed_data';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/data_refresh.dart';
import '../../core/config/app_config.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_layout.dart';
import '../../core/theme/theme_context.dart';
import '../../data/providers.dart';
import '../../data/services/backup_service.dart';
import '../../data/services/import_service.dart';
import '../../design_system/design_system.dart';
import 'csv_import_card.dart';

/// Файл, с которым открыли приложение, — ждёт разбора на экране импорта.
///
/// Присланный файл раньше было некуда деть: приложение о нём не знало, и его
/// приходилось искать вручную. Импорт при этом не начинается сам — открывается
/// обычный предпросмотр, из которого человек и решает.
class PendingImportFile extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? path) => state = path;
}

final pendingImportFileProvider = NotifierProvider<PendingImportFile, String?>(
  PendingImportFile.new,
);

/// Импорт профиля (§20, §21): выбор файла → проверки → предпросмотр →
/// резервная копия → применение → итог.
class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  ImportPreview? _preview;
  ImportResult? _result;
  String? _error;
  bool _busy = false;
  bool _dragging = false;
  bool _needPassword = false;
  final _password = TextEditingController();
  Uint8List? _pendingBytes;

  @override
  void initState() {
    super.initState();
    // Экран мог открыться из-за присланного файла — разбираем его сразу.
    WidgetsBinding.instance.addPostFrameCallback((_) => _takePendingFile());
  }

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  /// Забирает файл, с которым открыли приложение.
  Future<void> _takePendingFile() async {
    final path = ref.read(pendingImportFileProvider);
    if (path == null) return;
    ref.read(pendingImportFileProvider.notifier).set(null);

    final file = File(path);
    if (!file.existsSync()) return;
    await _inspect(await file.readAsBytes());
  }

  Future<void> _pickFile() async {
    final typeGroup = XTypeGroup(
      label: AppConfig.appName,
      extensions: [AppConfig.profileFileExtension],
    );
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null) return;
    await _inspect(await file.readAsBytes());
  }

  Future<void> _inspect(Uint8List bytes, {String? password}) async {
    setState(() {
      _busy = true;
      _error = null;
      _result = null;
      _pendingBytes = bytes;
    });
    try {
      final service = ImportService(ref.read(appDatabaseProvider));
      final preview = await service.inspect(bytes, password: password);
      if (!mounted) return;
      setState(() {
        _preview = preview;
        _needPassword = false;
      });
    } on ImportException catch (e) {
      if (!mounted) return;
      setState(() {
        _preview = null;
        // Пакет зашифрован — запрашиваем пароль.
        _needPassword =
            e.problem == ImportProblem.notAnArchive ||
            e.problem == ImportProblem.wrongPassword;
        _error = e.message;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _apply() async {
    final preview = _preview;
    if (preview == null) return;
    final l10n = AppLocalizations.of(context);

    setState(() => _busy = true);
    try {
      final db = ref.read(appDatabaseProvider);
      // Резервная копия перед импортом (§28).
      await BackupService(db).create(reason: 'beforeImport');
      final result = await ImportService(db).apply(preview);
      ref.read(dataRefreshProvider.notifier).bump();
      if (!mounted) return;
      setState(() {
        _result = result;
        _preview = null;
      });
      showMessage(context, l10n.importBackupCreated);
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    final body = ListView(
      padding: EdgeInsets.fromLTRB(
        context.layout.gutter,
        AppDimens.space16,
        context.layout.gutter,
        AppDimens.space40,
      ),
      children: [
        // Зона выбора/перетаскивания файла.
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: _dragging ? c.accentSoft : c.surfaceMuted,
            borderRadius: AppDimens.brLg,
            border: Border.all(color: _dragging ? c.accentPrimary : c.border),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.download_rounded, size: 28, color: c.textMuted),
                const SizedBox(height: AppDimens.space8),
                Text(
                  l10n.importDropHint,
                  style: context.text.bodySmall?.copyWith(color: c.textMuted),
                ),
                const SizedBox(height: AppDimens.space12),
                FilledButton.icon(
                  onPressed: _busy ? null : _pickFile,
                  icon: const Icon(Icons.folder_open_rounded, size: 18),
                  label: Text(l10n.importPickFile),
                ),
              ],
            ),
          ),
        ),

        if (_busy) ...[
          const SizedBox(height: AppDimens.space16),
          const LinearProgressIndicator(),
        ],

        // Перенос списка из таблицы: выгрузка в CSV была, обратного пути не
        // было — список из Excel переносили руками.
        const SizedBox(height: AppDimens.space24),
        const CsvImportCard(),

        if (_needPassword) ...[
          const SizedBox(height: AppDimens.space16),
          Text(l10n.importPasswordNeeded, style: context.text.titleMedium),
          const SizedBox(height: AppDimens.space8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: InputDecoration(labelText: l10n.exportPassword),
                ),
              ),
              const SizedBox(width: AppDimens.space12),
              FilledButton(
                onPressed: _pendingBytes == null
                    ? null
                    : () => _inspect(_pendingBytes!, password: _password.text),
                child: Text(l10n.commonNext),
              ),
            ],
          ),
        ],

        if (_error != null && !_needPassword) ...[
          const SizedBox(height: AppDimens.space16),
          Container(
            padding: const EdgeInsets.all(AppDimens.space16),
            decoration: BoxDecoration(
              color: c.coral.withValues(alpha: 0.12),
              borderRadius: AppDimens.brMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.importErrorTitle,
                  style: context.text.titleMedium?.copyWith(color: c.coral),
                ),
                const SizedBox(height: AppDimens.space4),
                Text(_error!, style: context.text.bodySmall),
              ],
            ),
          ),
        ],

        if (_preview != null) ...[
          const SizedBox(height: AppDimens.space20),
          _PreviewCard(preview: _preview!, onApply: _busy ? null : _apply),
        ],

        if (_result != null) ...[
          const SizedBox(height: AppDimens.space20),
          _ResultCard(result: _result!),
        ],
      ],
    );

    final desktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    return ScreenScaffold(
      header: ScreenHeader(
        title: l10n.importTitle,
        subtitle: l10n.importDropHint,
      ),
      child: desktop
          ? DropTarget(
              onDragEntered: (_) => setState(() => _dragging = true),
              onDragExited: (_) => setState(() => _dragging = false),
              onDragDone: (details) async {
                setState(() => _dragging = false);
                if (details.files.isEmpty) return;
                await _inspect(await details.files.first.readAsBytes());
              },
              child: body,
            )
          : body,
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.preview, required this.onApply});

  final ImportPreview preview;
  final VoidCallback? onApply;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.importPreviewTitle, style: context.text.titleLarge),
          const SizedBox(height: AppDimens.space12),
          Text(
            l10n.importProfileLine(preview.profileName),
            style: context.text.bodyMedium,
          ),
          Text(
            l10n.importFingerprintLine(preview.fingerprint),
            style: context.text.bodySmall?.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: AppDimens.space12),

          // Доверие профилю (§22).
          Container(
            padding: const EdgeInsets.all(AppDimens.space12),
            decoration: BoxDecoration(
              color: c.surfaceMuted,
              borderRadius: AppDimens.brMd,
            ),
            child: Row(
              children: [
                Icon(
                  preview.isKnownProfile
                      ? Icons.verified_rounded
                      : Icons.help_outline_rounded,
                  size: 18,
                  color: preview.isKnownProfile ? c.sage : c.textSecondary,
                ),
                const SizedBox(width: AppDimens.space8),
                Expanded(
                  child: Text(
                    preview.isKnownProfile
                        ? l10n.importVerified
                        : l10n.importTrustQuestion,
                    style: context.text.bodySmall,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimens.space16),
          if (preview.alreadyImported && !preview.hasChanges)
            Text(l10n.importNoChanges, style: context.text.bodyMedium)
          else ...[
            _row(context, l10n.importNewEntries, preview.newEntries),
            _row(context, l10n.importChangedEntries, preview.changedEntries),
            _row(context, l10n.importNewCategories, preview.newCategories),
            _row(context, l10n.importMovedCategories, preview.movedCategories),
            _row(context, l10n.importNewImages, preview.newAttachments),
            _row(context, l10n.importUnchanged, preview.unchanged),
            const SizedBox(height: AppDimens.space16),
            FilledButton.icon(
              onPressed: onApply,
              icon: const Icon(Icons.check_rounded, size: 20),
              label: Text(l10n.importApply),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, int value) {
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
          Text('$value', style: context.text.labelMedium),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});
  final ImportResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_rounded, color: c.sage),
              const SizedBox(width: AppDimens.space8),
              Text(l10n.importDone, style: context.text.titleLarge),
            ],
          ),
          const SizedBox(height: AppDimens.space12),
          Text(
            l10n.importProfileLine(result.profileName),
            style: context.text.bodyMedium,
          ),
          const SizedBox(height: AppDimens.space8),
          Text(
            '${l10n.importNewEntries}: ${result.newEntries}',
            style: context.text.bodySmall,
          ),
          Text(
            '${l10n.importChangedEntries}: ${result.changedEntries}',
            style: context.text.bodySmall,
          ),
          Text(
            '${l10n.importNewCategories}: ${result.newCategories}',
            style: context.text.bodySmall,
          ),
          Text(
            '${l10n.importNewImages}: ${result.newImages}',
            style: context.text.bodySmall,
          ),
          Text(
            '${l10n.importUnchanged}: ${result.unchanged}',
            style: context.text.bodySmall,
          ),
        ],
      ),
    );
  }
}
