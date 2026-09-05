import '../../domain/entities/postulacion.dart';

class PostulacionModel extends Postulacion {
  const PostulacionModel({
    required super.id,
    required super.actividadId,
    required super.usuarioId,
    required super.actividadTitulo,
    super.actividadCategoria = 'Voluntariado',
    super.actividadFecha = '2026-09-05',
    super.actividadHora = '08:00 AM',
    super.actividadUbicacion = 'Punto de encuentro',
    super.estado = 'aprobada',
    required super.fechaPostulacion,
  });

  factory PostulacionModel.fromJson(Map<String, dynamic> json) {
    return PostulacionModel(
      id: json['id']?.toString() ?? json['idpostulaciones']?.toString() ?? '',
      actividadId: json['actividad_id']?.toString() ?? json['actividades_idactividades']?.toString() ?? '',
      usuarioId: json['usuario_id']?.toString() ?? json['usuarios_idusuarios']?.toString() ?? '',
      actividadTitulo: json['actividad_titulo'] ?? json['comentario'] ?? 'Jornada Ambiental',
      actividadCategoria: json['actividad_categoria'] ?? 'Voluntariado',
      actividadFecha: json['actividad_fecha'] ?? json['fechapostulacion'] ?? '2026-09-05',
      actividadHora: json['actividad_hora'] ?? '08:00 AM',
      actividadUbicacion: json['actividad_ubicacion'] ?? 'Punto de encuentro',
      estado: json['estado'] ?? json['estadopostulacion'] ?? 'aprobada',
      fechaPostulacion: json['fecha_postulacion'] != null
          ? DateTime.parse(json['fecha_postulacion'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'actividad_id': actividadId,
      'usuario_id': usuarioId,
      'actividad_titulo': actividadTitulo,
      'actividad_categoria': actividadCategoria,
      'actividad_fecha': actividadFecha,
      'actividad_hora': actividadHora,
      'actividad_ubicacion': actividadUbicacion,
      'estado': estado,
      'fecha_postulacion': fechaPostulacion.toIso8601String(),
    };
  }
}
