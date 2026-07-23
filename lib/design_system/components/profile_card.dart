import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import 'app_card.dart';
import 'profile_avatar.dart';

/// Презентационные данные профиля для карточек и переключателя.
class ProfileChipData {
  const ProfileChipData({
    required this.id,
    required this.name,
    required this.color,
    this.subtitle,
    this.imagePath,
    this.entryCount,
    this.isExternal = false,
  });

  final String id;
  final String name;
  final Color color;
  final String? subtitle;
  final String? imagePath;
  final int? entryCount;
  final bool isExternal;
}

/// Карточка профиля (§3.4). Индивидуальный цвет как акцентная полоса слева.
class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.data,
    this.selected = false,
    this.onTap,
  });

  final ProfileChipData data;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      onTap: onTap,
      selected: selected,
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 5, color: data.color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.space16),
                child: Row(
                  children: [
                    ProfileAvatar(
                      name: data.name,
                      color: data.color,
                      imagePath: data.imagePath,
                      size: AppDimens.avatarLg,
                    ),
                    const SizedBox(width: AppDimens.space16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            data.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.titleLarge,
                          ),
                          if (data.subtitle != null) ...[
                            const SizedBox(height: AppDimens.space2),
                            Text(
                              data.subtitle!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.bodySmall?.copyWith(
                                color: c.textSecondary,
                              ),
                            ),
                          ],
                          if (data.entryCount != null) ...[
                            const SizedBox(height: AppDimens.space8),
                            Text(
                              _entriesLabel(data.entryCount!),
                              style: context.text.labelSmall?.copyWith(
                                color: c.textMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (data.isExternal)
                      Icon(
                        Icons.download_done_rounded,
                        size: 18,
                        color: c.textMuted,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _entriesLabel(int n) {
    final mod10 = n % 10;
    final mod100 = n % 100;
    final String word;
    if (mod10 == 1 && mod100 != 11) {
      word = 'запись';
    } else if (mod10 >= 2 && mod10 <= 4 && (mod100 < 10 || mod100 >= 20)) {
      word = 'записи';
    } else {
      word = 'записей';
    }
    return '$n $word';
  }
}
