import 'package:uuid/uuid.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/mock_data.dart';
import '../models/activity_model.dart';
import '../models/asistencia_model.dart';
import '../models/postulacion_model.dart';

abstract class ActivityRemoteDataSource {
  Future<List<ActivityModel>> getActivities({String? query, String? categoria});
  Future<ActivityModel?> getActivityById(String id);
  Future<List<PostulacionModel>> getUserPostulaciones(String usuarioId);
  Future<bool> postularseActividad(Map<String, dynamic> data);
  Future<AsistenciaModel> checkInAsistencia(Map<String, dynamic> data);
  Future<AsistenciaModel> checkOutAsistencia(Map<String, dynamic> data);
}

class ActivityRemoteDataSourceImpl implements ActivityRemoteDataSource {
  final ApiClient apiClient;
  final List<ActivityModel> _localActivities = [];
  final List<AsistenciaModel> _localAsistencias = [];
  static final List<PostulacionModel> _localPostulaciones = [];

  ActivityRemoteDataSourceImpl({required this.apiClient}) {
    _localActivities.addAll(
      MockData.sampleActivities.map((json) => ActivityModel.fromJson(json)),
    );
  }

  @override
  Future<List<ActivityModel>> getActivities({String? query, String? categoria}) async {
    List<ActivityModel> list;
    try {
      final response = await apiClient.dio.get(
        ApiConstants.activities,
        queryParameters: {
          if (query != null && query.isNotEmpty) 'q': query,
          if (categoria != null && categoria != 'Todos') 'categoria': categoria,
        },
      );
      list = (response.data as List).map((e) => ActivityModel.fromJson(e)).toList();
      if (list.isEmpty) {
        list = List<ActivityModel>.from(_localActivities);
      }
    } catch (_) {
      list = List<ActivityModel>.from(_localActivities);
    }

    var result = list;
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      result = result.where((a) {
        final matchTitle = a.titulo.toLowerCase().contains(q);
        final matchDesc = a.descripcion.toLowerCase().contains(q);
        final matchUbi = a.ubicacionNombre.toLowerCase().contains(q);
        final matchCat = a.categoria.toLowerCase().contains(q);
        final matchTags = a.tags.any((t) => t.toLowerCase().contains(q));
        return matchTitle || matchDesc || matchUbi || matchCat || matchTags;
      }).toList();
    }

    if (categoria != null && categoria.trim().isNotEmpty && categoria != 'Todos') {
      final c = categoria.trim().toLowerCase();
      result = result.where((a) => a.categoria.trim().toLowerCase() == c).toList();
    }

