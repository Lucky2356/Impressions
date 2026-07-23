import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme_controller.dart';
import '../../core/config/app_config.dart';
import '../../core/domain/relation.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../design_system.dart';

/// Внутренний экран «Галерея компонентов» (§3.4).
///
/// Показывает переиспользуемые компоненты в реальных состояниях и позволяет
/// переключать тему. На Этапе 2 используется как домашний экран; в готовом
/// приложении доступен только в debug-режиме.
class ComponentGalleryScreen extends ConsumerWidget {
  const ComponentGalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final mode = ref.watch(themeModeProvider);

    final profiles = _demoProfiles(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.componentGalleryTitle),
        actions: [
          IconButton(
            tooltip: l10n.themeLight,
            onPressed: () =>
                ref.read(themeModeProvider.notifier).set(ThemeMode.light),
            icon: Icon(
              Icons.light_mode_rounded,
              color: mode == ThemeMode.light ? c.accentPrimary : null,
            ),
          ),
          IconButton(
            tooltip: l10n.themeDark,
            onPressed: () =>
                ref.read(themeModeProvider.notifier).set(ThemeMode.dark),
            icon: Icon(
              Icons.dark_mode_rounded,
              color: mode == ThemeMode.dark ? c.accentPrimary : null,
            ),
          ),
          IconButton(
            tooltip: l10n.themeSystem,
            onPressed: () =>
                ref.read(themeModeProvider.notifier).set(ThemeMode.system),
            icon: Icon(
              Icons.brightness_auto_rounded,
              color: mode == ThemeMode.system ? c.accentPrimary : null,
            ),
          ),
          const SizedBox(width: AppDimens.space8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppDimens.maxContentWidth,
          ),
          child: ListView(
            padding: const EdgeInsets.all(AppDimens.space20),
            children: [
              _Section(
                title: 'Профили',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileSwitcher(
                      profiles: profiles,
                      activeId: profiles.first.id,
                      onSelected: (_) {},
                    ),
                    const SizedBox(height: AppDimens.space16),
                    ProfileCard(data: profiles.first, selected: true),
                    const SizedBox(height: AppDimens.space12),
                    ProfileCard(data: profiles[1]),
                  ],
                ),
              ),
              _Section(
                title: 'Хлебные крошки',
                child: const Breadcrumbs(
                  crumbs: [
                    Crumb('Продукты'),
                    Crumb('Колбасы'),
                    Crumb('Папа может'),
                  ],
                ),
              ),
              _Section(
                title: 'Чипы и рейтинг',
                child: Wrap(
                  spacing: AppDimens.space8,
                  runSpacing: AppDimens.space8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (final r in Relation.values) RelationChip(relation: r),
                    const StatusChip(
                      label: 'Хочу попробовать',
                      icon: Icons.bookmark_add_rounded,
                    ),
                    const StatusChip(
                      label: 'Просмотрено',
                      icon: Icons.visibility_rounded,
                    ),
                    const RatingView(value: 9.5),
                    const RatingView(value: null),
                  ],
                ),
              ),
              _Section(
                title: 'Карточки записей',
                child: Column(
                  children: [
                    Wrap(
                      spacing: AppDimens.space16,
                      runSpacing: AppDimens.space16,
                      children: [
                        for (final d in _demoEntries())
                          SizedBox(
                            width: 220,
                            child: EntryCard(data: d, onTap: () {}),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.space16),
                    EntryCardCompact(data: _demoEntries().first, onTap: () {}),
                  ],
                ),
              ),
              _Section(
                title: 'Перенос записи',
                child: Row(children: [TransferButton(onPressed: () {})]),
              ),
              _Section(
                title: 'Кнопки и диалоги',
                child: Wrap(
                  spacing: AppDimens.space12,
                  runSpacing: AppDimens.space12,
                  children: [
                    FilledButton(
                      onPressed: () {},
                      child: Text(l10n.commonSave),
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      child: Text(l10n.commonCancel),
                    ),
                    TextButton(
                      onPressed: () => ConfirmDialog.show(
                        context,
                        title: l10n.commonArchive,
                        message: l10n.emptyCatalogSubtitle,
                        destructive: true,
                      ),
                      child: Text(l10n.commonArchive),
                    ),
                  ],
                ),
              ),
              _Section(
                title: 'Пустое состояние',
                child: SizedBox(
                  height: 320,
                  child: EmptyState(
                    icon: Icons.auto_stories_rounded,
                    title: l10n.emptyCatalogTitle,
                    message: l10n.emptyCatalogSubtitle,
                    action: FilledButton(
                      onPressed: () {},
                      child: Text(l10n.commonAdd),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.space40),
              Center(
                child: Text(
                  '${AppConfig.appName} · дизайн-система',
                  style: context.text.labelSmall?.copyWith(color: c.textMuted),
                ),
              ),
              const SizedBox(height: AppDimens.space24),
            ],
          ),
        ),
      ),
    );
  }

  List<ProfileChipData> _demoProfiles(BuildContext context) {
    final c = context.colors;
    return [
      ProfileChipData(
        id: 'me',
        name: 'Александр',
        color: c.profileColorFor('me'),
        subtitle: 'Мой основной профиль',
        entryCount: 128,
      ),
      ProfileChipData(
        id: 'larisa',
        name: 'Лариса',
        color: c.profileColorFor('larisa'),
        subtitle: 'Саша с работы',
        entryCount: 42,
        isExternal: true,
      ),
      ProfileChipData(
        id: 'maxim',
        name: 'Максим',
        color: c.profileColorFor('maxim'),
        entryCount: 17,
        isExternal: true,
      ),
    ];
  }

  List<EntryCardData> _demoEntries() {
    return const [
      EntryCardData(
        title: 'Интерстеллар',
        subtitle: 'Кристофер Нолан · 2014',
        categoryPath: ['Фильмы', 'Фантастика'],
        relation: Relation.love,
        rating: 9.5,
      ),
      EntryCardData(
        title: 'Папа может',
        subtitle: 'Варёная колбаса',
        categoryPath: ['Продукты', 'Колбасы'],
        relation: Relation.like,
        rating: 7.0,
      ),
      EntryCardData(
        title: 'The Lord of the Rings',
        categoryPath: ['Книги'],
        relation: Relation.wantToTry,
        statusLabel: 'Хочу попробовать',
      ),
    ];
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.space32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.text.headlineSmall),
          const SizedBox(height: AppDimens.space16),
          child,
        ],
      ),
    );
  }
}
