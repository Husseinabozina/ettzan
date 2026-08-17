import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/features/dashboard/domain/entities/dashboard_summary.dart';

class DashboardGreetingCard extends StatelessWidget {
  const DashboardGreetingCard({required this.summary, super.key});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return EtzanCard(
      gradient: AppColors.calmGradient,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EtzanTag(
                  label: LocaleKeys.onTrack.tr(context: context),
                  selected: true,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  LocaleKeys.helloUser.tr(
                    context: context,
                    namedArgs: {'name': summary.firstName},
                  ),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  summary.dailyNudge,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: AppColors.inkMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          EtzanProgressRing(value: summary.monthlyProgress.clamp(0, 1)),
        ],
      ),
    );
  }
}
