import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';

/// Один сегмент хлебных крошек.
class Crumb {
  const Crumb(this.label, {this.onTap});
  final String label;
  final VoidCallback? onTap;
}

/// Хлебные крошки категории/объекта (§7.6): `Продукты / Колбасы / Папа может`.
///
/// Каждый сегмент кликабелен. На узком экране длинный путь сокращается
/// (первый / … / два последних) и раскрывается по нажатию на «…».
class Breadcrumbs extends StatefulWidget {
  const Breadcrumbs({
    super.key,
    required this.crumbs,
    this.collapseThreshold = 4,
  });

  final List<Crumb> crumbs;

  /// Если сегментов больше этого числа — путь сокращается на узком экране.
  final int collapseThreshold;

  @override
  State<Breadcrumbs> createState() => _BreadcrumbsState();
}

class _BreadcrumbsState extends State<Breadcrumbs> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isCompact =
        MediaQuery.sizeOf(context).width < AppDimens.breakpointCompact;
    final shouldCollapse =
        isCompact &&
        !_expanded &&
        widget.crumbs.length > widget.collapseThreshold;

    final List<Widget> children = [];

    void addCrumb(Crumb crumb, {required bool last}) {
      children.add(
        InkWell(
          onTap: crumb.onTap,
          borderRadius: AppDimens.brSm,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.space4,
              vertical: AppDimens.space2,
            ),
            child: Text(
              crumb.label,
              style: context.text.labelMedium?.copyWith(
                color: last ? c.textPrimary : c.textSecondary,
                fontWeight: last ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    Widget separator() => Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.space2),
      child: Text(
        '/',
        style: context.text.labelMedium?.copyWith(color: c.textMuted),
      ),
    );

    if (shouldCollapse) {
      addCrumb(widget.crumbs.first, last: false);
      children.add(separator());
      children.add(
        InkWell(
          onTap: () => setState(() => _expanded = true),
          borderRadius: AppDimens.brSm,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.space4,
              vertical: AppDimens.space2,
            ),
            child: Text(
              '…',
              style: context.text.labelMedium?.copyWith(color: c.textSecondary),
            ),
          ),
        ),
      );
      for (final crumb in widget.crumbs.sublist(widget.crumbs.length - 2)) {
        children.add(separator());
        addCrumb(crumb, last: crumb == widget.crumbs.last);
      }
    } else {
      for (var i = 0; i < widget.crumbs.length; i++) {
        if (i > 0) children.add(separator());
        addCrumb(widget.crumbs[i], last: i == widget.crumbs.length - 1);
      }
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}
