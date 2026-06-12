import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fursafy/core/utils/haversine_util.dart';
import 'package:fursafy/features/jobs/domain/entities/job_entity.dart';
import 'package:fursafy/features/jobs/domain/repositories/job_repository.dart';

import 'job_feed_event.dart';
import 'job_feed_state.dart';

class JobFeedBloc extends Bloc<JobFeedEvent, JobFeedState> {
  final JobRepository _jobRepository;
  String? _currentCategory;

  JobFeedBloc({required JobRepository jobRepository})
      : _jobRepository = jobRepository,
        super(JobFeedInitial()) {
    on<JobFeedLoadRequested>(_onLoadRequested);
    on<JobFeedSearchRequested>(_onSearchRequested);
    on<JobFeedFilterLocationApplied>(_onFilterLocationApplied);
  }

  Future<void> _onLoadRequested(
    JobFeedLoadRequested event,
    Emitter<JobFeedState> emit,
  ) async {
    final bool refresh = event.refresh;
    if (event.category != null) {
      _currentCategory = event.category == 'All' ? null : event.category;
    }

    if (state is JobFeedLoading) return;

    List<JobEntity> oldJobs = [];
    JobEntity? lastJob;

    if (state is JobFeedLoaded && !refresh) {
      oldJobs = (state as JobFeedLoaded).jobs;
      if (oldJobs.isNotEmpty) {
        lastJob = oldJobs.last;
      }
    }

    emit(JobFeedLoading(oldJobs, isFirstFetch: oldJobs.isEmpty));

    final result = await _jobRepository.getJobs(
      category: _currentCategory,
      lastJob: lastJob,
    );

    if (result.failure != null) {
      emit(JobFeedError(result.failure!.message, oldJobs));
    } else {
      final newJobs = result.jobs;
      final allJobs = refresh ? newJobs : oldJobs + newJobs;
      emit(JobFeedLoaded(allJobs, hasReachedMax: newJobs.isEmpty));
    }
  }

  Future<void> _onSearchRequested(
    JobFeedSearchRequested event,
    Emitter<JobFeedState> emit,
  ) async {
    emit(const JobFeedLoading([], isFirstFetch: true));
    final result = await _jobRepository.searchJobs(event.query);
    if (result.failure != null) {
      emit(JobFeedError(result.failure!.message, const []));
    } else {
      emit(JobFeedLoaded(result.jobs, hasReachedMax: true));
    }
  }

  Future<void> _onFilterLocationApplied(
    JobFeedFilterLocationApplied event,
    Emitter<JobFeedState> emit,
  ) async {
    emit(const JobFeedLoading([], isFirstFetch: true));

    final result = await _jobRepository.getJobs(category: null);

    if (result.failure != null) {
      emit(JobFeedError(result.failure!.message, const []));
    } else {
      final filteredJobs = result.jobs.where((job) {
        if (job.location == null) return false;
        final distance = HaversineUtil.distanceKm(
          lat1: event.latitude,
          lon1: event.longitude,
          lat2: job.location!.latitude,
          lon2: job.location!.longitude,
        );
        return distance <= event.radiusKm;
      }).toList();

      // Sort by proximity: closest first
      filteredJobs.sort((a, b) {
        final distA = HaversineUtil.distanceKm(
          lat1: event.latitude,
          lon1: event.longitude,
          lat2: a.location!.latitude,
          lon2: a.location!.longitude,
        );
        final distB = HaversineUtil.distanceKm(
          lat1: event.latitude,
          lon1: event.longitude,
          lat2: b.location!.latitude,
          lon2: b.location!.longitude,
        );
        return distA.compareTo(distB);
      });

      emit(JobFeedLoaded(filteredJobs, hasReachedMax: true));
    }
  }
}
