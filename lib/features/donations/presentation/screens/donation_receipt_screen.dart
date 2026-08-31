import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../certificates/domain/entities/certificate.dart';
import '../../../certificates/presentation/screens/certificate_pdf_viewer_screen.dart';
import '../../domain/entities/donation.dart';

class DonationReceiptScreen extends ConsumerWidget {
  final Donation donation;

  const DonationReceiptScreen({super.key, required this.donation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comprobante de donación'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icono de éxito
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryUltraLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 52,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                '¡Gracias por tu aporte!',
                textAlign: TextAlign.center,
                style: AppStyles.titleLarge.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tu donación contribuye a la restauración ecológica y apoyo a comunidades de la Fundación Biosferas.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 28),

              // Tarjeta de recibo
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: AppStyles.cardRadius,
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                  boxShadow: AppStyles.softShadow,
                ),
                child: Column(
                  children: [
                    _buildReceiptRow('Monto donado', AppFormatters.formatCurrency(donation.monto), isDark, isHighlight: true),
                    const Divider(),
                    _buildReceiptRow('Método de pago', donation.metodoPagoNombre, isDark),
                    const Divider(),
                    _buildReceiptRow('Código de transacción', donation.codigoTransaccion, isDark),
                    const Divider(),
                    _buildReceiptRow('Destino', donation.proyectoDestino ?? 'Conservación General', isDark),
                    const Divider(),
                    _buildReceiptRow('Fecha', AppFormatters.formatDateFull(donation.fecha), isDark),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // BOTÓN DESCARGAR / VER CERTIFICADO OFICIAL PDF
              ElevatedButton.icon(
                onPressed: () {
                  final cert = Certificate(
                    id: 'cert-don-${donation.id}',
                    tipo: CertificateType.donacion,
                    titulo: 'Certificado de Donación',
                    actividadTitulo: donation.proyectoDestino ?? 'Fondo de Conservación Ambiental',
                    monto: donation.monto,
                    fechaEmision: donation.fecha,
                    estado: 'aprobado',
                    codigoVerificacion: 'FB-DON-${donation.codigoTransaccion.replaceAll("TX-FB-", "")}',
                    firmadoPor: 'Carlos Mendoza - Tesorería Fundación',
                    destinatario: user?.nombreCompleto ?? 'Donante Solidario',
                    documentoIdentidad: '1.098.765.432',
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CertificatePdfViewerScreen(certificate: cert),
                    ),
                  );
                },
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
                label: const Text('Descargar / Ver Certificado PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 12),

              // BOTÓN VOLVER AL INICIO
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                  side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, bool isDark, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlight ? 16 : 13.5,
              fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
              color: isHighlight
                  ? AppColors.primary
                  : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
            ),
          ),
        ],
      ),
    );
  }
}
