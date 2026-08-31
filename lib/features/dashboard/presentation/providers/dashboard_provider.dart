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
    horasAcumuladas: 14,
    totalCertificados: 3,
    totalDonaciones: 120000.0,
    metaAnualHoras: 20,
  );
});
