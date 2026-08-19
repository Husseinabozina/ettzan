import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/data/etzan_backend_repository.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/di/injection.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/features/growth/presentation/components/habit_dialogs.dart';
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
  bool _editMode = false;

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
        _habits = List.of(habits);
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
    final updated = previous.copyWith(
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

  void _onReorder(int oldIndex, int newIndex) {
    final habits = _habits;
    if (habits == null) return;
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = habits.removeAt(oldIndex);
      habits.insert(newIndex, item);
    });
    _saveOrder();
  }

  Future<void> _saveOrder() async {
    try {
      await getIt<EtzanBackendRepository>()
          .reorderHabits(_habits!.map((habit) => habit.id).toList());
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocaleKeys.taskUpdateError.tr(context: context))),
      );
      _load();
    }
  }

  Future<void> _editHabit(HabitStatusItem habit) async {
    final result = await showHabitEditDialog(
      context,
      initialTitle: habit.title,
      initialIconKey: habit.iconKey,
      initialDays: habit.days,
    );
    if (result == null || !mounted) return;
    final index = _habits?.indexWhere((item) => item.id == habit.id) ?? -1;
    if (index == -1) return;
    final previous = _habits![index];
    final updated = previous.copyWith(
      title: result.title,
      iconKey: result.iconKey,
      days: result.days,
    );
    setState(() => _habits![index] = updated);
    _saveEdit(previous, updated);
  }

  Future<void> _saveEdit(
    HabitStatusItem previous,
    HabitStatusItem next,
  ) async {
    try {
      final repository = getIt<EtzanBackendRepository>();
      if (next.title != previous.title) {
        await repository.renameHabit(habitId: next.id, title: next.title);
      }
      if (!listEquals(previous.days, next.days)) {
        await repository.updateHabitDays(habitId: next.id, days: next.days);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        final index =
            _habits?.indexWhere((item) => item.id == next.id) ?? -1;
        if (index != -1) _habits![index] = previous;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocaleKeys.habitUpdateError.tr(context: context))),
      );
    }
  }

  Future<void> _deleteHabit(HabitStatusItem habit) async {
    final confirmed = await showHabitDeleteDialog(context);
    if (!confirmed || !mounted) return;
    final index = _habits?.indexWhere((item) => item.id == habit.id) ?? -1;
    if (index == -1) return;
    final removed = _habits!.removeAt(index);
    setState(() {});
    _saveDelete(removed);
  }

  Future<void> _saveDelete(HabitStatusItem habit) async {
    try {
      await getIt<EtzanBackendRepository>().deleteHabit(habit.id);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocaleKeys.habitDeleteError.tr(context: context))),
      );
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final habits = _habits ?? const <HabitStatusItem>[];
    final completed = habits.where((habit) => habit.completedToday).length;

    return EtzanPage(
      title: LocaleKeys.dailyPlan.tr(context: context),
      actions: [
        if (habits.isNotEmpty && !_loading && !_error)
          TextButton(
            onPressed: () => setState(() => _editMode = !_editMode),
            child: Text(
              _editMode
                  ? LocaleKeys.done.tr(context: context)
                  : LocaleKeys.planEdit.tr(context: context),
            ),
          ),
      ],
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
          else if (_editMode)
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: habits.length,
              onReorder: _onReorder,
              itemBuilder: (context, index) {
                final habit = habits[index];
                return ReorderableDragStartListener(
                  key: ValueKey(habit.id),
                  index: index,
                  child: PlanTaskTile(
                    index: index + 1,
                    title: habit.title,
                    checked: habit.completedToday,
                    onTap: () {},
                    editMode: true,
                    onEdit: () => _editHabit(habit),
                    onDelete: () => _deleteHabit(habit),
                  ),
                );
              },
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
