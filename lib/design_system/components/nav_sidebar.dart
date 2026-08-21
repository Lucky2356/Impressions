import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';

import 'app_logo.dart';

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
    this.collapsed = false,
  });

  final List<NavGroup> groups;
  final String activeId;
  final ValueChanged<String> onSelected;
  final String appTitle;
  final Widget? footer;

  /// Только значки: окно шире телефона, но подписям места нет.
  ///
  /// Названия разделов при этом никуда не деваются — они приходят подсказкой
  /// при наведении. Прятать восемь разделов из двенадцати в «Ещё» на таком
  /// экране незачем: это правило телефона, а не всякого узкого окна.
  final bool collapsed;

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
          _Logo(title: appTitle, collapsed: collapsed),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: collapsed ? AppDimens.space12 : AppDimens.space16,
                vertical: AppDimens.space8,
              ),
              children: [
                for (final (i, group) in groups.indexed) ...[
                  // Заголовок группы значками не прочесть, но границу между
                  // группами видно и без слов.
                  if (collapsed) ...[
                    if (i != 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimens.space8,
                        ),
                        child: Divider(height: 1, color: c.border),
                      ),
                  ] else if (group.title != null)
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
                      collapsed: collapsed,
                      onTap: () => onSelected(item.id),
                    ),
                ],
              ],
            ),
          ),
          if (footer != null)
            Padding(
              padding: EdgeInsets.all(
                collapsed ? AppDimens.space12 : AppDimens.space16,
              ),
              child: footer,
            ),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.title, required this.collapsed});
  final String title;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      // Ровно та же высота, что у шапки раздела справа, — иначе разделитель
      // под логотипом и разделитель под шапкой идут двумя разными линиями.
      // Со значками панель стоит рядом с компактной шапкой, с подписями — с
      // полной.
      height: collapsed
          ? AppDimens.headerHeightCompact
          : AppDimens.headerHeight,
      padding: EdgeInsets.symmetric(
        horizontal: collapsed ? AppDimens.space12 : AppDimens.space24,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      child: Row(
        mainAxisAlignment: collapsed
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          const AppLogo(size: 34),
          if (!collapsed) ...[
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
    this.collapsed = false,
  });

  final NavItemData data;
  final bool active;
  final VoidCallback onTap;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = active ? c.navActiveFg : c.textSecondary;
    if (collapsed) return _collapsed(context, fg);
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

  /// Тот же пункт одним значком. Название приходит подсказкой при наведении,
  /// а счётчик входящих сжимается в точку: цифре в 46 точек места нет.
  Widget _collapsed(BuildContext context, Color fg) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.space4),
      child: Tooltip(
        message: data.label,
        child: Material(
          color: active ? c.navActiveBg : Colors.transparent,
          borderRadius: AppDimens.brMd,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppDimens.brMd,
            child: SizedBox(
              height: 46,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(data.icon, size: 22, color: fg),
                  if (data.badge > 0)
                    Positioned(
                      right: AppDimens.space12,
                      top: AppDimens.space8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: c.accentPrimary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
