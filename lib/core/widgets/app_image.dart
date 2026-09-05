import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppImage extends StatelessWidget {
  final String? imagePathOrUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;

  const AppImage({
    super.key,
    required this.imagePathOrUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final src = imagePathOrUrl?.trim() ?? '';
    final defaultPlaceholder = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: borderRadius,
      ),
      child: const Icon(Icons.forest_rounded, color: AppColors.primary, size: 32),
    );

    Widget imageWidget;
    if (src.isEmpty) {
      imageWidget = placeholder ?? defaultPlaceholder;
    } else if (src.startsWith('assets/')) {
      imageWidget = Image.asset(
        src,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => placeholder ?? defaultPlaceholder,
      );
    } else {
      imageWidget = Image.network(
        src,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => placeholder ?? defaultPlaceholder,
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }
    return imageWidget;
  }
}
