import 'dart:math' as math;

/// Utilidad para cálculo de distancia geográfica y validación de Geofencing
class DistanceCalculator {
  DistanceCalculator._();

  /// Calcula la distancia en metros entre dos puntos geográficos usando la fórmula de Haversine
  static double calculateDistanceInMeters({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const double earthRadiusInMeters = 6371000; // Radio medio de la Tierra en metros

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusInMeters * c;
  }

  /// Determina si una coordenada se encuentra dentro del radio permitido (Geofence)
  static bool isWithinRadius({
    required double currentLat,
    required double currentLon,
    required double targetLat,
    required double targetLon,
    required double radiusInMeters,
  }) {
    final distance = calculateDistanceInMeters(
      lat1: currentLat,
      lon1: currentLon,
      lat2: targetLat,
      lon2: targetLon,
    );
    return distance <= radiusInMeters;
  }

  /// Convierte grados a radianes
  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

  /// Formatea la distancia de forma legible (metros o kilómetros)
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }
}
