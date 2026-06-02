part of 'notification_bloc.dart';

/// Notification loading status.
enum NotificationStatus { initial, loading, loaded, error }

/// Notification state.
class NotificationState extends Equatable {
  final List<NotificationEntity> notifications;
  final int unreadCount;
  final NotificationStatus status;
  final String? errorMessage;

  const NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.status = NotificationStatus.initial,
    this.errorMessage,
  });

  NotificationState copyWith({
    List<NotificationEntity>? notifications,
    int? unreadCount,
    NotificationStatus? status,
    String? errorMessage,
  }) =>
      NotificationState(
        notifications: notifications ?? this.notifications,
        unreadCount: unreadCount ?? this.unreadCount,
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [notifications, unreadCount, status, errorMessage];
}
