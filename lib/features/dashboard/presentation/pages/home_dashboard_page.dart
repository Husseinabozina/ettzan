import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:etzan_life_coaching/core/design_system/app_assets.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/navigation/app_routes.dart';
import 'package:etzan_life_coaching/core/widgets/feedback/app_error_state.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_shell.dart';
import 'package:etzan_life_coaching/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:etzan_life_coaching/features/dashboard/presentation/components/dashboard_greeting_card.dart';
import 'package:etzan_life_coaching/features/dashboard/presentation/components/dashboard_metrics_row.dart';
import 'package:etzan_life_coaching/features/dashboard/presentation/components/upcoming_session_card.dart';
import 'package:etzan_life_coaching/features/dashboard/presentation/cubit/dashboard_cubit.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EtzanShell(
      currentIndex: 0,
      title: LocaleKeys.home.tr(context: context),
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          return switch (state.status) {
            DashboardStatus.initial ||
            DashboardStatus.loading =>
              const Center(child: CircularProgressIndicator()),
            DashboardStatus.failure => AppErrorState(
                title: LocaleKeys.dashboardLoadError.tr(context: context),
                message: (state.message ?? LocaleKeys.dashboardLoadRetry)
                    .tr(context: context),
                retryLabel: LocaleKeys.retry.tr(context: context),
                onRetry: context.read<DashboardCubit>().load,
              ),
            DashboardStatus.success => _DashboardContent(
                summary: state.summary!,
              ),
          };
        },
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.summary,
  });

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      children: [
        DashboardGreetingCard(summary: summary),
        const SizedBox(height: AppSpacing.lg),
        DashboardMetricsRow(
          completedSessions: summary.completedSessions,
          supportHours: summary.supportHours,
          completedTasks: summary.completedTasks,
        ),
        const SizedBox(height: AppSpacing.lg),
        EtzanSectionTitle(
          title: LocaleKeys.upcomingSession.tr(context: context),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (summary.upcomingSession != null)
          UpcomingSessionCard(session: summary.upcomingSession!)
        else
          EtzanCard(
            child: Text(
              LocaleKeys.noUpcomingSession.tr(context: context),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.inkMuted),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        EtzanSectionTitle(
          title: LocaleKeys.quickActions.tr(context: context),
        ),
        const SizedBox(height: AppSpacing.sm),
        AdaptiveGrid(
          phone: 3,
          tablet: 3,
          desktop: 3,
          children: [
            EtzanIconTile(
              iconAsset: AppAssets.iconPeople,
              color: AppColors.primary,
              label: LocaleKeys.discoverCoach.tr(context: context),
              onTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.discoverCoaches),
            ),
            EtzanIconTile(
              iconAsset: AppAssets.iconBook,
              color: AppColors.lavender,
              label: LocaleKeys.journalHome.tr(context: context),
              onTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.journalHome),
            ),
            EtzanIconTile(
              iconAsset: AppAssets.iconSparkle,
              color: AppColors.warning,
              label: LocaleKeys.bookSession.tr(context: context),
              onTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.bookSession),
            ),
          ],
        ),
      ],
    );
  }
}
