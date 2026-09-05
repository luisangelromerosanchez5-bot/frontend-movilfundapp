class Postulacion {
  final String id;
  final String actividadId;
  final String usuarioId;
  final String actividadTitulo;
  final String actividadCategoria;
  final String actividadFecha;
  final String actividadHora;
  final String actividadUbicacion;
  final String estado; // 'aprobada', 'en_proceso'
  final DateTime fechaPostulacion;

  const Postulacion({
    required this.id,
    required this.actividadId,
    required this.usuarioId,
    required this.actividadTitulo,
    this.actividadCategoria = 'Voluntariado',
    this.actividadFecha = '2026-09-05',
    this.actividadHora = '08:00 AM',
    this.actividadUbicacion = 'Punto de encuentro',
    this.estado = 'aprobada',
    required this.fechaPostulacion,
  });
}
