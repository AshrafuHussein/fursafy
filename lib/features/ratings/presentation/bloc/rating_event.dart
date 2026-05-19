import 'package:equatable/equatable.dart';

abstract class RatingEvent extends Equatable {
  const RatingEvent();

  @override
  List<Object?> get props => [];
}

/// Submit a rating.
class RatingSubmitted extends RatingEvent {
  final String raterId;
  final String raterName;
  final String? raterAvatarUrl;
  final String rateeId;
  final String jobId;
  final int score;
  final String? comment;

  const RatingSubmitted({
    required this.raterId,
    required this.raterName,
    this.raterAvatarUrl,
    required this.rateeId,
    required this.jobId,
    required this.score,
    this.comment,
  });

  @override
  List<Object?> get props =>
      [raterId, raterName, rateeId, jobId, score, comment];
}

/// Load ratings for a user.
class RatingsLoadRequested extends RatingEvent {
  final String userId;
  const RatingsLoadRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Check if user already rated a job.
class RatingCheckRequested extends RatingEvent {
  final String raterId;
  final String jobId;
  const RatingCheckRequested({required this.raterId, required this.jobId});

  @override
  List<Object?> get props => [raterId, jobId];
}
