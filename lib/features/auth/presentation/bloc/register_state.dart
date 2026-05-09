part of 'register_bloc.dart';

enum RegisterStatus {
  initial,
  loading,
  roleSelected,
  detailsSubmitted,
  otpSent,
  otpVerified,
  success,
  failure,
}

class RegisterState extends Equatable {
  final RegisterStatus status;
  final String? errorMessage;

  final String? role;
  final String? email;
  final String? phone;
  final String? password;
  final String? displayName;
  final String? verificationId;

  const RegisterState({
    this.status = RegisterStatus.initial,
    this.errorMessage,
    this.role,
    this.email,
    this.phone,
    this.password,
    this.displayName,
    this.verificationId,
  });

  RegisterState copyWith({
    RegisterStatus? status,
    String? errorMessage,
    String? role,
    String? email,
    String? phone,
    String? password,
    String? displayName,
    String? verificationId,
  }) {
    return RegisterState(
      status: status ?? this.status,
      errorMessage: errorMessage, // null by default when copying unless specified
      role: role ?? this.role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      displayName: displayName ?? this.displayName,
      verificationId: verificationId ?? this.verificationId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        role,
        email,
        phone,
        password,
        displayName,
        verificationId,
      ];
}
