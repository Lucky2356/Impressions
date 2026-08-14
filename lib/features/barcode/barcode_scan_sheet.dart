import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../app/app_state.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/providers.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/services/barcode_decoder.dart';
import '../../data/services/product_lookup_service.dart';
import '../../design_system/design_system.dart';

/// Результат сканирования: сам код и найденные о нём сведения.
class ScannedProduct {
  const ScannedProduct({required this.code, this.info});

  final DecodedCode code;
  final ProductInfo? info;

  /// Название для подстановки в форму.
  String get suggestedTitle {
    final title = info?.displayTitle;
    if (title != null && title.isNotEmpty) return title;
    // QR с произвольным текстом — берём сам текст.
    return code.isProductCode ? code.value : code.value;
  }
}

/// Добавление товара по штрихкоду или QR-коду.
///
/// Способ ввода зависит от платформы: на Android — камера, на Windows —
/// поле ввода (USB-сканеры печатают код как клавиатура) и распознавание с
/// фотографии или снимка экрана. Ручной ввод доступен везде, поэтому функция
/// работает и без сети, и без камеры.
class BarcodeScanSheet extends ConsumerStatefulWidget {
  const BarcodeScanSheet({super.key, this.batch = false});

  /// Сканируем подряд: код за кодом, без закрытия окна.
  ///
  /// Разбирая пакет из магазина, сканер открывали заново на каждую позицию —
  /// а позиций в пакете десяток.
  final bool batch;

  static Future<ScannedProduct?> show(BuildContext context) async {
    final result = await _open(context, batch: false);
    return result == null || result.isEmpty ? null : result.first;
  }

  /// Пачка: возвращает всё отсканированное подряд.
  static Future<List<ScannedProduct>> showBatch(BuildContext context) async {
    return await _open(context, batch: true) ?? const [];
  }

  static Future<List<ScannedProduct>?> _open(
    BuildContext context, {
    required bool batch,
  }) {
    return showAdaptiveSheet<List<ScannedProduct>>(
      context,
      builder: (_) => BarcodeScanSheet(batch: batch),
    );
  }

  @override
  ConsumerState<BarcodeScanSheet> createState() => _BarcodeScanSheetState();
}

class _BarcodeScanSheetState extends ConsumerState<BarcodeScanSheet> {
  final _codeController = TextEditingController();
  final _codeFocus = FocusNode();

  bool _busy = false;
  String? _error;
  DecodedCode? _code;
  ProductInfo? _info;
  Map<String, String> _sourceErrors = const {};
  bool _lookupDone = false;

  /// Что уже отсканировано в этом заходе.
  final _collected = <ScannedProduct>[];

  /// Сканируем подряд. Переключатель внутри окна, а не отдельный вход: так
  /// режим виден там, где он и нужен, — с кодом в руках.
  late bool _batch = widget.batch;

  /// Камера доступна только на мобильных платформах.
  bool get _cameraAvailable => Platform.isAndroid || Platform.isIOS;

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  /// Забирает распознанное: по одному — закрывает окно, пачкой — копит.
  void _take() {
    final code = _code;
    if (code == null) return;
    final product = ScannedProduct(code: code, info: _info);

    if (!_batch) {
      Navigator.of(context).pop([product]);
      return;
    }

    setState(() {
      _collected.add(product);
      // Готовимся к следующему коду: поле и результат очищаются, окно остаётся.
      _code = null;
      _info = null;
      _lookupDone = false;
      _sourceErrors = const {};
      _codeController.clear();
    });
    _codeFocus.requestFocus();
  }

  Future<void> _submitManual() async {
    final value = _codeController.text.trim();
    if (value.isEmpty) return;
    final format = ProductLookupService.isGtin(value) ? 'EAN-13' : 'QR';
    await _accept(DecodedCode(value: value, format: format));
  }

