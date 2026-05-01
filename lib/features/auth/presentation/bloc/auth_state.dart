part of 'auth_bloc.dart';

/// Auth states.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state — checking auth.
class AuthInitial extends AuthState {}

/// Loading state.
class AuthLoading extends AuthState {}

/// User is authenticated.
class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// User is not authenticated.
class AuthUnauthenticated extends AuthState {}

/// Auth error.
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Password reset email sent.
class AuthPasswordResetSent extends AuthState {}
