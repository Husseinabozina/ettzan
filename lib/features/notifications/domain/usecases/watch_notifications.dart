import 'package:etzan_life_coaching/features/notifications/domain/entities/app_notification.dart';
import 'package:etzan_life_coaching/features/notifications/domain/repositories/notifications_repository.dart';

class WatchNotifications {
  const WatchNotifications(this._repository);
  final NotificationsRepository _repository;

  Stream<List<AppNotification>> call() => _repository.watchNotifications();
}
