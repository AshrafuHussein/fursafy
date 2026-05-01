import 'package:fursafy/features/notifications/domain/entities/notification_entity.dart';
import 'package:fursafy/core/error/failures.dart';

/// Abstract notification repository — domain layer contract.
abstract class NotificationRepository {
  /// Get notifications for a user.
  Future<({List<NotificationEntity> notifications, Failure? failure})>
      getNotifications(String uid, {int limit = 50});

  /// Stream of unread notification count.
  Stream<int> getUnreadCount(String uid);

  /// Mark a notification as read.
  Future<Failure?> markAsRead(String uid, String notificationId);

  /// Mark all notifications as read.
  Future<Failure?> markAllAsRead(String uid);
}
