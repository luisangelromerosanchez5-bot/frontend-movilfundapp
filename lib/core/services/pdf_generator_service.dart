import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/certificates/domain/entities/certificate.dart';

/// Servicio de generación e impresión de certificados oficiales en formato PDF
class PdfGeneratorService {
  /// Genera el documento PDF del certificado
  static Future<Uint8List> generateCertificatePdf(Certificate certificate) async {
    final pdf = pw.Document();

    final primaryColor = PdfColor.fromHex('2D6A4F');
    final secondaryColor = PdfColor.fromHex('52B788');
    final accentColor = PdfColor.fromHex('F4A261');
    final darkColor = PdfColor.fromHex('1A1A1A');
    final lightBg = PdfColor.fromHex('F8F9FA');

    final fontBold = await PdfGoogleFonts.merriweatherBold();
    final fontRegular = await PdfGoogleFonts.interRegular();
    final fontItalic = await PdfGoogleFonts.interItalic();
    final fontTitle = await PdfGoogleFonts.merriweatherRegular();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              border: pw.Border.all(color: primaryColor, width: 4),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
            ),
            padding: const pw.EdgeInsets.all(28),
            child: pw.Stack(
              children: [
                // Marca de agua sutil
                pw.Center(
                  child: pw.Opacity(
                    opacity: 0.04,
                    child: pw.Text(
                      'BIOSFERAS',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 80,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
                pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    // Cabecera institucional
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'FUNDACIÓN BIOSFERAS',
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 18,
                                color: primaryColor,
                                letterSpacing: 1.2,
                              ),
                            ),
                            pw.Text(
                              'Comprometidos con la regeneración ambiental y comunitaria',
                              style: pw.TextStyle(
                                font: fontItalic,
                                fontSize: 10,
                                color: PdfColors.grey700,
                              ),
                            ),
                          ],
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: pw.BoxDecoration(
                            color: secondaryColor,
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                          ),
                          child: pw.Text(
                            certificate.tipo == CertificateType.voluntariado
                                ? 'VOLUNTARIADO AMBIENTAL'
                                : 'DONACIÓN AMBIENTAL',
                            style: pw.TextStyle(
                              font: fontRegular,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    pw.Divider(color: accentColor, thickness: 2),

                    // Cuerpo del certificado
                    pw.Column(
                      children: [
                        pw.Text(
                          'CERTIFICADO DE RECONOCIMIENTO',
                          style: pw.TextStyle(
                            font: fontTitle,
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            color: darkColor,
                            letterSpacing: 1.5,
                          ),
                        ),
                        pw.SizedBox(height: 12),
                        pw.Text(
                          'La Fundación Biosferas hace constar que:',
                          style: pw.TextStyle(
                            font: fontRegular,
                            fontSize: 12,
                            color: PdfColors.grey800,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          certificate.destinatario.toUpperCase(),
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 20,
                            color: primaryColor,
                            letterSpacing: 1.1,
                          ),
                        ),
                        pw.Text(
                          'C.C. ${certificate.documentoIdentidad}',
                          style: pw.TextStyle(
                            font: fontRegular,
                            fontSize: 11,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 12),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          decoration: pw.BoxDecoration(
                            color: lightBg,
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                          ),
                          child: pw.Text(
                            certificate.tipo == CertificateType.voluntariado
                                ? 'Participó activamente en la jornada "${certificate.actividadTitulo}", acumulando un total de ${certificate.horas} horas de labor ecológica comprobada.'
                                : 'Realizó una generosa donación por valor de \$${certificate.monto?.toStringAsFixed(0) ?? '0'} COP destinada a: "${certificate.actividadTitulo}".',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              font: fontRegular,
                              fontSize: 12,
                              color: darkColor,
                              lineSpacing: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Pie de página y firmas
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Código de verificación:',
                              style: pw.TextStyle(font: fontRegular, fontSize: 9, color: PdfColors.grey600),
                            ),
                            pw.Text(
                              certificate.codigoVerificacion,
                              style: pw.TextStyle(font: fontBold, fontSize: 10, color: primaryColor),
                            ),
                            pw.Text(
                              'Fecha de emisión: ${certificate.fechaEmision.day}/${certificate.fechaEmision.month}/${certificate.fechaEmision.year}',
                              style: pw.TextStyle(font: fontRegular, fontSize: 9, color: PdfColors.grey600),
                            ),
                          ],
                        ),
                        pw.Column(
                          children: [
                            pw.Container(
                              width: 180,
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(top: pw.BorderSide(color: PdfColors.black, width: 1)),
                              ),
                              padding: const pw.EdgeInsets.only(top: 4),
                              child: pw.Column(
                                children: [
                                  pw.Text(
                                    certificate.firmadoPor,
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(font: fontBold, fontSize: 9),
                                  ),
                                  pw.Text(
                                    'Fundación Biosferas Colombia',
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(font: fontRegular, fontSize: 8, color: PdfColors.grey600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Abre el diálogo del sistema para imprimir o compartir/guardar el PDF
  static Future<void> printOrShareCertificate(Certificate certificate) async {
    final pdfBytes = await generateCertificatePdf(certificate);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Certificado_${certificate.codigoVerificacion}.pdf',
    );
  }
}
