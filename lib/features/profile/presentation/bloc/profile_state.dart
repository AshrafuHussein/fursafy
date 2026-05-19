import 'package:equatable/equatable.dart';
import 'package:fursafy/features/auth/domain/entities/user_entity.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserEntity user;
  final YouthProfile? youthProfile;

  const ProfileLoaded({required this.user, this.youthProfile});

  @override
  List<Object?> get props => [user, youthProfile];
}

class ProfileUpdateSuccess extends ProfileState {
  final String message;
  const ProfileUpdateSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileAvatarUploadSuccess extends ProfileState {
  final String avatarUrl;
  const ProfileAvatarUploadSuccess(this.avatarUrl);

  @override
  List<Object?> get props => [avatarUrl];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
