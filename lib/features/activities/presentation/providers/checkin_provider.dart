import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/services/location_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/asistencia.dart';
import 'activity_provider.dart';

final locationServiceProvider = Provider<LocationService>((ref) => LocationService());

class CheckInState {
  final bool isLoading;
  final bool isInside;
  final int distanceMeters;
  final int allowedRadiusMeters;
  final String precisionGps;
  final double currentLat;
  final double currentLng;
  final String? errorMessage;
  final Asistencia? asistencia;

  const CheckInState({
    this.isLoading = true,
    this.isInside = false,
    this.distanceMeters = 0,
    this.allowedRadiusMeters = 100,
    this.precisionGps = 'Alta',
    this.currentLat = 0.0,
    this.currentLng = 0.0,
    this.errorMessage,
    this.asistencia,
  });

  CheckInState copyWith({
    bool? isLoading,
    bool? isInside,
    int? distanceMeters,
    int? allowedRadiusMeters,
    String? precisionGps,
    double? currentLat,
    double? currentLng,
    String? errorMessage,
    Asistencia? asistencia,
  }) {
    return CheckInState(
      isLoading: isLoading ?? this.isLoading,
      isInside: isInside ?? this.isInside,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      allowedRadiusMeters: allowedRadiusMeters ?? this.allowedRadiusMeters,
      precisionGps: precisionGps ?? this.precisionGps,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      errorMessage: errorMessage ?? this.errorMessage,
      asistencia: asistencia ?? this.asistencia,
    );
  }
}

class CheckInNotifier extends StateNotifier<CheckInState> {
  final LocationService locationService;
  final Ref ref;
  final Activity activity;
  StreamSubscription<Position>? _positionSubscription;

  CheckInNotifier({
    required this.locationService,
    required this.ref,
    required this.activity,
  }) : super(CheckInState(allowedRadiusMeters: activity.radioPermitidoMetros)) {
    _startLocationMonitoring();
  }

  Future<void> _startLocationMonitoring() async {
    state = state.copyWith(isLoading: true);
    final hasPermission = await locationService.requestLocationPermission();

    if (!hasPermission) {
      // Simular ubicación dentro del rango para permitir prueba
      final result = await locationService.validateGeofence(
        targetLat: activity.latitud,
        targetLng: activity.longitud,
        allowedRadiusMeters: activity.radioPermitidoMetros.toDouble(),
      );
      state = state.copyWith(
        isLoading: false,
        isInside: result.isInside,
        distanceMeters: result.distanceMeters,
        precisionGps: result.gpsPrecision,
        currentLat: result.currentLat,
        currentLng: result.currentLng,
      );
      return;
    }

    try {
      final initialPos = await locationService.getCurrentPosition();
      if (initialPos != null) {
        final result = await locationService.validateGeofence(
          targetLat: activity.latitud,
          targetLng: activity.longitud,
          allowedRadiusMeters: activity.radioPermitidoMetros.toDouble(),
          forcedPosition: initialPos,
        );

        state = state.copyWith(
          isLoading: false,
          isInside: result.isInside,
          distanceMeters: result.distanceMeters,
          precisionGps: result.gpsPrecision,
          currentLat: result.currentLat,
          currentLng: result.currentLng,
        );
      }

      _positionSubscription = locationService.getPositionStream().listen((pos) async {
        final result = await locationService.validateGeofence(
          targetLat: activity.latitud,
          targetLng: activity.longitud,
          allowedRadiusMeters: activity.radioPermitidoMetros.toDouble(),
          forcedPosition: pos,
        );

        if (mounted) {
          state = state.copyWith(
            isLoading: false,
            isInside: result.isInside,
            distanceMeters: result.distanceMeters,
            precisionGps: result.gpsPrecision,
            currentLat: result.currentLat,
            currentLng: result.currentLng,
          );
        }
      });
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Permite simular estar dentro del punto de encuentro (para pruebas y demos)
  void simulateProximity({bool inside = true}) {
    if (inside) {
      state = state.copyWith(
        isInside: true,
        distanceMeters: 38,
        precisionGps: 'Alta',
        currentLat: activity.latitud + 0.0001,
        currentLng: activity.longitud + 0.0001,
      );
    } else {
      state = state.copyWith(
        isInside: false,
        distanceMeters: 450,
        precisionGps: 'Media',
        currentLat: activity.latitud + 0.0040,
        currentLng: activity.longitud + 0.0040,
      );
    }
  }

  Future<Asistencia?> submitCheckIn() async {
    if (!state.isInside) return null;

    state = state.copyWith(isLoading: true);
    final user = ref.read(authProvider).user;
    final repo = ref.read(activityRepositoryProvider);

    try {
      final asistencia = await repo.checkInAsistencia(
        actividadId: activity.id,
        usuarioId: user?.id ?? 'u101',
        lat: state.currentLat,
        lng: state.currentLng,
        distanciaMetros: state.distanceMeters,
        precisionGps: state.precisionGps,
      );
      state = state.copyWith(isLoading: false, asistencia: asistencia);
      return asistencia;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }
}

final checkInProviderFamily = StateNotifierProvider.family<CheckInNotifier, CheckInState, Activity>((ref, activity) {
  return CheckInNotifier(
    locationService: ref.watch(locationServiceProvider),
    ref: ref,
    activity: activity,
  );
});
