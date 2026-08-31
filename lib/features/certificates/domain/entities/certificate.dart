enum CertificateType {
  voluntariado,
  donacion,
}

/// Entidad de Certificado oficial emitido por Fundación Biosferas
class Certificate {
  final String id;
  final CertificateType tipo;
  final String titulo;
  final String actividadTitulo;
  final int? horas;
  final double? monto;
  final DateTime fechaEmision;
  final String estado; // 'aprobado' | 'en_proceso'
  final String codigoVerificacion;
  final String firmadoPor;
  final String destinatario;
  final String documentoIdentidad;

  const Certificate({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.actividadTitulo,
    this.horas,
    this.monto,
    required this.fechaEmision,
    required this.estado,
    required this.codigoVerificacion,
    required this.firmadoPor,
    required this.destinatario,
    required this.documentoIdentidad,
  });

  bool get estaAprobado => estado.toLowerCase() == 'aprobado';
}
