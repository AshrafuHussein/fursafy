import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminInviteEntity extends Equatable {
  final String email;
  final String role;
  final String status;
  final String invitedBy;
  final DateTime sentAt;
  final DateTime? acceptedAt;

  const AdminInviteEntity({
    required this.email,
    required this.role,
    required this.status,
    required this.invitedBy,
    required this.sentAt,
    this.acceptedAt,
  });

  @override
  List<Object?> get props => [email, role, status, invitedBy, sentAt, acceptedAt];

  Map<String, dynamic> toMap() => {
        'email': email,
        'role': role,
        'status': status,
        'invitedBy': invitedBy,
        'sentAt': Timestamp.fromDate(sentAt),
        'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      };

  factory AdminInviteEntity.fromMap(Map<String, dynamic> map) => AdminInviteEntity(
        email: map['email'] as String? ?? '',
        role: map['role'] as String? ?? 'Moderator',
        status: map['status'] as String? ?? 'pending',
        invitedBy: map['invitedBy'] as String? ?? '',
        sentAt: (map['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        acceptedAt: (map['acceptedAt'] as Timestamp?)?.toDate(),
      );
}
