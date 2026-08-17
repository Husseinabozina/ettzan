class NotificationDto {
  const NotificationDto({
    required this.id,
    required this.kind,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
    required this.isImportant,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) =>
      NotificationDto(
        id: json['id'] as String,
        kind: json['kind'] as String,
        title: json['title'] as String,
        message: json['message'] as String,
        createdAt: json['created_at'] as String,
        isRead: json['is_read'] as bool,
        isImportant: json['is_important'] as bool,
      );

  final String id;
  final String kind;
  final String title;
  final String message;
  final String createdAt;
  final bool isRead;
  final bool isImportant;
}
