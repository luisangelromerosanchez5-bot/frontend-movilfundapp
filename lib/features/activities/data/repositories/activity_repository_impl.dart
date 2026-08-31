import '../../domain/entities/activity.dart';
import '../../domain/entities/asistencia.dart';
import '../../domain/entities/postulacion.dart';
import '../../domain/repositories/activity_repository.dart';
import '../datasources/activity_remote_data_source.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityRemoteDataSource remoteDataSource;

  ActivityRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Activity>> getActivities({String? query, String? categoria}) async {
    return await remoteDataSource.getActivities(query: query, categoria: categoria);
  }

  @override
  Future<Activity?> getActivityById(String id) async {
    return await remoteDataSource.getActivityById(id);
  }

  @override
  Future<List<Postulacion>> getUserPostulaciones(String usuarioId) async {
    return await remoteDataSource.getUserPostulaciones(usuarioId);
  }

  @override
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
  }) async {
    return await remoteDataSource.postularseActividad({
      'actividad_id': actividadId,
      'usuario_id': usuarioId,
      'nombres': nombres,
      'correo': correo,
      'notas': notas,
      'actividad_titulo': actividadTitulo,
      'actividad_fecha': actividadFecha,
      'actividad_hora': actividadHora,
      'actividad_ubicacion': actividadUbicacion,
    });
  }

  @override
  Future<Asistencia> checkInAsistencia({
    required String actividadId,
    required String usuarioId,
    required double lat,
    required double lng,
    required int distanciaMetros,
    required String precisionGps,
  }) async {
    return await remoteDataSource.checkInAsistencia({
      'actividad_id': actividadId,
      'usuario_id': usuarioId,
      'lat_registrada': lat,
      'lng_registrada': lng,
      'distancia_metros': distanciaMetros,
      'precision_gps': precisionGps,
    });
  }

  @override
  Future<Asistencia> checkOutAsistencia({
    required String asistenciaId,
    required int pasosSesion,
    required double distanciaKm,
    required int calorias,
  }) async {
    return await remoteDataSource.checkOutAsistencia({
      'asistencia_id': asistenciaId,
      'pasos_sesion': pasosSesion,
      'distancia_km': distanciaKm,
      'calorias': calorias,
    });
  }
}
