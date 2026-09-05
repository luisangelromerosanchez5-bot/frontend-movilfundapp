import '../entities/activity.dart';
import '../entities/asistencia.dart';
import '../entities/postulacion.dart';

abstract class ActivityRepository {
  Future<List<Activity>> getActivities({String? query, String? categoria});
  Future<Activity?> getActivityById(String id);
  Future<List<Postulacion>> getUserPostulaciones(String usuarioId);
  Future<bool> postularseActividad({
    required String actividadId,
    required String usuarioId,
    required String nombres,
    required String correo,
    String? notas,
    String? actividadTitulo,
    String? actividadFecha,
    String? actividadHora,
    String? actividadUbicacion,
  });
  Future<Asistencia> checkInAsistencia({
    required String actividadId,
    required String usuarioId,
    required double lat,
    required double lng,
    required int distanciaMetros,
    required String precisionGps,
  });
  Future<Asistencia> checkOutAsistencia({
    required String asistenciaId,
    required int pasosSesion,
    required double distanciaKm,
    required int calorias,
    String? fotoEvidenciaUrl,
  });
}
