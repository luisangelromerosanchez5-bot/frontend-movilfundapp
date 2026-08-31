import '../../domain/entities/volunteer_stats.dart';

class VolunteerStatsModel extends VolunteerStats {
  const VolunteerStatsModel({
    required super.horasAcumuladas,
    required super.totalCertificados,
    required super.totalDonaciones,
    required super.metaAnualHoras,
  });

  factory VolunteerStatsModel.fromJson(Map<String, dynamic> json) {
    return VolunteerStatsModel(
      horasAcumuladas: (json['horas_acumuladas'] as num?)?.toInt() ?? 0,
      totalCertificados: (json['total_certificados'] as num?)?.toInt() ?? 0,
      totalDonaciones: (json['total_donaciones'] as num?)?.toDouble() ?? 0.0,
      metaAnualHoras: (json['meta_anual_horas'] as num?)?.toInt() ?? 20,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'horas_acumuladas': horasAcumuladas,
      'total_certificados': totalCertificados,
      'total_donaciones': totalDonaciones,
      'meta_anual_horas': metaAnualHoras,
    };
  }
}
