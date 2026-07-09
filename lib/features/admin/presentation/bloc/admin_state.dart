import 'package:equatable/equatable.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminStatsLoaded extends AdminState {
  final int totalUsers;
  final int totalJobs;
  final int totalApplications;
  final int completedJobs;
  final int flaggedJobsCount;
  final double totalTxVolume;

  const AdminStatsLoaded({
    required this.totalUsers,
    required this.totalJobs,
    required this.totalApplications,
    required this.completedJobs,
    required this.flaggedJobsCount,
    required this.totalTxVolume,
  });

  @override
  List<Object?> get props => [
        totalUsers,
        totalJobs,
        totalApplications,
        completedJobs,
        flaggedJobsCount,
        totalTxVolume,
      ];
}

class AdminPlatformConfigLoaded extends AdminState {
  final Map<String, dynamic> config;

  const AdminPlatformConfigLoaded(this.config);

  @override
  List<Object?> get props => [config];
}

class AdminActionSuccess extends AdminState {
  final String message;

  const AdminActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminFailure extends AdminState {
  final String message;

  const AdminFailure(this.message);

  @override
  List<Object?> get props => [message];
}
