import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/mock_data.dart';
import '../models/certificate_model.dart';

abstract class CertificateRemoteDataSource {
  Future<List<CertificateModel>> getCertificatesByUser(String usuarioId);
  Future<CertificateModel?> getCertificateById(String id);
}

class CertificateRemoteDataSourceImpl implements CertificateRemoteDataSource {
  final ApiClient apiClient;
  static final List<CertificateModel> localDynamicCertificates = [];

  CertificateRemoteDataSourceImpl({required this.apiClient});

  static void addDynamicCertificate(CertificateModel cert) {
    // Evitar duplicados por id
    localDynamicCertificates.removeWhere((c) => c.id == cert.id);
    localDynamicCertificates.insert(0, cert);
  }

  @override
  Future<List<CertificateModel>> getCertificatesByUser(String usuarioId) async {
    try {
      final response = await apiClient.dio.get('${ApiConstants.certificados}/usuario/$usuarioId');
      final remote = (response.data as List).map((e) => CertificateModel.fromJson(e)).toList();
      return [...localDynamicCertificates, ...remote];
    } catch (_) {
      final mock = MockData.sampleCertificates.map((e) => CertificateModel.fromJson(e)).toList();
      return [...localDynamicCertificates, ...mock];
    }
  }

  @override
  Future<CertificateModel?> getCertificateById(String id) async {
    final local = localDynamicCertificates.where((c) => c.id == id).firstOrNull;
    if (local != null) return local;

    try {
      final response = await apiClient.dio.get('${ApiConstants.certificados}/$id');
      return CertificateModel.fromJson(response.data);
    } catch (_) {
      try {
        final item = MockData.sampleCertificates.firstWhere((e) => e['id'] == id);
        return CertificateModel.fromJson(item);
      } catch (_) {
        return null;
      }
    }
  }
}
