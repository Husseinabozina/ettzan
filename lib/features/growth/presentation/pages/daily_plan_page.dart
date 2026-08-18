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
  List<HabitStatusItem>? _habits;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final habits =
          await getIt<EtzanBackendRepository>().getHabitsForToday();
      if (!mounted) return;
      setState(() {
        _habits = habits;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  /// Optimistic toggle: flips the tile instantly, saves in the background,
  /// and reverts if the save fails — no full-page reload.
  void _toggle(HabitStatusItem habit) {
    final index = _habits?.indexWhere((item) => item.id == habit.id) ?? -1;
    if (index == -1) return;
    final previous = _habits![index];
    final updated = HabitStatusItem(
      id: previous.id,
      title: previous.title,
      iconKey: previous.iconKey,
      frequency: previous.frequency,
      completedToday: !previous.completedToday,
    );
    setState(() => _habits![index] = updated);
    _saveToggle(updated, previous);
  }

  Future<void> _saveToggle(
    HabitStatusItem next,
    HabitStatusItem previous,
  ) async {
    try {
      await getIt<EtzanBackendRepository>().setHabitCompleted(
        habitId: next.id,
        completed: next.completedToday,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        final index =
            _habits?.indexWhere((item) => item.id == next.id) ?? -1;
        if (index != -1) _habits![index] = previous;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocaleKeys.taskUpdateError.tr(context: context))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final habits = _habits ?? const <HabitStatusItem>[];
    final completed = habits.where((habit) => habit.completedToday).length;

    return EtzanPage(
      title: LocaleKeys.dailyPlan.tr(context: context),
      child: ListView(
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
          if (_loading)
            const EtzanLoadingCard()
          else if (_error)
            EtzanEmptyState(
              title: LocaleKeys.habitsLoadError.tr(context: context),
              body: LocaleKeys.tryAgainLater.tr(context: context),
              action: EtzanPrimaryButton(
                label: LocaleKeys.retry.tr(context: context),
                onPressed: _load,
              ),
            )
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
      ),
    );
  }
}
