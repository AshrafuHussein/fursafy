import 'package:fursafy/features/jobs/domain/entities/job_entity.dart';
import 'package:fursafy/core/error/failures.dart';
import 'package:fursafy/core/constants/app_constants.dart';

/// Abstract job repository — domain layer contract.
abstract class JobRepository {
  /// Fetch paginated open jobs, optionally filtered by category.
  Future<({List<JobEntity> jobs, Failure? failure})> getJobs({
    String? category,
    int limit = AppConstants.jobsPerPage,
    JobEntity? lastJob,
  });

  /// Fetch a single job by ID.
  Future<({JobEntity? job, Failure? failure})> getJobById(String jobId);

  /// Create a new job listing.
  Future<({String? jobId, Failure? failure})> createJob(JobEntity job);

  /// Update an existing job.
  Future<Failure?> updateJob(JobEntity job);

  /// Close/delete a job (soft delete — set status to closed).
  Future<Failure?> closeJob(String jobId);

  /// Search jobs by title keyword.
  Future<({List<JobEntity> jobs, Failure? failure})> searchJobs(String query);

  /// Get jobs posted by a specific provider.
  Future<({List<JobEntity> jobs, Failure? failure})> getProviderJobs(
      String providerId);
}
