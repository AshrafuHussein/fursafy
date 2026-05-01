import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fursafy/core/constants/app_constants.dart';

/// Notification entity — stored per-user in notifications/{uid}.
class NotificationEntity extends Equatable {
  final String id;
  final NotificationType type;
  final String message;
  final String? jobId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.type,
    required this.message,
    this.jobId,
    this.isRead = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, type, isRead, createdAt];

  Map<String, dynamic> toMap() => {
        'type': type.firestoreValue,
        'message': message,
        'jobId': jobId,
        'isRead': isRead,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory NotificationEntity.fromMap(String id, Map<String, dynamic> map) =>
      NotificationEntity(
        id: id,
        type: NotificationType.fromString(map['type'] as String? ?? ''),
        message: map['message'] as String? ?? '',
        jobId: map['jobId'] as String?,
        isRead: map['isRead'] as bool? ?? false,
        createdAt:
            (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  NotificationEntity copyWith({
    String? id,
    NotificationType? type,
    String? message,
    String? jobId,
    bool? isRead,
    DateTime? createdAt,
  }) =>
      NotificationEntity(
        id: id ?? this.id,
        type: type ?? this.type,
        message: message ?? this.message,
        jobId: jobId ?? this.jobId,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt ?? this.createdAt,
      );
}
