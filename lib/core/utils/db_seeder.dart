import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:fursafy/core/constants/app_constants.dart';
import 'package:fursafy/features/jobs/domain/entities/job_entity.dart';

class DatabaseSeeder {
  static Future<void> seedJobsIfNeeded() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection(FirestorePaths.jobs)
          .limit(5)
          .get();

      if (querySnapshot.docs.length >= 3) {
        // Already seeded or has user jobs
        return;
      }

      final List<JobEntity> sampleJobs = [
        JobEntity(
          id: 'sample_job_1',
          providerId: 'sample_provider_1',
          providerName: 'Bakhresa Group',
          providerAvatarUrl: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=150&q=80',
          providerRating: 4.9,
          providerJobsDone: 42,
          title: 'Delivery Rider / Logistics Assistant',
          description: 'Looking for a reliable delivery rider to transport goods within Dar es Salaam. Fuel and motorbike will be provided. Must have a valid driving license.',
          skillsRequired: const ['Driving', 'Customer Service'],
          location: const GeoPoint(-6.8140, 39.2800), // Posta, Dar es Salaam
          locationName: 'Posta, Dar es Salaam',
          payAmount: 450000,
          payType: PayType.fixed,
          category: 'Delivery',
          status: JobStatus.open,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        JobEntity(
          id: 'sample_job_2',
          providerId: 'sample_provider_2',
          providerName: 'Mikocheni Tech Solutions',
          providerAvatarUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&w=150&q=80',
          providerRating: 4.7,
          providerJobsDone: 15,
          title: 'Junior Web Developer (WordPress/PHP)',
          description: 'We need an assistant developer to customize a client WordPress website. Basic knowledge of HTML, CSS, PHP, and responsive design is required.',
          skillsRequired: const ['Web Development', 'Graphic Design'],
          location: const GeoPoint(-6.7725, 39.2205), // Mikocheni
          locationName: 'Mikocheni, Dar es Salaam',
          payAmount: 25000,
          payType: PayType.hourly,
          category: 'Tech',
          status: JobStatus.open,
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        JobEntity(
          id: 'sample_job_3',
          providerId: 'sample_provider_3',
          providerName: 'Apex Construction Ltd',
          providerAvatarUrl: 'https://images.unsplash.com/photo-1531427186611-ecfd6d936c79?auto=format&fit=crop&w=150&q=80',
          providerRating: 4.5,
          providerJobsDone: 30,
          title: 'Assistant Mason for Site Prep',
          description: 'Urgent requirement for an assistant mason to help lay foundation and prepare materials on-site. Hard hats and safety equipment provided.',
          skillsRequired: const ['Masonry', 'Carpentry'],
          location: const GeoPoint(-6.7900, 39.2500), // Masaki
          locationName: 'Masaki, Dar es Salaam',
          payAmount: 350000,
          payType: PayType.fixed,
          category: 'Construction',
          status: JobStatus.open,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        JobEntity(
          id: 'sample_job_4',
          providerId: 'sample_provider_4',
          providerName: 'White Glove Cleaners',
          providerAvatarUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=150&q=80',
          providerRating: 4.8,
          providerJobsDone: 18,
          title: 'Commercial Office Cleaner',
          description: 'Professional cleaning crew needs two assistants for a commercial office deep-clean over the weekend. All cleaning supplies provided.',
          skillsRequired: const ['Cleaning'],
          location: const GeoPoint(-6.7924, 39.2083), // Dar es Salaam
          locationName: 'Kinondoni, Dar es Salaam',
          payAmount: 12000,
          payType: PayType.hourly,
          category: 'Cleaning',
          status: JobStatus.open,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];

      final batch = FirebaseFirestore.instance.batch();
      for (final job in sampleJobs) {
        final docRef = FirebaseFirestore.instance
            .collection(FirestorePaths.jobs)
            .doc(job.id);
        batch.set(docRef, job.toMap());
      }
      await batch.commit();
      debugPrint('[DatabaseSeeder] Successfully seeded ${sampleJobs.length} sample jobs.');
    } catch (e) {
      debugPrint('[DatabaseSeeder] Error seeding jobs: $e');
    }
  }

  /// Seeds the skills_taxonomy collection with the predefined skills from SRS §6.7.
  /// Only runs once — checks if the collection already has documents.
  static Future<void> seedSkillsTaxonomyIfNeeded() async {
    try {
      final col = FirebaseFirestore.instance.collection('skills_taxonomy');
      final existing = await col.limit(1).get();
      if (existing.docs.isNotEmpty) return; // Already seeded

      const skills = [
        {'id': 'plumbing', 'label_en': 'Plumbing', 'label_sw': 'Ufinyanzi wa Maji', 'category': 'technical_repair'},
        {'id': 'electrical', 'label_en': 'Electrical Work', 'label_sw': 'Kazi ya Umeme', 'category': 'technical_repair'},
        {'id': 'carpentry', 'label_en': 'Carpentry', 'label_sw': 'Useremala', 'category': 'construction'},
        {'id': 'cleaning', 'label_en': 'Cleaning', 'label_sw': 'Usafi', 'category': 'cleaning'},
        {'id': 'tutoring_math', 'label_en': 'Maths Tutoring', 'label_sw': 'Kufundisha Hisabati', 'category': 'tutoring'},
        {'id': 'it_support', 'label_en': 'IT Support', 'label_sw': 'Msaada wa Teknolojia', 'category': 'technical_repair'},
        {'id': 'driving', 'label_en': 'Driving', 'label_sw': 'Udereva', 'category': 'delivery'},
        {'id': 'painting', 'label_en': 'Painting', 'label_sw': 'Upigaji Rangi', 'category': 'construction'},
        {'id': 'cooking', 'label_en': 'Cooking / Catering', 'label_sw': 'Kupika / Upishi', 'category': 'other'},
        {'id': 'garden', 'label_en': 'Gardening', 'label_sw': 'Bustani', 'category': 'cleaning'},
      ];

      final batch = FirebaseFirestore.instance.batch();
      for (final skill in skills) {
        final docRef = col.doc(skill['id'] as String);
        batch.set(docRef, skill);
      }
      await batch.commit();
      debugPrint('[DatabaseSeeder] Successfully seeded ${skills.length} skills in skills_taxonomy.');
    } catch (e) {
      debugPrint('[DatabaseSeeder] Error seeding skills_taxonomy: $e');
    }
  }

  static Future<void> seedSystemLogsIfNeeded() async {
    try {
      final logsColl = FirebaseFirestore.instance.collection('system_logs');
      final logsSnap = await logsColl.limit(1).get();
      if (logsSnap.docs.isEmpty) {
        final batch = FirebaseFirestore.instance.batch();
        final sampleLogs = [
          {
            'eventId': 'EX-9021',
            'severity': 'critical',
            'title': 'Database Connection Timeout',
            'desc': 'Failed to establish handshake with secondary read-replica-01',
            'timestamp': Timestamp.now(),
          },
          {
            'eventId': 'US-1120',
            'severity': 'info',
            'title': 'User Login Successful',
            'desc': 'Administrator logged in from IP 197.250.2.14',
            'timestamp': Timestamp.now(),
          },
          {
            'eventId': 'CF-4412',
            'severity': 'info',
            'title': 'Rating Recalculation Triggered',
            'desc': 'updateRatingAverage cloud function successfully triggered for review ID review_081',
            'timestamp': Timestamp.now(),
          },
          {
            'eventId': 'JB-8821',
            'severity': 'info',
            'title': 'New Job Listed',
            'desc': 'Provider TechVerve Solutions listed a new opportunity for Software Architect',
            'timestamp': Timestamp.now(),
          },
          {
            'eventId': 'SE-2190',
            'severity': 'warning',
            'title': 'High Load Warning',
            'desc': 'Firestore active operations limit has reached 85% of allocated capacity',
            'timestamp': Timestamp.now(),
          }
        ];

        for (var log in sampleLogs) {
          batch.set(logsColl.doc(), log);
        }
        await batch.commit();
        debugPrint('[DatabaseSeeder] Successfully seeded system logs.');
      }
    } catch (e) {
      debugPrint('[DatabaseSeeder] Error seeding system logs: $e');
    }
  }
}
