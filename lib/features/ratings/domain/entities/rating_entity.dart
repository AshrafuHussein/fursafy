import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Rating entity — mutual ratings between youth and provider per job.
class RatingEntity extends Equatable {
  final String id;
  final String raterId;
  final String raterName;
  final String? raterAvatarUrl;
  final String rateeId;
  final String jobId;
  final int score; // 1-5
  final String? comment;
  final DateTime createdAt;

  const RatingEntity({
    required this.id,
    required this.raterId,
    required this.raterName,
    this.raterAvatarUrl,
    required this.rateeId,
    required this.jobId,
    required this.score,
    this.comment,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, raterId, rateeId, jobId, score];

  Map<String, dynamic> toMap() => {
        'raterId': raterId,
        'raterName': raterName,
        'raterAvatarUrl': raterAvatarUrl,
        'rateeId': rateeId,
        'jobId': jobId,
        'score': score,
        'comment': comment,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory RatingEntity.fromMap(String id, Map<String, dynamic> map) =>
      RatingEntity(
        id: id,
        raterId: map['raterId'] as String,
        raterName: map['raterName'] as String? ?? '',
        raterAvatarUrl: map['raterAvatarUrl'] as String?,
        rateeId: map['rateeId'] as String,
        jobId: map['jobId'] as String,
        score: (map['score'] as num?)?.toInt() ?? 0,
        comment: map['comment'] as String?,
        createdAt:
            (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
}
