import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCompletoController;
  late TextEditingController _cedulaController;
  late TextEditingController _telefonoController;
  late TextEditingController _correoController;
  late TextEditingController _ciudadController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nombreCompletoController = TextEditingController(text: user?.nombreCompleto ?? 'Luis Fernando Pérez Gómez');
    _cedulaController = TextEditingController(text: '1.098.765.432');
    _telefonoController = TextEditingController(text: user?.telefono ?? '3124567890');
    _correoController = TextEditingController(text: user?.correo ?? 'luis@correo.com');
    _ciudadController = TextEditingController(text: 'Bogotá D.C.');
  }

  @override
  void dispose() {
    _nombreCompletoController.dispose();
    _cedulaController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    _ciudadController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSaving = true);
      final currentUser = ref.read(authProvider).user;
      if (currentUser != null) {
        final updated = currentUser.copyWith(
          telefono: _telefonoController.text.trim(),
          correo: _correoController.text.trim(),
        );
        await ref.read(authProvider.notifier).updateProfile(updated);
      }
      setState(() => _isSaving = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Datos de contacto actualizados exitosamente'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar datos personales'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // AVISO DE IDENTIDAD INMUTABLE
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.secondaryUltraLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.shield_outlined, color: AppColors.secondary, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Por seguridad institucional, los nombres y la cédula no pueden modificarse tras el registro.',
                          style: TextStyle(fontSize: 12, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // NOMBRE COMPLETO (BLOQUEADO / READ-ONLY)
                Row(
                  children: [
                    Text(
                      'NOMBRE COMPLETO',
                      style: AppStyles.labelUppercase.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.lock_rounded, size: 14, color: AppColors.textSecondaryLight),
                  ],
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nombreCompletoController,
                  readOnly: true,
                  enabled: false,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                    suffixIcon: const Tooltip(
                      message: 'Campo inmutable',
                      child: Icon(Icons.lock_outline_rounded, size: 18),
                    ),
                    fillColor: isDark ? Colors.black26 : Colors.grey.shade100,
                    filled: true,
                  ),
                ),
                const SizedBox(height: 16),

                // CÉDULA / IDENTIFICACIÓN (BLOQUEADO / READ-ONLY)
                Row(
                  children: [
                    Text(
                      'NÚMERO DE IDENTIFICACIÓN (CÉDULA)',
                      style: AppStyles.labelUppercase.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.lock_rounded, size: 14, color: AppColors.textSecondaryLight),
                  ],
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _cedulaController,
                  readOnly: true,
                  enabled: false,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                    suffixIcon: const Tooltip(
                      message: 'Campo inmutable',
                      child: Icon(Icons.lock_outline_rounded, size: 18),
                    ),
                    fillColor: isDark ? Colors.black26 : Colors.grey.shade100,
                    filled: true,
                  ),
                ),
                const SizedBox(height: 16),

                // TELÉFONO / CELULAR (EDITABLE - SOLO NÚMEROS)
                Text(
                  'TELÉFONO / CELULAR DE CONTACTO',
                  style: AppStyles.labelUppercase.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _telefonoController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Ingresa tu teléfono';
                    if (v.trim().length < 7) return 'Debe tener al menos 7 dígitos';
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: '3124567890',
                    prefixIcon: Icon(Icons.phone_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 16),

                // CORREO ELECTRÓNICO DE CONTACTO (EDITABLE)
                Text(
                  'CORREO ELECTRÓNICO DE CONTACTO',
                  style: AppStyles.labelUppercase.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _correoController,
                  keyboardType: TextInputType.emailAddress,
                  validator: AppValidators.validateEmail,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.mail_outline_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: 16),

                // CIUDAD / DIRECCIÓN (EDITABLE)
                Text(
                  'CIUDAD / RESIDENCIA',
                  style: AppStyles.labelUppercase.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _ciudadController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.location_city_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 32),

                // BOTÓN GUARDAR
                ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Guardar cambios'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
