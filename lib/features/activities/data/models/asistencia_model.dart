import '../../domain/entities/asistencia.dart';

class AsistenciaModel extends Asistencia {
  const AsistenciaModel({
    required super.id,
    super.postulacionId,
    required super.usuarioId,
    required super.actividadId,
    required super.latRegistrada,
    required super.lngRegistrada,
    required super.distanciaMetros,
    required super.precisionGps,
    required super.checkInAt,
    super.checkOutAt,
    super.pasosSesion = 0,
    super.distanciaKm = 0.0,
    super.calorias = 0,
  });

  factory AsistenciaModel.fromJson(Map<String, dynamic> json) {
    return AsistenciaModel(
      id: json['id'] ?? '',
      postulacionId: json['postulacion_id'],
      usuarioId: json['usuario_id'] ?? '',
      actividadId: json['actividad_id'] ?? '',
      latRegistrada: (json['lat_registrada'] as num?)?.toDouble() ?? 0.0,
      lngRegistrada: (json['lng_registrada'] as num?)?.toDouble() ?? 0.0,
      distanciaMetros: (json['distancia_metros'] as num?)?.toInt() ?? 0,
      precisionGps: json['precision_gps'] ?? 'Alta',
      checkInAt: json['check_in_at'] != null
          ? DateTime.parse(json['check_in_at'])
          : DateTime.now(),
      checkOutAt: json['check_out_at'] != null
          ? DateTime.parse(json['check_out_at'])
          : null,
      pasosSesion: (json['pasos_sesion'] as num?)?.toInt() ?? 0,
      distanciaKm: (json['distancia_km'] as num?)?.toDouble() ?? 0.0,
      calorias: (json['calorias'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postulacion_id': postulacionId,
      'usuario_id': usuarioId,
      'actividad_id': actividadId,
      'lat_registrada': latRegistrada,
      'lng_registrada': lngRegistrada,
      'distancia_metros': distanciaMetros,
      'precision_gps': precisionGps,
      'check_in_at': checkInAt.toIso8601String(),
      'check_out_at': checkOutAt?.toIso8601String(),
      'pasos_sesion': pasosSesion,
      'distancia_km': distanciaKm,
      'calorias': calorias,
    };
  }
}
