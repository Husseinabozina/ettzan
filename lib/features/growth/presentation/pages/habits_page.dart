import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/data/etzan_backend_repository.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/di/injection.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/features/growth/presentation/components/growth_labels.dart';
import 'package:etzan_life_coaching/features/growth/presentation/components/habit_dialogs.dart';
import 'package:etzan_life_coaching/features/growth/presentation/pages/goals_overview_page.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  List<HabitStatusItem>? _habits;
  bool _loading = true;
  bool _error = false;
  bool _savingHabit = false;

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
          await getIt<EtzanBackendRepository>().getAllActiveHabits();
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

  /// Optimistic toggle: flips instantly, saves in the background, reverts on
  /// failure — no full-page reload.
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
        SnackBar(
            content: Text(LocaleKeys.habitUpdateError.tr(context: context))),
      );
    }
  }

  Future<void> _addHabit() async {
    final result = await showHabitEditDialog(context);
    if (result == null || !mounted) return;
    if (result.title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleKeys.habitNameRequired.tr(context: context)),
        ),
      );
      return;
    }

    setState(() => _savingHabit = true);
    try {
      await getIt<EtzanBackendRepository>().createHabit(
        title: result.title,
        iconKey: result.iconKey,
        days: result.days,
      );
      _load();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(LocaleKeys.habitCreateError.tr(context: context))),
      );
    } finally {
      if (mounted) setState(() => _savingHabit = false);
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
        SnackBar(
            content: Text(LocaleKeys.habitUpdateError.tr(context: context))),
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
        SnackBar(
            content: Text(LocaleKeys.habitDeleteError.tr(context: context))),
      );
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final habits = _habits ?? const <HabitStatusItem>[];
    final completed = habits.where((habit) => habit.completedToday).length;

    return EtzanPage(
      title: LocaleKeys.habitTracker.tr(context: context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _savingHabit ? null : _addHabit,
        icon: const Icon(Icons.add),
        label: Text(LocaleKeys.addHabit.tr(context: context)),
      ),
      child: ListView(
        padding: growthFloatingActionListPadding,
        children: [
          EtzanCard(
            gradient: AppColors.calmGradient,
            child: Row(
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.warning,
                  size: 72,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.todayHabits.tr(context: context),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        LocaleKeys.habitsCompletedToday.tr(
                          context: context,
                          namedArgs: {
                            'completed': '$completed',
                            'total': '${habits.length}',
                          },
                        ),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_loading) ...[
            const EtzanLoadingCard(),
            const SizedBox(height: AppSpacing.sm),
            const EtzanLoadingCard(),
          ] else if (_error)
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
              title: LocaleKeys.noHabits.tr(context: context),
              body: LocaleKeys.noHabitsDescription.tr(context: context),
            )
          else
            ...habits.map(
              (habit) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: EtzanCard(
                  onTap: () => _toggle(habit),
                  child: Row(
                    children: [
                      Checkbox(
                        value: habit.completedToday,
                        onChanged: (_) => _toggle(habit),
                      ),
                      Expanded(
                        child: Text(
                          habit.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Icon(
                        habitIcon(habit.iconKey, habit.title),
                        color: AppColors.primary,
                      ),
                      IconButton(
                        onPressed: () => _editHabit(habit),
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        color: AppColors.primary,
                        tooltip: LocaleKeys.editHabit.tr(context: context),
                      ),
                      IconButton(
                        onPressed: () => _deleteHabit(habit),
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: AppColors.danger,
                        tooltip: LocaleKeys.deleteHabit.tr(context: context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          if (habits.isNotEmpty)
            LinearProgressIndicator(
              value: completed / habits.length,
              minHeight: 12,
              backgroundColor: AppColors.divider,
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
        ],
      ),
    );
  }
}
