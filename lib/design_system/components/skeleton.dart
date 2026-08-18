import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import 'appear.dart';
import 'entry_card.dart';

/// Заглушка на время загрузки: форма будущего содержимого без самого
/// содержимого.
///
/// До 1.19.0 на время запроса показывалась пустота — экран моргал, а потом
/// список возникал разом. Пустой экран к тому же неотличим от «здесь ничего
/// нет», и на медленной базе выглядел ошибкой.
///
/// Скелетон намеренно **не пульсирует**. Бесконечная анимация никогда не
/// завершается, а `pumpAndSettle` ждёт именно завершения — она повесила бы
/// почти каждый виджет-тест в проекте. Спокойное появление и так снимает
/// моргание, а мерцающий блок на треть экрана спорил бы с §3.1.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = AppDimens.brSm,
  });

  final double? width;
  final double height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.colors.surfaceMuted,
        borderRadius: borderRadius,
      ),
    );
  }
}

/// Скелетон одной компактной карточки записи: миниатюра и три строки.
///
/// Повторяет [EntryCardCompact] по высоте, чтобы список не дёргался, когда
/// заглушки сменятся настоящими карточками.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      height: entryCardCompactHeight,
      padding: const EdgeInsets.all(AppDimens.space12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: AppDimens.brLg,
        border: Border.all(color: c.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(
            width: 56,
            height: 74,
            borderRadius: AppDimens.brSm,
          ),
          const SizedBox(width: AppDimens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBox(width: 90, height: 10),
                const SizedBox(height: AppDimens.space8),
                const SkeletonBox(height: 14),
                const SizedBox(height: AppDimens.space8),
                const SkeletonBox(width: 140, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Список заглушек — для лент, которые грузятся сверху вниз.
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.count = 4,
    this.padding = const EdgeInsets.symmetric(vertical: AppDimens.space8),
  });

  final int count;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    // Заглушку ставят и в отведённую коробку (там она обязана обрезаться), и
    // внутрь чужого списка (там высота не ограничена, и своя прокрутка упадёт).
    // Отличаем по входящим ограничениям, как это делает EmptyState.
    return LayoutBuilder(
      builder: (context, cns) {
        final cards = [
          for (var i = 0; i < count; i++)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : AppDimens.space8),
              child: Appear(index: i, child: const SkeletonCard()),
            ),
        ];
        if (!cns.hasBoundedHeight) {
          return Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: cards,
            ),
          );
        }
        return ListView(
          padding: padding,
          physics: const NeverScrollableScrollPhysics(),
          children: cards,
        );
      },
    );
  }
}

/// Сетка заглушек-обложек — для каталога и подборок.
class SkeletonGrid extends StatelessWidget {
  const SkeletonGrid({
    super.key,
    this.count = 8,
    this.minTileWidth = 180,
    this.aspectRatio = 0.62,
    this.padding = const EdgeInsets.symmetric(vertical: AppDimens.space8),
  });

  final int count;
  final double minTileWidth;
  final double aspectRatio;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, cns) {
          final cols = (cns.maxWidth / minTileWidth).floor().clamp(2, 6);
          return GridView.builder(
            // Внутри чужого списка сетка обязана вкладываться, в отведённой
            // коробке — обрезаться по ней. Прокрутки у заглушки нет в обоих
            // случаях: листать нечего.
            shrinkWrap: !cns.hasBoundedHeight,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              mainAxisSpacing: AppDimens.space16,
              crossAxisSpacing: AppDimens.space16,
              childAspectRatio: aspectRatio,
            ),
            itemCount: count,
            itemBuilder: (context, i) => Appear(
              index: i,
              child: const SkeletonBox(
                height: double.infinity,
                borderRadius: AppDimens.brLg,
              ),
            ),
          );
        },
      ),
    );
  }
}
