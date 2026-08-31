import 'package:flutter/material.dart';
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
  late TextEditingController _nombresController;
  late TextEditingController _apellidosController;
  late TextEditingController _telefonoController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nombresController = TextEditingController(text: user?.nombres ?? '');
    _apellidosController = TextEditingController(text: user?.apellidos ?? '');
    _telefonoController = TextEditingController(text: user?.telefono ?? '');
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSaving = true);
      final currentUser = ref.read(authProvider).user;
      if (currentUser != null) {
        final updated = currentUser.copyWith(
          nombres: _nombresController.text.trim(),
          apellidos: _apellidosController.text.trim(),
          telefono: _telefonoController.text.trim(),
        );
        await ref.read(authProvider.notifier).updateProfile(updated);
      }
      setState(() => _isSaving = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado exitosamente'),
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
                Text(
                  'NOMBRES',
                  style: AppStyles.labelUppercase.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nombresController,
                  validator: (v) => AppValidators.validateRequired(v, 'Nombres'),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'APELLIDOS',
                  style: AppStyles.labelUppercase.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _apellidosController,
                  validator: (v) => AppValidators.validateRequired(v, 'Apellidos'),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'TELÉFONO / CELULAR',
                  style: AppStyles.labelUppercase.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _telefonoController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: '+57 300 000 0000',
                    prefixIcon: Icon(Icons.phone_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 32),

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
