import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import 'api_exceptions.dart';

/// Cliente HTTP Dio configurado con interceptores para JWT y manejo de errores
class ApiClient {
  final Dio _dio;

  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConstants.defaultBaseUrl,
                connectTimeout: ApiConstants.connectTimeout,
                receiveTimeout: ApiConstants.receiveTimeout,
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            ) {
    _setupInterceptors();
  }

  Dio get dio => _dio;

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(ApiConstants.tokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          final exception = _handleDioError(e);
          return handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              error: exception,
              response: e.response,
              type: e.type,
            ),
          );
        },
      ),
    );
  }

  ApiException _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return const NetworkException();
    }

    final response = error.response;
    if (response != null) {
      final statusCode = response.statusCode;
      final data = response.data;
      final message = (data is Map && data.containsKey('message'))
          ? data['message'].toString()
          : (data is Map && data.containsKey('detail'))
              ? data['detail'].toString()
              : 'Error en la petición: $statusCode';

      if (statusCode == 401) {
        return UnauthorizedException(message: message);
      }
      if (statusCode == 422) {
        return ValidationException(message: message, data: data);
      }
      return ServerException(message: message, statusCode: statusCode);
    }

    return ApiException(message: error.message ?? 'Error desconocido de red');
  }
}
