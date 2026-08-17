import 'package:etzan_life_coaching/features/notifications/domain/entities/app_notification.dart';
import 'package:etzan_life_coaching/features/notifications/domain/repositories/notifications_repository.dart';

class GetNotifications {
  const GetNotifications(this._repository);
  final NotificationsRepository _repository;
  Future<List<AppNotification>> call() => _repository.getNotifications();
}
