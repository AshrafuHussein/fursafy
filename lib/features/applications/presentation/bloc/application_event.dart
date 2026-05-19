import 'package:equatable/equatable.dart';

abstract class ApplicationEvent extends Equatable {
  const ApplicationEvent();

  @override
  List<Object?> get props => [];
}

/// Load youth's own applications.
class ApplicationsLoadRequested extends ApplicationEvent {
  final String youthId;
  const ApplicationsLoadRequested(this.youthId);

  @override
  List<Object?> get props => [youthId];
}

/// Load applicants for a provider's job.
class JobApplicantsLoadRequested extends ApplicationEvent {
  final String jobId;
  const JobApplicantsLoadRequested(this.jobId);

  @override
  List<Object?> get props => [jobId];
}

/// Apply for a job.
class ApplicationSubmitted extends ApplicationEvent {
  final String jobId;
  final String jobTitle;
  final String youthId;
  final String youthName;
  final String? youthAvatarUrl;
  final String providerId;
  final String? coverMessage;

  const ApplicationSubmitted({
    required this.jobId,
    required this.jobTitle,
    required this.youthId,
    required this.youthName,
    this.youthAvatarUrl,
    required this.providerId,
    this.coverMessage,
  });

  @override
  List<Object?> get props =>
      [jobId, jobTitle, youthId, youthName, providerId, coverMessage];
}

/// Accept an application (provider action).
class ApplicationAccepted extends ApplicationEvent {
  final String applicationId;
  const ApplicationAccepted(this.applicationId);

  @override
  List<Object?> get props => [applicationId];
}

/// Reject an application (provider action).
class ApplicationRejected extends ApplicationEvent {
  final String applicationId;
  const ApplicationRejected(this.applicationId);

  @override
  List<Object?> get props => [applicationId];
}

/// Withdraw an application (youth action).
class ApplicationWithdrawn extends ApplicationEvent {
  final String applicationId;
  const ApplicationWithdrawn(this.applicationId);

  @override
  List<Object?> get props => [applicationId];
}
