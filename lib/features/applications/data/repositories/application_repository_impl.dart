import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fursafy/core/constants/app_constants.dart';
import 'package:fursafy/core/error/failures.dart';
import 'package:fursafy/features/applications/domain/entities/application_entity.dart';
import 'package:fursafy/features/applications/domain/repositories/application_repository.dart';

/// Firestore implementation of [ApplicationRepository].
class ApplicationRepositoryImpl implements ApplicationRepository {
  final FirebaseFirestore _db;
  ApplicationRepositoryImpl({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirestorePaths.applications);

  @override
  Future<({String? applicationId, Failure? failure})> applyForJob({
    required String jobId,
    required String jobTitle,
    required String youthId,
    required String youthName,
    String? youthAvatarUrl,
    required String providerId,
    String? coverMessage,
  }) async {
    try {
      // Check duplicate
      final existing = await _col
          .where('jobId', isEqualTo: jobId)
          .where('youthId', isEqualTo: youthId)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) {
        return (
          applicationId: null,
          failure: const ValidationFailure(message: 'Already applied for this job'),
        );
      }

      final docRef = await _col.add({
        'jobId': jobId,
        'jobTitle': jobTitle,
        'youthId': youthId,
        'youthName': youthName,
        'youthAvatarUrl': youthAvatarUrl,
        'providerId': providerId,
        'coverMessage': coverMessage ?? '',
        'status': ApplicationStatus.pending.name,
        'appliedAt': FieldValue.serverTimestamp(),
      });

      return (applicationId: docRef.id, failure: null);
    } catch (e) {
      return (
        applicationId: null,
        failure: ServerFailure(message: 'Failed to apply: $e'),
      );
    }
  }

  @override
  Future<bool> hasApplied({
    required String jobId,
    required String youthId,
  }) async {
    try {
      final snap = await _col
          .where('jobId', isEqualTo: jobId)
          .where('youthId', isEqualTo: youthId)
          .limit(1)
          .get();
      return snap.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<({List<ApplicationEntity> applications, Failure? failure})>
      getYouthApplications(String youthId) async {
    try {
      final snap = await _col
          .where('youthId', isEqualTo: youthId)
          .orderBy('appliedAt', descending: true)
          .get();
      final apps =
          snap.docs.map((d) => ApplicationEntity.fromMap(d.id, d.data())).toList();
      return (applications: apps, failure: null);
    } catch (e) {
      return (
        applications: <ApplicationEntity>[],
        failure: ServerFailure(message: 'Failed to load applications: $e'),
      );
    }
  }

  @override
  Future<({List<ApplicationEntity> applications, Failure? failure})>
      getJobApplicants(String jobId) async {
    try {
      final snap = await _col
          .where('jobId', isEqualTo: jobId)
          .orderBy('appliedAt', descending: true)
          .get();
      final apps =
          snap.docs.map((d) => ApplicationEntity.fromMap(d.id, d.data())).toList();
      return (applications: apps, failure: null);
    } catch (e) {
      return (
        applications: <ApplicationEntity>[],
        failure: ServerFailure(message: 'Failed to load applicants: $e'),
      );
    }
  }

  @override
  Future<Failure?> acceptApplication(String applicationId) async {
    try {
      await _col.doc(applicationId).update({
        'status': ApplicationStatus.accepted.name,
      });
      return null;
    } catch (e) {
      return ServerFailure(message: 'Failed to accept: $e');
    }
  }

  @override
  Future<Failure?> rejectApplication(String applicationId) async {
    try {
      await _col.doc(applicationId).update({
        'status': ApplicationStatus.rejected.name,
      });
      return null;
    } catch (e) {
      return ServerFailure(message: 'Failed to reject: $e');
    }
  }

  @override
  Future<Failure?> withdrawApplication(String applicationId) async {
    try {
      await _col.doc(applicationId).delete();
      return null;
    } catch (e) {
      return ServerFailure(message: 'Failed to withdraw: $e');
    }
  }
}
