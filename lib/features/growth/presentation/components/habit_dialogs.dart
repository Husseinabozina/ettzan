import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';

class HabitEditResult {
  const HabitEditResult({
    required this.title,
    required this.iconKey,
    this.days,
  });

  final String title;
  final String iconKey;
  final List<int>? days;
}

/// Shared add/edit dialog for a habit: name, icon, and weekdays.
/// `days` empty means every day; returns null when cancelled.
Future<HabitEditResult?> showHabitEditDialog(
  BuildContext context, {
  String? initialTitle,
  String initialIconKey = 'habit',
  List<int>? initialDays,
}) async {
  final titleController = TextEditingController(text: initialTitle ?? '');
  var iconKey = initialIconKey;
  final days = initialDays == null ? <int>[] : List<int>.from(initialDays);

  final result = await showDialog<HabitEditResult>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(
          initialTitle == null
              ? LocaleKeys.addHabit.tr(context: context)
              : LocaleKeys.editHabit.tr(context: context),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: LocaleKeys.habitName.tr(context: context),
                  hintText: LocaleKeys.habitNameHint.tr(context: context),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                LocaleKeys.habitIcon.tr(context: context),
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: habitIconLabels(context).entries.map((entry) {
                  return EtzanTag(
                    label: entry.value,
                    selected: iconKey == entry.key,
                    onTap: () => setDialogState(() => iconKey = entry.key),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                LocaleKeys.habitDays.tr(context: context),
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: weekdayLabels(context).map((entry) {
                  return EtzanTag(
                    label: entry.value,
                    selected: days.contains(entry.key),
                    onTap: () => setDialogState(() {
                      if (days.contains(entry.key)) {
                        days.remove(entry.key);
                      } else {
                        days.add(entry.key);
                      }
                    }),
                  );
                }).toList(),
              ),
              if (days.isEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  LocaleKeys.everyDay.tr(context: context),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.inkMuted),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LocaleKeys.cancel.tr(context: context)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(
              HabitEditResult(
                title: titleController.text.trim(),
                iconKey: iconKey,
                days: days.isEmpty ? null : List<int>.from(days),
              ),
            ),
            child: Text(LocaleKeys.save.tr(context: context)),
          ),
        ],
      ),
    ),
  );
  titleController.dispose();
  return result;
}

/// Shared delete confirmation for a habit. Returns true when confirmed.
Future<bool> showHabitDeleteDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(LocaleKeys.deleteHabitConfirmTitle.tr(context: context)),
      content: Text(LocaleKeys.deleteHabitConfirmBody.tr(context: context)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(LocaleKeys.cancel.tr(context: context)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(LocaleKeys.deleteHabit.tr(context: context)),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

Map<String, String> habitIconLabels(BuildContext context) => {
      'water': LocaleKeys.habitTypeWater.tr(context: context),
      'meditation': LocaleKeys.habitTypeMeditation.tr(context: context),
      'read': LocaleKeys.habitTypeReading.tr(context: context),
      'exercise': LocaleKeys.habitTypeExercise.tr(context: context),
      'habit': LocaleKeys.habitTypeGeneral.tr(context: context),
    };

List<MapEntry<int, String>> weekdayLabels(BuildContext context) => [
      for (final (day, key) in [
        (1, LocaleKeys.dayMonday),
        (2, LocaleKeys.dayTuesday),
        (3, LocaleKeys.dayWednesday),
        (4, LocaleKeys.dayThursday),
        (5, LocaleKeys.dayFriday),
        (6, LocaleKeys.daySaturday),
        (7, LocaleKeys.daySunday),
      ])
        MapEntry(day, key.tr(context: context)),
    ];
