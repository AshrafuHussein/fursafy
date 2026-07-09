import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fursafy/features/admin/domain/repositories/admin_repository.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository _repo;

  AdminBloc({required AdminRepository adminRepository})
      : _repo = adminRepository,
        super(AdminState.initial()) {
    on<AdminStatsFetchRequested>(_onFetchStats);
    on<AdminPlatformConfigLoadRequested>(_onLoadConfig);
    on<AdminPlatformConfigSaveRequested>(_onSaveConfig);
    on<AdminUserStatusToggleRequested>(_onToggleUserStatus);
    on<AdminJobModerateRequested>(_onModerateJob);
    on<AdminInviteRequested>(_onInviteAdmin);
    on<AdminWeeklySignupsFetchRequested>(_onFetchWeeklySignups);
  }

  Future<void> _onFetchStats(
    AdminStatsFetchRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final result = await _repo.fetchStats();
    if (result.failure != null) {
      emit(state.copyWith(isLoading: false, errorMessage: result.failure!.message));
    } else {
      emit(state.copyWith(
        isLoading: false,
        totalUsers: result.totalUsers,
        totalProviders: result.totalProviders,
        totalJobs: result.totalJobs,
        totalApplications: result.totalApplications,
        completedJobs: result.completedJobs,
        flaggedJobsCount: result.flaggedJobsCount,
        totalTxVolume: result.totalTxVolume,
      ));
    }
  }

  Future<void> _onLoadConfig(
    AdminPlatformConfigLoadRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final result = await _repo.loadPlatformConfig();
    if (result.failure != null) {
      emit(state.copyWith(isLoading: false, errorMessage: result.failure!.message));
    } else {
      emit(state.copyWith(
        isLoading: false,
        platformConfig: result.config ?? {},
      ));
    }
  }

  Future<void> _onSaveConfig(
    AdminPlatformConfigSaveRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final failure = await _repo.savePlatformConfig(event.config);
    if (failure != null) {
      emit(state.copyWith(isLoading: false, errorMessage: failure.message));
    } else {
      emit(state.copyWith(
        isLoading: false,
        platformConfig: event.config,
        successMessage: 'Configuration saved successfully and synced to Firestore!',
      ));
    }
  }

  Future<void> _onToggleUserStatus(
    AdminUserStatusToggleRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final failure = await _repo.toggleUserStatus(event.uid, event.currentStatus);
    if (failure != null) {
      emit(state.copyWith(isLoading: false, errorMessage: failure.message));
    } else {
      final newStatus = event.currentStatus == 'suspended' ? 'active' : 'suspended';
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'User status updated to $newStatus',
      ));
    }
  }

  Future<void> _onModerateJob(
    AdminJobModerateRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final failure = await _repo.moderateJob(event.jobId, event.action);
    if (failure != null) {
      emit(state.copyWith(isLoading: false, errorMessage: failure.message));
    } else {
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'Job Listing ${event.action} success',
      ));
    }
  }

  Future<void> _onInviteAdmin(
    AdminInviteRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final failure = await _repo.inviteAdmin(event.email);
    if (failure != null) {
      emit(state.copyWith(isLoading: false, errorMessage: failure.message));
    } else {
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'Invitation sent to ${event.email}',
      ));
    }
  }

  Future<void> _onFetchWeeklySignups(
    AdminWeeklySignupsFetchRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final result = await _repo.fetchWeeklyJobsData();
    if (result.failure != null) {
      emit(state.copyWith(isLoading: false, errorMessage: result.failure!.message));
    } else {
      emit(state.copyWith(
        isLoading: false,
        weeklyJobsData: result.jobsData,
      ));
    }
  }
}
