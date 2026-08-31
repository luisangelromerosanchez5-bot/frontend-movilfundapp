import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/volunteer_stats.dart';

final dashboardStatsProvider = FutureProvider<VolunteerStats>((ref) async {
  final authState = ref.watch(authProvider);
  final user = authState.user;

  if (user != null) {
    return VolunteerStats(
      horasAcumuladas: user.horasAcumuladas,
      totalCertificados: user.totalCertificados,
      totalDonaciones: user.totalDonaciones,
      metaAnualHoras: user.metaAnualHoras,
    );
  }

  return const VolunteerStats(
    horasAcumuladas: 0,
    totalCertificados: 0,
    totalDonaciones: 0.0,
    metaAnualHoras: 20,
  );
});
