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

  /// Fetches basic counts and aggregates the total transaction volume.
  Future<({
    Failure? failure,
    int totalUsers,
    int totalJobs,
    int totalApplications,
    int completedJobs,
    int flaggedJobsCount,
    double totalTxVolume
  })> fetchStats();
}
