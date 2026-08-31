import '../../domain/entities/user.dart';

/// Modelo de datos serializable para Usuario (DTO)
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.nombres,
    required super.apellidos,
    required super.correo,
    super.fechaNacimiento,
    super.telefono,
    super.rol = 'voluntario',
    super.fotoUrl,
    super.horasAcumuladas = 0,
    super.totalCertificados = 0,
    super.totalDonaciones = 0.0,
    super.metaAnualHoras = 20,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      nombres: json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
      correo: json['correo'] ?? '',
      fechaNacimiento: json['fecha_nacimiento'],
      telefono: json['telefono'],
      rol: json['rol'] ?? 'voluntario',
      fotoUrl: json['foto_url'],
      horasAcumuladas: (json['horas_acumuladas'] as num?)?.toInt() ?? 0,
      totalCertificados: (json['total_certificados'] as num?)?.toInt() ?? 0,
      totalDonaciones: (json['total_donaciones'] as num?)?.toDouble() ?? 0.0,
      metaAnualHoras: (json['meta_anual_horas'] as num?)?.toInt() ?? 20,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombres': nombres,
      'apellidos': apellidos,
      'correo': correo,
      'fecha_nacimiento': fechaNacimiento,
      'telefono': telefono,
      'rol': rol,
      'foto_url': fotoUrl,
      'horas_acumuladas': horasAcumuladas,
      'total_certificados': totalCertificados,
      'total_donaciones': totalDonaciones,
      'meta_anual_horas': metaAnualHoras,
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      nombres: user.nombres,
      apellidos: user.apellidos,
      correo: user.correo,
      fechaNacimiento: user.fechaNacimiento,
      telefono: user.telefono,
      rol: user.rol,
      fotoUrl: user.fotoUrl,
      horasAcumuladas: user.horasAcumuladas,
      totalCertificados: user.totalCertificados,
      totalDonaciones: user.totalDonaciones,
      metaAnualHoras: user.metaAnualHoras,
    );
  }
}
