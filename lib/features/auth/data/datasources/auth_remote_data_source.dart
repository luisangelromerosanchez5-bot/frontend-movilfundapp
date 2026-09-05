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

  String _getUserKey(String email) => 'fundapp_user_record_${email.trim().toLowerCase()}';

  @override
  Future<UserModel> login(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    final prefs = await SharedPreferences.getInstance();

    UserModel? localStoredUser;
    final storedJson = prefs.getString(_getUserKey(normalizedEmail));
    if (storedJson != null) {
      try {
        localStoredUser = UserModel.fromJson(jsonDecode(storedJson) as Map<String, dynamic>);
      } catch (_) {}
    }

    try {
      final response = await apiClient.dio.post(
        ApiConstants.login,
        data: {'email': normalizedEmail, 'password': password},
      );

      final token = response.data['access_token'] ?? 'mock-jwt-token-biosferas';
      final rawUserData = response.data['user'] as Map<String, dynamic>? ?? MockData.sampleUser;
      
      final merged = Map<String, dynamic>.from(rawUserData);
      if (localStoredUser != null) {
        if (localStoredUser.horasAcumuladas > (merged['horas_acumuladas'] ?? 0)) {
          merged['horas_acumuladas'] = localStoredUser.horasAcumuladas;
        }
        if (localStoredUser.totalCertificados > (merged['total_certificados'] ?? 0)) {
          merged['total_certificados'] = localStoredUser.totalCertificados;
        }
        if (localStoredUser.totalDonaciones > (merged['total_donaciones'] ?? 0)) {
          merged['total_donaciones'] = localStoredUser.totalDonaciones;
        }
      }

      final user = UserModel.fromJson(merged);
      final userJson = jsonEncode(user.toJson());
      await prefs.setString(ApiConstants.tokenKey, token);
      await prefs.setString(ApiConstants.userKey, userJson);
      await prefs.setString(_getUserKey(normalizedEmail), userJson);
      await prefs.setString('fundapp_user_record_${user.id}', userJson);

      return user;
    } catch (_) {
      final user = localStoredUser ?? UserModel.fromJson({
        ...MockData.sampleUser,
        'id': 'user_${normalizedEmail.hashCode.abs()}',
        'correo': normalizedEmail,
      });

      final userJson = jsonEncode(user.toJson());
      await prefs.setString(ApiConstants.tokenKey, 'mock-jwt-token-biosferas-2026');
      await prefs.setString(ApiConstants.userKey, userJson);
      await prefs.setString(_getUserKey(normalizedEmail), userJson);
      await prefs.setString('fundapp_user_record_${user.id}', userJson);

      return user;
    }
  }

  @override
  Future<UserModel> register(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final email = (data['correo'] as String? ?? data['email'] as String? ?? 'voluntario@correo.com').trim().toLowerCase();

    try {
      final response = await apiClient.dio.post(
        ApiConstants.register,
        data: data,
      );
      final token = response.data['access_token'] ?? 'mock-jwt-token-biosferas';
      final userData = response.data['user'] as Map<String, dynamic>? ?? {
        ...MockData.sampleUser,
        ...data,
      };

      final user = UserModel.fromJson(userData);
      final userJson = jsonEncode(user.toJson());
      await prefs.setString(ApiConstants.tokenKey, token);
      await prefs.setString(ApiConstants.userKey, userJson);
      await prefs.setString(_getUserKey(email), userJson);
      await prefs.setString('fundapp_user_record_${user.id}', userJson);

      return user;
    } catch (_) {
      final user = UserModel.fromJson({
        ...MockData.sampleUser,
        'id': 'user_${email.hashCode.abs()}',
        'nombres': data['nombres'] ?? 'Voluntario',
        'apellidos': data['apellidos'] ?? 'Biosferas',
        'correo': email,
        'fecha_nacimiento': data['fecha_nacimiento'],
        'telefono': data['telefono'],
      });

      final userJson = jsonEncode(user.toJson());
      await prefs.setString(ApiConstants.tokenKey, 'mock-jwt-token-biosferas-2026');
      await prefs.setString(ApiConstants.userKey, userJson);
      await prefs.setString(_getUserKey(email), userJson);
      await prefs.setString('fundapp_user_record_${user.id}', userJson);

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
    return null;
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toJson());
    await prefs.setString(ApiConstants.userKey, userJson);
    if (user.correo.isNotEmpty) {
      await prefs.setString(_getUserKey(user.correo), userJson);
    }
    await prefs.setString('fundapp_user_record_${user.id}', userJson);
    return user;
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    // Guardar el estado actual en el registro del usuario antes de cerrar sesión
    final currentUserJson = prefs.getString(ApiConstants.userKey);
    if (currentUserJson != null) {
      try {
        final data = jsonDecode(currentUserJson) as Map<String, dynamic>;
        final email = (data['correo'] as String? ?? '').toLowerCase();
        if (email.isNotEmpty) {
          await prefs.setString(_getUserKey(email), currentUserJson);
        }
        final id = data['id'] as String? ?? '';
        if (id.isNotEmpty) {
          await prefs.setString('fundapp_user_record_$id', currentUserJson);
        }
      } catch (_) {}
    }
    // Remover sesión activa pero preservando los datos por usuario
    await prefs.remove(ApiConstants.tokenKey);
    await prefs.remove(ApiConstants.userKey);
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 600));
  }
}
