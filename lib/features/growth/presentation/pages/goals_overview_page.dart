import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/data/etzan_backend_repository.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/di/injection.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/navigation/app_routes.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_shell.dart';
import 'package:etzan_life_coaching/features/growth/presentation/components/goal_card.dart';

const growthFloatingActionListPadding = EdgeInsets.only(bottom: 112);

class GoalsOverviewScreen extends StatefulWidget {
  const GoalsOverviewScreen({super.key});

  @override
  State<GoalsOverviewScreen> createState() => _GoalsOverviewScreenState();
}

class _GoalsOverviewScreenState extends State<GoalsOverviewScreen> {
  late Future<List<GoalItem>> _future;
  List<GoalItem>? _goals;
  final Set<String> _updatingGoalIds = <String>{};

  @override
  void initState() {
    super.initState();
    _future = _loadGoals();
  }

  Future<List<GoalItem>> _loadGoals() async {
    final goals = await getIt<EtzanBackendRepository>().getGoals();
    if (mounted) {
      setState(() => _goals = goals);
    }
    return goals;
  }

  void _reload() {
    setState(() {
      _goals = null;
      _future = _loadGoals();
    });
  }

  Future<void> _openCreateGoal() async {
    await Navigator.of(context).pushNamed(AppRoutes.createGoal);
    if (mounted) _reload();
  }

  Future<void> _updateGoal(GoalItem goal, double progress) async {
    if (_updatingGoalIds.contains(goal.id)) return;

    final previousGoals = List<GoalItem>.from(_goals ?? const []);
    final updatedProgress = progress.clamp(0.0, 1.0).toDouble();
    setState(() {
      _updatingGoalIds.add(goal.id);
      _goals = previousGoals
          .map(
            (item) => item.id == goal.id
                ? item.copyWith(
                    progress: updatedProgress,
                    isCompleted: updatedProgress >= 1,
                  )
                : item,
          )
          .toList(growable: false);
    });

    try {
      await getIt<EtzanBackendRepository>().updateGoalProgress(
        goalId: goal.id,
        progress: updatedProgress,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _goals = previousGoals);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleKeys.goalUpdateError.tr(context: context)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingGoalIds.remove(goal.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return EtzanShell(
      currentIndex: 2,
      title: LocaleKeys.goals.tr(context: context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateGoal,
        icon: const Icon(Icons.add),
        label: Text(LocaleKeys.createGoal.tr(context: context)),
      ),
      child: FutureBuilder<List<GoalItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return ListView(
              padding: growthFloatingActionListPadding,
              children: [
                const EtzanLoadingCard(),
                const SizedBox(height: AppSpacing.sm),
                const EtzanLoadingCard(),
              ],
            );
          }

          if (snapshot.hasError) {
            return ListView(
              padding: growthFloatingActionListPadding,
              children: [
                const SizedBox(height: 90),
                EtzanEmptyState(
                  title: LocaleKeys.goalsLoadError.tr(context: context),
                  body: LocaleKeys.checkConnectionAndRetry.tr(context: context),
                ),
              ],
            );
          }

          final goals = _goals ?? snapshot.data ?? const <GoalItem>[];
          final activeGoals =
              goals.where((goal) => !goal.isCompleted).toList(growable: false);
          final ratio = goals.isEmpty
              ? 0.0
              : goals.map((goal) => goal.progress).reduce((a, b) => a + b) /
                  goals.length;

          return ListView(
            padding: growthFloatingActionListPadding,
            children: [
              EtzanSectionTitle(
                  title: LocaleKeys.activeGoals.tr(context: context)),
              const SizedBox(height: AppSpacing.sm),
              if (activeGoals.isEmpty)
                EtzanEmptyState(
                  title: LocaleKeys.noActiveGoals.tr(context: context),
                  body:
                      LocaleKeys.noActiveGoalsDescription.tr(context: context),
                )
              else
                AdaptiveGrid(
                  phone: 1,
                  tablet: 2,
                  desktop: 3,
                  children: activeGoals
                      .map(
                        (goal) => GoalCard(
                          goal: goal,
                          isUpdating: _updatingGoalIds.contains(goal.id),
                          onProgressChanged: (progress) =>
                              _updateGoal(goal, progress),
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: AppSpacing.lg),
              EtzanCard(
                gradient: AppColors.calmGradient,
                child: Row(
                  children: [
                    EtzanProgressRing(value: ratio, size: 74),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocaleKeys.goalsProgress.tr(context: context),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            goals.isEmpty
                                ? LocaleKeys.addGoalsToStartTracking
                                    .tr(context: context)
                                : LocaleKeys.averageGoalProgress.tr(
                                    context: context,
                                    namedArgs: {
                                      'percent': '${(ratio * 100).round()}',
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AdaptiveGrid(
                phone: 2,
                tablet: 4,
                desktop: 4,
                children: [
                  EtzanIconTile(
                    icon: Icons.local_fire_department,
                    label: LocaleKeys.habitTracker.tr(context: context),
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.habits),
                  ),
                  EtzanIconTile(
                    icon: Icons.checklist,
                    label: LocaleKeys.dailyPlan.tr(context: context),
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.dailyPlan),
                  ),
                  EtzanIconTile(
                    icon: Icons.calendar_month_outlined,
                    label: LocaleKeys.calendar.tr(context: context),
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.calendar),
                  ),
                  EtzanIconTile(
                    icon: Icons.insights,
                    label: LocaleKeys.progress.tr(context: context),
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.progress),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