  /// Принимает распознанный код и, если разрешено, ищет о нём сведения.
  Future<void> _accept(DecodedCode code) async {
    setState(() {
      _code = code;
      _info = null;
      _error = null;
      _lookupDone = false;
      _busy = true;
    });

    try {
      final settings = ref.read(settingsRepositoryProvider);
      final allowed = await settings.getBool(
        SettingKeys.barcodeLookupEnabled,
        defaultValue: true,
      );
      if (!allowed || !code.isProductCode) {
        setState(() => _lookupDone = true);
        return;
      }

      final sources = await ref.read(updateServiceProvider).enabledSources();
      final result = await ref
          .read(productLookupProvider)
          .lookup(code.value, enabledSourceIds: sources);
      if (!mounted) return;
      setState(() {
        _info = result.info;
        _sourceErrors = result.errors;
        _lookupDone = true;
      });
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Распознаёт код с изображения: фотография кода или снимок экрана.
  Future<void> _fromImage({required bool fromCamera}) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      Uint8List? bytes;
      if (fromCamera) {
        final shot = await ImagePicker().pickImage(source: ImageSource.camera);
        bytes = shot == null ? null : await shot.readAsBytes();
      } else {
        const type = XTypeGroup(
          label: 'Изображения',
          extensions: ['png', 'jpg', 'jpeg', 'webp', 'bmp'],
        );
        final file = await openFile(acceptedTypeGroups: const [type]);
        bytes = file == null ? null : await file.readAsBytes();
      }
      if (bytes == null) {
        if (mounted) setState(() => _busy = false);
        return;
      }

      final decoded = ref.read(barcodeDecoderProvider).decodeImage(bytes);
      if (!mounted) return;
      if (decoded == null) {
        final l10n = AppLocalizations.of(context);
        setState(() {
          _busy = false;
          _error = l10n.barcodeNotRecognized;
        });
        return;
      }
      await _accept(decoded);
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = '$e';
        });
      }
    }
  }

  Future<void> _openCamera() async {
    final result = await showDialog<DecodedCode>(
      context: context,
      builder: (_) => const _CameraScannerDialog(),
    );
    if (result != null) await _accept(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.space20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.barcodeTitle,
                      style: context.text.headlineSmall,
                    ),
                  ),
                  // Пачкой или по одному — решают здесь же, с кодом в руках.
                  Tooltip(
                    message: l10n.barcodeBatchTitle,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.barcodeBatchTitle,
                          style: context.text.labelSmall,
                        ),
                        Switch(
                          value: _batch,
                          onChanged: (v) => setState(() => _batch = v),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.commonClose,
                    onPressed: () =>
                        Navigator.of(context).pop(List.of(_collected)),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.space4),
              Text(
                _cameraAvailable
                    ? l10n.barcodeHintMobile
                    : l10n.barcodeHintDesktop,
                style: context.text.bodySmall?.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: AppDimens.space20),

              // Ввод кода: сюда же печатает USB-сканер.
              TextField(
                controller: _codeController,
                focusNode: _codeFocus,
                autofocus: !_cameraAvailable,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Za-z\-]')),
                ],
                onSubmitted: (_) => _submitManual(),
                decoration: InputDecoration(
                  labelText: l10n.barcodeCodeLabel,
                  hintText: '4600682000594',
                  prefixIcon: const Icon(Icons.qr_code_2_rounded),
                  suffixIcon: IconButton(
                    tooltip: l10n.barcodeLookup,
                    onPressed: _busy ? null : _submitManual,
                    icon: const Icon(Icons.arrow_forward_rounded),
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.space12),

              Wrap(
                spacing: AppDimens.space8,
                runSpacing: AppDimens.space8,
                children: [
                  if (_cameraAvailable)
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _openCamera,
                      icon: const Icon(Icons.photo_camera_rounded, size: 18),
                      label: Text(l10n.barcodeUseCamera),
                    ),
                  if (_cameraAvailable)
                    OutlinedButton.icon(
                      onPressed: _busy
                          ? null
                          : () => _fromImage(fromCamera: true),
                      icon: const Icon(Icons.add_a_photo_rounded, size: 18),
                      label: Text(l10n.barcodePhoto),
                    ),
                  OutlinedButton.icon(
                    onPressed: _busy
                        ? null
                        : () => _fromImage(fromCamera: false),
                    icon: const Icon(Icons.image_search_rounded, size: 18),
                    label: Text(l10n.barcodeFromFile),
                  ),
                ],
              ),

              if (_busy) ...[
                const SizedBox(height: AppDimens.space20),
                const LinearProgressIndicator(minHeight: 3),
              ],

              if (_error != null) ...[
                const SizedBox(height: AppDimens.space16),
                _Banner(
                  icon: Icons.error_outline_rounded,
                  color: c.coral,
                  text: _error!,
                ),
              ],

              // Сколько уже собрано и кнопка «хватит»: в пачке результат
              // отдаётся не по одному коду, а целиком.
              if (_batch && _collected.isNotEmpty) ...[
                const SizedBox(height: AppDimens.space16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.barcodeBatchCollected(_collected.length),
                        style: context.text.labelMedium,
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () =>
                          Navigator.of(context).pop(List.of(_collected)),
                      icon: const Icon(Icons.done_all_rounded, size: 18),
                      label: Text(l10n.barcodeBatchFinish),
                    ),
                  ],
                ),
              ],

              if (_code != null && !_busy) ...[
                const SizedBox(height: AppDimens.space20),
                _ResultCard(
                  code: _code!,
                  info: _info,
                  lookupDone: _lookupDone,
                  sourceErrors: _sourceErrors,
                ),
                const SizedBox(height: AppDimens.space20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l10n.commonCancel),
                      ),
                    ),
                    const SizedBox(width: AppDimens.space12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _take,
                        child: Text(
                          _batch
                              ? l10n.barcodeBatchNext
                              : l10n.barcodeUseResult,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Карточка найденного товара.
class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.code,
    required this.info,
    required this.lookupDone,
    required this.sourceErrors,
  });

  final DecodedCode code;
  final ProductInfo? info;
  final bool lookupDone;
  final Map<String, String> sourceErrors;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final product = info;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                code.isProductCode
                    ? Icons.qr_code_scanner_rounded
                    : Icons.link_rounded,
                size: 18,
                color: c.accentPrimary,
              ),
              const SizedBox(width: AppDimens.space8),
              Text(code.value, style: context.text.titleMedium),
              const SizedBox(width: AppDimens.space8),
              StatusChip(label: code.format, compact: true),
            ],
          ),
          const SizedBox(height: AppDimens.space12),
          if (product != null) ...[
            Text(product.displayTitle, style: context.text.titleLarge),
            if (product.categories.isNotEmpty) ...[
              const SizedBox(height: AppDimens.space4),
              Text(
                product.categories.take(3).join(' · '),
                style: context.text.bodySmall?.copyWith(color: c.textSecondary),
              ),
            ],
            if (product.source != null) ...[
              const SizedBox(height: AppDimens.space8),
              Text(
                l10n.barcodeFoundIn(product.source!),
                style: context.text.labelSmall?.copyWith(color: c.textMuted),
              ),
            ],
          ] else if (lookupDone) ...[
            Text(
              sourceErrors.isEmpty
                  ? l10n.barcodeNotFound
                  : l10n.barcodeLookupFailed,
              style: context.text.bodyMedium,
            ),
            const SizedBox(height: AppDimens.space4),
            Text(
              l10n.barcodeFillManually,
              style: context.text.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.icon, required this.color, required this.text});

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.space12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: AppDimens.brMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppDimens.space8),
          Expanded(child: Text(text, style: context.text.bodySmall)),
        ],
      ),
    );
  }
}

