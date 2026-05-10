import 'package:fursafy/features/auth/domain/entities/user_entity.dart';
import 'package:fursafy/core/error/failures.dart';

/// Abstract auth repository — domain layer contract.
abstract class AuthRepository {
  /// Get current authenticated user, or null.
  Future<UserEntity?> getCurrentUser();

  /// Stream of auth state changes.
  Stream<UserEntity?> get authStateChanges;

  /// Sign in with email and password.
  Future<({UserEntity user, Failure? failure})> signInWithEmail({
    required String email,
    required String password,
  });

  /// Register with email and password.
  Future<({UserEntity user, Failure? failure})> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String role,
    String? phone,
  });

  /// Send phone OTP.
  Future<({Failure? failure, String? verificationId})> sendPhoneOtp({
    required String phoneNumber,
  });

  /// Verify phone OTP.
  Future<Failure?> verifyPhoneOtp({
    required String verificationId,
    required String otp,
  });

  /// Send password reset email.
  Future<Failure?> sendPasswordResetEmail({required String email});

  /// Create youth profile after registration.
  Future<Failure?> createYouthProfile({
    required String uid,
    required List<String> skills,
    required double latitude,
    required double longitude,
    String? bio,
  });

  /// Update FCM token for push notifications.
  Future<void> updateFcmToken(String uid, String token);

  /// Sign out.
  Future<void> signOut();
}
