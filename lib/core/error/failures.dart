/// Base failure class for domain-level errors.
abstract class Failure {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

/// Authentication failures.
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});

  factory AuthFailure.fromFirebaseCode(String code) {
    switch (code) {
      case 'user-not-found':
        return const AuthFailure(
          message: 'No user found with this email.',
          code: 'user-not-found',
        );
      case 'wrong-password':
        return const AuthFailure(
          message: 'Incorrect password.',
          code: 'wrong-password',
        );
      case 'email-already-in-use':
        return const AuthFailure(
          message: 'This email is already registered.',
          code: 'email-already-in-use',
        );
      case 'weak-password':
        return const AuthFailure(
          message: 'Password is too weak. Use at least 6 characters.',
          code: 'weak-password',
        );
      case 'invalid-email':
        return const AuthFailure(
          message: 'Invalid email address.',
          code: 'invalid-email',
        );
      case 'user-disabled':
        return const AuthFailure(
          message: 'This account has been suspended.',
          code: 'user-disabled',
        );
      case 'too-many-requests':
        return const AuthFailure(
          message: 'Too many attempts. Please try again later.',
          code: 'too-many-requests',
        );
      default:
        return AuthFailure(
          message: 'Authentication failed: $code',
          code: code,
        );
    }
  }
}

/// Firestore/data failures.
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

/// Network failures.
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
    super.code = 'network-error',
  });
}

/// Cache/local storage failures.
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Failed to load cached data.',
    super.code = 'cache-error',
  });
}

/// Permission failures.
class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = 'You do not have permission to perform this action.',
    super.code = 'permission-denied',
  });
}

/// Validation failures.
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code = 'validation'});
}
