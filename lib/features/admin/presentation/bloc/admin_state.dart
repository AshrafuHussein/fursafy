import 'package:equatable/equatable.dart';

class AdminState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  // Stats
  final int totalUsers;
  final int totalProviders;
  final int totalJobs;
  final int totalApplications;
  final int completedJobs;
  final int flaggedJobsCount;
  final double totalTxVolume;

  // Config
  final Map<String, dynamic> platformConfig;

  // Weekly Jobs
  final List<Map<String, dynamic>> weeklyJobsData;

  const AdminState({
    required this.isLoading,
    this.errorMessage,
    this.successMessage,
    required this.totalUsers,
    required this.totalProviders,
    required this.totalJobs,
    required this.totalApplications,
    required this.completedJobs,
    required this.flaggedJobsCount,
    required this.totalTxVolume,
    required this.platformConfig,
    required this.weeklyJobsData,
  });

  factory AdminState.initial() {
    return const AdminState(
      isLoading: false,
      totalUsers: 0,
      totalProviders: 0,
      totalJobs: 0,
      totalApplications: 0,
      completedJobs: 0,
      flaggedJobsCount: 0,
      totalTxVolume: 0.0,
      platformConfig: {},
      weeklyJobsData: [],
    );
  }

  AdminState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    int? totalUsers,
    int? totalProviders,
    int? totalJobs,
    int? totalApplications,
    int? completedJobs,
    int? flaggedJobsCount,
    double? totalTxVolume,
    Map<String, dynamic>? platformConfig,
    List<Map<String, dynamic>>? weeklyJobsData,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      totalUsers: totalUsers ?? this.totalUsers,
      totalProviders: totalProviders ?? this.totalProviders,
      totalJobs: totalJobs ?? this.totalJobs,
      totalApplications: totalApplications ?? this.totalApplications,
      completedJobs: completedJobs ?? this.completedJobs,
      flaggedJobsCount: flaggedJobsCount ?? this.flaggedJobsCount,
      totalTxVolume: totalTxVolume ?? this.totalTxVolume,
      platformConfig: platformConfig ?? this.platformConfig,
      weeklyJobsData: weeklyJobsData ?? this.weeklyJobsData,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        successMessage,
        totalUsers,
        totalProviders,
        totalJobs,
        totalApplications,
        completedJobs,
        flaggedJobsCount,
        totalTxVolume,
        platformConfig,
        weeklyJobsData,
      ];
}
