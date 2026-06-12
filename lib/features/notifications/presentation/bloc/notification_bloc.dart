import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fursafy/features/notifications/domain/entities/notification_entity.dart';
import 'package:fursafy/features/notifications/domain/repositories/notification_repository.dart';
import 'package:fursafy/core/services/notification_service.dart';
import 'package:fursafy/core/constants/app_constants.dart';

part 'notification_event.dart';
part 'notification_state.dart';

/// NotificationBloc — manages notification state, unread count,
/// and integrates with FCM foreground messages.
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _repository;
  StreamSubscription<int>? _unreadSub;

  NotificationBloc({required NotificationRepository repository})
      : _repository = repository,
        super(const NotificationState()) {
    on<NotificationLoadRequested>(_onLoadRequested);
    on<UnreadCountSubscriptionRequested>(_onUnreadSubscription);
    on<NotificationMarkAsRead>(_onMarkAsRead);
    on<NotificationMarkAllAsRead>(_onMarkAllAsRead);
    on<NotificationReceived>(_onNotificationReceived);
    on<_UnreadCountUpdated>(_onUnreadCountUpdated);

    // Register as the foreground message handler
    NotificationService.instance.onForegroundMessage = _handleFcmMessage;
  }

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> _onLoadRequested(
    NotificationLoadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final uid = _uid;
    debugPrint('[NotifBloc] _onLoadRequested — uid=$uid');
    if (uid == null) {
      debugPrint('[NotifBloc] No authenticated user — skipping load');
      return;
    }

    emit(state.copyWith(status: NotificationStatus.loading));

    final result = await _repository.getNotifications(uid);
    if (result.failure != null) {
      debugPrint('[NotifBloc] Load FAILED: ${result.failure!.message}');
      emit(state.copyWith(
        status: NotificationStatus.error,
        errorMessage: result.failure!.message,
      ));
    } else {
      debugPrint('[NotifBloc] Loaded ${result.notifications.length} notifications from Firestore');

      // Merge: preserve FCM-originated notifications (id starts with 'fcm_')
      // that don't yet have a matching Firestore document.
      // Match by message content + type to detect duplicates.
      final firestoreNotifs = result.notifications;
      final fcmOnly = state.notifications
          .where((n) => n.id.startsWith('fcm_'))
          .where((n) => !firestoreNotifs.any(
              (f) => f.message == n.message && f.type == n.type))
          .toList();

      debugPrint('[NotifBloc] Keeping ${fcmOnly.length} FCM-only notifications');
      final merged = [...fcmOnly, ...firestoreNotifs];

      emit(state.copyWith(
        status: NotificationStatus.loaded,
        notifications: merged,
      ));
    }
  }

  Future<void> _onUnreadSubscription(
    UnreadCountSubscriptionRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final uid = _uid;
    debugPrint('[NotifBloc] UnreadCountSubscriptionRequested — uid=$uid');
    if (uid == null) return;

    _unreadSub?.cancel();
    _unreadSub = _repository.getUnreadCount(uid).listen(
      (unreadCount) {
        debugPrint('[NotifBloc] Unread count stream → $unreadCount');
        add(_UnreadCountUpdated(unreadCount));
      },
      onError: (e) {
        debugPrint('[NotifBloc] Unread count stream ERROR: $e');
      },
    );
  }

  void _onUnreadCountUpdated(
    _UnreadCountUpdated event,
    Emitter<NotificationState> emit,
  ) {
    emit(state.copyWith(unreadCount: event.count));
  }

  Future<void> _onMarkAsRead(
    NotificationMarkAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final uid = _uid;
    if (uid == null) return;

    await _repository.markAsRead(uid, event.notificationId);

    // Optimistically update the local list
    final updated = state.notifications.map((n) {
      if (n.id == event.notificationId) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    emit(state.copyWith(notifications: updated));
  }

  Future<void> _onMarkAllAsRead(
    NotificationMarkAllAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final uid = _uid;
    if (uid == null) return;

    await _repository.markAllAsRead(uid);

    // Optimistically update all as read
    final updated =
        state.notifications.map((n) => n.copyWith(isRead: true)).toList();

    emit(state.copyWith(notifications: updated, unreadCount: 0));
  }

  /// Handle FCM foreground message — add it to state immediately for
  /// instant UI feedback, then reload from Firestore to reconcile.
  void _handleFcmMessage(RemoteMessage message) {
    final data = message.data;
    final notification = message.notification;
    debugPrint('[FCM] Foreground message received — adding to state');

    // 1. Show immediately (synthetic entry with 'fcm_' prefix)
    add(NotificationReceived({
      'type': data['type'] ?? 'job_match',
      'message': notification?.body ?? data['message'] ?? '',
      'title': notification?.title ?? '',
      'jobId': data['jobId'],
      'applicationId': data['applicationId'],
      'isRead': false,
    }));

    // 2. Reload from Firestore after a delay so the Cloud Function's
    //    write has time to propagate. The merge logic in _onLoadRequested
    //    will replace the synthetic entry with the real Firestore doc
    //    (matched by message + type), or keep it if no match exists.
    Future.delayed(const Duration(seconds: 2), () {
      add(const NotificationLoadRequested());
    });
  }

  void _onNotificationReceived(
    NotificationReceived event,
    Emitter<NotificationState> emit,
  ) {
    final newNotification = NotificationEntity(
      id: 'fcm_${DateTime.now().millisecondsSinceEpoch}',
      type: _parseType(event.data['type'] as String?),
      message: event.data['message'] as String? ?? '',
      jobId: event.data['jobId'] as String?,
      isRead: false,
      createdAt: DateTime.now(),
    );

    debugPrint('[NotifBloc] Added FCM notification: ${newNotification.id}');
    final updated = [newNotification, ...state.notifications];
    emit(state.copyWith(
      notifications: updated,
      unreadCount: state.unreadCount + 1,
    ));
  }

  NotificationType _parseType(String? type) {
    try {
      return NotificationType.fromString(type ?? '');
    } catch (_) {
      return NotificationType.jobMatch;
    }
  }

  @override
  Future<void> close() {
    _unreadSub?.cancel();
    NotificationService.instance.onForegroundMessage = null;
    return super.close();
  }
}
