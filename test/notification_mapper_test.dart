import 'package:flutter_test/flutter_test.dart';
import 'package:etzan_life_coaching/features/notifications/data/dto/notification_dto.dart';
import 'package:etzan_life_coaching/features/notifications/data/mappers/notification_mapper.dart';
import 'package:etzan_life_coaching/features/notifications/domain/entities/app_notification.dart';

void main() {
  test('notification API kind is mapped to a domain enum', () {
    const dto = NotificationDto(
      id: 'n1',
      kind: 'session_reminder',
      title: 'تذكير جلسة',
      message: 'بعد 30 دقيقة',
      createdAt: '2026-08-07T05:10:00+03:00',
      isRead: false,
      isImportant: true,
    );

    final domain = dto.toDomain();

    expect(domain.kind, NotificationKind.sessionReminder);
    expect(domain.isImportant, isTrue);
  });
}
