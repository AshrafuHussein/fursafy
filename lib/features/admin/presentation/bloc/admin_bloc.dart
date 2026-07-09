import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fursafy/features/admin/domain/repositories/admin_repository.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository _repo;

  AdminBloc({required AdminRepository adminRepository})
      : _repo = adminRepository,
        super(AdminInitial()) {
    on<AdminStatsFetchRequested>(_onFetchStats);
    on<AdminPlatformConfigLoadRequested>(_onLoadConfig);
    on<AdminPlatformConfigSaveRequested>(_onSaveConfig);
    on<AdminUserStatusToggleRequested>(_onToggleUserStatus);
    on<AdminJobModerateRequested>(_onModerateJob);
    on<AdminInviteRequested>(_onInviteAdmin);
  }

  Future<void> _onFetchStats(
    AdminStatsFetchRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final result = await _repo.fetchStats();
    if (result.failure != null) {
      emit(AdminFailure(result.failure!.message));
    } else {
      emit(AdminStatsLoaded(
        totalUsers: result.totalUsers,
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
    emit(AdminLoading());
    final result = await _repo.loadPlatformConfig();
    if (result.failure != null) {
      emit(AdminFailure(result.failure!.message));
    } else {
      emit(AdminPlatformConfigLoaded(result.config ?? {}));
    }
  }

  Future<void> _onSaveConfig(
    AdminPlatformConfigSaveRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final failure = await _repo.savePlatformConfig(event.config);
    if (failure != null) {
      emit(AdminFailure(failure.message));
    } else {
      emit(const AdminActionSuccess('Configuration saved successfully and synced to Firestore!'));
    }
  }

  Future<void> _onToggleUserStatus(
    AdminUserStatusToggleRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final failure = await _repo.toggleUserStatus(event.uid, event.currentStatus);
    if (failure != null) {
      emit(AdminFailure(failure.message));
    } else {
      final newStatus = event.currentStatus == 'suspended' ? 'active' : 'suspended';
      emit(AdminActionSuccess('User status updated to $newStatus'));
    }
  }

  Future<void> _onModerateJob(
    AdminJobModerateRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final failure = await _repo.moderateJob(event.jobId, event.action);
    if (failure != null) {
      emit(AdminFailure(failure.message));
    } else {
      emit(AdminActionSuccess('Job Listing ${event.action} success'));
    }
  }

  Future<void> _onInviteAdmin(
    AdminInviteRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final failure = await _repo.inviteAdmin(event.email);
    if (failure != null) {
      emit(AdminFailure(failure.message));
    } else {
      emit(AdminActionSuccess('Invitation sent to ${event.email}'));
    }
  }
}
