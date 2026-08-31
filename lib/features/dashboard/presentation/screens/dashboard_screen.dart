import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../activities/presentation/providers/activity_provider.dart';
import '../../../activities/presentation/screens/activity_detail_screen.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/annual_goal_card.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends ConsumerWidget {
  final VoidCallback? onNavigateToActivities;

  const DashboardScreen({super.key, this.onNavigateToActivities});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final activitiesAsync = ref.watch(activitiesListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final userName = authState.user?.nombres.split(' ').first ?? 'Voluntario';

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardStatsProvider);
            ref.invalidate(activitiesListProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header de bienvenida
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hola, $userName 👋',
                      style: AppStyles.titleLarge.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.eco_rounded, color: AppColors.primary, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Fila de Estadísticas Rápidas
                statsAsync.when(
                  data: (stats) => Row(
                    children: [
                      StatCard(value: '${stats.horasAcumuladas}h', label: 'Horas'),
                      const SizedBox(width: 10),
                      StatCard(value: '${stats.totalCertificados}', label: 'Certificados'),
                      const SizedBox(width: 10),
                      StatCard(
                        value: stats.totalDonaciones >= 1000
                            ? '\$${(stats.totalDonaciones / 1000).toStringAsFixed(0)}K'
                            : '\$0',
                        label: 'Donado',
                      ),
                    ],
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 16),

                // Meta anual de voluntariado
                statsAsync.when(
                  data: (stats) => AnnualGoalCard(
                    horasCompletadas: stats.horasAcumuladas,
                    metaTotalHoras: stats.metaAnualHoras,
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (error, stackTrace) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 26),

                // Sección Próximas Actividades
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Próximas actividades',
                      style: AppStyles.titleSmall.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    TextButton(
                      onPressed: onNavigateToActivities,
                      child: Text(
                        'Ver todas',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.secondaryLight : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Listado de próximas actividades
                activitiesAsync.when(
                  data: (activities) {
                    final upcoming = activities.take(3).toList();
                    return Column(
                      children: upcoming.map((act) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : Colors.white,
                            borderRadius: AppStyles.cardRadius,
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.forest_rounded, color: AppColors.primary),
                            ),
                            title: Text(
                              act.titulo,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                            subtitle: Text(
                              '${act.fecha} · ${act.hora}',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 15,
                              color: AppColors.textSecondaryLight,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ActivityDetailScreen(activity: act),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error al cargar actividades: $e'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
