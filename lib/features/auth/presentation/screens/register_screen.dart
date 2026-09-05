import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _cedulaController.dispose();
    _telefonoController.dispose();
    _fechaNacimientoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2001, 5, 2),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimaryLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _fechaNacimientoController.text = DateFormat('dd / MM / yyyy').format(picked);
      });
    }
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref.read(authProvider.notifier).register(
            nombres: _nombresController.text.trim(),
            apellidos: _apellidosController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fechaNacimiento: _fechaNacimientoController.text,
            telefono: _telefonoController.text.trim(),
          );

      if (!mounted) return;
      if (success) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.secondary, size: 28),
                SizedBox(width: 8),
                Text('¡Registro exitoso!'),
              ],
            ),
            content: const Text(
              'Tu cuenta ha sido creada correctamente en Fundación Biosferas. Por favor inicia sesión con tu correo y contraseña.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Ir a Iniciar Sesión'),
              ),
            ],
          ),
        );
      } else {
        final error = ref.read(authProvider).errorMessage ?? 'Error al registrar usuario';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Crear cuenta',
                  style: AppStyles.titleLarge.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Únete como voluntario a la Fundación Biosferas',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 24),

                // NOMBRES
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
                    hintText: 'Luis Fernando',
                    prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: 16),

                // APELLIDOS
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
                    hintText: 'Pérez Gómez',
                    prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: 16),

                // CÉDULA / IDENTIFICACIÓN (SOLO NÚMEROS)
                Text(
                  'CÉDULA / DOCUMENTO DE IDENTIDAD',
                  style: AppStyles.labelUppercase.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _cedulaController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Ingresa tu número de documento';
                    if (v.trim().length < 6) return 'Debe tener al menos 6 dígitos numéricos';
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: '1098765432',
                    prefixIcon: Icon(Icons.badge_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 16),

                // TELÉFONO (SOLO NÚMEROS)
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
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Ingresa tu número de teléfono';
                    if (v.trim().length < 7) return 'Debe tener al menos 7 dígitos';
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: '3124567890',
                    prefixIcon: Icon(Icons.phone_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 16),

                // FECHA DE NACIMIENTO
                Text(
                  'FECHA DE NACIMIENTO',
                  style: AppStyles.labelUppercase.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _fechaNacimientoController,
                  readOnly: true,
                  onTap: _selectDate,
                  decoration: const InputDecoration(
                    hintText: '02 / 05 / 2001',
                    prefixIcon: Icon(Icons.calendar_today_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 16),

                // CORREO ELECTRÓNICO (VALIDACIÓN ESTRICTA)
                Text(
                  'CORREO ELECTRÓNICO',
                  style: AppStyles.labelUppercase.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: AppValidators.validateEmail,
                  decoration: const InputDecoration(
                    hintText: 'luis@correo.com',
                    prefixIcon: Icon(Icons.mail_outline_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: 16),

                // CONTRASEÑA (MÍNIMO 6 CARACTERES)
                Text(
                  'CONTRASEÑA (MÍNIMO 6 CARACTERES)',
                  style: AppStyles.labelUppercase.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: AppValidators.validatePassword,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // BOTÓN CREAR CUENTA
                ElevatedButton(
                  onPressed: authState.status == AuthStatus.loading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: authState.status == AuthStatus.loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Crear cuenta'),
                ),
                const SizedBox(height: 20),

                // YA TENGO UNA CUENTA
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Ya tengo una cuenta · Iniciar sesión',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.secondaryLight : AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
