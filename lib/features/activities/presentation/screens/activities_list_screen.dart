import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/widgets/app_image.dart';
import '../../domain/entities/activity.dart';
import '../providers/activity_provider.dart';
import 'activity_detail_screen.dart';

class ActivitiesListScreen extends ConsumerWidget {
  const ActivitiesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(activitiesListProvider);
    final filter = ref.watch(activityFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final categories = ['Todos', 'Reforestación', 'Reciclaje', 'Conservación', 'Educación', 'Salud', 'Social'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Actividades Disponibles'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Buscador con diseño orgánico
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                onChanged: (val) {
                  ref.read(activityFilterProvider.notifier).state = filter.copyWith(query: val);
                },
                decoration: InputDecoration(
                  hintText: 'Buscar actividad, lugar o temática...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.secondary),
                  suffixIcon: filter.query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            ref.read(activityFilterProvider.notifier).state = filter.copyWith(query: '');
                          },
                        )
                      : null,
                ),
              ),
            ),

            // Chips de categorías filtrables
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = filter.categoria == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: isDark ? AppColors.secondary : AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                    backgroundColor: isDark ? AppColors.cardDark : Colors.white,
                    side: BorderSide(
                      color: isSelected
                          ? Colors.transparent
                          : (isDark ? AppColors.borderDark : AppColors.borderLight),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(activityFilterProvider.notifier).state = filter.copyWith(categoria: cat);
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // Lista de actividades
            Expanded(
              child: activitiesAsync.when(
                data: (activities) {
                  if (activities.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.nature_people_outlined, size: 36, color: AppColors.primary),
                          ),
                          const SizedBox(height: 14),
                          Text('No se encontraron actividades', style: AppStyles.titleSmall),
                          const SizedBox(height: 6),
                          const Text(
                            'Intenta cambiar la categoría o el término de búsqueda.',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => ref.refresh(activitiesListProvider),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        final activity = activities[index];
                        return _ActivityCard(activity: activity);
                      },
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (err, _) => Center(
                  child: Text('Error al cargar actividades: $err'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final Activity activity;

  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLleno = activity.estadoCupos == 'lleno';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: AppStyles.cardRadius,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: AppStyles.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppStyles.cardRadius,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ActivityDetailScreen(activity: activity),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fotografía única de la actividad con IA
                AppImage(
                  imagePathOrUrl: activity.imagenUrl,
                  width: 84,
                  height: 84,
                  borderRadius: BorderRadius.circular(12),
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 14),

                // Información de la actividad
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.titulo,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            '${activity.fecha} · ${activity.hora}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 13, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              activity.ubicacionNombre,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Tag de estado y categoría
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isLleno
                                  ? AppColors.error.withValues(alpha: 0.12)
                                  : AppColors.secondary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isLleno ? 'Lleno' : 'Disponible (${activity.cuposOcupados}/${activity.cuposTotales})',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isLleno ? AppColors.error : AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              activity.categoria,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondaryLight),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
