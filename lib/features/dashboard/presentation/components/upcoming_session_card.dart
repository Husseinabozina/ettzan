import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/navigation/app_routes.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:etzan_life_coaching/features/dashboard/presentation/components/dashboard_labels.dart';

class UpcomingSessionCard extends StatelessWidget {
  const UpcomingSessionCard({required this.session, super.key});

  final CoachingSession session;

  @override
  Widget build(BuildContext context) {
    return EtzanCard(
      onTap: () =>
          Navigator.of(context).pushNamed(AppRoutes.upcomingSessions),
      child: Row(
        children: [
          EtzanAvatar(name: session.coachName, online: session.isOnline),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.upcomingSession.tr(context: context),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.inkMuted,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  session.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${dashboardDateLabel(session.startsAt)} • '
                  '${dashboardTimeLabel(context, session.startsAt)} • '
                  '${LocaleKeys.durationMinutes.tr(
                    context: context,
                    namedArgs: {'count': '${session.durationMinutes}'},
                  )}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.inkMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            LocaleKeys.viewDetails.tr(context: context),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
