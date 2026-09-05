import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../activities/presentation/providers/activity_provider.dart';
import '../../../activities/presentation/screens/check_in_screen.dart';

class MyPostulacionesScreen extends ConsumerWidget {
  const MyPostulacionesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postulacionesAsync = ref.watch(userPostulacionesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Postulaciones'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.refresh(userPostulacionesProvider),
          child: postulacionesAsync.when(
            data: (postulaciones) {
              if (postulaciones.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.assignment_outlined,
                            size: 36,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tienes postulaciones activas',
                          textAlign: TextAlign.center,
                          style: AppStyles.titleSmall.copyWith(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Explora las actividades ambientales en la pestaña "Actividades" y postúlate como voluntario.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                itemCount: postulaciones.length,
                itemBuilder: (context, index) {
                  final post = postulaciones[index];
                  final isAprobada = post.estado.toLowerCase() == 'aprobada';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.white,
                      borderRadius: AppStyles.cardRadius,
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                      boxShadow: AppStyles.softShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isAprobada
                                    ? AppColors.secondary.withValues(alpha: 0.15)
                                    : AppColors.accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isAprobada ? 'Postulación Aprobada' : 'En revisión',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: isAprobada ? AppColors.primary : AppColors.accentDark,
                                ),
                              ),
                            ),
                            const Icon(Icons.forest_rounded, color: AppColors.primary, size: 20),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          post.actividadTitulo,
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              '${post.actividadFecha} · ${post.actividadHora}',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                post.actividadUbicacion,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final act = await ref.read(activityDetailProvider(post.actividadId).future);
                            if (act != null && context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CheckInScreen(activity: act),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.gps_fixed_rounded, size: 16),
                          label: const Text('Ir a Check-in GPS'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark ? AppColors.secondaryLight : AppColors.primary,
                            side: BorderSide(
                              color: isDark ? AppColors.secondary : AppColors.primary,
                            ),
                            minimumSize: const Size.fromHeight(38),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (err, _) => Center(
              child: Text('Error al cargar postulaciones: $err'),
            ),
          ),
        ),
      ),
    );
  }
}
