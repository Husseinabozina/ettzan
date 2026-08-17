import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:etzan_life_coaching/core/design_system/app_assets.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_asset_icon.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/features/notifications/domain/entities/app_notification.dart';
import 'package:etzan_life_coaching/features/notifications/presentation/cubit/notifications_cubit.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({required this.notification, super.key});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final visual = _visualFor(notification.kind);
    return EtzanCard(
      onTap: () =>
          context.read<NotificationsCubit>().markAsRead(notification.id),
      borderColor: notification.isRead
          ? AppColors.divider
          : visual.$2.withValues(alpha: .32),
      shadows: notification.isRead ? const [] : AppShadows.card,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          EtzanIconBadge(
              asset: visual.$1, color: visual.$2, size: 56, iconSize: 29),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (notification.isImportant)
                      const Icon(Icons.star_rounded,
                          color: AppColors.warning, size: 19),
                  ],
                ),
                const SizedBox(height: 4),
                Text(notification.message,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 5),
                Text(
                  _timeLabel(context, notification.createdAt),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.inkSubtle),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AnimatedContainer(
            duration: AppDurations.fast,
            width: notification.isRead ? 8 : 11,
            height: notification.isRead ? 8 : 11,
            decoration: BoxDecoration(
              color:
                  notification.isRead ? AppColors.divider : AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: notification.isRead
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: .28),
                        blurRadius: 9,
                        spreadRadius: 2,
                      ),
                    ],
            ),
          ),
        ],
      ),
    );
  }

  (String, Color) _visualFor(NotificationKind kind) => switch (kind) {
        NotificationKind.sessionReminder => (
            AppAssets.iconCalendar,
            AppColors.lavender
          ),
        NotificationKind.achievement => (
            AppAssets.iconTrophy,
            AppColors.warning
          ),
        NotificationKind.motivation => (AppAssets.iconHeart, AppColors.danger),
        NotificationKind.goalFollowUp => (
            AppAssets.iconTarget,
            AppColors.primary
          ),
        NotificationKind.newSession => (
            AppAssets.iconClock,
            const Color(0xFF62CFC3)
          ),
      };

  String _timeLabel(BuildContext context, DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? LocaleKeys.pm : LocaleKeys.am;
    return '$hour:$minute ${period.tr(context: context)}';
  }
}
