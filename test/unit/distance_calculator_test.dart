import 'package:flutter_test/flutter_test.dart';
import 'package:fundapp_mobile/core/utils/distance_calculator.dart';

void main() {
  group('DistanceCalculator & Geofencing Tests', () {
    test('Calcula distancia Haversine correctamente entre dos puntos cercanos', () {
      // Coordenadas en Bogotá
      const lat1 = 4.711000;
      const lon1 = -74.072100;
      const lat2 = 4.711200;
      const lon2 = -74.072100;

      final distance = DistanceCalculator.calculateDistanceInMeters(
        lat1: lat1,
        lon1: lon1,
        lat2: lat2,
        lon2: lon2,
      );

      // Aproximadamente 22 metros
      expect(distance, greaterThan(15));
      expect(distance, lessThan(30));
    });

    test('isWithinRadius devuelve true si está dentro de los 100m permitidos', () {
      const targetLat = 4.711000;
      const targetLon = -74.072100;
      const currentLat = 4.711200; // ~22m de distancia
      const currentLon = -74.072100;

      final isInside = DistanceCalculator.isWithinRadius(
        currentLat: currentLat,
        currentLon: currentLon,
        targetLat: targetLat,
        targetLon: targetLon,
        radiusInMeters: 100,
      );

      expect(isInside, isTrue);
    });

    test('isWithinRadius devuelve false si excede el radio permitido', () {
      const targetLat = 4.711000;
      const targetLon = -74.072100;
      const farLat = 4.720000; // ~1000m de distancia
      const farLon = -74.072100;

      final isInside = DistanceCalculator.isWithinRadius(
        currentLat: farLat,
        currentLon: farLon,
        targetLat: targetLat,
        targetLon: targetLon,
        radiusInMeters: 100,
      );

      expect(isInside, isFalse);
    });
  });
}
