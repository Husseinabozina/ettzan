import 'package:etzan_life_coaching/features/notifications/data/dto/notification_dto.dart';
import 'package:etzan_life_coaching/features/notifications/domain/entities/app_notification.dart';

extension NotificationDtoMapper on NotificationDto {
  AppNotification toDomain() => AppNotification(
        id: id,
        kind: _kindFromApi(kind),
        title: title,
        message: message,
        createdAt: DateTime.parse(createdAt),
        isRead: isRead,
        isImportant: isImportant,
      );

  NotificationKind _kindFromApi(String value) => switch (value) {
        'session' => NotificationKind.sessionReminder,
        'goal' => NotificationKind.goalFollowUp,
        'habit' => NotificationKind.achievement,
        'message' => NotificationKind.newSession,
        'system' => NotificationKind.motivation,
        'session_reminder' => NotificationKind.sessionReminder,
        'achievement' => NotificationKind.achievement,
        'motivation' => NotificationKind.motivation,
        'goal_follow_up' => NotificationKind.goalFollowUp,
        'new_session' => NotificationKind.newSession,
        _ => NotificationKind.motivation,
      };
}
