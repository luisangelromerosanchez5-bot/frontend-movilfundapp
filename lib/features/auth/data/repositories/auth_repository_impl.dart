import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> login({required String email, required String password}) async {
    final userModel = await remoteDataSource.login(email, password);
    return userModel;
  }

  @override
  Future<User> register({
    required String nombres,
    required String apellidos,
    required String email,
    required String password,
    String? fechaNacimiento,
    String? telefono,
  }) async {
    final userModel = await remoteDataSource.register({
      'nombres': nombres,
      'apellidos': apellidos,
      'correo': email,
      'password': password,
      'fecha_nacimiento': fechaNacimiento,
      'telefono': telefono,
    });
    return userModel;
  }

  @override
  Future<User?> getCurrentUser() async {
    return await remoteDataSource.getCurrentUser();
  }

  @override
  Future<User> updateProfile(User user) async {
    final userModel = UserModel.fromEntity(user);
    return await remoteDataSource.updateProfile(userModel);
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    await remoteDataSource.requestPasswordReset(email);
  }
}
