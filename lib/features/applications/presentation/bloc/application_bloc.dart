import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fursafy/features/applications/domain/repositories/application_repository.dart';
import 'application_event.dart';
import 'application_state.dart';

class ApplicationBloc extends Bloc<ApplicationEvent, ApplicationState> {
  final ApplicationRepository _repo;

  ApplicationBloc({required ApplicationRepository applicationRepository})
      : _repo = applicationRepository,
        super(ApplicationInitial()) {
    on<ApplicationsLoadRequested>(_onLoadYouth);
    on<JobApplicantsLoadRequested>(_onLoadJobApplicants);
    on<ApplicationSubmitted>(_onSubmit);
    on<ApplicationAccepted>(_onAccept);
    on<ApplicationRejected>(_onReject);
    on<ApplicationWithdrawn>(_onWithdraw);
  }

  Future<void> _onLoadYouth(
    ApplicationsLoadRequested event,
    Emitter<ApplicationState> emit,
  ) async {
    emit(ApplicationLoading());
    final result = await _repo.getYouthApplications(event.youthId);
    if (result.failure != null) {
      emit(ApplicationError(result.failure!.message));
    } else {
      emit(ApplicationsLoaded(result.applications));
    }
  }

  Future<void> _onLoadJobApplicants(
    JobApplicantsLoadRequested event,
    Emitter<ApplicationState> emit,
  ) async {
    emit(ApplicationLoading());
    final result = await _repo.getJobApplicants(event.jobId);
    if (result.failure != null) {
      emit(ApplicationError(result.failure!.message));
    } else {
      emit(ApplicationsLoaded(result.applications));
    }
  }

  Future<void> _onSubmit(
    ApplicationSubmitted event,
    Emitter<ApplicationState> emit,
  ) async {
    emit(ApplicationLoading());
    final result = await _repo.applyForJob(
      jobId: event.jobId,
      jobTitle: event.jobTitle,
      youthId: event.youthId,
      youthName: event.youthName,
      youthAvatarUrl: event.youthAvatarUrl,
      providerId: event.providerId,
      coverMessage: event.coverMessage,
    );
    if (result.failure != null) {
      emit(ApplicationError(result.failure!.message));
    } else {
      emit(ApplicationSubmitSuccess(result.applicationId!));
    }
  }

  Future<void> _onAccept(
    ApplicationAccepted event,
    Emitter<ApplicationState> emit,
  ) async {
    emit(ApplicationLoading());
    final failure = await _repo.acceptApplication(event.applicationId);
    if (failure != null) {
      emit(ApplicationError(failure.message));
    } else {
      emit(const ApplicationActionSuccess('Applicant accepted'));
    }
  }

  Future<void> _onReject(
    ApplicationRejected event,
    Emitter<ApplicationState> emit,
  ) async {
    emit(ApplicationLoading());
    final failure = await _repo.rejectApplication(event.applicationId);
    if (failure != null) {
      emit(ApplicationError(failure.message));
    } else {
      emit(const ApplicationActionSuccess('Applicant rejected'));
    }
  }

  Future<void> _onWithdraw(
    ApplicationWithdrawn event,
    Emitter<ApplicationState> emit,
  ) async {
    emit(ApplicationLoading());
    final failure = await _repo.withdrawApplication(event.applicationId);
    if (failure != null) {
      emit(ApplicationError(failure.message));
    } else {
      emit(const ApplicationActionSuccess('Application withdrawn'));
    }
  }
}
