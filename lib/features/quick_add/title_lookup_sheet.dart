import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/services/title_lookup_service.dart';
import '../../design_system/design_system.dart';

/// Выбор варианта, найденного по названию.
///
/// Вариантов всегда несколько, и подставлять первый попавшийся нельзя:
/// «Солярис» — это фильм 1968 года, фильм Тарковского и фильм Содерберга.
/// Поэтому лист показывает список, а решает человек.
class TitleLookupSheet extends ConsumerStatefulWidget {
  const TitleLookupSheet({super.key, required this.query, this.initialKind});

  final String query;

  /// С какого вида начать. Тип записи заводит человек и может переименовать,
  /// поэтому вид здесь выбирается отдельно, а не выводится из типа.
  final LookupKind? initialKind;

  /// Возвращает выбранный вариант или null, если человек закрыл лист.
  static Future<TitleMatch?> show(
    BuildContext context, {
    required String query,
    LookupKind? initialKind,
  }) {
    return showAdaptiveSheet<TitleMatch>(
      context,
      builder: (_) => TitleLookupSheet(query: query, initialKind: initialKind),
    );
  }

  @override
  ConsumerState<TitleLookupSheet> createState() => _TitleLookupSheetState();
}

class _TitleLookupSheetState extends ConsumerState<TitleLookupSheet> {
  late LookupKind _kind = widget.initialKind ?? LookupKind.film;
  late final TitleLookupService _service = TitleLookupService();

  List<TitleMatch>? _found;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _search();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() {
      _busy = true;
      _found = null;
    });
    final found = await _service.lookup(widget.query, _kind);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _found = found;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    String label(LookupKind kind) => switch (kind) {
      LookupKind.book => l10n.lookupKindBook,
      LookupKind.film => l10n.lookupKindFilm,
      LookupKind.series => l10n.lookupKindSeries,
      LookupKind.game => l10n.lookupKindGame,
    };

    final found = _found;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.space20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.lookupTitle,
                    style: context.text.headlineSmall,
                  ),
                ),
                IconButton(
                  tooltip: l10n.commonClose,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.space8),
            Text(
              widget.query,
              style: context.text.titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppDimens.space12),
            Wrap(
              spacing: AppDimens.space8,
              children: [
                for (final kind in LookupKind.values)
                  ChoiceChip(
                    label: Text(label(kind)),
                    selected: _kind == kind,
                    onSelected: _busy
                        ? null
                        : (_) {
                            setState(() => _kind = kind);
                            _search();
                          },
                  ),
              ],
            ),
            const SizedBox(height: AppDimens.space16),
            if (_busy)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimens.space24,
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: AppDimens.space12),
                    Text(l10n.lookupSearching, style: context.text.bodyMedium),
                  ],
                ),
              )
            else if (found == null || found.isEmpty)
              // «Ничего не нашлось» и «нет сети» человеку одинаковы: подставить
              // всё равно нечего, и подсказка одна — заполните сами.
              EmptyState(
                icon: Icons.search_off_rounded,
                title: l10n.lookupNothing,
                message: l10n.lookupNothingHint,
              )
            else
              for (final match in found)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(match.title),
                  subtitle: match.subtitle.isEmpty
                      ? null
                      : Text(match.subtitle),
                  trailing: Text(
                    match.source,
                    style: context.text.labelSmall?.copyWith(
                      color: c.textMuted,
                    ),
                  ),
                  onTap: () => Navigator.of(context).pop(match),
                ),
          ],
        ),
      ),
    );
  }
}
