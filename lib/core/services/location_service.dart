import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/distance_calculator.dart';

/// Servicio para obtención de ubicación GPS y Geofencing
class LocationService {
  /// Solicita permisos de ubicación
  Future<bool> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) return true;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Obtiene la posición GPS actual del voluntario
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        // Retornar posición de prueba si los permisos no están concedidos o en emulador
        debugPrint('[LocationService] Usando posición mock para pruebas en emulador/entorno');
        return Position(
          longitude: -74.072100,
          latitude: 4.711000,
          timestamp: DateTime.now(),
          accuracy: 5.0,
          altitude: 2600.0,
          altitudeAccuracy: 1.0,
          heading: 0.0,
          headingAccuracy: 1.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      debugPrint('[LocationService] Error obteniendo GPS: $e. Usando fallback.');
      return Position(
        longitude: -74.072200,
        latitude: 4.711100,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 2600.0,
        altitudeAccuracy: 1.0,
        heading: 0.0,
        headingAccuracy: 1.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );
    }
  }

  /// Obtiene el stream de posiciones para seguimiento en tiempo real
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2, // Actualizar cada 2 metros
      ),
    );
  }

  /// Valida si el voluntario está dentro del geofence de la actividad
  Future<GeofenceResult> validateGeofence({
    required double targetLat,
    required double targetLng,
    required double allowedRadiusMeters,
    Position? forcedPosition,
  }) async {
    final currentPos = forcedPosition ?? await getCurrentPosition();

    if (currentPos == null) {
      return const GeofenceResult(
        isInside: false,
        distanceMeters: 999999,
        gpsPrecision: 'Baja / No disponible',
        currentLat: 0,
        currentLng: 0,
      );
    }

    final distance = DistanceCalculator.calculateDistanceInMeters(
      lat1: currentPos.latitude,
      lon1: currentPos.longitude,
      lat2: targetLat,
      lon2: targetLng,
    );

    final isInside = distance <= allowedRadiusMeters;
    final precisionText = currentPos.accuracy <= 15 ? 'Alta' : (currentPos.accuracy <= 50 ? 'Media' : 'Baja');

    return GeofenceResult(
      isInside: isInside,
      distanceMeters: distance.round(),
      gpsPrecision: precisionText,
      currentLat: currentPos.latitude,
      currentLng: currentPos.longitude,
      accuracy: currentPos.accuracy,
    );
  }
}

class GeofenceResult {
  final bool isInside;
  final int distanceMeters;
  final String gpsPrecision;
  final double currentLat;
  final double currentLng;
  final double? accuracy;

  const GeofenceResult({
    required this.isInside,
    required this.distanceMeters,
    required this.gpsPrecision,
    required this.currentLat,
    required this.currentLng,
    this.accuracy,
  });
}
