import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Almacén persistente y sincronizado de postulaciones para el panel administrativo.
class AdminPostulacionesStore {
  AdminPostulacionesStore._();

  static const String _storageKey = 'fundapp_admin_postulaciones_list';

  static final List<Map<String, dynamic>> _defaultPostulaciones = [
    {
      'id': 'post-101',
      'voluntario': 'Carlos Alberto Ruiz',
      'correo': 'carlos.ruiz@correo.com',
      'actividad': 'Reforestación Río Bosque',
      'fecha': '2026-09-05',
      'estado': 'Pendiente',
    },
    {
      'id': 'post-102',
      'voluntario': 'María José Gómez',
      'correo': 'maria.gomez@correo.com',
      'actividad': 'Limpieza de Humedal Córdoba',
      'fecha': '2026-09-19',
      'estado': 'Aprobada',
    },
    {
      'id': 'post-103',
      'voluntario': 'Andrés Felipe Castro',
      'correo': 'andres.c@correo.com',
      'actividad': 'Jornada de Reciclaje Urbano',
      'fecha': '2026-09-11',
      'estado': 'Pendiente',
    },
    {
      'id': 'post-104',
      'voluntario': 'Diana Marcela Torres',
      'correo': 'diana.torres@correo.com',
      'actividad': 'Educación Ambiental Escolar',
      'fecha': '2026-09-25',
      'estado': 'Aprobada',
    },
  ];

  static Future<List<Map<String, dynamic>>> getPostulaciones() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final List decoded = jsonDecode(jsonStr);
        final list = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        if (list.isNotEmpty) return list;
      } catch (_) {}
    }
    // Si llegamos aquí, la lista está vacía o hubo error, devolvemos los mock y los guardamos
    await prefs.setString(_storageKey, jsonEncode(_defaultPostulaciones));
    return List<Map<String, dynamic>>.from(_defaultPostulaciones);
  }

  /// Registra una nueva postulación en el almacenamiento del admin
  static Future<void> savePostulacion(Map<String, dynamic> data) async {
    final list = await getPostulaciones();
    list.removeWhere((p) => p['id'] == data['id'] || (p['actividad'] == data['actividad'] && p['correo'] == data['correo']));
    list.insert(0, data);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(list));
  }

  /// Actualiza el estado de una postulación (Aprobada / Rechazada / Pendiente)
  static Future<void> updateEstado(String id, String nuevoEstado) async {
    final list = await getPostulaciones();
    final index = list.indexWhere((p) => p['id'] == id);
    if (index != -1) {
      list[index]['estado'] = nuevoEstado;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(list));
    }
  }
}
