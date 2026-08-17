import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';

String coachingDateLabel(DateTime value) =>
    '${value.year}/${value.month.toString().padLeft(2, '0')}/${value.day.toString().padLeft(2, '0')}';

String coachingTimeLabel(BuildContext context, DateTime value) {
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final minute = value.minute.toString().padLeft(2, '0');
  final period = value.hour >= 12 ? LocaleKeys.pm : LocaleKeys.am;
  return '$hour:$minute ${period.tr(context: context)}';
}

String coachingStatusLabel(BuildContext context, String status) =>
    switch (status) {
      'confirmed' => LocaleKeys.statusConfirmed.tr(context: context),
      'completed' => LocaleKeys.statusCompleted.tr(context: context),
      'cancelled' => LocaleKeys.statusCancelled.tr(context: context),
      _ => LocaleKeys.statusPendingConfirmation.tr(context: context),
    };

String coachingSessionTypeLabel(BuildContext context, String type) =>
    switch (type) {
      'intensive' => LocaleKeys.intensiveSession.tr(context: context),
      'individual' => LocaleKeys.individualSession.tr(context: context),
      _ => LocaleKeys.coachingSessionGeneric.tr(context: context),
    };
