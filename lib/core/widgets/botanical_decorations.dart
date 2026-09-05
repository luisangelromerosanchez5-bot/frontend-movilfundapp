import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Painter personalizado que dibuja delicadas hojas botánicas y curvas de la naturaleza
class BotanicalLeavesPainter extends CustomPainter {
  final Color leafColor;
  final double opacity;

  BotanicalLeavesPainter({
    this.leafColor = const Color(0xFF2E6F40),
    this.opacity = 0.12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = leafColor.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = leafColor.withValues(alpha: opacity * 1.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Dibujar hoja superior derecha
    _drawLeaf(
      canvas: canvas,
      center: Offset(size.width - 20, 30),
      size: 60,
      angle: -math.pi / 4,
      fillPaint: paint,
      strokePaint: linePaint,
    );

    // Dibujar hoja secundaria superior derecha
    _drawLeaf(
      canvas: canvas,
      center: Offset(size.width - 65, 15),
      size: 40,
      angle: -math.pi / 6,
      fillPaint: paint,
      strokePaint: linePaint,
    );

    // Dibujar hoja inferior izquierda
    _drawLeaf(
      canvas: canvas,
      center: Offset(25, size.height - 25),
      size: 55,
      angle: math.pi * 0.75,
      fillPaint: paint,
      strokePaint: linePaint,
    );

    // Dibujar hoja secundaria inferior izquierda
    _drawLeaf(
      canvas: canvas,
      center: Offset(65, size.height - 15),
      size: 38,
      angle: math.pi * 0.6,
      fillPaint: paint,
      strokePaint: linePaint,
    );
  }

  void _drawLeaf({
    required Canvas canvas,
    required Offset center,
    required double size,
    required double angle,
    required Paint fillPaint,
    required Paint strokePaint,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final path = Path();
    path.moveTo(0, -size / 2);
    // Curva derecha
    path.quadraticBezierTo(size / 2.2, 0, 0, size / 2);
    // Curva izquierda
    path.quadraticBezierTo(-size / 2.2, 0, 0, -size / 2);
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Nervadura central de la hoja
    canvas.drawLine(Offset(0, -size / 2), Offset(0, size / 2), strokePaint);

    // Nervaduras laterales
    canvas.drawLine(Offset(0, -size * 0.2), Offset(size * 0.18, -size * 0.1), strokePaint);
    canvas.drawLine(Offset(0, -size * 0.2), Offset(-size * 0.18, -size * 0.1), strokePaint);
    canvas.drawLine(Offset(0, size * 0.1), Offset(size * 0.18, size * 0.2), strokePaint);
    canvas.drawLine(Offset(0, size * 0.1), Offset(-size * 0.18, size * 0.2), strokePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BotanicalLeavesPainter oldDelegate) {
    return oldDelegate.leafColor != leafColor || oldDelegate.opacity != opacity;
  }
}

/// Contenedor botánico decorado con hojas y degradado ecológico
class BotanicalCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Gradient? gradient;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final bool showLeaves;
  final Border? border;

  const BotanicalCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.gradient,
    this.backgroundColor,
    this.borderRadius,
    this.showLeaves = true,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final r = borderRadius ?? BorderRadius.circular(16);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? (isDark ? AppColors.cardDark : Colors.white),
        gradient: gradient,
        borderRadius: r,
        border: border ??
            Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1,
            ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.primary).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: r,
        child: Stack(
          children: [
            if (showLeaves)
              Positioned.fill(
                child: CustomPaint(
                  painter: BotanicalLeavesPainter(
                    leafColor: isDark ? AppColors.secondaryLight : AppColors.primary,
                    opacity: isDark ? 0.08 : 0.06,
                  ),
                ),
              ),
            Padding(
              padding: padding ?? const EdgeInsets.all(16),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge con hoja orgánica y texto
class LeafTag extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color? color;
  final Color? textColor;

  const LeafTag({
    super.key,
    required this.text,
    this.icon = Icons.eco_rounded,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: activeColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: activeColor.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: activeColor),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor ?? activeColor,
            ),
          ),
        ],
      ),
    );
  }
}
