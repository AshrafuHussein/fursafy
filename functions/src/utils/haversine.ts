import * as admin from "firebase-admin";

/**
 * Haversine distance formula — computes the great-circle distance
 * between two GeoPoints in kilometres.
 *
 * Used by the Matching Engine to filter youth within MATCH_RADIUS_KM.
 */
export function haversineKm(
  p1: admin.firestore.GeoPoint,
  p2: admin.firestore.GeoPoint
): number {
  const R = 6371; // Earth's radius in km
  const dLat = ((p2.latitude - p1.latitude) * Math.PI) / 180;
  const dLon = ((p2.longitude - p1.longitude) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos((p1.latitude * Math.PI) / 180) *
      Math.cos((p2.latitude * Math.PI) / 180) *
      Math.sin(dLon / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}