/// Камера со сканером (только Android/iOS).
class _CameraScannerDialog extends StatefulWidget {
  const _CameraScannerDialog();

  @override
  State<_CameraScannerDialog> createState() => _CameraScannerDialogState();
}

class _CameraScannerDialogState extends State<_CameraScannerDialog> {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value == null || value.trim().isEmpty) continue;
      _handled = true;
      final format = switch (barcode.format) {
        BarcodeFormat.ean13 => 'EAN-13',
        BarcodeFormat.ean8 => 'EAN-8',
        BarcodeFormat.upcA => 'UPC-A',
        BarcodeFormat.upcE => 'UPC-E',
        BarcodeFormat.qrCode => 'QR',
        _ => 'CODE',
      };
      Navigator.of(
        context,
      ).pop(DecodedCode(value: value.trim(), format: format));
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 420,
        height: 520,
        child: Stack(
          children: [
            MobileScanner(controller: _controller, onDetect: _onDetect),
            Positioned(
              top: AppDimens.space8,
              right: AppDimens.space8,
              child: Row(
                children: [
                  IconButton.filledTonal(
                    tooltip: l10n.barcodeTorch,
                    onPressed: _controller.toggleTorch,
                    icon: const Icon(Icons.flashlight_on_rounded),
                  ),
                  const SizedBox(width: AppDimens.space8),
                  IconButton.filledTonal(
                    tooltip: l10n.commonClose,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
