import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

/// Servicio para captura y selección de imágenes con la cámara o galería
class CameraService {
  final ImagePicker _picker = ImagePicker();

  /// Solicita permisos de cámara
  Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      if (status.isGranted) return true;
      if (status.isPermanentlyDenied) {
        return false;
      }
      return true;
    } catch (e) {
      debugPrint('[CameraService] Error solicitando permiso de cámara: $e');
      return true;
    }
  }

  /// Toma una foto con la cámara del dispositivo
  Future<String?> takePhoto() async {
    try {
      await requestCameraPermission();
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (photo != null) {
        await saveProfilePhotoPath(photo.path);
        return photo.path;
      }
      return null;
    } catch (e) {
      debugPrint('[CameraService] Error tomando foto con la cámara: $e');
      return null;
    }
  }

  /// Selecciona una foto de la galería
  Future<String?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        await saveProfilePhotoPath(image.path);
        return image.path;
      }
      return null;
    } catch (e) {
      debugPrint('[CameraService] Error seleccionando imagen de galería: $e');
      return null;
    }
  }

  /// Guarda la ruta local de la foto de perfil en SharedPreferences
  Future<void> saveProfilePhotoPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConstants.profilePhotoKey, path);
  }

  /// Obtiene la ruta guardada de la foto de perfil
  Future<String?> getSavedProfilePhotoPath() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(ApiConstants.profilePhotoKey);
    if (path != null && File(path).existsSync()) {
      return path;
    }
    return path;
  }
}
