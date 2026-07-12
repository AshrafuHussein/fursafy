import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fursafy/features/admin/domain/repositories/admin_repository.dart';
import 'package:fursafy/features/auth/domain/entities/user_entity.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository _repo;

  StreamSubscription? _adminsSub;
  StreamSubscription? _invitesSub;
  StreamSubscription? _keysSub;
  StreamSubscription? _transactionsSub;

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
    on<AdminJobPostRequested>(_onPostJob);

    on<AdminInviteRevokeRequested>(_onRevokeAdminInvite);
    on<AdminApiKeyGenerateRequested>(_onGenerateApiKey);
    on<AdminApiKeyDeleteRequested>(_onDeleteApiKey);
    on<AdminUserVerificationUpdateRequested>(_onUserVerificationUpdate);
    on<AdminTransactionStatusUpdateRequested>(_onTransactionStatusUpdate);
    on<AdminBatchPayoutReleaseRequested>(_onBatchPayoutRelease);
    on<AdminAnalyticsLoadRequested>(_onLoadAnalytics);

    on<AdminAdminsUpdated>(_onAdminsUpdated);
    on<AdminApiKeysUpdated>(_onApiKeysUpdated);
    on<AdminTransactionsUpdated>(_onTransactionsUpdated);

    // Initialize Streams
    _adminsSub = _repo.getAdmins().listen((adminsList) {
      add(AdminAdminsUpdated(adminsList, state.adminInvites));
    });

    _invitesSub = _repo.getAdminInvitations().listen((invitesList) {
      add(AdminAdminsUpdated(state.admins, invitesList));
    });

    _keysSub = _repo.getApiKeys().listen((keys) {
      add(AdminApiKeysUpdated(keys));
    });

    _transactionsSub = _repo.getTransactions().listen((txs) {
      add(AdminTransactionsUpdated(txs));
    });
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

  Future<void> _onPostJob(
    AdminJobPostRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final failure = await _repo.postJob(event.jobData);
    if (failure != null) {
      emit(state.copyWith(isLoading: false, errorMessage: failure.message));
    } else {
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'Opportunity posted successfully!',
      ));
    }
  }

  Future<void> _onRevokeAdminInvite(
    AdminInviteRevokeRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final failure = await _repo.revokeAdminInvite(event.email);
    if (failure != null) {
      emit(state.copyWith(isLoading: false, errorMessage: failure.message));
    } else {
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'Invitation revoked for ${event.email}',
      ));
    }
  }

  Future<void> _onGenerateApiKey(
    AdminApiKeyGenerateRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final failure = await _repo.generateApiKey(event.name, event.environment);
    if (failure != null) {
      emit(state.copyWith(isLoading: false, errorMessage: failure.message));
    } else {
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'API Key generated successfully!',
      ));
    }
  }

  Future<void> _onDeleteApiKey(
    AdminApiKeyDeleteRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final failure = await _repo.deleteApiKey(event.keyId);
    if (failure != null) {
      emit(state.copyWith(isLoading: false, errorMessage: failure.message));
    } else {
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'API Key deleted successfully!',
      ));
    }
  }

  Future<void> _onUserVerificationUpdate(
    AdminUserVerificationUpdateRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final targetStatus = event.isApproved ? 'active' : 'rejected';
    final failure = await _repo.updateUserStatus(
      uid: event.uid,
      targetStatus: targetStatus,
      reason: event.rejectionReason,
      notes: event.notes,
    );
    if (failure != null) {
      emit(state.copyWith(isLoading: false, errorMessage: failure.message));
    } else {
      emit(state.copyWith(
        isLoading: false,
        successMessage: event.isApproved ? 'User verification approved!' : 'User verification rejected.',
      ));
    }
  }

  Future<void> _onTransactionStatusUpdate(
    AdminTransactionStatusUpdateRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final failure = await _repo.updateTransactionStatus(event.transactionId, event.status);
    if (failure != null) {
      emit(state.copyWith(isLoading: false, errorMessage: failure.message));
    } else {
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'Transaction status updated to ${event.status}',
      ));
    }
  }

  Future<void> _onBatchPayoutRelease(
    AdminBatchPayoutReleaseRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final failure = await _repo.authorizeBatchPayouts(event.transactionIds);
    if (failure != null) {
      emit(state.copyWith(isLoading: false, errorMessage: failure.message));
    } else {
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'Batch payout authorized and released successfully!',
      ));
    }
  }

  Future<void> _onLoadAnalytics(
    AdminAnalyticsLoadRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final result = await _repo.fetchAnalyticsData();
    if (result.failure != null) {
      emit(state.copyWith(isLoading: false, errorMessage: result.failure!.message));
    } else {
      emit(state.copyWith(
        isLoading: false,
        analyticsRegional: result.regionalData,
        analyticsCategories: result.categoryShareData,
        analyticsGrowth: result.growthMetrics,
      ));
    }
  }

  void _onAdminsUpdated(
    AdminAdminsUpdated event,
    Emitter<AdminState> emit,
  ) {
    emit(state.copyWith(
      admins: List<UserEntity>.from(event.admins),
      adminInvites: List<Map<String, dynamic>>.from(event.invites),
    ));
  }

  void _onApiKeysUpdated(
    AdminApiKeysUpdated event,
    Emitter<AdminState> emit,
  ) {
    emit(state.copyWith(
      apiKeys: List<Map<String, dynamic>>.from(event.apiKeys),
    ));
  }

  void _onTransactionsUpdated(
    AdminTransactionsUpdated event,
    Emitter<AdminState> emit,
  ) {
    emit(state.copyWith(
      transactions: List<Map<String, dynamic>>.from(event.transactions),
    ));
  }

  @override
  Future<void> close() {
    _adminsSub?.cancel();
    _invitesSub?.cancel();
    _keysSub?.cancel();
    _transactionsSub?.cancel();
    return super.close();
  }
}
