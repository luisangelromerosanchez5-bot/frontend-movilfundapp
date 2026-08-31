import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/certificate.dart';
import '../providers/certificate_provider.dart';
import 'certificate_pdf_viewer_screen.dart';

class CertificatesScreen extends ConsumerWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final certificatesAsync = ref.watch(userCertificatesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis certificados'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.refresh(userCertificatesProvider),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: certificatesAsync.when(
              data: (certificates) {
                if (certificates.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 80),
                      child: Column(
                        children: [
                          const Icon(Icons.workspace_premium_outlined, size: 64, color: AppColors.textSecondaryLight),
                          const SizedBox(height: 12),
                          Text('No tienes certificados aún', style: AppStyles.titleSmall),
                        ],
                      ),
                    ),
                  );
                }

                // Certificado destacado (el primero aprobado)
                final featured = certificates.where((c) => c.estaAprobado).firstOrNull ?? certificates.first;

                // Historial
                final history = certificates.where((c) => c.id != featured.id).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tarjeta destacada de certificado más reciente
                    _buildFeaturedCertificateCard(context, featured, isDark),
                    const SizedBox(height: 28),

                    // Sección Historial
                    Text(
                      'Historial',
                      style: AppStyles.titleSmall.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...history.map((cert) => _buildHistoryCertificateCard(context, cert, isDark)),
                    const SizedBox(height: 24),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCertificateCard(BuildContext context, Certificate cert, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: AppStyles.cardRadius,
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: AppStyles.softShadow,
      ),
      child: Column(
        children: [
          // Icono Trofeo / Certificado
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.secondaryUltraLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.workspace_premium_rounded, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 12),

          Text(
            cert.titulo,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            cert.tipo == CertificateType.voluntariado
                ? '${cert.horas} horas · Emitido: ${AppFormatters.formatDateShort(cert.fechaEmision)}'
                : '${AppFormatters.formatCurrency(cert.monto ?? 0)} · Emitido: ${AppFormatters.formatDateShort(cert.fechaEmision)}',
            style: TextStyle(
              fontSize: 12.5,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 16),

          // Botón Descargar PDF
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CertificatePdfViewerScreen(certificate: cert),
                ),
              );
            },
            icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
            label: const Text('Descargar / Ver PDF'),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? AppColors.secondaryLight : AppColors.primary,
              side: BorderSide(color: isDark ? AppColors.secondary : AppColors.primary, width: 1.5),
              minimumSize: const Size.fromHeight(44),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCertificateCard(BuildContext context, Certificate cert, bool isDark) {
    final isAprobado = cert.estaAprobado;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: AppStyles.cardRadius,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isAprobado
                ? AppColors.secondary.withValues(alpha: 0.15)
                : AppColors.accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            cert.tipo == CertificateType.voluntariado
                ? Icons.nature_people_rounded
                : Icons.volunteer_activism_rounded,
            color: isAprobado ? AppColors.primary : AppColors.accentDark,
          ),
        ),
        title: Text(
          cert.titulo,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        subtitle: Text(
          isAprobado
              ? 'Emitido ${AppFormatters.formatDateShort(cert.fechaEmision)}'
              : 'En proceso de aprobación',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        trailing: isAprobado
            ? IconButton(
                icon: const Icon(Icons.visibility_outlined, color: AppColors.primary),
                tooltip: 'Ver PDF',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CertificatePdfViewerScreen(certificate: cert),
                    ),
                  );
                },
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'En proceso',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentDark),
                ),
              ),
      ),
    );
  }
}
