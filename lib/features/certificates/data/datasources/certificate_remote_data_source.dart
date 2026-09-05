import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/certificate_model.dart';

abstract class CertificateRemoteDataSource {
  Future<List<CertificateModel>> getCertificatesByUser(String usuarioId);
  Future<CertificateModel?> getCertificateById(String id);
}

class CertificateRemoteDataSourceImpl implements CertificateRemoteDataSource {
  final ApiClient apiClient;
  static final Map<String, List<CertificateModel>> _userDynamicCertificates = {};

  CertificateRemoteDataSourceImpl({required this.apiClient});

  static void addDynamicCertificate(CertificateModel cert, {String? userId}) {
    final uid = userId ?? cert.destinatario;
    final list = _userDynamicCertificates.putIfAbsent(uid, () => []);
    list.removeWhere((c) => c.id == cert.id);
    list.insert(0, cert);
  }

  static List<CertificateModel> getDynamicCertificatesForUser(String userId) {
    return _userDynamicCertificates[userId] ?? [];
  }

  @override
  Future<List<CertificateModel>> getCertificatesByUser(String usuarioId) async {
    final localList = _userDynamicCertificates[usuarioId] ?? [];
    try {
      final response = await apiClient.dio.get('${ApiConstants.certificados}/usuario/$usuarioId');
      final remote = (response.data as List).map((e) => CertificateModel.fromJson(e)).toList();
      
      final Map<String, CertificateModel> map = {};
      for (final c in remote) {
        map[c.id] = c;
      }
      for (final c in localList) {
        map[c.id] = c;
      }
      return map.values.toList();
    } catch (_) {
      return localList;
    }
  }

  @override
  Future<CertificateModel?> getCertificateById(String id) async {
    for (final list in _userDynamicCertificates.values) {
      final found = list.where((c) => c.id == id).firstOrNull;
      if (found != null) return found;
    }

    try {
      final response = await apiClient.dio.get('${ApiConstants.certificados}/$id');
      return CertificateModel.fromJson(response.data);
    } catch (_) {
      return null;
    }
  }
}
