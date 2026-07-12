import 'package:fursafy/core/error/failures.dart';
import 'package:fursafy/features/auth/domain/entities/user_entity.dart';

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

  /// Streams all administrator users from users collection where role is admin.
  Stream<List<UserEntity>> getAdmins();

  /// Streams pending invitations from /admin_invitations collection.
  Stream<List<Map<String, dynamic>>> getAdminInvitations();

  /// Revokes or deletes a pending administrator invite.
  Future<Failure?> revokeAdminInvite(String email);

  /// Streams platform API Keys from /config/api_keys collection.
  Stream<List<Map<String, dynamic>>> getApiKeys();

  /// Generates a new API Key and adds it to Firestore.
  Future<Failure?> generateApiKey(String name, String environment);

  /// Deletes an API Key.
  Future<Failure?> deleteApiKey(String keyId);

  /// Updates status of a user (with detailed reasons/notes if suspended).
  Future<Failure?> updateUserStatus({
    required String uid,
    required String targetStatus,
    String? reason,
    String? notes,
    String? adminUid,
  });

  /// Streams all platform transaction logs.
  Stream<List<Map<String, dynamic>>> getTransactions();

  /// Resolves a dispute or releases a payout transaction.
  Future<Failure?> updateTransactionStatus(String transactionId, String newStatus);

  /// Batch authorizes and processes pending payout transactions.
  Future<Failure?> authorizeBatchPayouts(List<String> transactionIds);

  /// Dynamic aggregates for analytics page.
  Future<({
    Failure? failure,
    List<Map<String, dynamic>> regionalData,
    List<Map<String, dynamic>> categoryShareData,
    List<Map<String, dynamic>> growthMetrics,
  })> fetchAnalyticsData();
}
