import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fursafy/core/constants/app_constants.dart';

/// User entity — represents any user (youth, provider, admin).
class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String? phone;
  final String displayName;
  final String? avatarUrl;
  final UserRole role;
  final AccountStatus status;
  final String? fcmToken;
  final GeoPoint? location;
  final String? locationName;
  final DateTime createdAt;

  const UserEntity({
    required this.uid,
    required this.email,
    this.phone,
    required this.displayName,
    this.avatarUrl,
    required this.role,
    this.status = AccountStatus.active,
    this.fcmToken,
    this.location,
    this.locationName,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        uid,
        email,
        phone,
        displayName,
        avatarUrl,
        role,
        status,
        fcmToken,
        location,
        locationName,
        createdAt,
      ];

  /// Firestore serialization.
  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'phone': phone,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'role': role.name,
        'status': status.name,
        'fcmToken': fcmToken,
        'location': location,
        'locationName': locationName,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory UserEntity.fromMap(Map<String, dynamic> map) => UserEntity(
        uid: map['uid'] as String,
        email: map['email'] as String,
        phone: map['phone'] as String?,
        displayName: map['displayName'] as String? ?? '',
        avatarUrl: map['avatarUrl'] as String?,
        role: UserRole.fromString(map['role'] as String? ?? 'youth'),
        status:
            AccountStatus.fromString(map['status'] as String? ?? 'active'),
        fcmToken: map['fcmToken'] as String?,
        location: map['location'] as GeoPoint?,
        locationName: map['locationName'] as String?,
        createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  UserEntity copyWith({
    String? uid,
    String? email,
    String? phone,
    String? displayName,
    String? avatarUrl,
    UserRole? role,
    AccountStatus? status,
    String? fcmToken,
    GeoPoint? location,
    String? locationName,
    DateTime? createdAt,
  }) =>
      UserEntity(
        uid: uid ?? this.uid,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        displayName: displayName ?? this.displayName,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        role: role ?? this.role,
        status: status ?? this.status,
        fcmToken: fcmToken ?? this.fcmToken,
        location: location ?? this.location,
        locationName: locationName ?? this.locationName,
        createdAt: createdAt ?? this.createdAt,
      );
}

/// Youth profile entity.
class YouthProfile extends Equatable {
  final String uid;
  final List<String> skills;
  final GeoPoint? location;
  final String? bio;
  final double ratingAvg;
  final int ratingCount;
  final int jobsCompleted;
  final String status; // 'available' or 'unavailable'

  const YouthProfile({
    required this.uid,
    this.skills = const [],
    this.location,
    this.bio,
    this.ratingAvg = 0.0,
    this.ratingCount = 0,
    this.jobsCompleted = 0,
    this.status = 'available',
  });

  @override
  List<Object?> get props => [
        uid,
        skills,
        location,
        bio,
        ratingAvg,
        ratingCount,
        jobsCompleted,
        status,
      ];

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'skills': skills,
        'location': location,
        'bio': bio,
        'ratingAvg': ratingAvg,
        'ratingCount': ratingCount,
        'jobsCompleted': jobsCompleted,
        'status': status,
      };

  factory YouthProfile.fromMap(Map<String, dynamic> map) => YouthProfile(
        uid: map['uid'] as String,
        skills: List<String>.from(map['skills'] ?? []),
        location: map['location'] as GeoPoint?,
        bio: map['bio'] as String?,
        ratingAvg: (map['ratingAvg'] as num?)?.toDouble() ?? 0.0,
        ratingCount: (map['ratingCount'] as num?)?.toInt() ?? 0,
        jobsCompleted: (map['jobsCompleted'] as num?)?.toInt() ?? 0,
        status: map['status'] as String? ?? 'available',
      );

  YouthProfile copyWith({
    String? uid,
    List<String>? skills,
    GeoPoint? location,
    String? bio,
    double? ratingAvg,
    int? ratingCount,
    int? jobsCompleted,
    String? status,
  }) =>
      YouthProfile(
        uid: uid ?? this.uid,
        skills: skills ?? this.skills,
        location: location ?? this.location,
        bio: bio ?? this.bio,
        ratingAvg: ratingAvg ?? this.ratingAvg,
        ratingCount: ratingCount ?? this.ratingCount,
        jobsCompleted: jobsCompleted ?? this.jobsCompleted,
        status: status ?? this.status,
      );
}
