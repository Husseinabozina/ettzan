import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/data/etzan_backend_repository.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/di/injection.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/features/growth/presentation/components/growth_labels.dart';
import 'package:etzan_life_coaching/features/growth/presentation/pages/goals_overview_page.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  late Future<List<HabitStatusItem>> _future =
      getIt<EtzanBackendRepository>().getHabitsForToday();
  bool _savingHabit = false;

  void _reload() => setState(
      () => _future = getIt<EtzanBackendRepository>().getHabitsForToday());

  Future<void> _toggle(HabitStatusItem habit, bool value) async {
    try {
      await getIt<EtzanBackendRepository>()
          .setHabitCompleted(habitId: habit.id, completed: value);
      _reload();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(LocaleKeys.habitUpdateError.tr(context: context))),
      );
    }
  }

  Future<void> _addHabit() async {
    final titleController = TextEditingController();
    var iconKey = 'habit';
    final iconLabels = {
      'habit': LocaleKeys.habitTypeGeneral.tr(context: context),
      'water': LocaleKeys.habitTypeWater.tr(context: context),
      'meditation': LocaleKeys.habitTypeMeditation.tr(context: context),
      'read': LocaleKeys.habitTypeReading.tr(context: context),
      'exercise': LocaleKeys.habitTypeExercise.tr(context: context),
    };
    final result = await showDialog<({String title, String iconKey})>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(LocaleKeys.addHabit.tr(context: context)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: LocaleKeys.habitName.tr(context: context),
                  hintText: LocaleKeys.habitNameHint.tr(context: context),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: iconLabels.entries.map((entry) {
                  return EtzanTag(
                    label: entry.value,
                    selected: iconKey == entry.key,
                    onTap: () => setDialogState(() => iconKey = entry.key),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(LocaleKeys.cancel.tr(context: context)),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(
                (title: titleController.text.trim(), iconKey: iconKey),
              ),
              child: Text(LocaleKeys.save.tr(context: context)),
            ),
          ],
        ),
      ),
    );
    titleController.dispose();
    if (result == null) return;
    if (result.title.isEmpty) {
      if (!mounted) return;
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
      );
      _reload();
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

  @override
  Widget build(BuildContext context) {
    return EtzanPage(
      title: LocaleKeys.habitTracker.tr(context: context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _savingHabit ? null : _addHabit,
        icon: const Icon(Icons.add),
        label: Text(LocaleKeys.addHabit.tr(context: context)),
      ),
      child: FutureBuilder<List<HabitStatusItem>>(
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
                  title: LocaleKeys.habitsLoadError.tr(context: context),
                  body: LocaleKeys.tryAgainLater.tr(context: context),
                ),
              ],
            );
          }

          final habits = snapshot.data ?? const <HabitStatusItem>[];
          final completed =
              habits.where((habit) => habit.completedToday).length;
          return ListView(
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
              if (habits.isEmpty)
                EtzanEmptyState(
                  title: LocaleKeys.noHabits.tr(context: context),
                  body: LocaleKeys.noHabitsDescription.tr(context: context),
                )
              else
                ...habits.map(
                  (habit) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: EtzanCard(
                      onTap: () => _toggle(habit, !habit.completedToday),
                      child: Row(
                        children: [
                          Checkbox(
                            value: habit.completedToday,
                            onChanged: (value) =>
                                _toggle(habit, value ?? false),
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
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
            ],
          );
        },
      ),
    );
  }
}
