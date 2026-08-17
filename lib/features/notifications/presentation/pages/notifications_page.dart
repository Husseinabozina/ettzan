import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/widgets/feedback/app_error_state.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/features/notifications/presentation/components/notification_card.dart';
import 'package:etzan_life_coaching/features/notifications/presentation/cubit/notifications_cubit.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) => EtzanPage(
        title: LocaleKeys.notifications.tr(context: context),
        child: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) => RefreshIndicator(
            onRefresh: context.read<NotificationsCubit>().load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              children: [
                EtzanSegmentedControl<NotificationFilter>(
                  items: {
                    NotificationFilter.all: LocaleKeys.all.tr(context: context),
                    NotificationFilter.unread:
                        LocaleKeys.unread.tr(context: context),
                    NotificationFilter.important:
                        LocaleKeys.important.tr(context: context),
                  },
                  selected: state.filter,
                  onChanged: context.read<NotificationsCubit>().changeFilter,
                ),
                const SizedBox(height: AppSpacing.xl),
                EtzanSectionTitle(title: LocaleKeys.today.tr(context: context)),
                const SizedBox(height: AppSpacing.sm),
                if (state.status == NotificationsStatus.loading &&
                    state.notifications.isEmpty) ...const [
                  EtzanLoadingCard(),
                  SizedBox(height: AppSpacing.sm),
                  EtzanLoadingCard(),
                  SizedBox(height: AppSpacing.sm),
                  EtzanLoadingCard(),
                ] else if (state.status == NotificationsStatus.failure &&
                    state.notifications.isEmpty)
                  AppErrorState(
                    title:
                        LocaleKeys.notificationsLoadError.tr(context: context),
                    message: (state.messageKey ?? LocaleKeys.tryAgain)
                        .tr(context: context),
                    retryLabel: LocaleKeys.retry.tr(context: context),
                    onRetry: context.read<NotificationsCubit>().load,
                  )
                else if (state.visibleNotifications.isEmpty)
                  EtzanEmptyState(
                    title: LocaleKeys.noNotifications.tr(context: context),
                    body: LocaleKeys.changeFilterOrReturnLater
                        .tr(context: context),
                  )
                else
                  ...state.visibleNotifications.map(
                    (notification) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: NotificationCard(notification: notification),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
}
