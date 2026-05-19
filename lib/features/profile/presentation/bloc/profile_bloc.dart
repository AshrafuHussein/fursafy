import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fursafy/features/profile/domain/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repo;

  ProfileBloc({required ProfileRepository profileRepository})
      : _repo = profileRepository,
        super(ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoad);
    on<UserProfileUpdated>(_onUpdateUser);
    on<YouthProfileUpdated>(_onUpdateYouth);
    on<ProfileAvatarUploadRequested>(_onUploadAvatar);
  }

  Future<void> _onLoad(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    // Load User
    final userResult = await _repo.getUserProfile(event.uid);
    if (userResult.failure != null) {
      emit(ProfileError(userResult.failure!.message));
      return;
    }
    final user = userResult.user!;

    // If youth, load youth profile
    if (user.role.name == 'youth') {
      final youthResult = await _repo.getYouthProfile(event.uid);
      if (youthResult.failure != null) {
        emit(ProfileError(youthResult.failure!.message));
        return;
      }
      emit(ProfileLoaded(user: user, youthProfile: youthResult.profile));
    } else {
      emit(ProfileLoaded(user: user));
    }
  }

  Future<void> _onUpdateUser(
    UserProfileUpdated event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final failure = await _repo.updateUserProfile(event.user);
    if (failure != null) {
      emit(ProfileError(failure.message));
    } else {
      emit(const ProfileUpdateSuccess('Profile updated successfully'));
    }
  }

  Future<void> _onUpdateYouth(
    YouthProfileUpdated event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final failure = await _repo.updateYouthProfile(event.profile);
    if (failure != null) {
      emit(ProfileError(failure.message));
    } else {
      emit(const ProfileUpdateSuccess('Professional details updated'));
    }
  }

  Future<void> _onUploadAvatar(
    ProfileAvatarUploadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final result = await _repo.uploadAvatar(event.uid, event.filePath);
    if (result.failure != null) {
      emit(ProfileError(result.failure!.message));
    } else {
      emit(ProfileAvatarUploadSuccess(result.url!));
    }
  }
}
