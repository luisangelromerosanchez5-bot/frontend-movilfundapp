import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/botanical_decorations.dart';
import '../../domain/entities/certificate.dart';
import '../providers/certificate_provider.dart';
import 'certificate_pdf_viewer_screen.dart';

class CertificatesScreen extends ConsumerStatefulWidget {
  const CertificatesScreen({super.key});

  @override
  ConsumerState<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends ConsumerState<CertificatesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final certificatesAsync = ref.watch(userCertificatesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Certificados Oficiales'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.secondary,
          unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          indicatorColor: AppColors.secondary,
          indicatorWeight: 3,
          tabs: const [
            Tab(
              icon: Icon(Icons.volunteer_activism_rounded, size: 20),
              text: 'Donaciones',
            ),
            Tab(
              icon: Icon(Icons.nature_people_rounded, size: 20),
              text: 'Participación',
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.refresh(userCertificatesProvider),
          child: certificatesAsync.when(
            data: (certificates) {
              final donacionCerts = certificates
                  .where((c) => c.tipo == CertificateType.donacion)
                  .toList();
              final participacionCerts = certificates
                  .where((c) => c.tipo == CertificateType.voluntariado)
                  .toList();

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildCertList(
                    context,
                    donacionCerts,
                    isDonacion: true,
                    isDark: isDark,
                  ),
                  _buildCertList(
                    context,
                    participacionCerts,
                    isDonacion: false,
                    isDark: isDark,
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (err, _) => Center(
              child: Text('Error al cargar certificados: $err'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCertList(
    BuildContext context,
    List<Certificate> list, {
    required bool isDonacion,
    required bool isDark,
  }) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDonacion ? Icons.volunteer_activism_outlined : Icons.nature_people_outlined,
                  size: 36,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isDonacion
                    ? 'No tienes certificados de donación'
                    : 'No tienes certificados de participación',
                textAlign: TextAlign.center,
                style: AppStyles.titleSmall.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isDonacion
                    ? 'Realiza un aporte económico para apoyar la reforestación y se generará tu certificado oficial deducible.'
                    : 'Participa en jornadas de voluntariado ambiental y al hacer check-out se emitirá tu certificado con horas acumuladas.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: list.length,
      itemBuilder: (ctx, index) {
        final cert = list[index];
        final isAprobado = cert.estaAprobado;

        return BotanicalCard(
          margin: const EdgeInsets.only(bottom: 14),
          showLeaves: true,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAprobado
                          ? AppColors.secondary.withValues(alpha: 0.15)
                          : AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAprobado ? Icons.eco_rounded : Icons.hourglass_top_rounded,
                          size: 13,
                          color: isAprobado ? AppColors.secondary : AppColors.accentDark,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isAprobado ? 'Certificado Aprobado' : 'En proceso',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: isAprobado ? AppColors.primary : AppColors.accentDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    cert.codigoVerificacion,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Text(
                cert.titulo,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                cert.actividadTitulo,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.secondaryLight : AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Icon(
                    isDonacion ? Icons.volunteer_activism_rounded : Icons.eco_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isDonacion
                        ? 'Aporte: ${AppFormatters.formatCurrency(cert.monto ?? 0)}'
                        : '${cert.horas ?? 4} horas de voluntariado certificadas',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Text(
                    'Emitido: ${AppFormatters.formatDateShort(cert.fechaEmision)}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Botón Ver PDF
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CertificatePdfViewerScreen(certificate: cert),
                    ),
                  );
                },
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                label: const Text('Descargar / Ver Certificado PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(42),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
