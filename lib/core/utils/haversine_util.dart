import 'dart:math';

/// Haversine formula to compute the distance between two GeoPoints in km.
///
/// Used by the matching engine and client-side distance filtering.
class HaversineUtil {
  HaversineUtil._();

  static const double _earthRadiusKm = 6371.0;

  /// Compute distance in kilometers between two coordinates.
  static double distanceKm({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return _earthRadiusKm * c;
  }

  static double _toRadians(double degrees) => degrees * pi / 180;
}
