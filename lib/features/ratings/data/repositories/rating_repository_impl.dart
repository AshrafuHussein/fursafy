import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fursafy/core/constants/app_constants.dart';
import 'package:fursafy/core/error/failures.dart';
import 'package:fursafy/features/ratings/domain/entities/rating_entity.dart';
import 'package:fursafy/features/ratings/domain/repositories/rating_repository.dart';

/// Firestore implementation of [RatingRepository].
class RatingRepositoryImpl implements RatingRepository {
  final FirebaseFirestore _db;
  RatingRepositoryImpl({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirestorePaths.ratings);

  @override
  Future<({String? ratingId, Failure? failure})> submitRating({
    required String raterId,
    required String raterName,
    String? raterAvatarUrl,
    required String rateeId,
    required String jobId,
    required int score,
    String? comment,
  }) async {
    try {
      // Prevent duplicate rating
      final existing = await _col
          .where('raterId', isEqualTo: raterId)
          .where('jobId', isEqualTo: jobId)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) {
        return (
          ratingId: null,
          failure: const ValidationFailure(
            message: 'You have already rated this job',
          ),
        );
      }

      final docRef = await _col.add({
        'raterId': raterId,
        'raterName': raterName,
        'raterAvatarUrl': raterAvatarUrl,
        'rateeId': rateeId,
        'jobId': jobId,
        'score': score,
        'comment': comment ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update ratee's average score in their profile
      await _updateAverageScore(rateeId);

      return (ratingId: docRef.id, failure: null);
    } catch (e) {
      return (
        ratingId: null,
        failure: ServerFailure(message: 'Failed to submit rating: $e'),
      );
    }
  }

  @override
  Future<bool> hasRated({
    required String raterId,
    required String jobId,
  }) async {
    try {
      final snap = await _col
          .where('raterId', isEqualTo: raterId)
          .where('jobId', isEqualTo: jobId)
          .limit(1)
          .get();
      return snap.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<({List<RatingEntity> ratings, Failure? failure})> getUserRatings(
    String userId,
  ) async {
    try {
      final snap = await _col
          .where('rateeId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      final ratings = snap.docs
          .map((d) => RatingEntity.fromMap(d.id, d.data()))
          .toList();
      return (ratings: ratings, failure: null);
    } catch (e) {
      return (
        ratings: <RatingEntity>[],
        failure: ServerFailure(message: 'Failed to load ratings: $e'),
      );
    }
  }

  /// Recalculates and stores the average rating on the user's document.
  Future<void> _updateAverageScore(String userId) async {
    try {
      final snap = await _col.where('rateeId', isEqualTo: userId).get();
      if (snap.docs.isEmpty) return;

      final total = snap.docs.fold<int>(
        0,
        (acc, d) => acc + (d.data()['score'] as int? ?? 0),
      );
      final avg = total / snap.docs.length;

      final ratingAvg = double.parse(avg.toStringAsFixed(1));
      final ratingCount = snap.docs.length;

      // Update in users collection
      await _db.collection(FirestorePaths.users).doc(userId).update({
        'ratingAvg': ratingAvg,
        'ratingCount': ratingCount,
        'averageRating':
            ratingAvg, // Keep for backward compatibility with profile screen
        'totalRatings': ratingCount,
      });

      // Also attempt to update youth_profiles if it exists
      try {
        await _db.collection(FirestorePaths.youthProfiles).doc(userId).update({
          'ratingAvg': ratingAvg,
          'ratingCount': ratingCount,
          'averageRating': ratingAvg,
        });
      } catch (_) {}

      // If the rated user is a provider, update the rating on all their jobs
      try {
        final jobsSnap = await _db
            .collection(FirestorePaths.jobs)
            .where('providerId', isEqualTo: userId)
            .get();

        if (jobsSnap.docs.isNotEmpty) {
          final batch = _db.batch();
          for (final doc in jobsSnap.docs) {
            batch.update(doc.reference, {'providerRating': ratingAvg});
          }
          await batch.commit();
        }
        // ignore: empty_catches
      } catch (e) {}

      // ignore: empty_catches
    } catch (e) {}
  }
}
