import 'package:equatable/equatable.dart';

abstract class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object?> get props => [];
}

/// Initial state — no location data yet.
class LocationInitial extends LocationState {}

/// GPS is being acquired.
class LocationLoading extends LocationState {}

/// Location successfully obtained.
class LocationLoaded extends LocationState {
  final double latitude;
  final double longitude;
  final String address;

  const LocationLoaded({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  @override
  List<Object?> get props => [latitude, longitude, address];
}

/// Location permission was denied by the user.
class LocationDenied extends LocationState {
  final bool isPermanent;

  const LocationDenied({this.isPermanent = false});

  @override
  List<Object?> get props => [isPermanent];
}

/// Location services are disabled on the device.
class LocationServiceDisabled extends LocationState {}

/// An unexpected error occurred.
class LocationError extends LocationState {
  final String message;

  const LocationError(this.message);

  @override
  List<Object?> get props => [message];
}
