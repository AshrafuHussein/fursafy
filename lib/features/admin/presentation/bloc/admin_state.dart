import 'package:equatable/equatable.dart';
import 'package:fursafy/features/auth/domain/entities/user_entity.dart';

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

  // Real-time Lists
  final List<UserEntity> admins;
  final List<Map<String, dynamic>> adminInvites;
  final List<Map<String, dynamic>> apiKeys;
  final List<Map<String, dynamic>> transactions;

  // Analytics Dynamic Data
  final List<Map<String, dynamic>> analyticsRegional;
  final List<Map<String, dynamic>> analyticsCategories;
  final List<Map<String, dynamic>> analyticsGrowth;

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
    this.admins = const [],
    this.adminInvites = const [],
    this.apiKeys = const [],
    this.transactions = const [],
    this.analyticsRegional = const [],
    this.analyticsCategories = const [],
    this.analyticsGrowth = const [],
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
      admins: [],
      adminInvites: [],
      apiKeys: [],
      transactions: [],
      analyticsRegional: [],
      analyticsCategories: [],
      analyticsGrowth: [],
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
    List<UserEntity>? admins,
    List<Map<String, dynamic>>? adminInvites,
    List<Map<String, dynamic>>? apiKeys,
    List<Map<String, dynamic>>? transactions,
    List<Map<String, dynamic>>? analyticsRegional,
    List<Map<String, dynamic>>? analyticsCategories,
    List<Map<String, dynamic>>? analyticsGrowth,
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
      admins: admins ?? this.admins,
      adminInvites: adminInvites ?? this.adminInvites,
      apiKeys: apiKeys ?? this.apiKeys,
      transactions: transactions ?? this.transactions,
      analyticsRegional: analyticsRegional ?? this.analyticsRegional,
      analyticsCategories: analyticsCategories ?? this.analyticsCategories,
      analyticsGrowth: analyticsGrowth ?? this.analyticsGrowth,
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
        admins,
        adminInvites,
        apiKeys,
        transactions,
        analyticsRegional,
        analyticsCategories,
        analyticsGrowth,
      ];
}
