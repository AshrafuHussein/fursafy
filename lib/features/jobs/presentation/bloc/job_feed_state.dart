import 'package:equatable/equatable.dart';
import 'package:fursafy/features/jobs/domain/entities/job_entity.dart';

abstract class JobFeedState extends Equatable {
  const JobFeedState();

  @override
  List<Object?> get props => [];
}

class JobFeedInitial extends JobFeedState {}

class JobFeedLoading extends JobFeedState {
  final List<JobEntity> oldJobs;
  final bool isFirstFetch;

  const JobFeedLoading(this.oldJobs, {this.isFirstFetch = false});

  @override
  List<Object?> get props => [oldJobs, isFirstFetch];
}

class JobFeedLoaded extends JobFeedState {
  final List<JobEntity> jobs;
  final bool hasReachedMax;

  const JobFeedLoaded(this.jobs, {this.hasReachedMax = false});

  @override
  List<Object?> get props => [jobs, hasReachedMax];
}

class JobFeedError extends JobFeedState {
  final String message;
  final List<JobEntity> oldJobs;

  const JobFeedError(this.message, this.oldJobs);

  @override
  List<Object?> get props => [message, oldJobs];
}
