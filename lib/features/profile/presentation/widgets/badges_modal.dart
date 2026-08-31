import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/network/mock_data.dart';

class BadgesModal extends StatelessWidget {
  const BadgesModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: AppStyles.modalRadius),
      builder: (_) => const BadgesModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final badges = MockData.sampleBadges;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scrollController) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: ListView(
          controller: scrollController,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Insignias de esfuerzo físico e impacto',
              style: AppStyles.titleMedium.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Otorgadas automáticamente durante el monitoreo de pasos en jornadas de voluntariado.',
              style: TextStyle(
                fontSize: 12.5,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 20),

            ...badges.map((badge) {
              final obtenida = badge['obtenida'] as bool;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: AppStyles.cardRadius,
                  border: Border.all(
                    color: obtenida
                        ? AppColors.secondary.withValues(alpha: 0.5)
                        : (isDark ? AppColors.borderDark : AppColors.borderLight),
                    width: obtenida ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: obtenida
                            ? AppColors.secondaryUltraLight
                            : (isDark ? AppColors.borderDark : Colors.grey.shade100),
                      ),
                      child: Icon(
                        obtenida ? Icons.workspace_premium_rounded : Icons.lock_outline_rounded,
                        color: obtenida ? AppColors.primary : AppColors.textSecondaryLight,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            badge['nombre'],
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            badge['descripcion'],
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (obtenida)
                      const Icon(Icons.check_circle_rounded, color: AppColors.secondary, size: 20),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
