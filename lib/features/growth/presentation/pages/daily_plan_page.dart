import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/data/etzan_backend_repository.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/di/injection.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/features/growth/presentation/components/plan_task_tile.dart';

class DailyPlanScreen extends StatefulWidget {
  const DailyPlanScreen({super.key});

  @override
  State<DailyPlanScreen> createState() => _DailyPlanScreenState();
}

class _DailyPlanScreenState extends State<DailyPlanScreen> {
  late Future<List<HabitStatusItem>> _future =
      getIt<EtzanBackendRepository>().getHabitsForToday();

  void _reload() {
    setState(() {
      _future = getIt<EtzanBackendRepository>().getHabitsForToday();
    });
  }

  Future<void> _toggle(HabitStatusItem habit) async {
    try {
      await getIt<EtzanBackendRepository>().setHabitCompleted(
        habitId: habit.id,
        completed: !habit.completedToday,
      );
      _reload();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(LocaleKeys.taskUpdateError.tr(context: context))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return EtzanPage(
      title: LocaleKeys.dailyPlan.tr(context: context),
      child: FutureBuilder<List<HabitStatusItem>>(
        future: _future,
        builder: (context, snapshot) {
          final habits = snapshot.data ?? const <HabitStatusItem>[];
          final completed =
              habits.where((habit) => habit.completedToday).length;
          return ListView(
            children: [
              EtzanCard(
                gradient: AppColors.calmGradient,
                child: Row(
                  children: [
                    const Icon(Icons.wb_sunny,
                        color: AppColors.warning, size: 50),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        LocaleKeys.focusToday.tr(context: context),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              EtzanSectionTitle(
                  title: LocaleKeys.priorities.tr(context: context)),
              const SizedBox(height: AppSpacing.sm),
              if (snapshot.connectionState != ConnectionState.done)
                const EtzanLoadingCard()
              else if (habits.isEmpty)
                EtzanEmptyState(
                  title: LocaleKeys.noTodayTasks.tr(context: context),
                  body: LocaleKeys.noTodayTasksDescription.tr(context: context),
                )
              else
                ...habits.take(5).toList().asMap().entries.map(
                      (entry) => PlanTaskTile(
                        index: entry.key + 1,
                        title: entry.value.title,
                        checked: entry.value.completedToday,
                        onTap: () => _toggle(entry.value),
                      ),
                    ),
              const SizedBox(height: AppSpacing.lg),
              EtzanCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    EtzanMetric(
                      value: '$completed',
                      label: LocaleKeys.completed.tr(context: context),
                      icon: Icons.check_circle_outline,
                    ),
                    EtzanMetric(
                      value: '${habits.length - completed}',
                      label: LocaleKeys.pending.tr(context: context),
                      icon: Icons.timelapse,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
