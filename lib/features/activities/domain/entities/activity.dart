/// Entidad de dominio de Actividad Ambiental
class Activity {
  final String id;
  final String titulo;
  final String descripcion;
  final String categoria;
  final String fecha;
  final String hora;
  final int duracionHoras;
  final int cuposTotales;
  final int cuposOcupados;
  final String estadoCupos; // 'disponible' | 'lleno'
  final String ubicacionNombre;
  final double latitud;
  final double longitud;
  final int radioPermitidoMetros;
  final int puntosImpacto;
  final List<String> tags;
  final String? imagenUrl;

  const Activity({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.fecha,
    required this.hora,
    required this.duracionHoras,
    required this.cuposTotales,
    required this.cuposOcupados,
    required this.estadoCupos,
    required this.ubicacionNombre,
    required this.latitud,
    required this.longitud,
    this.radioPermitidoMetros = 100,
    this.puntosImpacto = 100,
    this.tags = const [],
    this.imagenUrl,
  });

  bool get estaDisponible => estadoCupos.toLowerCase() == 'disponible' && cuposOcupados < cuposTotales;
  int get cuposRestantes => (cuposTotales - cuposOcupados).clamp(0, cuposTotales);
}
