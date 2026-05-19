import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fursafy/core/constants/app_constants.dart';
import 'package:fursafy/core/error/failures.dart';
import 'package:fursafy/features/notifications/domain/entities/notification_entity.dart';
import 'package:fursafy/features/notifications/domain/repositories/notification_repository.dart';

/// Firestore implementation of [NotificationRepository].
class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseFirestore _db;
  NotificationRepositoryImpl({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection(FirestorePaths.users).doc(uid)
          .collection('notifications');

  @override
  Future<({List<NotificationEntity> notifications, Failure? failure})>
      getNotifications(String uid, {int limit = 50}) async {
    try {
      final snap = await _col(uid)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      final items = snap.docs
          .map((d) => NotificationEntity.fromMap(d.id, d.data()))
          .toList();
      return (notifications: items, failure: null);
    } catch (e) {
      return (
        notifications: <NotificationEntity>[],
        failure: ServerFailure(message: 'Failed to load notifications: $e'),
      );
    }
  }

  @override
  Stream<int> getUnreadCount(String uid) {
    return _col(uid)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  @override
  Future<Failure?> markAsRead(String uid, String notificationId) async {
    try {
      await _col(uid).doc(notificationId).update({'read': true});
      return null;
    } catch (e) {
      return ServerFailure(message: 'Failed to mark as read: $e');
    }
  }

  @override
  Future<Failure?> markAllAsRead(String uid) async {
    try {
      final snap = await _col(uid).where('read', isEqualTo: false).get();
      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();
      return null;
    } catch (e) {
      return ServerFailure(message: 'Failed to mark all as read: $e');
    }
  }
}
