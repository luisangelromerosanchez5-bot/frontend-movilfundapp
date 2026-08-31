import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/donation.dart';
import '../providers/donation_provider.dart';
import 'donation_receipt_screen.dart';

class DonationScreen extends ConsumerStatefulWidget {
  const DonationScreen({super.key});

  @override
  ConsumerState<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends ConsumerState<DonationScreen> {
  final _customAmountController = TextEditingController();

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final donationState = ref.watch(donationProvider);
    final donationNotifier = ref.read(donationProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final predefinedAmounts = [20000.0, 50000.0, 100000.0];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hacer una donación'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tu aporte impulsa nuestros proyectos ambientales',
                style: TextStyle(
                  fontSize: 13.5,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24),

              // SECCIÓN: SELECCIONA UN MONTO
              Text(
                'SELECCIONA UN MONTO',
                style: AppStyles.labelUppercase.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 12),

              // Botones de montos predefinidos ($20K, $50K, $100K)
              Row(
                children: predefinedAmounts.map((amount) {
                  final isSelected = !donationState.isCustomAmount && donationState.selectedAmount == amount;
                  final label = amount >= 1000 ? '\$${(amount / 1000).toStringAsFixed(0)}K' : '\$$amount';

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: OutlinedButton(
                        onPressed: () {
                          _customAmountController.clear();
                          donationNotifier.setPredefinedAmount(amount);
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: isSelected
                              ? (isDark ? AppColors.primary : AppColors.secondaryUltraLight)
                              : Colors.transparent,
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.borderLight),
                            width: isSelected ? 2 : 1,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: AppStyles.buttonRadius),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? (isDark ? Colors.white : AppColors.primaryDark)
                                : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // OTRO MONTO
              Text(
                'OTRO MONTO',
                style: AppStyles.labelUppercase.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _customAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '\$0',
                  prefixText: '\$ ',
                ),
                onChanged: (val) {
                  final clean = val.replaceAll(RegExp(r'[^\d]'), '');
                  final parsed = double.tryParse(clean);
                  if (parsed != null && parsed > 0) {
                    donationNotifier.setCustomAmount(parsed);
                  }
                },
              ),
              const SizedBox(height: 28),

              // SECCIÓN: MÉTODO DE PAGO
              Text(
                'MÉTODO DE PAGO',
                style: AppStyles.labelUppercase.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 12),

              _buildPaymentOption(
                title: 'Tarjeta de crédito/débito',
                icon: Icons.credit_card_rounded,
                method: PaymentMethod.creditCard,
                selectedMethod: donationState.selectedMethod,
                isDark: isDark,
                onTap: () => donationNotifier.setPaymentMethod(PaymentMethod.creditCard),
              ),
              const SizedBox(height: 10),

              _buildPaymentOption(
                title: 'PSE (Transferencia bancaria)',
                icon: Icons.account_balance_rounded,
                method: PaymentMethod.pse,
                selectedMethod: donationState.selectedMethod,
                isDark: isDark,
                onTap: () => donationNotifier.setPaymentMethod(PaymentMethod.pse),
              ),
              const SizedBox(height: 10),

              _buildPaymentOption(
                title: 'Nequi / Daviplata',
                icon: Icons.phone_android_rounded,
                method: PaymentMethod.nequiDaviplata,
                selectedMethod: donationState.selectedMethod,
                isDark: isDark,
                onTap: () => donationNotifier.setPaymentMethod(PaymentMethod.nequiDaviplata),
              ),
              const SizedBox(height: 36),

              // BOTÓN DONAR
              ElevatedButton(
                onPressed: donationState.isLoading
                    ? null
                    : () async {
                        final donation = await donationNotifier.submitDonation();
                        if (donation != null && context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DonationReceiptScreen(donation: donation),
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: donationState.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        'Donar ${AppFormatters.formatCurrency(donationState.selectedAmount)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required IconData icon,
    required PaymentMethod method,
    required PaymentMethod selectedMethod,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final isSelected = method == selectedMethod;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: AppStyles.cardRadius,
        border: Border.all(
          color: isSelected ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondaryLight),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        trailing: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? AppColors.primary : Colors.transparent,
            border: Border.all(
              color: isSelected ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.borderLight),
              width: 2,
            ),
          ),
          child: isSelected
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}
