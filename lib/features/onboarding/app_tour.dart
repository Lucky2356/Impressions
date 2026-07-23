import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/data_refresh.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../app/app_state.dart';
import '../../data/repositories/settings_repository.dart';
import '../../design_system/design_system.dart';

/// Показывалось ли обучение.
final tourDoneProvider = FutureProvider<bool>((ref) async {
  ref.watch(dataRefreshProvider);
  return ref
      .read(settingsRepositoryProvider)
      .getBool(SettingKeys.tourDone, defaultValue: false);
});

/// Один шаг обучения.
class _Step {
  const _Step({
    required this.icon,
    required this.title,
    required this.body,
    this.hint,
  });

  final IconData icon;
  final String title;
  final String body;

  /// Подсказка про способ ввода: на Windows это горячая клавиша, на телефоне —
  /// жест. Одна и та же фраза для обеих платформ была бы наполовину неверной.
  final String? hint;
}

/// Короткое обучение по разделам.
///
/// Онбординг объясняет модель — зачем профили и чем объект отличается от
/// мнения. Здесь другое: где что лежит и как это делать быстро. Показывается
/// один раз после первого запуска, повторно вызывается из настроек.
class AppTour extends ConsumerStatefulWidget {
  const AppTour({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: const AppTour(),
        ),
      ),
    );
  }

  @override
  ConsumerState<AppTour> createState() => _AppTourState();
}

class _AppTourState extends ConsumerState<AppTour> {
  int _index = 0;

  static bool get _isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  List<_Step> _steps(AppLocalizations l10n) => [
    _Step(
      icon: Icons.add_circle_outline_rounded,
      title: l10n.tourAddTitle,
      body: l10n.tourAddBody,
      hint: _isDesktop ? l10n.tourAddHintDesktop : l10n.tourAddHintMobile,
    ),
    _Step(
      icon: Icons.qr_code_scanner_rounded,
      title: l10n.tourScanTitle,
      body: _isDesktop ? l10n.tourScanBodyDesktop : l10n.tourScanBodyMobile,
      hint: _isDesktop ? l10n.tourScanHintDesktop : null,
    ),
    _Step(
      icon: Icons.grid_view_rounded,
      title: l10n.tourShelvesTitle,
      body: l10n.tourShelvesBody,
    ),
    _Step(
      icon: Icons.search_rounded,
      title: l10n.tourSearchTitle,
      body: l10n.tourSearchBody,
      hint: _isDesktop ? l10n.tourSearchHintDesktop : null,
    ),
    _Step(
      icon: Icons.checklist_rounded,
      title: l10n.tourBulkTitle,
      body: _isDesktop ? l10n.tourBulkBodyDesktop : l10n.tourBulkBodyMobile,
    ),
    _Step(
      icon: Icons.shield_outlined,
      title: l10n.tourSafetyTitle,
      body: l10n.tourSafetyBody,
    ),
  ];

  Future<void> _finish() async {
    await ref
        .read(settingsRepositoryProvider)
        .setBool(SettingKeys.tourDone, true);
    ref.read(dataRefreshProvider.notifier).bump();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final steps = _steps(l10n);
    final step = steps[_index];
    final last = _index == steps.length - 1;

    return Padding(
      padding: const EdgeInsets.all(AppDimens.space24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppLogo(size: 28),
              const SizedBox(width: AppDimens.space12),
              Expanded(
                child: Text(l10n.tourTitle, style: context.text.titleMedium),
              ),
              TextButton(onPressed: _finish, child: Text(l10n.tourSkip)),
            ],
          ),
          const SizedBox(height: AppDimens.space20),
          // Шаги сменяются с плавным переходом: резкая подмена текста читается
          // как сбой, а не как «следующая страница».
          AnimatedSwitcher(
            duration: AppDimens.durationMedium,
            child: Column(
              key: ValueKey(_index),
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: c.accentSoft,
                    borderRadius: AppDimens.brMd,
                  ),
                  child: Icon(step.icon, size: 26, color: c.accentPrimary),
                ),
                const SizedBox(height: AppDimens.space16),
                Text(step.title, style: context.text.headlineSmall),
                const SizedBox(height: AppDimens.space8),
                Text(
                  step.body,
                  style: context.text.bodyMedium?.copyWith(
                    color: c.textSecondary,
                  ),
                ),
                if (step.hint != null) ...[
                  const SizedBox(height: AppDimens.space12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.space12,
                      vertical: AppDimens.space8,
                    ),
                    decoration: BoxDecoration(
                      color: c.surfaceMuted,
                      borderRadius: AppDimens.brSm,
                      border: Border.all(color: c.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          size: 16,
                          color: c.textMuted,
                        ),
                        const SizedBox(width: AppDimens.space8),
                        Expanded(
                          child: Text(
                            step.hint!,
                            style: context.text.labelSmall?.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppDimens.space24),
          Row(
            children: [
              for (var i = 0; i < steps.length; i++)
                AnimatedContainer(
                  duration: AppDimens.durationFast,
                  margin: const EdgeInsets.only(right: 6),
                  width: i == _index ? 20 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: i == _index ? c.accentPrimary : c.border,
                    borderRadius: AppDimens.brPill,
                  ),
                ),
              const Spacer(),
              if (_index > 0)
                TextButton(
                  onPressed: () => setState(() => _index--),
                  child: Text(l10n.commonBack),
                ),
              const SizedBox(width: AppDimens.space8),
              FilledButton(
                onPressed: last ? _finish : () => setState(() => _index++),
                child: Text(last ? l10n.tourFinish : l10n.tourNext),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
