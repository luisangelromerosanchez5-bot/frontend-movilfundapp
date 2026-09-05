import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/widgets/botanical_decorations.dart';
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
          color: AppColors.primary,
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
                // Header de bienvenida botánico
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Hola, $userName',
                              style: AppStyles.titleLarge.copyWith(
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.spa_rounded, color: AppColors.secondary, size: 22),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Bienvenido a tu impacto ecosocial 🌱',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondaryLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.15),
                            AppColors.secondary.withValues(alpha: 0.25),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(Icons.eco_rounded, color: AppColors.primary, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Fila de Estadísticas Rápidas con Iconos de la Naturaleza
                statsAsync.when(
                  data: (stats) => Row(
                    children: [
                      StatCard(
                        value: '${stats.horasAcumuladas}h',
                        label: 'Horas',
                        icon: Icons.schedule_rounded,
                      ),
                      const SizedBox(width: 10),
                      StatCard(
                        value: '${stats.totalCertificados}',
                        label: 'Certificados',
                        icon: Icons.workspace_premium_rounded,
                      ),
                      const SizedBox(width: 10),
                      StatCard(
                        value: stats.totalDonaciones >= 1000
                            ? '\$${(stats.totalDonaciones / 1000).toStringAsFixed(0)}K'
                            : '\$0',
                        label: 'Donaciones',
                        icon: Icons.volunteer_activism_rounded,
                      ),
                    ],
                  ),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
                  error: (error, stackTrace) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 16),

                // Meta anual de voluntariado con tarjeta botánica
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
                    Row(
                      children: [
                        const Icon(Icons.forest_rounded, size: 20, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Próximas actividades',
                          style: AppStyles.titleSmall.copyWith(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: onNavigateToActivities,
                      child: Row(
                        children: [
                          Text(
                            'Ver todas',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.secondaryLight : AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primary),
                        ],
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
                        return BotanicalCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          showLeaves: true,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ActivityDetailScreen(activity: act),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.park_rounded, color: AppColors.primary, size: 26),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        act.titulo,
                                        style: TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.textSecondaryLight),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${act.fecha} · ${act.hora}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 15,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
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
