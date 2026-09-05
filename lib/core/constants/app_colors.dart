import 'package:flutter/material.dart';

/// Paleta de colores oficial de FundAPP (Fundación Biosferas)
/// Inspirada en el concepto ecosocial, tonos botánicos orgánicos y degradados naturales.
class AppColors {
  AppColors._();

  // Colores de marca principales
  static const Color primary = Color(0xFF2E6F40); // Verde bosque profundo orgánico
  static const Color primaryDark = Color(0xFF1B4326);
  static const Color primaryLight = Color(0xFF439359);

  static const Color secondary = Color(0xFF3EB075); // Verde esmeralda hoja fresco
  static const Color secondaryLight = Color(0xFF60D394);
  static const Color secondaryUltraLight = Color(0xFFE2F7EC);

  static const Color accent = Color(0xFFD4AF37); // Tono tierra/dorado cálido
  static const Color accentDark = Color(0xFFB8860B);

  // Estados
  static const Color success = Color(0xFF3EB075);
  static const Color warning = Color(0xFFE9C46A);
  static const Color error = Color(0xFFE63946);
  static const Color info = Color(0xFF457B9D);

  // Modo Claro (Light Theme)
  static const Color backgroundLight = Color(0xFFF4F7F4);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF14241B);
  static const Color textSecondaryLight = Color(0xFF5A6F62);
  static const Color borderLight = Color(0xFFE2EBE4);
  static const Color dividerLight = Color(0xFFD7E3DA);

  // Modo Oscuro Botánico Orgánico (Dark Theme)
  static const Color backgroundDark = Color(0xFF0D1C13);
  static const Color surfaceDark = Color(0xFF13241A);
  static const Color cardDark = Color(0xFF182E21);
  static const Color cardDarkElevated = Color(0xFF1E3829);
  static const Color textPrimaryDark = Color(0xFFEDF5EF);
  static const Color textSecondaryDark = Color(0xFF98ADA0);
  static const Color borderDark = Color(0xFF244030);
  static const Color dividerDark = Color(0xFF1C3325);

  // Degradados de la naturaleza
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x990A170F),
      Color(0xF00D1C13),
      Color(0xFF0D1C13),
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1B3525),
      Color(0xFF14281C),
    ],
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4EBA86),
      Color(0xFF2E7D56),
    ],
  );
}
