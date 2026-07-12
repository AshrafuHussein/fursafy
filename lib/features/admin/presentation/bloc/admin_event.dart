import 'package:equatable/equatable.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

class AdminStatsFetchRequested extends AdminEvent {}

class AdminPlatformConfigLoadRequested extends AdminEvent {}

class AdminPlatformConfigSaveRequested extends AdminEvent {
  final Map<String, dynamic> config;

  const AdminPlatformConfigSaveRequested(this.config);

  @override
  List<Object?> get props => [config];
}

class AdminUserStatusToggleRequested extends AdminEvent {
  final String uid;
  final String currentStatus;

  const AdminUserStatusToggleRequested({required this.uid, required this.currentStatus});

  @override
  List<Object?> get props => [uid, currentStatus];
}

class AdminJobModerateRequested extends AdminEvent {
  final String jobId;
  final String action;

  const AdminJobModerateRequested({required this.jobId, required this.action});

  @override
  List<Object?> get props => [jobId, action];
}

class AdminInviteRequested extends AdminEvent {
  final String email;

  const AdminInviteRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class AdminWeeklySignupsFetchRequested extends AdminEvent {}

class AdminJobPostRequested extends AdminEvent {
  final Map<String, dynamic> jobData;

  const AdminJobPostRequested(this.jobData);

  @override
  List<Object?> get props => [jobData];
}

class AdminInviteRevokeRequested extends AdminEvent {
  final String email;

  const AdminInviteRevokeRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class AdminApiKeyGenerateRequested extends AdminEvent {
  final String name;
  final String environment;

  const AdminApiKeyGenerateRequested({required this.name, required this.environment});

  @override
  List<Object?> get props => [name, environment];
}

class AdminApiKeyDeleteRequested extends AdminEvent {
  final String keyId;

  const AdminApiKeyDeleteRequested(this.keyId);

  @override
  List<Object?> get props => [keyId];
}

class AdminUserVerificationUpdateRequested extends AdminEvent {
  final String uid;
  final bool isApproved;
  final String? rejectionReason;
  final String? notes;

  const AdminUserVerificationUpdateRequested({
    required this.uid,
    required this.isApproved,
    this.rejectionReason,
    this.notes,
  });

  @override
  List<Object?> get props => [uid, isApproved, rejectionReason, notes];
}

class AdminTransactionStatusUpdateRequested extends AdminEvent {
  final String transactionId;
  final String status;

  const AdminTransactionStatusUpdateRequested({required this.transactionId, required this.status});

  @override
  List<Object?> get props => [transactionId, status];
}

class AdminBatchPayoutReleaseRequested extends AdminEvent {
  final List<String> transactionIds;

  const AdminBatchPayoutReleaseRequested(this.transactionIds);

  @override
  List<Object?> get props => [transactionIds];
}

class AdminAnalyticsLoadRequested extends AdminEvent {}

class AdminAdminsUpdated extends AdminEvent {
  final List<dynamic> admins;
  final List<Map<String, dynamic>> invites;

  const AdminAdminsUpdated(this.admins, this.invites);

  @override
  List<Object?> get props => [admins, invites];
}

class AdminApiKeysUpdated extends AdminEvent {
  final List<Map<String, dynamic>> apiKeys;

  const AdminApiKeysUpdated(this.apiKeys);

  @override
  List<Object?> get props => [apiKeys];
}

class AdminTransactionsUpdated extends AdminEvent {
  final List<Map<String, dynamic>> transactions;

  const AdminTransactionsUpdated(this.transactions);

  @override
  List<Object?> get props => [transactions];
}
