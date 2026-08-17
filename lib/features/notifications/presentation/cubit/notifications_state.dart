part of 'notifications_cubit.dart';

enum NotificationsStatus { initial, loading, success, failure }

class NotificationsState extends Equatable {
  const NotificationsState({
    required this.status,
    required this.notifications,
    required this.filter,
    this.messageKey,
  });

  const NotificationsState.initial()
      : status = NotificationsStatus.initial,
        notifications = const <AppNotification>[],
        filter = NotificationFilter.all,
        messageKey = null;

  final NotificationsStatus status;
  final List<AppNotification> notifications;
  final NotificationFilter filter;
  final String? messageKey;

  List<AppNotification> get visibleNotifications => switch (filter) {
        NotificationFilter.all => notifications,
        NotificationFilter.unread =>
          notifications.where((item) => !item.isRead).toList(growable: false),
        NotificationFilter.important => notifications
            .where((item) => item.isImportant)
            .toList(growable: false),
      };

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<AppNotification>? notifications,
    NotificationFilter? filter,
    String? messageKey,
    bool clearMessageKey = false,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      filter: filter ?? this.filter,
      messageKey: clearMessageKey ? null : (messageKey ?? this.messageKey),
    );
  }

  @override
  List<Object?> get props => [status, notifications, filter, messageKey];
}
