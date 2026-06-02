part of 'notification_bloc.dart';

/// Notification events.
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Load notifications from Firestore.
class NotificationLoadRequested extends NotificationEvent {
  const NotificationLoadRequested();
}

/// Start streaming the unread notification count.
class UnreadCountSubscriptionRequested extends NotificationEvent {
  const UnreadCountSubscriptionRequested();
}

/// Mark a single notification as read.
class NotificationMarkAsRead extends NotificationEvent {
  final String notificationId;

  const NotificationMarkAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Mark all notifications as read.
class NotificationMarkAllAsRead extends NotificationEvent {
  const NotificationMarkAllAsRead();
}

/// A new notification arrived via FCM foreground handler.
class NotificationReceived extends NotificationEvent {
  final Map<String, dynamic> data;

  const NotificationReceived(this.data);

  @override
  List<Object?> get props => [data];
}

/// Unread count changed (from stream).
class _UnreadCountUpdated extends NotificationEvent {
  final int count;

  const _UnreadCountUpdated(this.count);

  @override
  List<Object?> get props => [count];
}
