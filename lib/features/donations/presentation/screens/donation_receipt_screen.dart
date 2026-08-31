import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/donation.dart';

class DonationReceiptScreen extends StatelessWidget {
  final Donation donation;

  const DonationReceiptScreen({super.key, required this.donation});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              const SizedBox(height: 36),

              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
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
