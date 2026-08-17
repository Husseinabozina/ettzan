import 'package:etzan_life_coaching/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:etzan_life_coaching/features/notifications/data/mappers/notification_mapper.dart';
import 'package:etzan_life_coaching/features/notifications/domain/entities/app_notification.dart';
import 'package:etzan_life_coaching/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl(this._remoteDataSource);
  final NotificationsRemoteDataSource _remoteDataSource;

  @override
  Future<List<AppNotification>> getNotifications() async {
    final dtos = await _remoteDataSource.getNotifications();
    return dtos.map((dto) => dto.toDomain()).toList(growable: false);
  }

  @override
  Stream<List<AppNotification>> watchNotifications() {
    return _remoteDataSource.watchNotifications().map(
          (dtos) => dtos.map((dto) => dto.toDomain()).toList(growable: false),
        );
  }

  @override
  Future<void> markAsRead(String id) => _remoteDataSource.markAsRead(id);
}
