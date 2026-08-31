/// Excepciones estándar de la aplicación y red
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException({super.message = 'Sin conexión a internet. Verifica tu red.'});
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException({super.message = 'Sesión expirada o no autorizada. Por favor inicia sesión de nuevo.'})
      : super(statusCode: 401);
}

class ServerException extends ApiException {
  const ServerException({super.message = 'Error en el servidor de Fundación Biosferas. Intenta de nuevo más tarde.', super.statusCode});
}

class ValidationException extends ApiException {
  const ValidationException({required super.message, super.data})
      : super(statusCode: 422);
}
