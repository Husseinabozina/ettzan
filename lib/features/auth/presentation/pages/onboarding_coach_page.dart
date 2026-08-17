import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/design_system/app_assets.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/navigation/app_routes.dart';
import 'package:etzan_life_coaching/features/auth/presentation/components/onboarding_layout.dart';

class OnboardingCoachScreen extends StatelessWidget {
  const OnboardingCoachScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      title: LocaleKeys.coachTitle.tr(context: context),
      body: LocaleKeys.coachBody.tr(context: context),
      illustrationAsset: AppAssets.onboardingCoach,
      pageIndex: 1,
      onNext: () =>
          Navigator.of(context).pushReplacementNamed(AppRoutes.signUp),
    );
  }
}
