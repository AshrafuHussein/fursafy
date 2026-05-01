import 'package:fursafy/features/applications/domain/entities/application_entity.dart';
import 'package:fursafy/core/error/failures.dart';

/// Abstract application repository — domain layer contract.
abstract class ApplicationRepository {
  /// Submit a job application.
  Future<({String? applicationId, Failure? failure})> applyForJob({
    required String jobId,
    required String jobTitle,
    required String youthId,
    required String youthName,
    String? youthAvatarUrl,
    required String providerId,
    String? coverMessage,
  });

  /// Check if youth already applied for a job.
  Future<bool> hasApplied({
    required String jobId,
    required String youthId,
  });

  /// Get youth's applications.
  Future<({List<ApplicationEntity> applications, Failure? failure})>
      getYouthApplications(String youthId);

  /// Get applicants for a job.
  Future<({List<ApplicationEntity> applications, Failure? failure})>
      getJobApplicants(String jobId);

  /// Accept an application.
  Future<Failure?> acceptApplication(String applicationId);

  /// Reject an application.
  Future<Failure?> rejectApplication(String applicationId);

  /// Withdraw an application.
  Future<Failure?> withdrawApplication(String applicationId);
}
