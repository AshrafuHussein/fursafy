import 'package:equatable/equatable.dart';
import 'package:fursafy/features/auth/domain/entities/user_entity.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Load full profile (User + Youth Profile if applicable)
class ProfileLoadRequested extends ProfileEvent {
  final String uid;
  const ProfileLoadRequested(this.uid);

  @override
  List<Object?> get props => [uid];
}

/// Update User Profile
class UserProfileUpdated extends ProfileEvent {
  final UserEntity user;
  const UserProfileUpdated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Update Youth Profile
class YouthProfileUpdated extends ProfileEvent {
  final YouthProfile profile;
  const YouthProfileUpdated(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Upload new avatar
class ProfileAvatarUploadRequested extends ProfileEvent {
  final String uid;
  final String filePath;
  const ProfileAvatarUploadRequested(this.uid, this.filePath);

  @override
  List<Object?> get props => [uid, filePath];
}
