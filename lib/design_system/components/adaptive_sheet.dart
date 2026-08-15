import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';

/// Показывает содержимое диалогом на широком экране и листом снизу на узком.
///
/// Правило одно и то же для формы записи, карточки, сканера и выбора записей в
/// подборку, но было написано в каждом из них заново — и уже разошлось в
/// мелочах. [height] задаёт высоту диалога, [heightFactor] — какую часть
/// экрана занимает лист на телефоне.
Future<T?> showAdaptiveSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  double width = 560,
  double? height,
  double? heightFactor,
}) {
  final screen = MediaQuery.sizeOf(context);
  final wide = screen.width >= AppDimens.breakpointExpanded;
  if (wide) {
    return showDialog<T>(
      context: context,
      builder: (ctx) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          // Диалог растёт по содержимому, и на невысоком окне длинная форма
          // уезжала нижним краем за экран вместе с кнопкой «Сохранить»:
          // прокрутка внутри упиралась в то, что прокручивать уже некуда.
          constraints: BoxConstraints(maxHeight: screen.height * 0.9),
          child: SizedBox(width: width, height: height, child: builder(ctx)),
        ),
      ),
    );
  }
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => heightFactor == null
        ? builder(ctx)
        : FractionallySizedBox(heightFactor: heightFactor, child: builder(ctx)),
  );
}
