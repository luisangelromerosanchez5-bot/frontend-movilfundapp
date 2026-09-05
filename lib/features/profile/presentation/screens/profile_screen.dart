import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/widgets/botanical_decorations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/badges_modal.dart';
import '../widgets/profile_avatar.dart';
import 'edit_profile_screen.dart';
import 'my_postulaciones_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = authState.user;

    final userInitials = (user != null && user.nombres.isNotEmpty)
        ? '${user.nombres[0]}${user.apellidos.isNotEmpty ? user.apellidos[0] : ''}'
        : 'LF';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tarjeta Botánica con Avatar y Badges de Naturaleza
              BotanicalCard(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                showLeaves: true,
                child: Column(
                  children: [
                    ProfileAvatar(
                      userId: user?.id ?? user?.correo,
                      initialPhotoPath: user?.fotoUrl,
                      initials: userInitials,
                      onPhotoChanged: (path) {
                        if (user != null) {
                          ref.read(authProvider.notifier).updateProfile(user.copyWith(fotoUrl: path));
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    // Nombre de usuario
                    Text(
                      user?.nombreCompleto ?? 'Luis Fernando Pérez',
                      textAlign: TextAlign.center,
                      style: AppStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 3),

                    // Correo electrónico
                    Text(
                      user?.correo ?? 'luis@correo.com',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Badges botánicos de impacto ecológico
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: const [
                        LeafTag(text: 'Voluntario Activo', icon: Icons.eco_rounded),
                        LeafTag(text: 'Protector de Bosques', icon: Icons.park_rounded, color: AppColors.primary),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Opciones del perfil
              _buildOptionCard(
                context: context,
                isDark: isDark,
                icon: Icons.person_outline_rounded,
                title: 'Editar datos personales',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                  );
                },
              ),
              const SizedBox(height: 10),

              _buildOptionCard(
                context: context,
                isDark: isDark,
                icon: Icons.assignment_turned_in_outlined,
                title: 'Mis postulaciones a actividades',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyPostulacionesScreen()),
                  );
                },
              ),
              const SizedBox(height: 10),

              _buildOptionCard(
                context: context,
                isDark: isDark,
                icon: Icons.emoji_events_outlined,
                title: 'Insignias y esfuerzo físico',
                onTap: () => BadgesModal.show(context),
              ),
              const SizedBox(height: 10),

              _buildOptionCard(
                context: context,
                isDark: isDark,
                icon: Icons.notifications_none_rounded,
                title: 'Notificaciones',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notificaciones activas para avisos de voluntariado'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              _buildOptionCard(
                context: context,
                isDark: isDark,
                icon: Icons.lock_outline_rounded,
                title: 'Seguridad y contraseña',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: AppStyles.cardRadius),
                      title: const Text('Seguridad de la cuenta'),
                      content: const Text(
                        'Tu cuenta cuenta con autenticación segura JWT y cifrado de extremo a extremo.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Aceptar'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              // Switch de Tema Claro / Oscuro
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: AppStyles.cardRadius,
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  leading: Icon(
                    isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                    color: isDark ? AppColors.secondary : AppColors.primary,
                  ),
                  title: Text(
                    'Tema (${isDark ? 'Oscuro' : 'Claro'})',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  trailing: Switch(
                    value: isDark,
                    activeThumbColor: AppColors.secondary,
                    onChanged: (_) {
                      ref.read(themeModeProvider.notifier).toggleTheme();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),

              _buildOptionCard(
                context: context,
                isDark: isDark,
                icon: Icons.help_outline_rounded,
                title: 'Ayuda y soporte',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: AppStyles.cardRadius),
                      title: const Text('Fundación Biosferas'),
                      content: const Text(
                        'FundAPP Móvil v1.0.0\n\nContacto de soporte:\nsoporte@fundacionbiosferas.org\nTel: +57 (601) 789 0000',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Entendido'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Botón Cerrar sesión
              OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: AppStyles.cardRadius),
                      title: const Text('Cerrar sesión'),
                      content: const Text('¿Estás seguro de que deseas salir de FundAPP?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                          child: const Text('Cerrar sesión'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await ref.read(authProvider.notifier).logout();
                  }
                },
                icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
                label: const Text('Cerrar sesión', style: TextStyle(color: AppColors.error)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: AppStyles.cardRadius,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Icon(icon, color: isDark ? AppColors.secondary : AppColors.primary),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondaryLight),
      ),
    );
  }
}
