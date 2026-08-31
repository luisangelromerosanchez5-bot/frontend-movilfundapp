import '../../domain/entities/donation.dart';
import '../../domain/repositories/donation_repository.dart';
import '../datasources/donation_remote_data_source.dart';

class DonationRepositoryImpl implements DonationRepository {
  final DonationRemoteDataSource remoteDataSource;

  DonationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Donation> createDonation({
    required String usuarioId,
    required double monto,
    required PaymentMethod metodoPago,
    String? proyectoDestino,
  }) async {
    return await remoteDataSource.createDonation({
      'usuario_id': usuarioId,
      'monto': monto,
      'metodo_pago': metodoPago.name,
      'proyecto_destino': proyectoDestino,
    });
  }

  @override
  Future<List<Donation>> getDonationsByUser(String usuarioId) async {
    return await remoteDataSource.getDonationsByUser(usuarioId);
  }
}
