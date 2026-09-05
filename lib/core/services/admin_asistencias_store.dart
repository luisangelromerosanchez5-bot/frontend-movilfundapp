import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AdminAsistenciasStore {
  AdminAsistenciasStore._();

  static const String _key = 'fundapp_admin_asistencias_list';
  static final List<Map<String, dynamic>> _inMemory = [];

  static const List<Map<String, dynamic>> defaultSampleAsistencias = [
    {
      'id': 'asist-01',
      'voluntario': 'Luis Fernando Pérez',
      'actividad': 'Reforestación Río Bosque',
      'fecha': '2026-08-31',
      'pasos': 6482,
      'distancia_km': 4.6,
      'gps_precision': 'Alta (38m)',
      'foto_evidencia': 'assets/images/act_reforestacion_rio.jpg',
    },
    {
      'id': 'asist-02',
      'voluntario': 'Camila Torres',
      'actividad': 'Limpieza de Humedal Córdoba',
      'fecha': '2026-08-28',
      'pasos': 8210,
      'distancia_km': 5.8,
      'gps_precision': 'Alta (12m)',
      'foto_evidencia': 'assets/images/act_humedal_cordoba.jpg',
    },
  ];

  static Future<void> saveRealAsistencia(Map<String, dynamic> record) async {
    _inMemory.removeWhere((item) => item['id'] == record['id']);
    _inMemory.insert(0, record);

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedJson = prefs.getString(_key);
      List<dynamic> list = [];
      if (storedJson != null) {
        try {
          list = jsonDecode(storedJson) as List<dynamic>;
        } catch (_) {}
      }

      list.removeWhere((item) => (item as Map<String, dynamic>)['id'] == record['id']);
      list.insert(0, record);

      await prefs.setString(_key, jsonEncode(list));
    } catch (_) {}
  }

  static Future<List<Map<String, dynamic>>> getAsistencias() async {
    final List<Map<String, dynamic>> result = [];

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedJson = prefs.getString(_key);
      if (storedJson != null) {
        final decoded = jsonDecode(storedJson) as List<dynamic>;
        for (final item in decoded) {
          result.add(Map<String, dynamic>.from(item as Map));
        }
      }
    } catch (_) {}

    // Fusionar con registros en memoria que no estén en result
    for (final mem in _inMemory) {
      if (!result.any((r) => r['id'] == mem['id'])) {
        result.insert(0, mem);
      }
    }

    // Agregar las asistencias de ejemplo al final si no están presentes
    for (final sample in defaultSampleAsistencias) {
      if (!result.any((r) => r['id'] == sample['id'])) {
        result.add(sample);
      }
    }

    return result;
  }
}
