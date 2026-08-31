import 'package:flutter/material.dart';

/// Paleta de colores oficial de FundAPP (Fundación Biosferas)
/// Extraída de la propuesta técnica y mockups de la plataforma.
class AppColors {
  AppColors._();

  // Colores de marca principales
  static const Color primary = Color(0xFF2D6A4F); // Verde bosque profundo
  static const Color primaryDark = Color(0xFF1B4332);
  static const Color primaryLight = Color(0xFF40916C);

  static const Color secondary = Color(0xFF52B788); // Verde salvia fresco
  static const Color secondaryLight = Color(0xFF74C69D);
  static const Color secondaryUltraLight = Color(0xFFD8F3DC);

  static const Color accent = Color(0xFFF4A261); // Naranja acento cálido
  static const Color accentDark = Color(0xFFE76F51);

  // Estados
  static const Color success = Color(0xFF2D6A4F);
  static const Color warning = Color(0xFFE9C46A);
  static const Color error = Color(0xFFE63946);
  static const Color info = Color(0xFF457B9D);

  // Modo Claro (Light Theme)
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF6C757D);
  static const Color borderLight = Color(0xFFE9ECEF);
  static const Color dividerLight = Color(0xFFDEE2E6);

  // Modo Oscuro (Dark Theme)
  static const Color backgroundDark = Color(0xFF0F1713);
  static const Color surfaceDark = Color(0xFF18231E);
  static const Color cardDark = Color(0xFF1E2B24);
  static const Color textPrimaryDark = Color(0xFFF8F9FA);
  static const Color textSecondaryDark = Color(0xFFADB5BD);
  static const Color borderDark = Color(0xFF2D3E35);
  static const Color dividerDark = Color(0xFF23322B);
}
