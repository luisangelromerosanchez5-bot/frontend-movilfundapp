import 'package:flutter_test/flutter_test.dart';
import 'package:fundapp_mobile/features/activities/data/models/activity_model.dart';
import 'package:fundapp_mobile/features/activities/data/models/asistencia_model.dart';

void main() {
  group('ActivityModel and AsistenciaModel Tests', () {
    test('Parsea ActivityModel desde JSON correctamente', () {
      final json = {
        'id': 'act-001',
        'titulo': 'Reforestación Río Bosque',
        'descripcion': 'Siembra de árboles',
        'categoria': 'Reforestación',
        'fecha': '2026-09-05',
        'hora': '08:00 AM',
        'duracion_horas': 4,
        'cupos_totales': 30,
        'cupos_ocupados': 18,
        'estado_cupos': 'disponible',
        'ubicacion_nombre': 'Vereda El Bosque',
        'latitud': 4.711000,
        'longitud': -74.072100,
        'radio_permitido_metros': 100,
        'puntos_impacto': 150,
      };

      final model = ActivityModel.fromJson(json);

      expect(model.id, 'act-001');
      expect(model.titulo, 'Reforestación Río Bosque');
      expect(model.estaDisponible, isTrue);
      expect(model.cuposRestantes, 12);
    });

    test('Parsea AsistenciaModel con métricas de podómetro y GPS', () {
      final json = {
        'id': 'asist-001',
        'usuario_id': 'u101',
        'actividad_id': 'act-001',
        'lat_registrada': 4.711000,
        'lng_registrada': -74.072100,
        'distancia_metros': 38,
        'precision_gps': 'Alta',
        'check_in_at': '2026-08-31T08:00:00.000Z',
        'pasos_sesion': 6482,
        'distancia_km': 4.6,
        'calorias': 259,
      };

      final model = AsistenciaModel.fromJson(json);

      expect(model.distanciaMetros, 38);
      expect(model.pasosSesion, 6482);
      expect(model.precisionGps, 'Alta');
      expect(model.estaEnCurso, isTrue);
    });
  });
}
