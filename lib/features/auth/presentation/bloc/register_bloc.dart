import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/auth_repository.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository _authRepository;

  RegisterBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const RegisterState()) {
    on<RegisterRoleSelected>(_onRoleSelected);
    on<RegisterDetailsSubmitted>(_onDetailsSubmitted);
    on<RegisterOtpVerified>(_onOtpVerified);
    on<RegisterSkillsSubmitted>(_onSkillsSubmitted);
  }

  void _onRoleSelected(
    RegisterRoleSelected event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(
      status: RegisterStatus.roleSelected,
      role: event.role,
    ));
  }

  Future<void> _onDetailsSubmitted(
    RegisterDetailsSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(state.copyWith(
      status: RegisterStatus.loading,
      email: event.email,
      phone: event.phone,
      password: event.password,
      displayName: event.displayName,
    ));

    // Register with email and password first
    final result = await _authRepository.registerWithEmail(
      email: event.email,
      password: event.password,
      displayName: event.displayName,
      role: state.role ?? 'youth',
      phone: event.phone,
    );

    if (result.failure != null) {
      emit(state.copyWith(
        status: RegisterStatus.failure,
        errorMessage: result.failure!.message,
      ));
      return;
    }

    // Send OTP
    final resultPhone = await _authRepository.sendPhoneOtp(phoneNumber: event.phone);
    if (resultPhone.failure != null) {
      emit(state.copyWith(
        status: RegisterStatus.failure,
        errorMessage: resultPhone.failure!.message,
      ));
    } else {
      emit(state.copyWith(
        status: RegisterStatus.otpSent,
        verificationId: resultPhone.verificationId,
      ));
    }
  }

  Future<void> _onOtpVerified(
    RegisterOtpVerified event,
    Emitter<RegisterState> emit,
  ) async {
    emit(state.copyWith(status: RegisterStatus.loading));

    final failure = await _authRepository.verifyPhoneOtp(
      verificationId: state.verificationId ?? '',
      otp: event.otp,
    );

    if (failure != null) {
      emit(state.copyWith(
        status: RegisterStatus.failure,
        errorMessage: failure.message,
      ));
    } else {
      emit(state.copyWith(status: RegisterStatus.otpVerified));
    }
  }

  Future<void> _onSkillsSubmitted(
    RegisterSkillsSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(state.copyWith(status: RegisterStatus.loading));

    final user = await _authRepository.getCurrentUser();
    if (user == null) {
      emit(state.copyWith(
        status: RegisterStatus.failure,
        errorMessage: 'User not authenticated',
      ));
      return;
    }

    final failure = await _authRepository.createYouthProfile(
      uid: user.uid,
      skills: event.skills,
      latitude: event.latitude,
      longitude: event.longitude,
      bio: event.bio,
    );

    if (failure != null) {
      emit(state.copyWith(
        status: RegisterStatus.failure,
        errorMessage: failure.message,
      ));
    } else {
      emit(state.copyWith(status: RegisterStatus.success));
    }
  }
}
