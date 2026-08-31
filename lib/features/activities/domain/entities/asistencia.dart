/// Entidad de Asistencia y Check-in/Check-out con sensores GPS y Podómetro
class Asistencia {
  final String id;
  final String? postulacionId;
  final String usuarioId;
  final String actividadId;
  final double latRegistrada;
  final double lngRegistrada;
  final int distanciaMetros;
  final String precisionGps;
  final DateTime checkInAt;
  final DateTime? checkOutAt;
  final int pasosSesion;
  final double distanciaKm;
  final int calorias;

  const Asistencia({
    required this.id,
    this.postulacionId,
    required this.usuarioId,
    required this.actividadId,
    required this.latRegistrada,
    required this.lngRegistrada,
    required this.distanciaMetros,
    required this.precisionGps,
    required this.checkInAt,
    this.checkOutAt,
    this.pasosSesion = 0,
    this.distanciaKm = 0.0,
    this.calorias = 0,
  });

  bool get estaEnCurso => checkOutAt == null;

  Asistencia copyWith({
    String? id,
    String? postulacionId,
    String? usuarioId,
    String? actividadId,
    double? latRegistrada,
    double? lngRegistrada,
    int? distanciaMetros,
    String? precisionGps,
    DateTime? checkInAt,
    DateTime? checkOutAt,
    int? pasosSesion,
    double? distanciaKm,
    int? calorias,
  }) {
    return Asistencia(
      id: id ?? this.id,
      postulacionId: postulacionId ?? this.postulacionId,
      usuarioId: usuarioId ?? this.usuarioId,
      actividadId: actividadId ?? this.actividadId,
      latRegistrada: latRegistrada ?? this.latRegistrada,
      lngRegistrada: lngRegistrada ?? this.lngRegistrada,
      distanciaMetros: distanciaMetros ?? this.distanciaMetros,
      precisionGps: precisionGps ?? this.precisionGps,
      checkInAt: checkInAt ?? this.checkInAt,
      checkOutAt: checkOutAt ?? this.checkOutAt,
      pasosSesion: pasosSesion ?? this.pasosSesion,
      distanciaKm: distanciaKm ?? this.distanciaKm,
      calorias: calorias ?? this.calorias,
    );
  }
}
