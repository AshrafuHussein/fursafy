import 'package:fursafy/features/auth/domain/entities/user_entity.dart';
import 'package:fursafy/core/error/failures.dart';

/// Abstract profile repository — domain layer contract.
abstract class ProfileRepository {
  /// Get user profile by uid.
  Future<({UserEntity? user, Failure? failure})> getUserProfile(String uid);

  /// Get youth profile by uid.
  Future<({YouthProfile? profile, Failure? failure})> getYouthProfile(
      String uid);

  /// Update user profile.
  Future<Failure?> updateUserProfile(UserEntity user);

  /// Update youth profile.
  Future<Failure?> updateYouthProfile(YouthProfile profile);

  /// Upload profile avatar and return download URL.
  Future<({String? url, Failure? failure})> uploadAvatar(
      String uid, String filePath);
}
