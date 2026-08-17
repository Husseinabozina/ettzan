import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:etzan_life_coaching/core/error/app_failure.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/features/notifications/domain/entities/app_notification.dart';
import 'package:etzan_life_coaching/features/notifications/domain/usecases/get_notifications.dart';
import 'package:etzan_life_coaching/features/notifications/domain/usecases/mark_notification_as_read.dart';
import 'package:etzan_life_coaching/features/notifications/domain/usecases/watch_notifications.dart';

part 'notifications_state.dart';

enum NotificationFilter { all, unread, important }

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(
      this._getNotifications, this._markAsRead, this._watchNotifications)
      : super(const NotificationsState.initial());

  final GetNotifications _getNotifications;
  final MarkNotificationAsRead _markAsRead;
  final WatchNotifications _watchNotifications;
  StreamSubscription<List<AppNotification>>? _notificationsSubscription;

  Future<void> load() async {
    emit(state.copyWith(status: NotificationsStatus.loading));
    try {
      final notifications = await _getNotifications();
      emit(state.copyWith(
        status: NotificationsStatus.success,
        notifications: notifications,
        clearMessageKey: true,
      ));
      _startWatching();
    } on AppFailure catch (e) {
      emit(state.copyWith(
        status: NotificationsStatus.failure,
        messageKey: _messageKeyForFailure(e),
      ));
    } catch (_) {
      emit(state.copyWith(
        status: NotificationsStatus.failure,
        messageKey: LocaleKeys.notificationsLoadRetry,
      ));
    }
  }

  void _startWatching() {
    _notificationsSubscription ??= _watchNotifications().listen(
      (notifications) {
        if (isClosed) return;
        emit(state.copyWith(
          status: NotificationsStatus.success,
          notifications: notifications,
          clearMessageKey: true,
        ));
      },
      onError: (_) {
        if (isClosed) return;
        emit(state.copyWith(
          status: NotificationsStatus.failure,
          messageKey: LocaleKeys.notificationsRealtimeError,
        ));
      },
    );
  }

  void changeFilter(NotificationFilter filter) =>
      emit(state.copyWith(filter: filter));

  Future<void> markAsRead(String id) async {
    final updated = state.notifications
        .map((item) => item.id == id ? item.copyWith(isRead: true) : item)
        .toList(growable: false);
    emit(state.copyWith(notifications: updated));
    try {
      await _markAsRead(id);
    } catch (_) {
      await load();
    }
  }

  @override
  Future<void> close() async {
    await _notificationsSubscription?.cancel();
    return super.close();
  }

  String _messageKeyForFailure(AppFailure failure) {
    if (failure.code == 'auth_required') return LocaleKeys.loginSessionExpired;
    return LocaleKeys.notificationsLoadRetry;
  }
}
