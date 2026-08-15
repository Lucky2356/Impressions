import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/relation.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../core/utils/dates.dart';
import '../../data/models/entry_view.dart';
import '../../data/repositories/year_review.dart';
import '../../design_system/design_system.dart';
import '../entry/entry_detail_sheet.dart';
import 'year_providers.dart';
import 'year_share_card.dart';

/// Итоги года (§14): ретроспектива, которую листают.
///
/// Экран статистики отвечает на вопрос «каковы мои вкусы» и отвечает
/// распределениями. Здесь другой вопрос — «каким был этот год», — и таблицы на
/// него не отвечают: год вспоминают событиями, а не долями.
class YearScreen extends ConsumerWidget {
  const YearScreen({super.key});

  /// Открывает итоги отдельным экраном поверх текущего.
  ///
  /// Не разделом навигации: к итогам возвращаются раз в год, а место в
  /// боковой панели занимают постоянно.
  static Future<void> show(BuildContext context) {
    return Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const YearScreen()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final year = ref.watch(yearReviewYearProvider);
    final review = ref.watch(yearReviewProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.yearTitle),
        actions: [
          IconButton(
            tooltip: l10n.yearPrevious,
            onPressed: () =>
                ref.read(yearReviewYearProvider.notifier).set(year - 1),
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Center(child: Text('$year', style: context.text.titleMedium)),
          IconButton(
            tooltip: l10n.yearNext,
            onPressed: year >= DateTime.now().year
                ? null
                : () => ref.read(yearReviewYearProvider.notifier).set(year + 1),
            icon: const Icon(Icons.chevron_right_rounded),
          ),
          const SizedBox(width: AppDimens.space8),
        ],
      ),
      body: review == null
          ? const Center(child: CircularProgressIndicator())
          : review.isEmpty
          ? EmptyState(
              icon: Icons.celebration_outlined,
              title: l10n.yearEmptyTitle,
              message: l10n.yearEmptyMessage('$year'),
            )
          : _Pages(review: review),
    );
  }
}

/// Карточки листаются, а не прокручиваются списком: каждая — одно
/// утверждение о годе, и следующее должно приходить по одному.
class _Pages extends StatefulWidget {
  const _Pages({required this.review});

  final YearReview review;

  @override
  State<_Pages> createState() => _PagesState();
}

class _PagesState extends State<_Pages> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    final c = context.colors;

    final pages = <Widget>[
      _TotalCard(review: review),
      if (review.best.isNotEmpty) _BestCard(review: review),
      if (review.topCategory != null || review.busiestMonth != null)
        _PlacesCard(review: review),
      if (review.first != null) _EdgesCard(review: review),
      YearShareCard(review: review),
    ];

    return Column(
      children: [
        Expanded(
          child: PageView(
            controller: _controller,
            onPageChanged: (i) => setState(() => _page = i),
            children: [
              for (final page in pages)
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.space24),
                      child: page,
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Точки-указатели: без них непонятно, что карточек несколько и что
        // они кончаются.
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimens.space24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < pages.length; i++)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppDimens.space4,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _page ? c.accentPrimary : c.border,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Крупное число с подписью — общий вид всех карточек года.
class _YearCard extends StatelessWidget {
  const _YearCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppDimens.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: context.text.labelMedium?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimens.space16),
          Flexible(child: child),
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.review});
  final YearReview review;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    return _YearCard(
      title: l10n.yearYours('${review.year}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${review.total}', style: context.text.displayLarge),
          Text(
            l10n.yearImpressions(review.total),
            style: context.text.titleMedium?.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: AppDimens.space24),
          if (review.averageRating != null)
            _Line(
              icon: Icons.star_rounded,
              label: l10n.yearAverage(
                review.averageRating!.toStringAsFixed(1),
                review.rated,
              ),
            ),
          if (review.finished > 0)
            _Line(
              icon: Icons.check_circle_rounded,
              label: l10n.yearFinished(review.finished),
            ),
          if (review.newCategories > 0)
            _Line(
              icon: Icons.account_tree_rounded,
              label: l10n.yearNewCategories(review.newCategories),
            ),
        ],
      ),
    );
  }
}

class _BestCard extends StatelessWidget {
  const _BestCard({required this.review});
  final YearReview review;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    return _YearCard(
      title: l10n.yearBest,
      child: ListView(
        shrinkWrap: true,
        children: [
          for (final entry in review.best)
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.space12),
              child: InkWell(
                borderRadius: AppDimens.brSm,
                onTap: () => EntryDetailSheet.show(context, entry.entryId),
                child: Row(
                  children: [
                    SizedBox(
                      width: 48,
                      child: CoverImage(
                        title: entry.title,
                        imagePath: entry.coverPath,
                        seedColor: c.profileColorFor(entry.objectId),
                        borderRadius: AppDimens.brSm,
                      ),
                    ),
                    const SizedBox(width: AppDimens.space12),
                    Expanded(
                      child: Text(
                        entry.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.titleMedium,
                      ),
                    ),
                    const SizedBox(width: AppDimens.space8),
                    RatingView(value: entry.rating, compact: true),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlacesCard extends StatelessWidget {
  const _PlacesCard({required this.review});
  final YearReview review;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final month = review.busiestMonth;

    return _YearCard(
      title: l10n.yearWhereAndWhen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (review.topCategory case final top?) ...[
            _Big(
              label: l10n.yearTopCategory,
              value: top.name,
              note: l10n.yearImpressions(top.count),
            ),
            const SizedBox(height: AppDimens.space24),
          ],
          if (month != null)
            _Big(
              label: l10n.yearBusiestMonth,
              // Название месяца берём у локали: свой список сместился бы от
              // языка интерфейса.
              value: localeDate(context, 'LLLL').format(month.month),
              note: l10n.yearImpressions(month.count),
            ),
          const SizedBox(height: AppDimens.space24),
          for (final relation in Relation.values)
            if ((review.byRelation[relation.name] ?? 0) > 0)
              _Line(
                icon: relation.icon,
                label:
                    '${relation.label(l10n)} — '
                    '${review.byRelation[relation.name]}',
              ),
        ],
      ),
    );
  }
}

class _EdgesCard extends StatelessWidget {
  const _EdgesCard({required this.review});
  final YearReview review;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final format = localeDate(context, 'd MMMM');

    String when(EntryView entry) {
      final date = entry.impressionDate ?? entry.createdAt;
      return date == null ? '' : format.format(date);
    }

    return _YearCard(
      title: l10n.yearEdges,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (review.first case final first?)
            _Big(label: l10n.yearFirst, value: first.title, note: when(first)),
          if (review.last case final last?) ...[
            const SizedBox(height: AppDimens.space24),
            _Big(label: l10n.yearLast, value: last.title, note: when(last)),
          ],
        ],
      ),
    );
  }
}

/// Подпись, крупное значение и уточнение под ним.
class _Big extends StatelessWidget {
  const _Big({required this.label, required this.value, required this.note});

  final String label;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: context.text.labelSmall?.copyWith(color: c.textSecondary),
        ),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.text.headlineMedium,
        ),
        if (note.isNotEmpty)
          Text(
            note,
            style: context.text.bodySmall?.copyWith(color: c.textMuted),
          ),
      ],
    );
  }
}

/// Строка со значком — для перечислений внутри карточки.
class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.space8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: c.textSecondary),
          const SizedBox(width: AppDimens.space12),
          Expanded(child: Text(label, style: context.text.bodyMedium)),
        ],
      ),
    );
  }
}
