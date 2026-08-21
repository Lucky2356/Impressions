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
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget? leading;

  /// Дополнительная строка под заголовком: фильтры, вкладки.
  final Widget? bottom;

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
    // Мерку шапка берёт у своего каркаса, а не из собственного параметра:
    // раньше их было два одинаковых, и стоило разойтись — заголовок и список
    // вставали с разным отступом слева.
    final scope = ContentWidthScope.of(context);
    return alignNarrowColumn(
      context,
      content,
      scope.width,
      scope.narrowWidth,
      Alignment.centerLeft,
    );
  }

  Widget _content(BuildContext context) {
    final c = context.colors;

    final heading = Column(
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
            style: context.text.bodySmall?.copyWith(color: c.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );

    final actionsRow = Wrap(
      spacing: AppDimens.space8,
      runSpacing: AppDimens.space8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: actions,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Кнопки стоят в `Wrap`, а `Wrap` в строке получает неограниченную
        // ширину и забирает сколько нужно. На телефоне «Отметить все
        // просмотренными» съедало строку целиком, и от заголовка оставалось
        // ровно ноль точек — без всякого переполнения, молча.
        LayoutBuilder(
          builder: (context, cns) {
            if (actions.isEmpty) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: AppDimens.space12),
                  ],
                  Expanded(child: heading),
                ],
              );
            }

            if (cns.maxWidth < AppDimens.breakpointCompact) {
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
                      Expanded(child: heading),
                    ],
                  ),
                  const SizedBox(height: AppDimens.space12),
                  actionsRow,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: AppDimens.space12),
                ],
                Expanded(child: heading),
                const SizedBox(width: AppDimens.space16),
                actionsRow,
              ],
            );
          },
        ),
        if (bottom != null) ...[
          const SizedBox(height: AppDimens.space16),
          bottom!,
        ],
      ],
    );
  }
}

/// Метка колонки для чтения.
///
/// По ней видно, ограничена ли ширина раздела: у [ContentWidth.full] такой
/// коробки нет вовсе. Нужна проверкам раскладки — иначе «занимает всё окно»
/// приходится подтверждать замером пикселей.
const contentColumnKey = ValueKey('content-column');

/// Ставит содержимое в общую колонку раздела.
///
/// Разделы с более узкой собственной колонкой (настройки) прижимаются к её
/// левому краю, а не центрируются сами по себе. Иначе при переходе из каталога
/// в настройки содержимое заметно прыгало вправо: у каждого раздела был свой
/// отступ слева.
Widget alignNarrowColumn(
  BuildContext context,
  Widget content,
  ContentWidth width,
  double? narrowWidth,
  Alignment alignment,
) {
  var body = content;
  if (narrowWidth != null && narrowWidth.isFinite) {
    body = Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: narrowWidth),
        child: content,
      ),
    );
  }
  final outer = context.layout.maxWidthFor(
    width,
    MediaQuery.textScalerOf(context).scale(1),
  );
  if (!outer.isFinite) return body;
  return Align(
    alignment: alignment == Alignment.topLeft
        ? Alignment.topCenter
        : Alignment.center,
    child: ConstrainedBox(
      key: contentColumnKey,
      constraints: BoxConstraints(maxWidth: outer),
      child: body,
    ),
  );
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
    this.width = ContentWidth.reading,
    this.maxWidth,
  });

  final Widget header;
  final Widget child;

  /// Как раздел занимает окно: колонкой для чтения или всей шириной.
  final ContentWidth width;

  /// Своя, более узкая колонка вместо общей — для разделов вроде настроек.
  /// Имеет смысл только вместе с [ContentWidth.reading].
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return ContentWidthScope(
      width: width,
      narrowWidth: maxWidth,
      child: Column(
        children: [
          header,
          Divider(height: 1, color: c.border),
          Expanded(
            child: Builder(
              builder: (context) => alignNarrowColumn(
                context,
                child,
                width,
                maxWidth,
                Alignment.topLeft,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Мерка ширины, заданная каркасом раздела, — чтобы шапка не повторяла её
/// вторым параметром.
class ContentWidthScope extends InheritedWidget {
  const ContentWidthScope({
    super.key,
    required this.width,
    required this.narrowWidth,
    required super.child,
  });

  final ContentWidth width;
  final double? narrowWidth;

  /// Вне каркаса шапка ведёт себя как колонка для чтения — так же, как
  /// [ScreenScaffold] по умолчанию.
  static ContentWidthScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ContentWidthScope>() ??
      const ContentWidthScope(
        width: ContentWidth.reading,
        narrowWidth: null,
        child: SizedBox.shrink(),
      );

  @override
  bool updateShouldNotify(ContentWidthScope old) =>
      old.width != width || old.narrowWidth != narrowWidth;
}
