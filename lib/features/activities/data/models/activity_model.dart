import '../../domain/entities/activity.dart';

class ActivityModel extends Activity {
  const ActivityModel({
    required super.id,
    required super.titulo,
    required super.descripcion,
    required super.categoria,
    required super.fecha,
    required super.hora,
    required super.duracionHoras,
    required super.cuposTotales,
    required super.cuposOcupados,
    required super.estadoCupos,
    required super.ubicacionNombre,
    required super.latitud,
    required super.longitud,
    super.radioPermitidoMetros = 100,
    super.puntosImpacto = 100,
    super.tags = const [],
    super.imagenUrl,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      categoria: json['categoria'] ?? 'General',
      fecha: json['fecha'] ?? '',
      hora: json['hora'] ?? '',
      duracionHoras: (json['duracion_horas'] as num?)?.toInt() ?? 2,
      cuposTotales: (json['cupos_totales'] as num?)?.toInt() ?? 20,
      cuposOcupados: (json['cupos_ocupados'] as num?)?.toInt() ?? 0,
      estadoCupos: json['estado_cupos'] ?? 'disponible',
      ubicacionNombre: json['ubicacion_nombre'] ?? '',
      latitud: (json['latitud'] as num?)?.toDouble() ?? 4.7110,
      longitud: (json['longitud'] as num?)?.toDouble() ?? -74.0721,
      radioPermitidoMetros: (json['radio_permitido_metros'] as num?)?.toInt() ?? 100,
      puntosImpacto: (json['puntos_impacto'] as num?)?.toInt() ?? 100,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : const [],
      imagenUrl: json['imagen_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'categoria': categoria,
      'fecha': fecha,
      'hora': hora,
      'duracion_horas': duracionHoras,
      'cupos_totales': cuposTotales,
      'cupos_ocupados': cuposOcupados,
      'estado_cupos': estadoCupos,
      'ubicacion_nombre': ubicacionNombre,
      'latitud': latitud,
      'longitud': longitud,
      'radio_permitido_metros': radioPermitidoMetros,
      'puntos_impacto': puntosImpacto,
      'tags': tags,
      'imagen_url': imagenUrl,
    };
  }
}
