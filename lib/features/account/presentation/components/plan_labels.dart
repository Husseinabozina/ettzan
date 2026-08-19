import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';

/// Maps subscription-plan feature codes (stored in Supabase) to localized
/// labels; unknown codes fall back to the raw value.
String planFeatureLabel(BuildContext context, String code) => switch (code) {
      'basic_goals' => LocaleKeys.featureBasicGoals.tr(context: context),
      'basic_habits' => LocaleKeys.featureBasicHabits.tr(context: context),
      'limited_resources' =>
        LocaleKeys.featureLimitedResources.tr(context: context),
      'unlimited_goals' =>
        LocaleKeys.featureUnlimitedGoals.tr(context: context),
      'unlimited_habits' =>
        LocaleKeys.featureUnlimitedHabits.tr(context: context),
      'premium_resources' =>
        LocaleKeys.featurePremiumResources.tr(context: context),
      'coach_chat' => LocaleKeys.featureCoachChat.tr(context: context),
      'progress_insights' =>
        LocaleKeys.featureProgressInsights.tr(context: context),
      _ => code,
    };
