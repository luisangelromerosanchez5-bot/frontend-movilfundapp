import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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

  static Future<void> addDynamicCertificate(CertificateModel cert, {String? userId}) async {
    final uid = userId ?? cert.destinatario;
    final list = _userDynamicCertificates.putIfAbsent(uid, () => []);
    list.removeWhere((c) => c.id == cert.id);
    list.insert(0, cert);

    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'fundapp_user_certs_$uid';
      final jsonList = list.map((c) => c.toJson()).toList();
      await prefs.setString(key, jsonEncode(jsonList));
    } catch (_) {}
  }

  static List<CertificateModel> getDynamicCertificatesForUser(String userId) {
    return _userDynamicCertificates[userId] ?? [];
  }

  @override
  Future<List<CertificateModel>> getCertificatesByUser(String usuarioId) async {
    List<CertificateModel> localList = List.from(_userDynamicCertificates[usuarioId] ?? []);
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'fundapp_user_certs_$usuarioId';
      final storedJson = prefs.getString(key);
      if (storedJson != null) {
        final decoded = jsonDecode(storedJson) as List;
        for (final item in decoded) {
          final cert = CertificateModel.fromJson(item as Map<String, dynamic>);
          if (!localList.any((c) => c.id == cert.id)) {
            localList.add(cert);
          }
        }
      }
    } catch (_) {}

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
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith('fundapp_user_certs_'));
      for (final k in keys) {
        final stored = prefs.getString(k);
        if (stored != null) {
          final decoded = jsonDecode(stored) as List;
          for (final item in decoded) {
            final cert = CertificateModel.fromJson(item as Map<String, dynamic>);
            if (cert.id == id) return cert;
          }
        }
      }
    } catch (_) {}

    try {
      final response = await apiClient.dio.get('${ApiConstants.certificados}/$id');
      return CertificateModel.fromJson(response.data);
    } catch (_) {
      return null;
    }
  }
}

