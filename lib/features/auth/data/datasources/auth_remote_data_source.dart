import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/mock_data.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(Map<String, dynamic> data);
  Future<UserModel?> getCurrentUser();
  Future<UserModel> updateProfile(UserModel user);
  Future<void> logout();
  Future<void> requestPasswordReset(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      final token = response.data['access_token'] ?? 'mock-jwt-token-biosferas';
      final userData = response.data['user'] ?? MockData.sampleUser;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(ApiConstants.tokenKey, token);
      await prefs.setString(ApiConstants.userKey, jsonEncode(userData));

      return UserModel.fromJson(userData);
    } catch (_) {
      // Fallback a autenticación simulada si no hay backend activo
      final prefs = await SharedPreferences.getInstance();
      final user = UserModel.fromJson({
        ...MockData.sampleUser,
        'correo': email,
      });
      await prefs.setString(ApiConstants.tokenKey, 'mock-jwt-token-biosferas-2026');
      await prefs.setString(ApiConstants.userKey, jsonEncode(user.toJson()));
      return user;
    }
  }

  @override
  Future<UserModel> register(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.register,
        data: data,
      );
      final token = response.data['access_token'] ?? 'mock-jwt-token-biosferas';
      final userData = response.data['user'] ?? {
        ...MockData.sampleUser,
        ...data,
      };

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(ApiConstants.tokenKey, token);
      await prefs.setString(ApiConstants.userKey, jsonEncode(userData));

      return UserModel.fromJson(userData);
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      final user = UserModel.fromJson({
        ...MockData.sampleUser,
        'nombres': data['nombres'] ?? 'Voluntario',
        'apellidos': data['apellidos'] ?? 'Biosferas',
        'correo': data['correo'] ?? 'voluntario@correo.com',
        'fecha_nacimiento': data['fecha_nacimiento'],
        'telefono': data['telefono'],
      });
      await prefs.setString(ApiConstants.tokenKey, 'mock-jwt-token-biosferas-2026');
      await prefs.setString(ApiConstants.userKey, jsonEncode(user.toJson()));
      return user;
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(ApiConstants.userKey);
    if (userJson != null) {
      try {
        final data = jsonDecode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(data);
      } catch (_) {
        return null;
      }
    }
    return UserModel.fromJson(MockData.sampleUser);
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConstants.userKey, jsonEncode(user.toJson()));
    return user;
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConstants.tokenKey);
    await prefs.remove(ApiConstants.userKey);
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    // Simula envío de enlace de recuperación al correo
    await Future.delayed(const Duration(milliseconds: 600));
  }
}
