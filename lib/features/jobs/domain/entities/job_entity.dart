import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fursafy/core/constants/app_constants.dart';

/// Job listing entity.
class JobEntity extends Equatable {
  final String id;
  final String providerId;
  final String providerName;
  final String? providerAvatarUrl;
  final double providerRating;
  final int providerJobsDone;
  final String title;
  final String description;
  final List<String> skillsRequired;
  final GeoPoint? location;
  final String? locationName;
  final double payAmount;
  final PayType payType;
  final String category;
  final JobStatus status;
  final DateTime? deadline;
  final DateTime createdAt;

  const JobEntity({
    required this.id,
    required this.providerId,
    required this.providerName,
    this.providerAvatarUrl,
    this.providerRating = 0.0,
    this.providerJobsDone = 0,
    required this.title,
    required this.description,
    this.skillsRequired = const [],
    this.location,
    this.locationName,
    required this.payAmount,
    this.payType = PayType.fixed,
    required this.category,
    this.status = JobStatus.open,
    this.deadline,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        providerId,
        title,
        status,
        createdAt,
      ];

  Map<String, dynamic> toMap() => {
        'providerId': providerId,
        'providerName': providerName,
        'providerAvatarUrl': providerAvatarUrl,
        'providerRating': providerRating,
        'providerJobsDone': providerJobsDone,
        'title': title,
        'description': description,
        'skillsRequired': skillsRequired,
        'location': location,
        'locationName': locationName,
        'payAmount': payAmount,
        'payType': payType.name,
        'category': category,
        'status': status.name,
        'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory JobEntity.fromMap(String id, Map<String, dynamic> map) => JobEntity(
        id: id,
        providerId: map['providerId'] as String,
        providerName: map['providerName'] as String? ?? '',
        providerAvatarUrl: map['providerAvatarUrl'] as String?,
        providerRating: (map['providerRating'] as num?)?.toDouble() ?? 0.0,
        providerJobsDone: (map['providerJobsDone'] as num?)?.toInt() ?? 0,
        title: map['title'] as String,
        description: map['description'] as String? ?? '',
        skillsRequired: List<String>.from(map['skillsRequired'] ?? []),
        location: map['location'] as GeoPoint?,
        locationName: map['locationName'] as String?,
        payAmount: (map['payAmount'] as num?)?.toDouble() ?? 0.0,
        payType: PayType.fromString(map['payType'] as String? ?? 'fixed'),
        category: map['category'] as String? ?? 'Other',
        status: JobStatus.fromString(map['status'] as String? ?? 'open'),
        deadline: (map['deadline'] as Timestamp?)?.toDate(),
        createdAt:
            (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  JobEntity copyWith({
    String? id,
    String? providerId,
    String? providerName,
    String? providerAvatarUrl,
    double? providerRating,
    int? providerJobsDone,
    String? title,
    String? description,
    List<String>? skillsRequired,
    GeoPoint? location,
    String? locationName,
    double? payAmount,
    PayType? payType,
    String? category,
    JobStatus? status,
    DateTime? deadline,
    DateTime? createdAt,
  }) =>
      JobEntity(
        id: id ?? this.id,
        providerId: providerId ?? this.providerId,
        providerName: providerName ?? this.providerName,
        providerAvatarUrl: providerAvatarUrl ?? this.providerAvatarUrl,
        providerRating: providerRating ?? this.providerRating,
        providerJobsDone: providerJobsDone ?? this.providerJobsDone,
        title: title ?? this.title,
        description: description ?? this.description,
        skillsRequired: skillsRequired ?? this.skillsRequired,
        location: location ?? this.location,
        locationName: locationName ?? this.locationName,
        payAmount: payAmount ?? this.payAmount,
        payType: payType ?? this.payType,
        category: category ?? this.category,
        status: status ?? this.status,
        deadline: deadline ?? this.deadline,
        createdAt: createdAt ?? this.createdAt,
      );
}
