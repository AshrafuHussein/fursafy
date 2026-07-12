import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fursafy/core/constants/app_constants.dart';
import 'package:fursafy/core/error/failures.dart';
import 'package:fursafy/features/admin/domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  final FirebaseFirestore _firestore;

  AdminRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<({Failure? failure, Map<String, dynamic>? config})> loadPlatformConfig() async {
    try {
      final doc = await _firestore.collection('config').doc('platform').get();
      if (doc.exists) {
        return (failure: null, config: doc.data());
      }
      return (failure: null, config: null);
    } catch (e) {
      return (failure: ServerFailure(message: e.toString()), config: null);
    }
  }

  @override
  Future<Failure?> savePlatformConfig(Map<String, dynamic> config) async {
    try {
      await _firestore.collection('config').doc('platform').set({
        ...config,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      return ServerFailure(message: e.toString());
    }
  }

  @override
  Future<Failure?> toggleUserStatus(String uid, String currentStatus) async {
    final newStatus = currentStatus == 'suspended' ? 'active' : 'suspended';
    try {
      final batch = _firestore.batch();
      
      // Update primary user doc
      final userRef = _firestore.collection(FirestorePaths.users).doc(uid);
      batch.update(userRef, {'status': newStatus});

      // Update youth profile status if it exists
      final youthRef = _firestore.collection(FirestorePaths.youthProfiles).doc(uid);
      final youthDoc = await youthRef.get();
      if (youthDoc.exists) {
        batch.update(youthRef, {'status': newStatus == 'active' ? 'available' : 'inactive'});
      }

      // Log event
      final logRef = _firestore.collection('system_logs').doc();
      batch.set(logRef, {
        'eventId': 'US-${uid.substring(0, 4).toUpperCase()}',
        'severity': newStatus == 'suspended' ? 'warning' : 'info',
        'title': 'User Status Toggled',
        'desc': 'User with ID $uid has been set to $newStatus',
        'timestamp': Timestamp.now(),
      });

      await batch.commit();
      return null;
    } catch (e) {
      return ServerFailure(message: e.toString());
    }
  }

  @override
  Future<Failure?> moderateJob(String jobId, String action) async {
    try {
      final jobRef = _firestore.collection(FirestorePaths.jobs).doc(jobId);
      
      if (action == 'delete') {
        await jobRef.delete();
      } else {
        String status = 'open';
        if (action == 'close') {
          status = 'closed';
        } else if (action == 'flag') {
          status = 'flagged';
        } else if (action == 'approve') {
          status = 'open';
        }
        await jobRef.update({'status': status});
      }

      // Log event
      await _firestore.collection('system_logs').add({
        'eventId': 'JB-${jobId.substring(0, 4).toUpperCase()}',
        'severity': action == 'flag' || action == 'delete' ? 'warning' : 'info',
        'title': 'Job Listing Moderated',
        'desc': 'Job Listing with ID $jobId was subject to action: $action',
        'timestamp': Timestamp.now(),
      });
      return null;
    } catch (e) {
      return ServerFailure(message: e.toString());
    }
  }

  @override
  Future<Failure?> inviteAdmin(String email) async {
    try {
      await _firestore.collection('system_logs').add({
        'eventId': 'AD-INV',
        'severity': 'info',
        'title': 'Administrator Invited',
        'desc': 'Invitation generated and sent to $email',
        'timestamp': Timestamp.now(),
      });
      return null;
    } catch (e) {
      return ServerFailure(message: e.toString());
    }
  }

  @override
  Future<Failure?> postJob(Map<String, dynamic> jobData) async {
    try {
      final docRef = await _firestore.collection(FirestorePaths.jobs).add(jobData);
      
      // Log event
      await _firestore.collection('system_logs').add({
        'eventId': 'JB-POST',
        'severity': 'info',
        'title': 'New Opportunity Posted',
        'desc': 'A new job opportunity "${jobData['title']}" was posted directly by Admin. (Job ID: ${docRef.id})',
        'timestamp': Timestamp.now(),
      });
      return null;
    } catch (e) {
      return ServerFailure(message: e.toString());
    }
  }

  @override
  Future<({
    Failure? failure,
    int totalUsers,
    int totalProviders,
    int totalJobs,
    int totalApplications,
    int completedJobs,
    int flaggedJobsCount,
    double totalTxVolume
  })> fetchStats() async {
    try {
      final results = await Future.wait([
        _firestore.collection(FirestorePaths.users).get(),
        _firestore.collection(FirestorePaths.jobs).get(),
        _firestore.collection(FirestorePaths.applications).get(),
      ]);

      final usersSnap = results[0];
      final jobsSnap = results[1];
      final appsSnap = results[2];

      int providerCount = 0;
      for (var doc in usersSnap.docs) {
        final data = doc.data();
        if (data['role'] == 'provider') {
          providerCount++;
        }
      }

      int completedCount = 0;
      double txVolume = 0.0;
      int flaggedCount = 0;

      for (var doc in jobsSnap.docs) {
        final data = doc.data();
        final status = data['status'] ?? 'open';
        final payAmount = (data['payAmount'] ?? 0.0) as num;
        
        if (status == 'completed' || status == 'closed') {
          completedCount++;
          txVolume += payAmount.toDouble();
        }
        if (status == 'flagged') {
          flaggedCount++;
        }
      }

      return (
        failure: null,
        totalUsers: usersSnap.docs.length,
        totalProviders: providerCount,
        totalJobs: jobsSnap.docs.length,
        totalApplications: appsSnap.docs.length,
        completedJobs: completedCount,
        flaggedJobsCount: flaggedCount,
        totalTxVolume: txVolume,
      );
    } catch (e) {
      return (
        failure: ServerFailure(message: e.toString()),
        totalUsers: 0,
        totalProviders: 0,
        totalJobs: 0,
        totalApplications: 0,
        completedJobs: 0,
        flaggedJobsCount: 0,
        totalTxVolume: 0.0,
      );
    }
  }

  @override
  Future<({Failure? failure, List<Map<String, dynamic>> signupData})> fetchWeeklySignupData() async {
    try {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      final query = await _firestore.collection(FirestorePaths.users)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
          .get();

      final Map<String, int> counts = {
        'Mon': 0,
        'Tue': 0,
        'Wed': 0,
        'Thu': 0,
        'Fri': 0,
        'Sat': 0,
        'Sun': 0,
      };

      for (var doc in query.docs) {
        final data = doc.data();
        final timestamp = data['createdAt'] as Timestamp?;
        if (timestamp != null) {
          final date = timestamp.toDate();
          final weekday = _getWeekdayLabel(date.weekday);
          counts[weekday] = (counts[weekday] ?? 0) + 1;
        }
      }

      int maxVal = counts.values.fold(0, (max, val) => val > max ? val : max);
      if (maxVal == 0) maxVal = 1;

      final List<Map<String, dynamic>> result = [];
      final daysOrder = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      for (var day in daysOrder) {
        final count = counts[day] ?? 0;
        result.add({
          'day': day,
          'count': count,
          'scale': count / maxVal,
        });
      }

      return (failure: null, signupData: result);
    } catch (e) {
      return (failure: ServerFailure(message: e.toString()), signupData: <Map<String, dynamic>>[]);
    }
  }

  String _getWeekdayLabel(int dayIndex) {
    switch (dayIndex) {
      case DateTime.monday: return 'Mon';
      case DateTime.tuesday: return 'Tue';
      case DateTime.wednesday: return 'Wed';
      case DateTime.thursday: return 'Thu';
      case DateTime.friday: return 'Fri';
      case DateTime.saturday: return 'Sat';
      case DateTime.sunday: return 'Sun';
      default: return 'Mon';
    }
  }

  @override
  Future<({Failure? failure, List<Map<String, dynamic>> jobsData})> fetchWeeklyJobsData() async {
    try {
      final now = DateTime.now();
      final twelveWeeksAgo = now.subtract(const Duration(days: 84));
      final query = await _firestore.collection(FirestorePaths.jobs)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(twelveWeeksAgo))
          .get();

      final List<int> weeklyCounts = List.filled(12, 0);

      for (var doc in query.docs) {
        final data = doc.data();
        final timestamp = data['createdAt'] as Timestamp?;
        if (timestamp != null) {
          final date = timestamp.toDate();
          final diffDays = now.difference(date).inDays;
          final weekIndex = diffDays ~/ 7;
          if (weekIndex >= 0 && weekIndex < 12) {
            weeklyCounts[11 - weekIndex]++;
          }
        }
      }

      int maxVal = weeklyCounts.fold(0, (max, val) => val > max ? val : max);
      if (maxVal == 0) maxVal = 1;

      final List<Map<String, dynamic>> result = [];
      for (int i = 0; i < 12; i++) {
        final count = weeklyCounts[i];
        result.add({
          'weekLabel': i == 11 ? 'Current' : 'Week ${i + 1}',
          'count': count,
          'scale': count / maxVal,
        });
      }

      return (failure: null, jobsData: result);
    } catch (e) {
      return (failure: ServerFailure(message: e.toString()), jobsData: <Map<String, dynamic>>[]);
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> getRecentSystemLogs() {
    return _firestore.collection('system_logs')
        .orderBy('timestamp', descending: true)
        .limit(4)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }
}
