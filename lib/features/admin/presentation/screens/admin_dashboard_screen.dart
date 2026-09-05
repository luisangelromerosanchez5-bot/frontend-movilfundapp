import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../activities/presentation/providers/activity_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Lista local de postulaciones para gestionar en admin
  final List<Map<String, dynamic>> _adminPostulaciones = [
    {
      'id': 'post-101',
      'voluntario': 'Carlos Alberto Ruiz',
      'correo': 'carlos.ruiz@correo.com',
      'actividad': 'Reforestación Río Bosque',
      'fecha': '2026-09-05',
      'estado': 'Pendiente',
    },
    {
      'id': 'post-102',
      'voluntario': 'María José Gómez',
      'correo': 'maria.gomez@correo.com',
      'actividad': 'Limpieza de Humedal Córdoba',
      'fecha': '2026-09-19',
      'estado': 'Aprobada',
    },
    {
      'id': 'post-103',
      'voluntario': 'Andrés Felipe Castro',
      'correo': 'andres.c@correo.com',
      'actividad': 'Jornada de Reciclaje Urbano',
      'fecha': '2026-09-11',
      'estado': 'Pendiente',
    },
  ];

  // Lista de auditoría de asistencias
  final List<Map<String, dynamic>> _adminAsistencias = [
    {
      'id': 'asist-01',
      'voluntario': 'Luis Fernando Pérez',
      'actividad': 'Reforestación Río Bosque',
      'fecha': '2026-08-31',
      'pasos': 6482,
      'distancia_km': 4.6,
      'gps_precision': 'Alta (38m)',
      'foto_evidencia': 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=600',
    },
    {
      'id': 'asist-02',
      'voluntario': 'Camila Torres',
      'actividad': 'Recuperación de Humedales',
      'fecha': '2026-08-28',
      'pasos': 8210,
      'distancia_km': 5.8,
      'gps_precision': 'Alta (12m)',
      'foto_evidencia': 'https://images.unsplash.com/photo-1618477461853-cf6ed80faba5?w=600',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCreateActivityModal() {
    final formKey = GlobalKey<FormState>();
    final tituloCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final categoriaCtrl = TextEditingController(text: 'Reforestación');
    final fechaCtrl = TextEditingController(text: '2026-10-10');
    final horaCtrl = TextEditingController(text: '08:00 AM');
    final cuposCtrl = TextEditingController(text: '30');
    final ubicacionCtrl = TextEditingController(text: 'Parque Ecológico Central');
    final latCtrl = TextEditingController(text: '4.7110');
    final lngCtrl = TextEditingController(text: '-74.0721');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          left: 24,
          right: 24,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Nueva Actividad de Voluntariado', style: AppStyles.titleSmall),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: tituloCtrl,
                  decoration: const InputDecoration(labelText: 'Título de la actividad *'),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Descripción del impacto ambiental *'),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: categoriaCtrl,
                        decoration: const InputDecoration(labelText: 'Categoría'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: cuposCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Cupos'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: fechaCtrl,
                        decoration: const InputDecoration(labelText: 'Fecha (AAAA-MM-DD)'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: horaCtrl,
                        decoration: const InputDecoration(labelText: 'Hora'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: ubicacionCtrl,
                  decoration: const InputDecoration(labelText: 'Ubicación / Punto de encuentro'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: latCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Latitud GPS'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: lngCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Longitud GPS'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      Navigator.pop(ctx);
                      ref.invalidate(activitiesListProvider);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('¡Actividad creada y publicada exitosamente!'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Publicar Actividad'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.admin_panel_settings_rounded, color: AppColors.secondary, size: 24),
            SizedBox(width: 8),
            Text('Panel Administrativo'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            tooltip: 'Cerrar sesión admin',
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.secondary,
          unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          indicatorColor: AppColors.secondary,
          tabs: const [
            Tab(text: 'Métricas'),
            Tab(text: 'Actividades'),
            Tab(text: 'Postulaciones'),
            Tab(text: 'Asistencias'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMetricsTab(isDark),
          _buildActivitiesTab(isDark),
          _buildPostulacionesTab(isDark),
          _buildAsistenciasTab(isDark),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateActivityModal,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Crear Actividad', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildMetricsTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen Ecosocial Global',
            style: AppStyles.titleMedium.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Métricas consolidadas de la Fundación Biosferas',
            style: TextStyle(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
          ),
          const SizedBox(height: 18),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.25,
            children: [
              _buildMetricCard('Voluntarios', '42', Icons.people_outline_rounded, AppColors.secondary, isDark),
              _buildMetricCard('Recaudado', '\$3.45M', Icons.favorite_outline_rounded, AppColors.accent, isDark),
              _buildMetricCard('Actividades', '31', Icons.forest_outlined, AppColors.primaryLight, isDark),
              _buildMetricCard('Asistencias', '88', Icons.how_to_reg_outlined, AppColors.info, isDark),
            ],
          ),
          const SizedBox(height: 24),

          // Indicador de impacto ambiental
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: AppStyles.cardRadius,
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              boxShadow: AppStyles.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.eco_rounded, color: AppColors.secondary),
                    SizedBox(width: 8),
                    Text(
                      'Impacto Ambiental Acumulado',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildImpactRow('Árboles nativos plantados:', '1.250 árboles', isDark),
                const Divider(),
                _buildImpactRow('Material reciclado recuperado:', '3.840 kg', isDark),
                const Divider(),
                _buildImpactRow('Horas de voluntariado totales:', '352 horas', isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: AppStyles.cardRadius,
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        boxShadow: AppStyles.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 26),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImpactRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          Text(value, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildActivitiesTab(bool isDark) {
    final activitiesAsync = ref.watch(activitiesListProvider);
    return activitiesAsync.when(
      data: (activities) => ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        itemCount: activities.length,
        itemBuilder: (ctx, index) {
          final act = activities[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: AppStyles.cardRadius),
            color: isDark ? AppColors.cardDark : Colors.white,
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  act.imagenUrl ?? 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=200',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.forest),
                ),
              ),
              title: Text(act.titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text('${act.fecha} · ${act.cuposOcupados}/${act.cuposTotales} cupos', style: const TextStyle(fontSize: 12)),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: act.estadoCupos == 'lleno' ? AppColors.error.withValues(alpha: 0.15) : AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  act.estadoCupos == 'lleno' ? 'Lleno' : 'Activo',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: act.estadoCupos == 'lleno' ? AppColors.error : AppColors.primary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildPostulacionesTab(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      itemCount: _adminPostulaciones.length,
      itemBuilder: (ctx, index) {
        final post = _adminPostulaciones[index];
        final isPendiente = post['estado'] == 'Pendiente';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: AppStyles.cardRadius),
          color: isDark ? AppColors.cardDark : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(post['voluntario'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(
                      post['estado'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: post['estado'] == 'Aprobada' ? AppColors.secondary : AppColors.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(post['actividad'], style: TextStyle(fontSize: 13, color: isDark ? AppColors.secondaryLight : AppColors.primary)),
                Text('${post['correo']} · ${post['fecha']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                if (isPendiente) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            post['estado'] = 'Rechazada';
                          });
                        },
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                        child: const Text('Rechazar'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            post['estado'] = 'Aprobada';
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Postulación de ${post['voluntario']} aprobada.')),
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        child: const Text('Aprobar'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAsistenciasTab(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      itemCount: _adminAsistencias.length,
      itemBuilder: (ctx, index) {
        final asist = _adminAsistencias[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: AppStyles.cardRadius),
          color: isDark ? AppColors.cardDark : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(asist['voluntario'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Row(
                      children: const [
                        Icon(Icons.check_circle_rounded, color: AppColors.secondary, size: 16),
                        SizedBox(width: 4),
                        Text('Check-out OK', style: TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(asist['actividad'], style: TextStyle(fontSize: 13, color: isDark ? AppColors.secondaryLight : AppColors.primary)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text('👣 ${AppFormatters.formatNumber(asist['pasos'])} pasos', style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 12),
                    Text('📏 ${asist['distancia_km']} km', style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 12),
                    Text('📍 GPS ${asist['gps_precision']}', style: const TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (dialogCtx) => Dialog(
                        shape: RoundedRectangleBorder(borderRadius: AppStyles.cardRadius),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: Image.network(asist['foto_evidencia'], fit: BoxFit.cover),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'Evidencia fotográfica: ${asist['voluntario']}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: const [
                      Icon(Icons.camera_alt_outlined, color: AppColors.primary, size: 16),
                      SizedBox(width: 6),
                      Text('Ver foto de evidencia capturada', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
