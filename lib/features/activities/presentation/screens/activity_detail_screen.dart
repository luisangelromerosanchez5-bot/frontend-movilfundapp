import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/activity.dart';
import '../providers/activity_provider.dart';
import 'check_in_screen.dart';

class ActivityDetailScreen extends ConsumerStatefulWidget {
  final Activity activity;

  const ActivityDetailScreen({super.key, required this.activity});

  @override
  ConsumerState<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends ConsumerState<ActivityDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombresController;
  late TextEditingController _correoController;
  bool _isSubmitting = false;
  bool _isRegistered = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nombresController = TextEditingController(text: user?.nombreCompleto ?? 'Luis Fernando Pérez');
    _correoController = TextEditingController(text: user?.correo ?? 'luis@correo.com');
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  Future<void> _handlePostulacion() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);
      final user = ref.read(authProvider).user;
      final repo = ref.read(activityRepositoryProvider);

      final success = await repo.postularseActividad(
        actividadId: widget.activity.id,
        usuarioId: user?.id ?? '1',
        nombres: _nombresController.text,
        correo: _correoController.text,
        actividadTitulo: widget.activity.titulo,
        actividadFecha: widget.activity.fecha,
        actividadHora: widget.activity.hora,
        actividadUbicacion: widget.activity.ubicacionNombre,
      );

      setState(() {
        _isSubmitting = false;
        _isRegistered = success;
      });

      if (!mounted) return;
      if (success) {
        ref.invalidate(activitiesListProvider);
        ref.invalidate(userPostulacionesProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Postulación confirmada con éxito! Puedes verla en tu perfil.'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity.titulo),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner / Imagen de la actividad
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  image: widget.activity.imagenUrl != null
                      ? DecorationImage(
                          image: NetworkImage(widget.activity.imagenUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: widget.activity.imagenUrl == null
                    ? const Center(
                        child: Icon(Icons.forest_rounded, size: 64, color: AppColors.primary),
                      )
                    : null,
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Text(
                      widget.activity.titulo,
                      style: AppStyles.titleLarge.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Metadatos
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.activity.ubicacionNombre,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.activity.fecha} · ${widget.activity.hora}',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Descripción
                    Text(
                      widget.activity.descripcion,
                      style: AppStyles.bodyMedium.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botón para acceder directamente a Check-in GPS
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryUltraLight.withValues(alpha: isDark ? 0.15 : 0.8),
                        borderRadius: AppStyles.cardRadius,
                        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.gps_fixed_rounded, color: AppColors.primary, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '¿Ya estás en el lugar?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.primaryDark,
                                  ),
                                ),
                                const Text(
                                  'Valida tu GPS y marca asistencia',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CheckInScreen(activity: widget.activity),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              minimumSize: const Size(90, 36),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            child: const Text('Check-in', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Formulario de postulación prellenado
                    Text(
                      'Formulario de postulación',
                      style: AppStyles.titleSmall.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 14),

                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'NOMBRES Y APELLIDOS',
                            style: AppStyles.labelUppercase.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nombresController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                            ),
                          ),
                          const SizedBox(height: 16),

                          Text(
                            'CORREO ELECTRÓNICO',
                            style: AppStyles.labelUppercase.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _correoController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.mail_outline_rounded, size: 20),
                            ),
                          ),
                          const SizedBox(height: 24),

                          ElevatedButton(
                            onPressed: (_isSubmitting || _isRegistered || widget.activity.estadoCupos == 'lleno')
                                ? null
                                : _handlePostulacion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Text(
                                    _isRegistered
                                        ? '¡Ya estás postulado!'
                                        : widget.activity.estadoCupos == 'lleno'
                                            ? 'Cupos agotados'
                                            : 'Postularme a esta actividad',
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
