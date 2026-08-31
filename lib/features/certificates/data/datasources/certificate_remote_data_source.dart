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

  CertificateRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<CertificateModel>> getCertificatesByUser(String usuarioId) async {
    try {
      final response = await apiClient.dio.get('${ApiConstants.certificados}/usuario/$usuarioId');
      return (response.data as List).map((e) => CertificateModel.fromJson(e)).toList();
    } catch (_) {
      return MockData.sampleCertificates.map((e) => CertificateModel.fromJson(e)).toList();
    }
  }

  @override
  Future<CertificateModel?> getCertificateById(String id) async {
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
