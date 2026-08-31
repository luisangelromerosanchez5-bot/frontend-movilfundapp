import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

/// Servicio para conteo de pasos y esfuerzo físico durante la jornada activa
class PedometerService {
  StreamSubscription<StepCount>? _subscription;
  Timer? _simulationTimer;

  int _pasosInicio = 0;
  int _pasosSesion = 0;
  DateTime? _inicioSesion;
  bool _isTracking = false;

  final StreamController<PedometerSessionData> _sessionDataController =
      StreamController<PedometerSessionData>.broadcast();

  Stream<PedometerSessionData> get sessionStream => _sessionDataController.stream;
  int get pasosSesion => _pasosSesion;
  bool get isTracking => _isTracking;
  DateTime? get inicioSesion => _inicioSesion;

  /// Solicita el permiso ACTIVITY_RECOGNITION en Android y Motion en iOS
  Future<bool> requestActivityPermission() async {
    try {
      final status = await Permission.activityRecognition.request();
      if (status.isGranted) return true;
      if (status.isDenied || status.isPermanentlyDenied) return false;
      return true;
    } catch (e) {
      debugPrint('[PedometerService] Permiso activity recognition exception: $e');
      return true;
    }
  }

  /// Inicia la sesión de medición tras el check-in
  Future<void> iniciarSesion({bool allowSimulationFallback = true}) async {
    _pasosInicio = 0;
    _pasosSesion = 0;
    _inicioSesion = DateTime.now();
    _isTracking = true;

    final hasPermission = await requestActivityPermission();

    if (!hasPermission && !allowSimulationFallback) {
      debugPrint('[PedometerService] Permiso denegado');
      return;
    }

    try {
      _subscription = Pedometer.stepCountStream.listen(
        (StepCount event) {
          if (_pasosInicio == 0) {
            _pasosInicio = event.steps;
          }
          _pasosSesion = event.steps - _pasosInicio;
          _emitCurrentData();
        },
        onError: (error) {
          debugPrint('[PedometerService] Sensor físico no disponible ($error). Activando simulación.');
          if (allowSimulationFallback) {
            _startSimulation();
          }
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('[PedometerService] Excepción al suscribir sensor de pasos: $e');
      if (allowSimulationFallback) {
        _startSimulation();
      }
    }
  }

  /// Permite simular el avance de pasos (útil en emulador o para demos de sustentación)
  void _startSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isTracking) {
        timer.cancel();
        return;
      }
      // Simula entre 3 y 8 pasos cada 2 segundos
      _pasosSesion += 4;
      _emitCurrentData();
    });
  }

  /// Permite añadir pasos manualmente para pruebas/demos
  void addManualSteps(int steps) {
    if (!_isTracking) return;
    _pasosSesion += steps;
    _emitCurrentData();
  }

  void _emitCurrentData() {
    final now = DateTime.now();
    final duration = _inicioSesion != null ? now.difference(_inicioSesion!) : Duration.zero;
    final km = (_pasosSesion * 0.75) / 1000.0;
    final calories = (_pasosSesion * 0.04).round();

    final data = PedometerSessionData(
      steps: _pasosSesion,
      distanceKm: km,
      duration: duration,
      calories: calories,
      isActive: _isTracking,
    );

    if (!_sessionDataController.isClosed) {
      _sessionDataController.add(data);
    }
  }

  /// Finaliza la sesión (Check-out) y retorna los datos finales
  PedometerSessionData finalizarSesion() {
    _isTracking = false;
    _subscription?.cancel();
    _simulationTimer?.cancel();

    final now = DateTime.now();
    final duration = _inicioSesion != null ? now.difference(_inicioSesion!) : Duration.zero;
    final km = (_pasosSesion * 0.75) / 1000.0;
    final calories = (_pasosSesion * 0.04).round();

    final finalData = PedometerSessionData(
      steps: _pasosSesion,
      distanceKm: km,
      duration: duration,
      calories: calories,
      isActive: false,
    );

    if (!_sessionDataController.isClosed) {
      _sessionDataController.add(finalData);
    }

    return finalData;
  }

  void dispose() {
    _subscription?.cancel();
    _simulationTimer?.cancel();
    _sessionDataController.close();
  }
}

class PedometerSessionData {
  final int steps;
  final double distanceKm;
  final Duration duration;
  final int calories;
  final bool isActive;

  const PedometerSessionData({
    required this.steps,
    required this.distanceKm,
    required this.duration,
    required this.calories,
    required this.isActive,
  });

  factory PedometerSessionData.initial() => const PedometerSessionData(
        steps: 0,
        distanceKm: 0.0,
        duration: Duration.zero,
        calories: 0,
        isActive: false,
      );
}
