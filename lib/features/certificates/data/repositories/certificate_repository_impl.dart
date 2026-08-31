import '../../domain/entities/certificate.dart';
import '../../domain/repositories/certificate_repository.dart';
import '../datasources/certificate_remote_data_source.dart';

class CertificateRepositoryImpl implements CertificateRepository {
  final CertificateRemoteDataSource remoteDataSource;

  CertificateRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Certificate>> getCertificatesByUser(String usuarioId) async {
    return await remoteDataSource.getCertificatesByUser(usuarioId);
  }

  @override
  Future<Certificate?> getCertificateById(String id) async {
    return await remoteDataSource.getCertificateById(id);
  }
}
