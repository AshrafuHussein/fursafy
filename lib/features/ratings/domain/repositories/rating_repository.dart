import 'package:fursafy/features/ratings/domain/entities/rating_entity.dart';
import 'package:fursafy/core/error/failures.dart';

/// Abstract rating repository — domain layer contract.
abstract class RatingRepository {
  /// Submit a rating.
  Future<({String? ratingId, Failure? failure})> submitRating({
    required String raterId,
    required String raterName,
    String? raterAvatarUrl,
    required String rateeId,
    required String jobId,
    required int score,
    String? comment,
  });

  /// Check if user already rated for this job.
  Future<bool> hasRated({
    required String raterId,
    required String jobId,
  });

  /// Get ratings for a user.
  Future<({List<RatingEntity> ratings, Failure? failure})> getUserRatings(
      String userId);
}
