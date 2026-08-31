import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../certificates/domain/entities/certificate.dart';
import '../../../certificates/presentation/screens/certificate_pdf_viewer_screen.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/asistencia.dart';
import '../providers/pedometer_provider.dart';

class ActiveActivityScreen extends ConsumerWidget {
  final Activity activity;
  final Asistencia? asistencia;

  const ActiveActivityScreen({
    super.key,
    required this.activity,
    this.asistencia,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(
      activeSessionProviderFamily((activity: activity, asistencia: asistencia)),
    );
    final sessionNotifier = ref.read(
      activeSessionProviderFamily((activity: activity, asistencia: asistencia)).notifier,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;

    return PopScope(
      canPop: !sessionState.isTracking,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('La actividad está en curso. Realiza check-out para finalizarla.'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Actividad en curso'),
          automaticallyImplyLeading: false,
          actions: [
            // Botón de prueba para simular pasos durante demostración
            IconButton(
              icon: const Icon(Icons.directions_walk_rounded),
              tooltip: '+500 pasos (Demo)',
              onPressed: () {
                sessionNotifier.addSimulatedSteps(500);
              },
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Título y badge En Vivo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        activity.titulo,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'En vivo · ${AppFormatters.formatDuration(sessionState.duration)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Contador de Podómetro Circular Principal
                Center(
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? AppColors.cardDark : Colors.white,
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.4),
                        width: 8,
                      ),
                      boxShadow: AppStyles.elevatedShadow,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppFormatters.formatNumber(sessionState.steps),
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.secondaryLight : AppColors.primary,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'PASOS REGISTRADOS',
                          style: AppStyles.labelUppercase.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Fila de Métricas Secundarias
                Row(
                  children: [
                    _buildSubMetric(
                      '${sessionState.distanceKm.toStringAsFixed(1)} km',
                      'Distancia est.',
                      isDark,
                    ),
                    const SizedBox(width: 10),
                    _buildSubMetric(
                      '${sessionState.duration.inMinutes} min',
                      'Tiempo activo',
                      isDark,
                    ),
                    const SizedBox(width: 10),
                    _buildSubMetric(
                      '${(sessionState.progressMeta * 100).round()}%',
                      'Meta personal',
                      isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Sección: Insignias de esta jornada
                Text(
                  'Insignias de esta jornada',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 12),

                // Lista horizontal de insignias
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBadgeItem(
                      'Primeros pasos',
                      Icons.directions_walk_rounded,
                      sessionState.unlockedBadges.contains('Primeros pasos'),
                      '1+ pasos',
                      isDark,
                    ),
                    _buildBadgeItem(
                      'Caminante',
                      Icons.nordic_walking_rounded,
                      sessionState.unlockedBadges.contains('Caminante constante'),
                      '2.000+ pasos',
                      isDark,
                    ),
                    _buildBadgeItem(
                      'Intensa',
                      Icons.local_fire_department_rounded,
                      sessionState.unlockedBadges.contains('Jornada intensa'),
                      '8.000+ pasos',
                      isDark,
                    ),
                    _buildBadgeItem(
                      'Top Mes',
                      Icons.emoji_events_rounded,
                      false,
                      'Top ranking',
                      isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 36),

                // Botón Finalizar y hacer check-out
                ElevatedButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: AppStyles.cardRadius),
                        title: const Text('¿Finalizar jornada?'),
                        content: Text(
                          'Se completará tu registro de ${AppFormatters.formatNumber(sessionState.steps)} pasos (${sessionState.distanceKm.toStringAsFixed(1)} km) y se generará tu Certificado Oficial de Voluntariado.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Continuar actividad'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                            child: const Text('Finalizar y Generar Certificado'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      await sessionNotifier.finishSessionAndCheckOut();
                      if (context.mounted) {
                        final horasAct = activity.duracionHoras > 0 ? activity.duracionHoras : 4;
                        final certCode = 'FB-VOL-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
                        final cert = Certificate(
                          id: 'cert-vol-${DateTime.now().millisecondsSinceEpoch}',
                          tipo: CertificateType.voluntariado,
                          titulo: 'Certificado de Voluntariado',
                          actividadTitulo: activity.titulo,
                          horas: horasAct,
                          fechaEmision: DateTime.now(),
                          estado: 'aprobado',
                          codigoVerificacion: certCode,
                          firmadoPor: 'Dra. Elena Ramos - Directora Ejecutiva',
                          destinatario: user?.nombreCompleto ?? 'Voluntario Biosferas',
                          documentoIdentidad: '1.098.765.432',
                        );

                        // Mostrar modal con opción de descargar PDF o volver
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (dialogCtx) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: AppStyles.cardRadius),
                            title: Row(
                              children: const [
                                Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 28),
                                SizedBox(width: 10),
                                Text('¡Jornada Exitosa!'),
                              ],
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Has acumulado $horasAct horas de voluntariado en "${activity.titulo}".',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Tu certificado de participación ha sido generado y ya está disponible en la pestaña Certificados.',
                                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondaryLight),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogCtx);
                                  Navigator.pop(context);
                                },
                                child: const Text('Ir al inicio'),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(dialogCtx);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CertificatePdfViewerScreen(certificate: cert),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                                label: const Text('Ver Certificado PDF'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text('Finalizar y hacer check-out'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubMetric(String value, String label, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: AppStyles.cardRadius,
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeItem(String name, IconData icon, bool unlocked, String subtitle, bool isDark) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: unlocked
                ? AppColors.accent.withValues(alpha: 0.2)
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            border: Border.all(
              color: unlocked ? AppColors.accent : Colors.transparent,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: unlocked ? AppColors.accentDark : AppColors.textSecondaryLight,
            size: 26,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: unlocked
                ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                : AppColors.textSecondaryLight,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 9, color: AppColors.textSecondaryLight),
        ),
      ],
    );
  }
}
