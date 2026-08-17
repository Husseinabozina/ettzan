import 'package:equatable/equatable.dart';

enum NotificationKind {
  sessionReminder,
  achievement,
  motivation,
  goalFollowUp,
  newSession,
}

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
    required this.isImportant,
  });

  final String id;
  final NotificationKind kind;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final bool isImportant;

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        kind: kind,
        title: title,
        message: message,
        createdAt: createdAt,
        isRead: isRead ?? this.isRead,
        isImportant: isImportant,
      );

  @override
  List<Object?> get props =>
      [id, kind, title, message, createdAt, isRead, isImportant];
}
