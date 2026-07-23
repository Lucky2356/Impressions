import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';

/// Пункт боковой навигации.
class NavItemData {
  const NavItemData({
    required this.id,
    required this.icon,
    required this.label,
    this.badge = 0,
  });
  final String id;
  final IconData icon;
  final String label;

  /// Счётчик справа: непросмотренные входящие изменения и т. п.
  final int badge;
}

/// Группа пунктов с заголовком-капсом.
class NavGroup {
  const NavGroup({this.title, required this.items});
  final String? title;
  final List<NavItemData> items;
}

/// Боковая навигация (ориентир YowBooks): логотип, сгруппированные пункты,
/// активный пункт — мягкая персиковая заливка + оранжевый текст.
class NavSidebar extends StatelessWidget {
  const NavSidebar({
    super.key,
    required this.groups,
    required this.activeId,
    required this.onSelected,
    required this.appTitle,
    this.footer,
  });

  final List<NavGroup> groups;
  final String activeId;
  final ValueChanged<String> onSelected;
  final String appTitle;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Ширину задаёт вызывающая сторона по разрешению экрана — панель просто
    // занимает всё доступное место.
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(right: BorderSide(color: c.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Logo(title: appTitle),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space16,
                vertical: AppDimens.space8,
              ),
              children: [
                for (final group in groups) ...[
                  if (group.title != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimens.space12,
                        AppDimens.space16,
                        0,
                        AppDimens.space8,
                      ),
                      child: Text(
                        group.title!.toUpperCase(),
                        style: context.text.labelSmall?.copyWith(
                          color: c.textMuted,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  for (final item in group.items)
                    _NavTile(
                      data: item,
                      active: item.id == activeId,
                      onTap: () => onSelected(item.id),
                    ),
                ],
              ],
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.all(AppDimens.space16),
              child: footer,
            ),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.space24),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: c.accentPrimary,
              borderRadius: AppDimens.brSm,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.bookmark_rounded,
              size: 20,
              color: c.accentPrimaryOn,
            ),
          ),
          const SizedBox(width: AppDimens.space12),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.titleLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.data,
    required this.active,
    required this.onTap,
  });

  final NavItemData data;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = active ? c.navActiveFg : c.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.space2),
      child: Material(
        color: active ? c.navActiveBg : Colors.transparent,
        borderRadius: AppDimens.brMd,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppDimens.brMd,
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.space12),
            child: Row(
              children: [
                Icon(data.icon, size: 20, color: fg),
                const SizedBox(width: AppDimens.space12),
                Expanded(
                  child: Text(
                    data.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodyMedium?.copyWith(
                      color: fg,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (data.badge > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.space8,
                    ),
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: c.accentPrimary,
                      borderRadius: AppDimens.brPill,
                    ),
                    child: Text(
                      data.badge > 99 ? '99+' : '${data.badge}',
                      style: context.text.labelSmall?.copyWith(
                        color: c.accentPrimaryOn,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
