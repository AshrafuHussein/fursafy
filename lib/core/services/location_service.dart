import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Singleton service wrapping GPS location + reverse geocoding.
///
/// Usage:
/// ```dart
/// final pos = await LocationService.instance.getCurrentPosition();
/// final address = await LocationService.instance.getAddressFromCoords(pos.latitude, pos.longitude);
/// ```
class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  /// Cached last-known position (survives hot reload, lost on app restart).
  Position? _lastPosition;
  Position? get lastPosition => _lastPosition;

  /// Cached last-known address string.
  String? _lastAddress;
  String? get lastAddress => _lastAddress;

  // ──────────────────── Permission helpers ────────────────────

  /// Check if location services are enabled on the device.
  Future<bool> isServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check current permission status without requesting.
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission. Returns the resulting permission.
  Future<LocationPermission> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }

  /// Whether we have sufficient permission to get foreground location.
  Future<bool> hasPermission() async {
    final perm = await Geolocator.checkPermission();
    return perm == LocationPermission.whileInUse ||
        perm == LocationPermission.always;
  }

  /// Request background (always) permission. Must be called AFTER
  /// the user has already granted foreground permission.
  Future<LocationPermission> requestBackgroundPermission() async {
    final perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.whileInUse) {
      // On Android 11+, this opens the "Allow all the time" settings page.
      return await Geolocator.requestPermission();
    }
    return perm;
  }

  // ──────────────────── Position ────────────────────

  /// Get the current GPS position. Requests permission if needed.
  /// Returns `null` if permission is denied or services are off.
  Future<Position?> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('LocationService: Location services are disabled.');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('LocationService: Permission denied.');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('LocationService: Permission permanently denied.');
        return null;
      }

      // Try to get last known position first (fast, reliable fallback)
      Position? position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        _lastPosition = position;
      }

      // Try to get current position with moderate accuracy (faster lock, works on emulators)
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 8),
          ),
        );
        _lastPosition = position;
      } catch (e) {
        debugPrint('LocationService: getCurrentPosition failed or timed out: $e. Using last known/cache.');
      }

      return position ?? _lastPosition;
    } catch (e) {
      debugPrint('LocationService: Error getting position: $e');
      return _lastPosition;
    }
  }

  /// Get last known position (faster, may be stale).
  Future<Position?> getLastKnownPosition() async {
    try {
      final pos = await Geolocator.getLastKnownPosition();
      if (pos != null) _lastPosition = pos;
      return pos ?? _lastPosition;
    } catch (e) {
      debugPrint('LocationService: Error getting last known position: $e');
      return _lastPosition;
    }
  }

  // ──────────────────── Reverse Geocoding ────────────────────

  /// Convert lat/lng to a human-readable address string.
  /// Returns a short address like "Kinondoni, Dar es Salaam".
  Future<String?> getAddressFromCoords(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) return null;

      final place = placemarks.first;
      final address = _formatAddress(place);
      _lastAddress = address;
      return address;
    } catch (e) {
      debugPrint('LocationService: Reverse geocoding error: $e');
      return null;
    }
  }

  /// Format a Placemark into a short, user-friendly address.
  String _formatAddress(Placemark place) {
    final parts = <String>[];

    // Prefer subLocality (neighborhood/district) first
    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      parts.add(place.subLocality!);
    } else if (place.locality != null && place.locality!.isNotEmpty) {
      parts.add(place.locality!);
    }

    // Add the administrative area (city/region) if different
    if (place.administrativeArea != null &&
        place.administrativeArea!.isNotEmpty &&
        !parts.contains(place.administrativeArea!)) {
      parts.add(place.administrativeArea!);
    }

    // If we got nothing useful, try the full name
    if (parts.isEmpty && place.name != null && place.name!.isNotEmpty) {
      parts.add(place.name!);
    }

    return parts.isNotEmpty ? parts.join(', ') : 'Unknown location';
  }

  /// Full flow: get position + reverse geocode in one call.
  /// Returns (lat, lng, address) or null if failed.
  Future<({double latitude, double longitude, String address})?> getLocationWithAddress() async {
    final position = await getCurrentPosition();
    if (position == null) return null;

    final address = await getAddressFromCoords(
      position.latitude,
      position.longitude,
    );

    return (
      latitude: position.latitude,
      longitude: position.longitude,
      address: address ?? 'Current location',
    );
  }

  // ──────────────────── Background Location ────────────────────

  /// Listen to position updates in the background.
  Stream<Position> getPositionStream({
    int distanceFilterMeters = 500,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: distanceFilterMeters,
      ),
    ).map((position) {
      _lastPosition = position;
      return position;
    });
  }

  // ──────────────────── Distance ────────────────────

  /// Distance in km between two coordinates.
  double distanceKm({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    final meters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
    return meters / 1000.0;
  }

  /// Open the device location settings (useful when permission is denied forever).
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings (useful when permission is permanently denied).
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }
}
