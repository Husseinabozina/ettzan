import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';

class DashboardMetricsRow extends StatelessWidget {
  const DashboardMetricsRow({
    required this.completedSessions,
    required this.supportHours,
    required this.completedTasks,
    super.key,
  });

  final int completedSessions;
  final double supportHours;
  final int completedTasks;

  @override
  Widget build(BuildContext context) {
    return EtzanCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          EtzanMetric(
            icon: Icons.task_alt_outlined,
            value: '$completedSessions',
            label: LocaleKeys.sessionsMetric.tr(context: context),
          ),
          const SizedBox(
            height: 42,
            child: VerticalDivider(
              width: AppSpacing.lg,
              color: AppColors.divider,
            ),
          ),
          EtzanMetric(
            icon: Icons.schedule_outlined,
            value: supportHours.toStringAsFixed(1),
            label: LocaleKeys.supportHoursMetric.tr(context: context),
          ),
          const SizedBox(
            height: 42,
            child: VerticalDivider(
              width: AppSpacing.lg,
              color: AppColors.divider,
            ),
          ),
          EtzanMetric(
            icon: Icons.checklist_outlined,
            value: '$completedTasks',
            label: LocaleKeys.tasksMetric.tr(context: context),
          ),
        ],
      ),
    );
  }
}
