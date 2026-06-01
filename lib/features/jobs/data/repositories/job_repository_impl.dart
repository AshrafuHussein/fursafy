import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fursafy/core/constants/app_constants.dart';
import 'package:fursafy/core/error/failures.dart';
import 'package:fursafy/features/jobs/domain/entities/job_entity.dart';
import 'package:fursafy/features/jobs/domain/repositories/job_repository.dart';

class JobRepositoryImpl implements JobRepository {
  final FirebaseFirestore _firestore;

  JobRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<({List<JobEntity> jobs, Failure? failure})> getJobs({
    String? category,
    int limit = AppConstants.jobsPerPage,
    JobEntity? lastJob,
  }) async {
    try {
      Query query = _firestore
          .collection(FirestorePaths.jobs)
          .where('status', isEqualTo: JobStatus.open.name);

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      query = query.orderBy('createdAt', descending: true).limit(limit);

      if (lastJob != null) {
        final lastDoc = await _firestore
            .collection(FirestorePaths.jobs)
            .doc(lastJob.id)
            .get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final snapshot = await query.get();
      final List<JobEntity> jobs = snapshot.docs
          .map(
            (doc) =>
                JobEntity.fromMap(doc.id, doc.data()! as Map<String, dynamic>),
          )
          .toList();

      return (jobs: jobs, failure: null);
    } catch (e) {
      return (
        jobs: <JobEntity>[],
        failure: ServerFailure(message: e.toString()),
      );
    }
  }

  @override
  Future<({JobEntity? job, Failure? failure})> getJobById(String jobId) async {
    try {
      final doc = await _firestore
          .collection(FirestorePaths.jobs)
          .doc(jobId)
          .get();
      if (!doc.exists || doc.data() == null) {
        return (
          job: null,
          failure: const ServerFailure(message: 'Job not found'),
        );
      }
      return (job: JobEntity.fromMap(doc.id, doc.data()!), failure: null);
    } catch (e) {
      return (job: null, failure: ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<({String? jobId, Failure? failure})> createJob(JobEntity job) async {
    try {
      final docRef = _firestore.collection(FirestorePaths.jobs).doc();
      final jobWithId = job.copyWith(id: docRef.id);
      await docRef.set(jobWithId.toMap());
      return (jobId: docRef.id, failure: null);
    } catch (e) {
      return (jobId: null, failure: ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Failure?> updateJob(JobEntity job) async {
    try {
      await _firestore
          .collection(FirestorePaths.jobs)
          .doc(job.id)
          .update(job.toMap());
      return null;
    } catch (e) {
      return ServerFailure(message: e.toString());
    }
  }

  @override
  Future<Failure?> closeJob(String jobId) async {
    try {
      await _firestore.collection(FirestorePaths.jobs).doc(jobId).update({
        'status': JobStatus.closed.name,
      });
      return null;
    } catch (e) {
      return ServerFailure(message: e.toString());
    }
  }

  @override
  Future<({List<JobEntity> jobs, Failure? failure})> searchJobs(
    String queryText,
  ) async {
    try {
      final lowercaseQuery = queryText.toLowerCase();
      final snapshot = await _firestore
          .collection(FirestorePaths.jobs)
          .where('status', isEqualTo: JobStatus.open.name)
          .orderBy('title')
          .startAt([lowercaseQuery])
          .endAt(['$lowercaseQuery\uf8ff'])
          .limit(20)
          .get();

      final List<JobEntity> jobs = snapshot.docs
          .map((doc) => JobEntity.fromMap(doc.id, doc.data()))
          .toList();
      return (jobs: jobs, failure: null);
    } catch (e) {
      return (
        jobs: <JobEntity>[],
        failure: ServerFailure(message: e.toString()),
      );
    }
  }

  @override
  Future<({List<JobEntity> jobs, Failure? failure})> getProviderJobs(
    String providerId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(FirestorePaths.jobs)
          .where('providerId', isEqualTo: providerId)
          .orderBy('createdAt', descending: true)
          .get();

      final List<JobEntity> jobs = snapshot.docs
          .map((doc) => JobEntity.fromMap(doc.id, doc.data()))
          .toList();
      return (jobs: jobs, failure: null);
    } catch (e) {
      return (
        jobs: <JobEntity>[],
        failure: ServerFailure(message: e.toString()),
      );
    }
  }
}
