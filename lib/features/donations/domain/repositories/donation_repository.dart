import '../entities/donation.dart';

abstract class DonationRepository {
  Future<Donation> createDonation({
    required String usuarioId,
    required double monto,
    required PaymentMethod metodoPago,
    String? proyectoDestino,
  });
  Future<List<Donation>> getDonationsByUser(String usuarioId);
}
