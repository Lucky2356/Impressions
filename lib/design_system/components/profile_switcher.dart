import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import 'profile_avatar.dart';
import 'profile_card.dart';

/// Переключатель профилей (§3.4). Компактный вид активного профиля; по нажатию
/// открывается лист выбора. В галерее показывается встроенный горизонтальный ряд.
class ProfileSwitcher extends StatelessWidget {
  const ProfileSwitcher({
    super.key,
    required this.profiles,
    required this.activeId,
    required this.onSelected,
  });

  final List<ProfileChipData> profiles;
  final String activeId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.space4),
        itemCount: profiles.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppDimens.space16),
        itemBuilder: (context, i) {
          final p = profiles[i];
          final active = p.id == activeId;
          return _SwitcherItem(
            data: p,
            active: active,
            onTap: () => onSelected(p.id),
          );
        },
      ),
    );
  }
}

class _SwitcherItem extends StatelessWidget {
  const _SwitcherItem({
    required this.data,
    required this.active,
    required this.onTap,
  });

  final ProfileChipData data;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: AppDimens.brMd,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ProfileAvatar(
              name: data.name,
              color: data.color,
              imagePath: data.imagePath,
              size: AppDimens.avatarMd,
              selected: active,
            ),
            const SizedBox(height: AppDimens.space4),
            Text(
              data.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.labelSmall?.copyWith(
                color: active ? c.textPrimary : c.textSecondary,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
