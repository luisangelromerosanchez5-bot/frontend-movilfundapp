import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/pdf_generator_service.dart';
import '../../domain/entities/certificate.dart';

class CertificatePdfViewerScreen extends StatelessWidget {
  final Certificate certificate;

  const CertificatePdfViewerScreen({super.key, required this.certificate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(certificate.titulo),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Compartir certificado',
            onPressed: () async {
              await PdfGeneratorService.printOrShareCertificate(certificate);
            },
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => PdfGeneratorService.generateCertificatePdf(certificate),
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        loadingWidget: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        pdfFileName: 'Certificado_${certificate.codigoVerificacion}.pdf',
      ),
    );
  }
}
