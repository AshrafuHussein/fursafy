part of 'register_bloc.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

class RegisterRoleSelected extends RegisterEvent {
  final String role;
  const RegisterRoleSelected(this.role);

  @override
  List<Object?> get props => [role];
}

class RegisterDetailsSubmitted extends RegisterEvent {
  final String email;
  final String phone;
  final String password;
  final String displayName;

  const RegisterDetailsSubmitted({
    required this.email,
    required this.phone,
    required this.password,
    required this.displayName,
  });

  @override
  List<Object?> get props => [email, phone, password, displayName];
}

class RegisterOtpVerified extends RegisterEvent {
  final String otp;
  const RegisterOtpVerified(this.otp);

  @override
  List<Object?> get props => [otp];
}

class RegisterSkillsSubmitted extends RegisterEvent {
  final List<String> skills;
  final double latitude;
  final double longitude;
  final String? bio;

  const RegisterSkillsSubmitted({
    required this.skills,
    required this.latitude,
    required this.longitude,
    this.bio,
  });

  @override
  List<Object?> get props => [skills, latitude, longitude, bio];
}
