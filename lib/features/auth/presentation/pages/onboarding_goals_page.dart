import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/design_system/app_assets.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/navigation/app_routes.dart';
import 'package:etzan_life_coaching/features/auth/presentation/components/onboarding_layout.dart';

class OnboardingGoalsScreen extends StatelessWidget {
  const OnboardingGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      title: LocaleKeys.growTitle.tr(context: context),
      body: LocaleKeys.growBody.tr(context: context),
      illustrationAsset: AppAssets.onboardingGoals,
      pageIndex: 0,
      onNext: () =>
          Navigator.of(context).pushReplacementNamed(AppRoutes.onboardingCoach),
    );
  }
}
