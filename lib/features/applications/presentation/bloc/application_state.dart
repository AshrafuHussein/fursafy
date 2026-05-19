import 'package:equatable/equatable.dart';
import 'package:fursafy/features/applications/domain/entities/application_entity.dart';

abstract class ApplicationState extends Equatable {
  const ApplicationState();

  @override
  List<Object?> get props => [];
}

class ApplicationInitial extends ApplicationState {}

class ApplicationLoading extends ApplicationState {}

class ApplicationsLoaded extends ApplicationState {
  final List<ApplicationEntity> applications;

  const ApplicationsLoaded(this.applications);

  @override
  List<Object?> get props => [applications];
}

class ApplicationSubmitSuccess extends ApplicationState {
  final String applicationId;
  const ApplicationSubmitSuccess(this.applicationId);

  @override
  List<Object?> get props => [applicationId];
}

class ApplicationActionSuccess extends ApplicationState {
  final String message;
  const ApplicationActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ApplicationError extends ApplicationState {
  final String message;
  const ApplicationError(this.message);

  @override
  List<Object?> get props => [message];
}
