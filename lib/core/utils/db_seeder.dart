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
}
