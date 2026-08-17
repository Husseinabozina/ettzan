import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:etzan_life_coaching/core/error/app_failure.dart';
import 'package:etzan_life_coaching/features/notifications/data/dto/notification_dto.dart';

abstract interface class NotificationsRemoteDataSource {
  Future<List<NotificationDto>> getNotifications();
  Stream<List<NotificationDto>> watchNotifications();
  Future<void> markAsRead(String id);
}

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  const NotificationsRemoteDataSourceImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<List<NotificationDto>> getNotifications() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw const AppFailure('auth_required', code: 'auth_required');
    }

    final rows = await _supabase
        .from('notifications')
        .select('id,type,title,body,payload,is_read,created_at')
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(100);

    return (rows as List<dynamic>)
        .map((row) =>
            _notificationFromJson(Map<String, dynamic>.from(row as Map)))
        .toList(growable: false);
  }

  @override
  Stream<List<NotificationDto>> watchNotifications() {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw const AppFailure('auth_required', code: 'auth_required');
    }

    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(100)
        .map((rows) => rows
            .map((row) => _notificationFromJson(Map<String, dynamic>.from(row)))
            .toList(growable: false));
  }

  @override
  Future<void> markAsRead(String id) async {
    if (_supabase.auth.currentUser == null) {
      throw const AppFailure('auth_required', code: 'auth_required');
    }
    await _supabase
        .from('notifications')
        .update({'is_read': true}).eq('id', id);
  }

  NotificationDto _notificationFromJson(Map<String, dynamic> json) {
    final payload = (json['payload'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    return NotificationDto.fromJson({
      'id': json['id'],
      'kind': json['type'],
      'title': json['title'],
      'message': json['body'] ?? '',
      'created_at': json['created_at'],
      'is_read': json['is_read'] ?? false,
      'is_important': payload['is_important'] == true,
    });
  }
}
