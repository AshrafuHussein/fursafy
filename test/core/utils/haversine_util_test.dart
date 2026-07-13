import 'package:flutter_test/flutter_test.dart';
import 'package:fursafy/core/utils/haversine_util.dart';

void main() {
  group('HaversineUtil Distance Calculations', () {
    test('returns 0.0 for identical coordinates', () {
      final distance = HaversineUtil.distanceKm(
        lat1: -6.8140,
        lon1: 39.2800,
        lat2: -6.8140,
        lon2: 39.2800,
      );
      expect(distance, 0.0);
    });

    test('calculates correct distance between Dar es Salaam Posta and Masaki', () {
      // Posta: -6.8140, 39.2800
      // Masaki: -6.7900, 39.2500
      final distance = HaversineUtil.distanceKm(
        lat1: -6.8140,
        lon1: 39.2800,
        lat2: -6.7900,
        lon2: 39.2500,
      );
      
      // Expected distance is approximately 4.25 km
      expect(distance, closeTo(4.25, 0.05));
    });

    test('calculates correct distance between Dar es Salaam and Arusha', () {
      // Dar es Salaam: -6.8000, 39.2800
      // Arusha: -3.3723, 36.6938
      final distance = HaversineUtil.distanceKm(
        lat1: -6.8000,
        lon1: 39.2800,
        lat2: -3.3723,
        lon2: 36.6938,
      );

      // Expected distance is approximately 476.75 km
      expect(distance, closeTo(476.75, 1.0));
    });

    test('handles negative/south/west coordinates properly', () {
      // Test with coordinates in different hemispheres if needed
      // e.g. London (51.5074, -0.1278) to New York (40.7128, -74.0060)
      final distance = HaversineUtil.distanceKm(
        lat1: 51.5074,
        lon1: -0.1278,
        lat2: 40.7128,
        lon2: -74.0060,
      );

      // Expected distance is approximately 5570 km
      expect(distance, closeTo(5570.0, 20.0));
    });
  });
}
