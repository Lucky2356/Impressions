import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';

/// Короткая отметка «Сохранено» рядом с полем, которое сохраняется само.
///
/// Нажатие на оценку или отношение видно по самому переключателю, а заметка и
/// прогресс уходят в базу молча — на экране не меняется ничего, и понять,
/// записалось ли набранное, нечем. Снек для этого не годится: он перекрывает
/// содержимое и появлялся бы после каждого поля.
///
/// Место под отметку занято всегда, поэтому её появление ничего не сдвигает.
class SavedFlash extends StatefulWidget {
  const SavedFlash({super.key, required this.tick});

  /// Счётчик сохранений: вырос — значит, было что сохранять.
  final int tick;

  @override
  State<SavedFlash> createState() => _SavedFlashState();
}

class _SavedFlashState extends State<SavedFlash> {
  static const _visible = Duration(seconds: 2);

  bool _show = false;
  Timer? _timer;

  @override
  void didUpdateWidget(SavedFlash old) {
    super.didUpdateWidget(old);
    if (widget.tick == old.tick) return;
    setState(() => _show = true);
    _timer?.cancel();
    _timer = Timer(_visible, () {
      if (mounted) setState(() => _show = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return SizedBox(
      height: AppDimens.space20,
      child: Align(
        alignment: Alignment.centerRight,
        child: AnimatedOpacity(
          opacity: _show ? 1 : 0,
          duration: AppDimens.durationFast,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_rounded, size: 14, color: c.textMuted),
              const SizedBox(width: AppDimens.space4),
              Text(
                l10n.savedShort,
                style: context.text.labelSmall?.copyWith(color: c.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
