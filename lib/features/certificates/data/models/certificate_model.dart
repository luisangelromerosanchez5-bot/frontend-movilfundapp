import '../../domain/entities/certificate.dart';

class CertificateModel extends Certificate {
  const CertificateModel({
    required super.id,
    required super.tipo,
    required super.titulo,
    required super.actividadTitulo,
    super.horas,
    super.monto,
    required super.fechaEmision,
    required super.estado,
    required super.codigoVerificacion,
    required super.firmadoPor,
    required super.destinatario,
    required super.documentoIdentidad,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      id: json['id'] ?? '',
      tipo: json['tipo'] == 'donacion' ? CertificateType.donacion : CertificateType.voluntariado,
      titulo: json['titulo'] ?? 'Certificado',
      actividadTitulo: json['actividad_titulo'] ?? '',
      horas: (json['horas'] as num?)?.toInt(),
      monto: (json['monto'] as num?)?.toDouble(),
      fechaEmision: json['fecha_emision'] != null ? DateTime.parse(json['fecha_emision']) : DateTime.now(),
      estado: json['estado'] ?? 'aprobado',
      codigoVerificacion: json['codigo_verificacion'] ?? 'FB-CERT-000',
      firmadoPor: json['firmado_por'] ?? 'Dirección Fundación Biosferas',
      destinatario: json['destinatario'] ?? 'Voluntario Biosferas',
      documentoIdentidad: json['documento_identidad'] ?? '1.098.765.432',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo == CertificateType.donacion ? 'donacion' : 'voluntariado',
      'titulo': titulo,
      'actividad_titulo': actividadTitulo,
      'horas': horas,
      'monto': monto,
      'fecha_emision': fechaEmision.toIso8601String(),
      'estado': estado,
      'codigo_verificacion': codigoVerificacion,
      'firmado_por': firmadoPor,
      'destinatario': destinatario,
      'documento_identidad': documentoIdentidad,
    };
  }
}
