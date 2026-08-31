import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../certificates/data/datasources/certificate_remote_data_source.dart';
import '../../../certificates/data/models/certificate_model.dart';
import '../../../certificates/domain/entities/certificate.dart';
import '../../../certificates/presentation/providers/certificate_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../data/datasources/donation_remote_data_source.dart';
import '../../data/repositories/donation_repository_impl.dart';
import '../../domain/entities/donation.dart';
import '../../domain/repositories/donation_repository.dart';

final donationRemoteDataSourceProvider = Provider<DonationRemoteDataSource>((ref) {
  return DonationRemoteDataSourceImpl(apiClient: ref.watch(apiClientProvider));
});

final donationRepositoryProvider = Provider<DonationRepository>((ref) {
  return DonationRepositoryImpl(remoteDataSource: ref.watch(donationRemoteDataSourceProvider));
});

class DonationFormState {
  final double selectedAmount;
  final bool isCustomAmount;
  final PaymentMethod selectedMethod;
  final bool isLoading;
  final String? errorMessage;
  final Donation? lastDonation;

  const DonationFormState({
    this.selectedAmount = 50000.0,
    this.isCustomAmount = false,
    this.selectedMethod = PaymentMethod.creditCard,
    this.isLoading = false,
    this.errorMessage,
    this.lastDonation,
  });

  DonationFormState copyWith({
    double? selectedAmount,
    bool? isCustomAmount,
    PaymentMethod? selectedMethod,
    bool? isLoading,
    String? errorMessage,
    Donation? lastDonation,
  }) {
    return DonationFormState(
      selectedAmount: selectedAmount ?? this.selectedAmount,
      isCustomAmount: isCustomAmount ?? this.isCustomAmount,
      selectedMethod: selectedMethod ?? this.selectedMethod,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      lastDonation: lastDonation ?? this.lastDonation,
    );
  }
}

class DonationNotifier extends StateNotifier<DonationFormState> {
  final DonationRepository repository;
  final Ref ref;

  DonationNotifier({required this.repository, required this.ref})
      : super(const DonationFormState());

  void setPredefinedAmount(double amount) {
    state = state.copyWith(selectedAmount: amount, isCustomAmount: false);
  }

  void setCustomAmount(double amount) {
    state = state.copyWith(selectedAmount: amount, isCustomAmount: true);
  }

  void setPaymentMethod(PaymentMethod method) {
    state = state.copyWith(selectedMethod: method);
  }

  Future<Donation?> submitDonation() async {
    if (state.selectedAmount < 5000) {
      state = state.copyWith(errorMessage: 'El monto mínimo es \$5.000 COP');
      return null;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    final user = ref.read(authProvider).user;

    try {
      final donation = await repository.createDonation(
        usuarioId: user?.id ?? '1',
        monto: state.selectedAmount,
        metodoPago: state.selectedMethod,
        proyectoDestino: 'Reforestación y Conservación de Humedales',
      );

      // Crear certificado dinámico de donación
      final certCode = 'FB-DON-${donation.codigoTransaccion.replaceAll("TX-FB-", "")}';
      final newCert = CertificateModel(
        id: 'cert-don-${donation.id}',
        tipo: CertificateType.donacion,
        titulo: 'Certificado de Donación',
        actividadTitulo: donation.proyectoDestino ?? 'Fondo de Conservación Ambiental',
        monto: donation.monto,
        fechaEmision: donation.fecha,
        estado: 'aprobado',
        codigoVerificacion: certCode,
        firmadoPor: 'Carlos Mendoza - Tesorería Fundación',
        destinatario: user?.nombreCompleto ?? 'Donante Solidario',
        documentoIdentidad: '1.098.765.432',
      );

      CertificateRemoteDataSourceImpl.addDynamicCertificate(newCert);

      // Actualizar donación acumulada del usuario
      if (user != null) {
        final updatedUser = user.copyWith(
          totalDonaciones: user.totalDonaciones + state.selectedAmount,
          totalCertificados: user.totalCertificados + 1,
        );
        await ref.read(authProvider.notifier).updateProfile(updatedUser);
      }

      // Refrescar proveedores de certificados y dashboard
      ref.invalidate(userCertificatesProvider);
      ref.invalidate(dashboardStatsProvider);

      state = state.copyWith(isLoading: false, lastDonation: donation);
      return donation;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }
}

final donationProvider = StateNotifierProvider<DonationNotifier, DonationFormState>((ref) {
  return DonationNotifier(
    repository: ref.watch(donationRepositoryProvider),
    ref: ref,
  );
});
