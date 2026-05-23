import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fursafy/core/constants/app_constants.dart';

/// Application entity — a youth's application for a specific job.
class ApplicationEntity extends Equatable {
  final String id;
  final String jobId;
  final String jobTitle;
  final String youthId;
  final String youthName;
  final String? youthAvatarUrl;
  final String providerId;
  final ApplicationStatus status;
  final String? coverMessage;
  final DateTime appliedAt;

  final Map<String, bool>? checklist;
  final bool arrived;

  const ApplicationEntity({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.youthId,
    required this.youthName,
    this.youthAvatarUrl,
    required this.providerId,
    this.status = ApplicationStatus.pending,
    this.coverMessage,
    required this.appliedAt,
    this.checklist,
    this.arrived = false,
  });

  @override
  List<Object?> get props => [id, jobId, youthId, status, appliedAt, checklist, arrived];

  Map<String, dynamic> toMap() => {
        'jobId': jobId,
        'jobTitle': jobTitle,
        'youthId': youthId,
        'youthName': youthName,
        'youthAvatarUrl': youthAvatarUrl,
        'providerId': providerId,
        'status': status.name,
        'coverMessage': coverMessage,
        'appliedAt': Timestamp.fromDate(appliedAt),
        'checklist': checklist,
        'arrived': arrived,
      };

  factory ApplicationEntity.fromMap(String id, Map<String, dynamic> map) =>
      ApplicationEntity(
        id: id,
        jobId: map['jobId'] as String,
        jobTitle: map['jobTitle'] as String? ?? '',
        youthId: map['youthId'] as String,
        youthName: map['youthName'] as String? ?? '',
        youthAvatarUrl: map['youthAvatarUrl'] as String?,
        providerId: map['providerId'] as String,
        status: ApplicationStatus.fromString(
            map['status'] as String? ?? 'pending'),
        coverMessage: map['coverMessage'] as String?,
        appliedAt:
            (map['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        checklist: map['checklist'] != null
            ? Map<String, bool>.from(map['checklist'] as Map)
            : null,
        arrived: map['arrived'] as bool? ?? false,
      );

  ApplicationEntity copyWith({
    String? id,
    String? jobId,
    String? jobTitle,
    String? youthId,
    String? youthName,
    String? youthAvatarUrl,
    String? providerId,
    ApplicationStatus? status,
    String? coverMessage,
    DateTime? appliedAt,
    Map<String, bool>? checklist,
    bool? arrived,
  }) =>
      ApplicationEntity(
        id: id ?? this.id,
        jobId: jobId ?? this.jobId,
        jobTitle: jobTitle ?? this.jobTitle,
        youthId: youthId ?? this.youthId,
        youthName: youthName ?? this.youthName,
        youthAvatarUrl: youthAvatarUrl ?? this.youthAvatarUrl,
        providerId: providerId ?? this.providerId,
        status: status ?? this.status,
        coverMessage: coverMessage ?? this.coverMessage,
        appliedAt: appliedAt ?? this.appliedAt,
        checklist: checklist ?? this.checklist,
        arrived: arrived ?? this.arrived,
      );
}
