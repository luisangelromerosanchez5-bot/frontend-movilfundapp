import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/pedometer_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../certificates/data/datasources/certificate_remote_data_source.dart';
import '../../../certificates/data/models/certificate_model.dart';
import '../../../certificates/domain/entities/certificate.dart';
import '../../../certificates/presentation/providers/certificate_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/asistencia.dart';
import 'activity_provider.dart';

final pedometerServiceProvider = Provider<PedometerService>((ref) {
  final service = PedometerService();
  ref.onDispose(() => service.dispose());
  return service;
});

class ActiveSessionState {
  final Activity activity;
  final Asistencia? asistencia;
  final int steps;
  final double distanceKm;
  final Duration duration;
  final int calories;
  final bool isTracking;
  final double progressMeta; // ej. meta de 8.000 pasos
  final List<String> unlockedBadges;
  final bool isCompleted;

  const ActiveSessionState({
    required this.activity,
    this.asistencia,
    this.steps = 0,
    this.distanceKm = 0.0,
    this.duration = Duration.zero,
    this.calories = 0,
    this.isTracking = true,
    this.progressMeta = 0.0,
    this.unlockedBadges = const [],
    this.isCompleted = false,
  });

  ActiveSessionState copyWith({
    Activity? activity,
    Asistencia? asistencia,
    int? steps,
    double? distanceKm,
    Duration? duration,
    int? calories,
    bool? isTracking,
    double? progressMeta,
    List<String>? unlockedBadges,
    bool? isCompleted,
  }) {
    return ActiveSessionState(
      activity: activity ?? this.activity,
      asistencia: asistencia ?? this.asistencia,
      steps: steps ?? this.steps,
      distanceKm: distanceKm ?? this.distanceKm,
      duration: duration ?? this.duration,
      calories: calories ?? this.calories,
      isTracking: isTracking ?? this.isTracking,
      progressMeta: progressMeta ?? this.progressMeta,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class ActiveSessionNotifier extends StateNotifier<ActiveSessionState> {
  final PedometerService pedometerService;
  final Ref ref;
  StreamSubscription<PedometerSessionData>? _sessionSubscription;
  Timer? _timer;

  ActiveSessionNotifier({
    required this.pedometerService,
    required this.ref,
    required Activity activity,
    Asistencia? asistencia,
  }) : super(ActiveSessionState(activity: activity, asistencia: asistencia)) {
    _startSession();
  }

  void _startSession() {
    pedometerService.iniciarSesion();
    _sessionSubscription = pedometerService.sessionStream.listen((data) {
      _updateSessionData(data);
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.isTracking && mounted) {
        final newDuration = state.duration + const Duration(seconds: 1);
        state = state.copyWith(duration: newDuration);
      }
    });
  }

  void _updateSessionData(PedometerSessionData data) {
    if (!mounted) return;

    final targetSteps = 8000;
    final progress = (data.steps / targetSteps).clamp(0.0, 1.0);

    // Calcular insignias desbloqueadas
    final badges = <String>[];
    if (data.steps >= 1) badges.add('Primeros pasos');
    if (data.steps >= 2000) badges.add('Caminante constante');
    if (data.steps >= 8000) badges.add('Jornada intensa');

    state = state.copyWith(
      steps: data.steps,
      distanceKm: data.distanceKm,
      calories: data.calories,
      progressMeta: progress,
      unlockedBadges: badges,
    );
  }

  void addSimulatedSteps(int count) {
    pedometerService.addManualSteps(count);
  }

  Future<Asistencia?> finishSessionAndCheckOut() async {
    final finalData = pedometerService.finalizarSesion();
    _timer?.cancel();

    final repo = ref.read(activityRepositoryProvider);
    final asistenciaId = state.asistencia?.id ?? 'asist-001';

    try {
      final updated = await repo.checkOutAsistencia(
        asistenciaId: asistenciaId,
        pasosSesion: finalData.steps,
        distanciaKm: finalData.distanceKm,
        calorias: finalData.calories,
      );

      final user = ref.read(authProvider).user;
      final horasActividad = state.activity.duracionHoras > 0 ? state.activity.duracionHoras : 4;

      // Generar Certificado Oficial de Participación / Voluntariado
      final certCode = 'FB-VOL-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      final newCert = CertificateModel(
        id: 'cert-vol-${DateTime.now().millisecondsSinceEpoch}',
        tipo: CertificateType.voluntariado,
        titulo: 'Certificado de Voluntariado',
        actividadTitulo: state.activity.titulo,
        horas: horasActividad,
        fechaEmision: DateTime.now(),
        estado: 'aprobado',
        codigoVerificacion: certCode,
        firmadoPor: 'Dra. Elena Ramos - Directora Ejecutiva',
        destinatario: user?.nombreCompleto ?? 'Voluntario Biosferas',
        documentoIdentidad: '1.098.765.432',
      );

      CertificateRemoteDataSourceImpl.addDynamicCertificate(newCert);

      // Actualizar horas acumuladas y certificados del usuario
      if (user != null) {
        final updatedUser = user.copyWith(
          horasAcumuladas: user.horasAcumuladas + horasActividad,
          totalCertificados: user.totalCertificados + 1,
        );
        await ref.read(authProvider.notifier).updateProfile(updatedUser);
      }

      // Refrescar certificados y dashboard
      ref.invalidate(userCertificatesProvider);
      ref.invalidate(dashboardStatsProvider);

      state = state.copyWith(
        isTracking: false,
        isCompleted: true,
        asistencia: updated,
      );
      return updated;
    } catch (_) {
      state = state.copyWith(isTracking: false, isCompleted: true);
      return null;
    }
  }

  @override
  void dispose() {
    _sessionSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }
}

final activeSessionProviderFamily =
    StateNotifierProvider.family<ActiveSessionNotifier, ActiveSessionState, ({Activity activity, Asistencia? asistencia})>(
        (ref, arg) {
  return ActiveSessionNotifier(
    pedometerService: ref.watch(pedometerServiceProvider),
    ref: ref,
    activity: arg.activity,
    asistencia: arg.asistencia,
  );
});
