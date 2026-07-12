import 'package:fursafy/core/error/failures.dart';

abstract class AdminRepository {
  /// Loads the global platform config from Firestore `/config/platform`.
  Future<({Failure? failure, Map<String, dynamic>? config})> loadPlatformConfig();

  /// Saves the global platform config to Firestore `/config/platform`.
  Future<Failure?> savePlatformConfig(Map<String, dynamic> config);

  /// Toggles status of a user (active <-> suspended).
  Future<Failure?> toggleUserStatus(String uid, String currentStatus);

  /// Performs moderation on a job listing (approve, flag, close, delete).
  Future<Failure?> moderateJob(String jobId, String action);

  /// Sends an invitation to an administrator and logs the invitation event.
  Future<Failure?> inviteAdmin(String email);

  /// Posts a new opportunity (job listing) directly as admin.
  Future<Failure?> postJob(Map<String, dynamic> jobData);

  /// Fetches basic counts and aggregates the total transaction volume.
  Future<({
    Failure? failure,
    int totalUsers,
    int totalProviders,
    int totalJobs,
    int totalApplications,
    int completedJobs,
    int flaggedJobsCount,
    double totalTxVolume
  })> fetchStats();

  /// Fetches signups from the last 7 days grouped by weekday.
  Future<({Failure? failure, List<Map<String, dynamic>> signupData})> fetchWeeklySignupData();

  /// Fetches jobs posted over the last 12 weeks.
  Future<({Failure? failure, List<Map<String, dynamic>> jobsData})> fetchWeeklyJobsData();

  /// Streams the 4 most recent events from the system logs.
  Stream<List<Map<String, dynamic>>> getRecentSystemLogs();
}
