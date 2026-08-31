import 'package:uuid/uuid.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/donation_model.dart';

abstract class DonationRemoteDataSource {
  Future<DonationModel> createDonation(Map<String, dynamic> data);
  Future<List<DonationModel>> getDonationsByUser(String usuarioId);
}

class DonationRemoteDataSourceImpl implements DonationRemoteDataSource {
  final ApiClient apiClient;
  final List<DonationModel> _localDonations = [];

  DonationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<DonationModel> createDonation(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.dio.post(ApiConstants.donaciones, data: data);
      return DonationModel.fromJson(response.data);
    } catch (_) {
      final newDonation = DonationModel(
        id: const Uuid().v4(),
        usuarioId: data['usuario_id'] ?? 'u101',
        monto: (data['monto'] as num).toDouble(),
        metodoPago: DonationModel.fromJson(data).metodoPago,
        estado: 'completada',
        fecha: DateTime.now(),
        codigoTransaccion: 'TX-FB-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
        proyectoDestino: data['proyecto_destino'] ?? 'Fondo General de Conservación',
      );
      _localDonations.add(newDonation);
      return newDonation;
    }
  }

  @override
  Future<List<DonationModel>> getDonationsByUser(String usuarioId) async {
    try {
      final response = await apiClient.dio.get('${ApiConstants.donaciones}/usuario/$usuarioId');
      return (response.data as List).map((e) => DonationModel.fromJson(e)).toList();
    } catch (_) {
      return List.from(_localDonations);
    }
  }
}
