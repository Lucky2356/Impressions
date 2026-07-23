import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_layout.dart';
import '../../core/theme/theme_context.dart';

/// Единая шапка раздела: заголовок, пояснение и действия справа.
///
/// Раньше каждый экран рисовал свой блок заголовка с разными отступами и
/// размерами шрифта. Теперь форма одна, экраны задают только содержимое.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.leading,
    this.bottom,
    this.constrain = true,
    this.maxWidth,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget? leading;

  /// Дополнительная строка под заголовком: фильтры, вкладки.
  final Widget? bottom;

  /// Должно совпадать с одноимённым параметром [ScreenScaffold]: если
  /// содержимое раздела занимает всю ширину, шапка тоже не сужается.
  final bool constrain;

  /// Своя предельная ширина вместо общей — для разделов вроде настроек,
  /// где колонка уже. Должна совпадать с [ScreenScaffold.maxWidth].
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final layout = context.layout;
    return Container(
      color: c.background,
      padding: EdgeInsets.only(
        top: AppDimens.space20,
        bottom: bottom == null ? AppDimens.space16 : AppDimens.space12,
      ),
      // Та же колонка, что и у содержимого раздела: и ограничение ширины, и
      // боковой отступ должны совпадать, иначе на широком мониторе заголовок
      // и список стоят с разным отступом слева.
      child: _constrained(layout, context),
    );
  }

  Widget _constrained(AppLayout layout, BuildContext context) {
    final content = Padding(
      padding: EdgeInsets.symmetric(horizontal: layout.gutter),
      child: _content(context),
    );
    final limit = maxWidth ?? layout.contentMaxWidth;
    if (!constrain || !limit.isFinite) return content;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: limit),
        child: content,
      ),
    );
  }

  Widget _content(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: AppDimens.space12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: context.text.headlineSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppDimens.space2),
                    Text(
                      subtitle!,
                      style: context.text.bodySmall?.copyWith(
                        color: c.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (actions.isNotEmpty) ...[
              const SizedBox(width: AppDimens.space16),
              Wrap(
                spacing: AppDimens.space8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: actions,
              ),
            ],
          ],
        ),
        if (bottom != null) ...[
          const SizedBox(height: AppDimens.space16),
          bottom!,
        ],
      ],
    );
  }
}

/// Каркас раздела: шапка, разделитель и содержимое с ограничением ширины.
///
/// Ограничение ширины — часть поддержки 4K: на очень широком мониторе списки
/// не растягиваются на весь экран, а остаются читаемой колонкой.
class ScreenScaffold extends StatelessWidget {
  const ScreenScaffold({
    super.key,
    required this.header,
    required this.child,
    this.constrain = true,
    this.maxWidth,
  });

  final Widget header;
  final Widget child;
  final bool constrain;

  /// Своя предельная ширина вместо общей; должна совпадать с
  /// [ScreenHeader.maxWidth], иначе шапка и содержимое разъедутся.
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final layout = context.layout;
    final limit = maxWidth ?? layout.contentMaxWidth;
    final body = constrain && limit.isFinite
        ? Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: limit),
              child: child,
            ),
          )
        : child;

    return Column(
      children: [
        header,
        Divider(height: 1, color: c.border),
        Expanded(child: body),
      ],
    );
  }
}
