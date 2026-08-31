import '../entities/certificate.dart';

abstract class CertificateRepository {
  Future<List<Certificate>> getCertificatesByUser(String usuarioId);
  Future<Certificate?> getCertificateById(String id);
}
