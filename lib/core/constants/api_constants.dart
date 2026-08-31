/// Configuración de endpoints y constantes de red
class ApiConstants {
  ApiConstants._();

  // URL base apuntando al backend en la nube (Render)
  static const String defaultBaseUrl = 'https://backend-movilfundapp.onrender.com/api/v1';

  // Timeout settings
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/auth/me';
  static const String activities = '/actividades';
  static const String postulaciones = '/postulaciones';
  static const String asistencias = '/asistencias';
  static const String donaciones = '/donaciones';
  static const String certificados = '/certificados';
  static const String estadisticas = '/usuarios/estadisticas';

  // SharedPreferences Keys
  static const String tokenKey = 'fundapp_jwt_token';
  static const String userKey = 'fundapp_user_data';
  static const String themeKey = 'fundapp_theme_mode';
  static const String profilePhotoKey = 'fundapp_profile_photo_path';
  static const String activeActivityKey = 'fundapp_active_activity';
}
