/// Validadores para formularios de autenticación, postulación y donaciones
class AppValidators {
  AppValidators._();

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu correo electrónico';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingresa un correo electrónico válido';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es obligatorio';
    }
    return null;
  }

  static String? validateName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es obligatorio';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return '$fieldName debe tener al menos 2 caracteres';
    }
    // Solo letras (incluyendo acentos y ñ), espacios, apóstrofes y guiones
    final nameRegex = RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s'-]+$");
    if (!nameRegex.hasMatch(trimmed)) {
      return '$fieldName no debe contener números ni símbolos';
    }
    return null;
  }

  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa un monto';
    }
    final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
    final amount = double.tryParse(cleanValue);
    if (amount == null || amount < 5000) {
      return 'El monto mínimo de donación es de \$5.000 COP';
    }
    return null;
  }
}
