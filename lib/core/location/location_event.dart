import 'package:equatable/equatable.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

/// Request the device's current GPS location.
class LocationRequested extends LocationEvent {
  const LocationRequested();
}

/// Request location permission explicitly (e.g., before first use).
class LocationPermissionRequested extends LocationEvent {
  const LocationPermissionRequested();
}

/// Set location manually (e.g., from saved profile data).
class LocationSetManually extends LocationEvent {
  final double latitude;
  final double longitude;
  final String address;

  const LocationSetManually({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  @override
  List<Object?> get props => [latitude, longitude, address];
}

/// Clear the cached location.
class LocationCleared extends LocationEvent {
  const LocationCleared();
}

/// Start listening to background location updates.
class LocationBackgroundStarted extends LocationEvent {
  const LocationBackgroundStarted();
}

/// Stop background location updates.
class LocationBackgroundStopped extends LocationEvent {
  const LocationBackgroundStopped();
}
