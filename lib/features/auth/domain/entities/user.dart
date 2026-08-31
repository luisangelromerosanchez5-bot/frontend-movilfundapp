/// Entidad de dominio de Usuario
class User {
  final String id;
  final String nombres;
  final String apellidos;
  final String correo;
  final String? fechaNacimiento;
  final String? telefono;
  final String rol;
  final String? fotoUrl;
  final int horasAcumuladas;
  final int totalCertificados;
  final double totalDonaciones;
  final int metaAnualHoras;

  const User({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.correo,
    this.fechaNacimiento,
    this.telefono,
    this.rol = 'voluntario',
    this.fotoUrl,
    this.horasAcumuladas = 0,
    this.totalCertificados = 0,
    this.totalDonaciones = 0.0,
    this.metaAnualHoras = 20,
  });

  String get nombreCompleto => '$nombres $apellidos'.trim();

  User copyWith({
    String? id,
    String? nombres,
    String? apellidos,
    String? correo,
    String? fechaNacimiento,
    String? telefono,
    String? rol,
    String? fotoUrl,
    int? horasAcumuladas,
    int? totalCertificados,
    double? totalDonaciones,
    int? metaAnualHoras,
  }) {
    return User(
      id: id ?? this.id,
      nombres: nombres ?? this.nombres,
      apellidos: apellidos ?? this.apellidos,
      correo: correo ?? this.correo,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      telefono: telefono ?? this.telefono,
      rol: rol ?? this.rol,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      horasAcumuladas: horasAcumuladas ?? this.horasAcumuladas,
      totalCertificados: totalCertificados ?? this.totalCertificados,
      totalDonaciones: totalDonaciones ?? this.totalDonaciones,
      metaAnualHoras: metaAnualHoras ?? this.metaAnualHoras,
    );
  }
}
