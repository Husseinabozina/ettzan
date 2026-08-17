import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';

String growthDateLabel(DateTime value) =>
    '${value.year}/${value.month.toString().padLeft(2, '0')}/${value.day.toString().padLeft(2, '0')}';

String growthTimeLabel(BuildContext context, DateTime value) {
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final minute = value.minute.toString().padLeft(2, '0');
  final period = value.hour >= 12 ? LocaleKeys.pm : LocaleKeys.am;
  return '$hour:$minute ${period.tr(context: context)}';
}

String remainingGoalLabel(BuildContext context, DateTime? date) {
  if (date == null) return LocaleKeys.noTargetDate.tr(context: context);
  final days = DateTime(date.year, date.month, date.day)
      .difference(DateTime.now())
      .inDays;
  if (days < 0) return LocaleKeys.targetDatePast.tr(context: context);
  if (days == 0) return LocaleKeys.targetDateToday.tr(context: context);
  return LocaleKeys.targetDateRemaining.tr(
    context: context,
    namedArgs: {'days': '$days'},
  );
}

String sessionTypeLabel(BuildContext context, String type) => switch (type) {
      'intensive' => LocaleKeys.intensiveSession.tr(context: context),
      'individual' => LocaleKeys.individualSession.tr(context: context),
      _ => LocaleKeys.coachingSessionGeneric.tr(context: context),
    };

IconData habitIcon(String key, String title) {
  final value = '$key $title'.toLowerCase();
  if (value.contains('water')) return Icons.water_drop_outlined;
  if (value.contains('meditation')) return Icons.self_improvement;
  if (value.contains('read')) return Icons.menu_book_outlined;
  return Icons.check_circle_outline;
}
