import 'package:equatable/equatable.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

class AdminStatsFetchRequested extends AdminEvent {}

class AdminPlatformConfigLoadRequested extends AdminEvent {}

class AdminPlatformConfigSaveRequested extends AdminEvent {
  final Map<String, dynamic> config;

  const AdminPlatformConfigSaveRequested(this.config);

  @override
  List<Object?> get props => [config];
}

class AdminUserStatusToggleRequested extends AdminEvent {
  final String uid;
  final String currentStatus;

  const AdminUserStatusToggleRequested({required this.uid, required this.currentStatus});

  @override
  List<Object?> get props => [uid, currentStatus];
}

class AdminJobModerateRequested extends AdminEvent {
  final String jobId;
  final String action;

  const AdminJobModerateRequested({required this.jobId, required this.action});

  @override
  List<Object?> get props => [jobId, action];
}

class AdminInviteRequested extends AdminEvent {
  final String email;

  const AdminInviteRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class AdminWeeklySignupsFetchRequested extends AdminEvent {}