    return result;
  }

  @override
  Future<ActivityModel?> getActivityById(String id) async {
    try {
      final response = await apiClient.dio.get('${ApiConstants.activities}/$id');
      return ActivityModel.fromJson(response.data);
    } catch (_) {
      try {
        return _localActivities.firstWhere((a) => a.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  @override
  Future<List<PostulacionModel>> getUserPostulaciones(String usuarioId) async {
    try {
      final response = await apiClient.dio.get('${ApiConstants.postulaciones}/usuario/$usuarioId');
      final remote = (response.data as List).map((e) => PostulacionModel.fromJson(e)).toList();
      return [..._localPostulaciones.where((p) => p.usuarioId == usuarioId), ...remote];
    } catch (_) {
      final userPosts = _localPostulaciones.where((p) => p.usuarioId == usuarioId).toList();
      if (userPosts.isNotEmpty) return userPosts;

      // Si no hay aún, retornar postulaciones registradas en memoria
      return userPosts;
    }
  }

  @override
  Future<bool> postularseActividad(Map<String, dynamic> data) async {
    final actId = data['actividad_id']?.toString() ?? '';
    final userId = data['usuario_id']?.toString() ?? '1';
    final actTitulo = data['actividad_titulo'] ?? 'Actividad de Voluntariado';
    final actFecha = data['actividad_fecha'] ?? '2026-09-05';
    final actHora = data['actividad_hora'] ?? '08:00 AM';
    final actUbicacion = data['actividad_ubicacion'] ?? 'Punto de encuentro';

    final newPost = PostulacionModel(
      id: const Uuid().v4(),
      actividadId: actId,
      usuarioId: userId,
      actividadTitulo: actTitulo,
      actividadFecha: actFecha,
      actividadHora: actHora,
      actividadUbicacion: actUbicacion,
      estado: 'aprobada',
      fechaPostulacion: DateTime.now(),
    );

    // Evitar duplicados
    _localPostulaciones.removeWhere((p) => p.actividadId == actId && p.usuarioId == userId);
    _localPostulaciones.insert(0, newPost);

    try {
      await apiClient.dio.post(ApiConstants.postulaciones, data: data);
      return true;
    } catch (_) {
      final index = _localActivities.indexWhere((a) => a.id == actId);
      if (index != -1) {
        final act = _localActivities[index];
        _localActivities[index] = ActivityModel(
          id: act.id,
          titulo: act.titulo,
          descripcion: act.descripcion,
          categoria: act.categoria,
          fecha: act.fecha,
          hora: act.hora,
          duracionHoras: act.duracionHoras,
          cuposTotales: act.cuposTotales,
          cuposOcupados: act.cuposOcupados + 1,
          estadoCupos: act.cuposOcupados + 1 >= act.cuposTotales ? 'lleno' : 'disponible',
          ubicacionNombre: act.ubicacionNombre,
          latitud: act.latitud,
          longitud: act.longitud,
          radioPermitidoMetros: act.radioPermitidoMetros,
          puntosImpacto: act.puntosImpacto,
          tags: act.tags,
          imagenUrl: act.imagenUrl,
        );
      }
      return true;
    }
  }

  @override
  Future<AsistenciaModel> checkInAsistencia(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.dio.post(ApiConstants.asistencias, data: data);
      return AsistenciaModel.fromJson(response.data);
    } catch (_) {
      final newAsistencia = AsistenciaModel(
        id: const Uuid().v4(),
        actividadId: data['actividad_id'] ?? '',
        usuarioId: data['usuario_id'] ?? '',
        latRegistrada: (data['lat_registrada'] as num?)?.toDouble() ?? 0.0,
        lngRegistrada: (data['lng_registrada'] as num?)?.toDouble() ?? 0.0,
        distanciaMetros: (data['distancia_metros'] as num?)?.toInt() ?? 0,
        precisionGps: data['precision_gps'] ?? 'Alta',
        checkInAt: DateTime.now(),
      );
      _localAsistencias.add(newAsistencia);
      return newAsistencia;
    }
  }

  @override
  Future<AsistenciaModel> checkOutAsistencia(Map<String, dynamic> data) async {
    try {
      final id = data['asistencia_id'];
      final response = await apiClient.dio.patch('${ApiConstants.asistencias}/$id', data: data);
      return AsistenciaModel.fromJson(response.data);
    } catch (_) {
      final id = data['asistencia_id'];
      final index = _localAsistencias.indexWhere((a) => a.id == id);
      if (index != -1) {
        final existing = _localAsistencias[index];
        final updated = AsistenciaModel(
          id: existing.id,
          postulacionId: existing.postulacionId,
          usuarioId: existing.usuarioId,
          actividadId: existing.actividadId,
          latRegistrada: existing.latRegistrada,
          lngRegistrada: existing.lngRegistrada,
          distanciaMetros: existing.distanciaMetros,
          precisionGps: existing.precisionGps,
          checkInAt: existing.checkInAt,
          checkOutAt: DateTime.now(),
          pasosSesion: (data['pasos_sesion'] as num?)?.toInt() ?? 0,
          distanciaKm: (data['distancia_km'] as num?)?.toDouble() ?? 0.0,
          calorias: (data['calorias'] as num?)?.toInt() ?? 0,
        );
        _localAsistencias[index] = updated;
        return updated;
      }

      return AsistenciaModel(
        id: id ?? const Uuid().v4(),
        usuarioId: 'u101',
        actividadId: 'act-001',
        latRegistrada: 4.711,
        lngRegistrada: -74.072,
        distanciaMetros: 38,
        precisionGps: 'Alta',
        checkInAt: DateTime.now().subtract(const Duration(minutes: 42)),
        checkOutAt: DateTime.now(),
        pasosSesion: (data['pasos_sesion'] as num?)?.toInt() ?? 6482,
        distanciaKm: (data['distancia_km'] as num?)?.toDouble() ?? 4.6,
        calorias: 259,
      );
    }
  }
}
