import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fursafy/features/jobs/presentation/bloc/job_feed_bloc.dart';
import 'package:fursafy/features/jobs/presentation/bloc/job_feed_event.dart';
import 'package:fursafy/features/jobs/presentation/bloc/job_feed_state.dart';
import 'package:fursafy/features/jobs/domain/repositories/job_repository.dart';
import 'package:fursafy/features/jobs/domain/entities/job_entity.dart';
import 'package:fursafy/core/constants/app_constants.dart';
import 'package:fursafy/core/error/failures.dart';

class MockJobRepository extends Mock implements JobRepository {}

void main() {
  late MockJobRepository mockJobRepository;

  final sampleJob = JobEntity(
    id: 'test_job_1',
    providerId: 'provider_123',
    providerName: 'Test Provider',
    title: 'Test Job',
    description: 'Job description text',
    skillsRequired: const ['Plumbing'],
    location: const GeoPoint(-6.8140, 39.2800),
    locationName: 'Dar es Salaam',
    payAmount: 15000,
    payType: PayType.fixed,
    category: 'Cleaning',
    status: JobStatus.open,
    createdAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    mockJobRepository = MockJobRepository();
  });

  group('JobFeedBloc', () {
    test('initial state is JobFeedInitial', () {
      expect(
        JobFeedBloc(jobRepository: mockJobRepository).state,
        isA<JobFeedInitial>(),
      );
    });

    blocTest<JobFeedBloc, JobFeedState>(
      'emits [JobFeedLoading, JobFeedLoaded] when load requested succeeds',
      build: () {
        when(() => mockJobRepository.getJobs(category: any(named: 'category'), lastJob: any(named: 'lastJob')))
            .thenAnswer((_) => Future.value((jobs: [sampleJob], failure: null)));
        return JobFeedBloc(jobRepository: mockJobRepository);
      },
      act: (bloc) => bloc.add(const JobFeedLoadRequested()),
      expect: () => [
        const JobFeedLoading([], isFirstFetch: true),
        JobFeedLoaded([sampleJob], hasReachedMax: false),
      ],
    );

    blocTest<JobFeedBloc, JobFeedState>(
      'emits [JobFeedLoading, JobFeedError] when load requested fails',
      build: () {
        const failure = ServerFailure(message: 'Failed to fetch jobs.');
        when(() => mockJobRepository.getJobs(category: any(named: 'category'), lastJob: any(named: 'lastJob')))
            .thenAnswer((_) => Future.value((jobs: const <JobEntity>[], failure: failure)));
        return JobFeedBloc(jobRepository: mockJobRepository);
      },
      act: (bloc) => bloc.add(const JobFeedLoadRequested()),
      expect: () => [
        const JobFeedLoading([], isFirstFetch: true),
        const JobFeedError('Failed to fetch jobs.', []),
      ],
    );

    blocTest<JobFeedBloc, JobFeedState>(
      'emits [JobFeedLoading, JobFeedLoaded] on search requested successfully',
      build: () {
        when(() => mockJobRepository.searchJobs('Plumbing'))
            .thenAnswer((_) => Future.value((jobs: [sampleJob], failure: null)));
        return JobFeedBloc(jobRepository: mockJobRepository);
      },
      act: (bloc) => bloc.add(const JobFeedSearchRequested('Plumbing')),
      expect: () => [
        const JobFeedLoading([], isFirstFetch: true),
        JobFeedLoaded([sampleJob], hasReachedMax: true),
      ],
    );

    blocTest<JobFeedBloc, JobFeedState>(
      'emits [JobFeedLoading, JobFeedLoaded] with location proximity filtering and sorting',
      build: () {
        final job1 = sampleJob.copyWith(id: 'job_far', location: const GeoPoint(-6.7500, 39.2000)); // Far
        final job2 = sampleJob.copyWith(id: 'job_close', location: const GeoPoint(-6.8100, 39.2700)); // Close
        
        when(() => mockJobRepository.getJobs(category: null))
            .thenAnswer((_) => Future.value((jobs: [job1, job2], failure: null)));
        return JobFeedBloc(jobRepository: mockJobRepository);
      },
      act: (bloc) => bloc.add(const JobFeedFilterLocationApplied(
        latitude: -6.8140,
        longitude: 39.2800,
        radiusKm: 15.0,
      )),
      expect: () => [
        const JobFeedLoading([], isFirstFetch: true),
        // job_close is closer, so it must be sorted first in the list
        isA<JobFeedLoaded>().having(
          (s) => s.jobs.map((j) => j.id).toList(),
          'sorted jobs ids',
          ['job_close', 'job_far'],
        ),
      ],
    );
  });
}
