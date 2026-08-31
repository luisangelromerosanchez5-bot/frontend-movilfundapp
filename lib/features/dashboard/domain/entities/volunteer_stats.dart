/// Entidad de estadísticas de voluntariado e impacto
class VolunteerStats {
  final int horasAcumuladas;
  final int totalCertificados;
  final double totalDonaciones;
  final int metaAnualHoras;

  const VolunteerStats({
    required this.horasAcumuladas,
    required this.totalCertificados,
    required this.totalDonaciones,
    required this.metaAnualHoras,
  });

  double get progresoMeta => metaAnualHoras > 0 ? (horasAcumuladas / metaAnualHoras).clamp(0.0, 1.0) : 0.0;
  int get porcentajeMeta => (progresoMeta * 100).round();
}
