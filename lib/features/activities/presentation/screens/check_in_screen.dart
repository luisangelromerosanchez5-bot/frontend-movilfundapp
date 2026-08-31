import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../domain/entities/activity.dart';
import '../providers/checkin_provider.dart';
import 'active_activity_screen.dart';

class CheckInScreen extends ConsumerWidget {
  final Activity activity;

  const CheckInScreen({super.key, required this.activity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkInState = ref.watch(checkInProviderFamily(activity));
    final checkInNotifier = ref.read(checkInProviderFamily(activity).notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in de actividad'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Botón para alternar simulación de proximidad (fines de demostración técnica)
          PopupMenuButton<bool>(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Simulador GPS',
            onSelected: (inside) {
              checkInNotifier.simulateProximity(inside: inside);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: true,
                child: Text('📍 Simular dentro de radio (38m)'),
              ),
              const PopupMenuItem(
                value: false,
                child: Text('🚫 Simular fuera de radio (450m)'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Subtítulo de actividad
              Text(
                '${activity.titulo} · ${activity.fecha}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24),

              // Visualizador de Geofencing / Radar de ubicación
              Center(
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    color: checkInState.isInside
                        ? AppColors.secondaryUltraLight.withValues(alpha: 0.8)
                        : AppColors.error.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: checkInState.isInside
                          ? AppColors.secondary
                          : AppColors.error.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Círculo concéntrico
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (checkInState.isInside ? AppColors.secondary : AppColors.error)
                              .withValues(alpha: 0.15),
                        ),
                      ),
                      // Pin de ubicación central
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: checkInState.isInside ? AppColors.primary : AppColors.error,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (checkInState.isInside ? AppColors.primary : AppColors.error)
                                  .withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Estado de proximidad
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    checkInState.isInside ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                    color: checkInState.isInside ? AppColors.primary : AppColors.error,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    checkInState.isInside
                        ? 'Estás dentro del punto de encuentro'
                        : 'Estás fuera del radio permitido',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: checkInState.isInside ? AppColors.primary : AppColors.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tabla de métricas GPS
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: AppStyles.cardRadius,
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Column(
                  children: [
                    _buildMetricRow(
                      'Distancia al punto',
                      '${checkInState.distanceMeters} m',
                      isDark,
                    ),
                    const Divider(),
                    _buildMetricRow(
                      'Radio permitido',
                      '${checkInState.allowedRadiusMeters} m',
                      isDark,
                    ),
                    const Divider(),
                    _buildMetricRow(
                      'Precisión GPS',
                      checkInState.precisionGps,
                      isDark,
                      valueColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Botón Marcar Asistencia
              ElevatedButton(
                onPressed: (!checkInState.isInside || checkInState.isLoading)
                    ? null
                    : () async {
                        final asistencia = await checkInNotifier.submitCheckIn();
                        if (asistencia != null && context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ActiveActivityScreen(
                                activity: activity,
                                asistencia: asistencia,
                              ),
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: checkInState.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Marcar asistencia'),
              ),
              const SizedBox(height: 12),

              // Leyenda inferior
              Text(
                'Se registrará tu ubicación y hora exacta para validar tu certificado',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, bool isDark, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: valueColor ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
            ),
          ),
        ],
      ),
    );
  }
}
