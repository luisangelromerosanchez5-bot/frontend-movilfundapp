import '../entities/user.dart';

/// Contrato abstracto del repositorio de autenticación
abstract class AuthRepository {
  Future<User> login({required String email, required String password});
  Future<User> register({
    required String nombres,
    required String apellidos,
    required String email,
    required String password,
    String? fechaNacimiento,
    String? telefono,
  });
  Future<User?> getCurrentUser();
  Future<User> updateProfile(User user);
  Future<void> logout();
  Future<void> requestPasswordReset(String email);
}
