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
    if (uid == null) return;

    emit(state.copyWith(status: NotificationStatus.loading));

    final result = await _repository.getNotifications(uid);
    if (result.failure != null) {
      emit(state.copyWith(
        status: NotificationStatus.error,
        errorMessage: result.failure!.message,
      ));
    } else {
      emit(state.copyWith(
        status: NotificationStatus.loaded,
        notifications: result.notifications,
      ));
    }
  }

  Future<void> _onUnreadSubscription(
    UnreadCountSubscriptionRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final uid = _uid;
    if (uid == null) return;

    _unreadSub?.cancel();
  _unreadSub = _repository.getUnreadCount(uid).listen(
          (unreadCount) => add(_UnreadCountUpdated(unreadCount)),
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

  /// Handle FCM foreground message → reload notifications from Firestore.
  ///
  /// The Cloud Function already writes the notification document to Firestore,
  /// so we reload from the canonical source instead of creating a synthetic
  /// in-memory entry (which would get wiped on the next Firestore load).
  void _handleFcmMessage(RemoteMessage message) {
    debugPrint('[FCM] Foreground message received — reloading notifications');

    // Small delay to allow the Cloud Function Firestore write to propagate
    Future.delayed(const Duration(milliseconds: 800), () {
      add(const NotificationLoadRequested());
    });
  }

  void _onNotificationReceived(
    NotificationReceived event,
    Emitter<NotificationState> emit,
  ) {
    final newNotification = NotificationEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _parseType(event.data['type'] as String?),
      message: event.data['message'] as String? ?? '',
      jobId: event.data['jobId'] as String?,
      isRead: false,
      createdAt: DateTime.now(),
    );

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
