import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../core/config/app_config.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/providers.dart';

/// Первый запуск: создание собственного профиля и стартовой структуры (§8).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _nickname = TextEditingController();
  bool _starterSubcategories = true;
  bool _busy = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _nickname.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final profiles = ref.read(profileRepositoryProvider);
      final seed = ref.read(seedServiceProvider);
      final profile = await profiles.createOwnProfile(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim().isEmpty ? null : _lastName.text.trim(),
        nickname: _nickname.text.trim().isEmpty ? null : _nickname.text.trim(),
      );
      await seed.seedForProfile(
        profile.id,
        withStarterSubcategories: _starterSubcategories,
      );
      await ref.read(activeProfileIdProvider.notifier).setActive(profile.id);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.space24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: c.accentPrimary,
                        borderRadius: AppDimens.brLg,
                      ),
                      child: Icon(
                        Icons.bookmark_rounded,
                        size: 34,
                        color: c.accentPrimaryOn,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.space24),
                  Text(
                    AppConfig.appName,
                    textAlign: TextAlign.center,
                    style: context.text.displayMedium,
                  ),
                  const SizedBox(height: AppDimens.space8),
                  Text(
                    l10n.onboardingWelcomeSubtitle,
                    textAlign: TextAlign.center,
                    style: context.text.bodyMedium?.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimens.space32),
                  TextFormField(
                    controller: _firstName,
                    autofocus: true,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.onboardingProfileNameLabel,
                      hintText: l10n.onboardingProfileNameHint,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.onboardingNameRequired
                        : null,
                  ),
                  const SizedBox(height: AppDimens.space12),
                  TextFormField(
                    controller: _lastName,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.onboardingLastNameLabel,
                    ),
                  ),
                  const SizedBox(height: AppDimens.space12),
                  TextFormField(
                    controller: _nickname,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _create(),
                    decoration: InputDecoration(
                      labelText: l10n.onboardingNicknameLabel,
                    ),
                  ),
                  const SizedBox(height: AppDimens.space24),
                  Container(
                    padding: const EdgeInsets.all(AppDimens.space16),
                    decoration: BoxDecoration(
                      color: c.surfaceMuted,
                      borderRadius: AppDimens.brMd,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.onboardingStarterTitle,
                          style: context.text.titleMedium,
                        ),
                        const SizedBox(height: AppDimens.space4),
                        Text(
                          l10n.onboardingStarterHint,
                          style: context.text.bodySmall?.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppDimens.space12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.onboardingStarterSubcategories,
                                style: context.text.bodyMedium,
                              ),
                            ),
                            Switch.adaptive(
                              value: _starterSubcategories,
                              onChanged: (v) =>
                                  setState(() => _starterSubcategories = v),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.space24),
                  FilledButton(
                    onPressed: _busy ? null : _create,
                    child: Text(
                      _busy
                          ? l10n.onboardingCreating
                          : l10n.onboardingCreateProfile,
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
