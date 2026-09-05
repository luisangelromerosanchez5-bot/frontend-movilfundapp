import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/botanical_decorations.dart';

class AnnualGoalCard extends StatelessWidget {
  final int horasCompletadas;
  final int metaTotalHoras;

  const AnnualGoalCard({
    super.key,
    required this.horasCompletadas,
    required this.metaTotalHoras,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = metaTotalHoras > 0 ? (horasCompletadas / metaTotalHoras).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).round();

    return BotanicalCard(
      padding: const EdgeInsets.all(18),
      showLeaves: true,
      child: Row(
        children: [
          // Indicador circular de progreso con porcentaje
          SizedBox(
            width: 62,
            height: 62,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6.5,
                  backgroundColor: isDark ? AppColors.borderDark : AppColors.secondaryUltraLight,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? AppColors.secondary : AppColors.primary,
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$percentage%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          // Textos informativos y badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.eco_rounded, size: 16, color: AppColors.secondary),
                    const SizedBox(width: 6),
                    Text(
                      'Meta de Voluntariado',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  '$horasCompletadas de $metaTotalHoras horas ecológicas acumuladas',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
