import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/data/etzan_backend_repository.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';

class WeeklyProgressCard extends StatelessWidget {
  const WeeklyProgressCard({required this.profile, super.key});

  final ProfileOverview profile;

  @override
  Widget build(BuildContext context) {
    final weeklyRatio = (profile.streakDays / 7).clamp(0.0, 1.0).toDouble();
    return EtzanCard(
      child: Row(
        children: [
          EtzanProgressRing(value: weeklyRatio, size: 76),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.weeklyProgress.tr(context: context),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  profile.streakDays == 0
                      ? LocaleKeys.startHabitToSeeProgress.tr(context: context)
                      : LocaleKeys.weeklyActivity.tr(
                          context: context,
                          namedArgs: {'count': '${profile.streakDays}'},
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
