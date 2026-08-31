import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/camera_service.dart';

class ProfileAvatar extends StatefulWidget {
  final String? initialPhotoPath;
  final String initials;
  final ValueChanged<String>? onPhotoChanged;

  const ProfileAvatar({
    super.key,
    this.initialPhotoPath,
    required this.initials,
    this.onPhotoChanged,
  });

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  final CameraService _cameraService = CameraService();
  String? _currentPhotoPath;

  @override
  void initState() {
    super.initState();
    _currentPhotoPath = widget.initialPhotoPath;
    _loadSavedPhoto();
  }

  Future<void> _loadSavedPhoto() async {
    final saved = await _cameraService.getSavedProfilePhotoPath();
    if (saved != null && mounted) {
      setState(() {
        _currentPhotoPath = saved;
      });
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Foto de perfil',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.secondaryUltraLight,
                  child: Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                ),
                title: const Text('Tomar foto con la cámara'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final path = await _cameraService.takePhoto();
                  if (path != null && mounted) {
                    setState(() => _currentPhotoPath = path);
                    widget.onPhotoChanged?.call(path);
                  }
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.secondaryUltraLight,
                  child: Icon(Icons.photo_library_rounded, color: AppColors.primary),
                ),
                title: const Text('Elegir de la galería'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final path = await _cameraService.pickFromGallery();
                  if (path != null && mounted) {
                    setState(() => _currentPhotoPath = path);
                    widget.onPhotoChanged?.call(path);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasLocalImage = _currentPhotoPath != null &&
        File(_currentPhotoPath!).existsSync();

    return Center(
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.15),
              border: Border.all(color: AppColors.secondary, width: 2.5),
              image: hasLocalImage
                  ? DecorationImage(
                      image: FileImage(File(_currentPhotoPath!)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: !hasLocalImage
                ? Center(
                    child: Text(
                      widget.initials,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _showImagePickerModal,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
