import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Painter avanzado que dibuja rica vegetación botánica: hojas de monstera, ramas con hojas,
/// nervaduras orgánicas, partículas de hojas flotantes y siluetas de árboles.
class BotanicalLeavesPainter extends CustomPainter {
  final Color leafColor;
  final double opacity;
  final bool showFloatingLeaves;
  final bool showTreeWatermark;

  BotanicalLeavesPainter({
    this.leafColor = const Color(0xFF2E6F40),
    this.opacity = 0.12,
    this.showFloatingLeaves = true,
    this.showTreeWatermark = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = leafColor.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = leafColor.withValues(alpha: opacity * 1.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    final accentPaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: opacity * 0.9)
      ..style = PaintingStyle.fill;

    if (showTreeWatermark) {
      _drawTreeWatermark(canvas, size, fillPaint, strokePaint);
    }

    // 1. Ramillete de hojas superior derecho
    _drawBranch(
      canvas: canvas,
      start: Offset(size.width + 10, -10),
      end: Offset(size.width - 90, 80),
      fillPaint: fillPaint,
      strokePaint: strokePaint,
    );

    // 2. Ramillete de hojas inferior izquierdo
    _drawBranch(
      canvas: canvas,
      start: Offset(-10, size.height + 10),
      end: Offset(90, size.height - 80),
      fillPaint: fillPaint,
      strokePaint: strokePaint,
    );

    // 3. Hoja grande tipo Monstera estilizada superior izquierda
    _drawMonsteraLeaf(
      canvas: canvas,
      center: Offset(20, 45),
      size: 55,
      angle: math.pi / 4,
      fillPaint: fillPaint,
      strokePaint: strokePaint,
    );

    // 4. Hoja grande inferior derecha
    _drawMonsteraLeaf(
      canvas: canvas,
      center: Offset(size.width - 25, size.height - 35),
      size: 60,
      angle: -math.pi * 0.75,
      fillPaint: fillPaint,
      strokePaint: strokePaint,
    );

    // 5. Pequeñas hojas flotantes ambientales en el lienzo
    if (showFloatingLeaves) {
      _drawLeaf(
        canvas: canvas,
        center: Offset(size.width * 0.22, size.height * 0.35),
        size: 18,
        angle: 0.3,
        fillPaint: accentPaint,
        strokePaint: strokePaint,
      );
      _drawLeaf(
        canvas: canvas,
        center: Offset(size.width * 0.82, size.height * 0.45),
        size: 22,
        angle: -0.6,
        fillPaint: accentPaint,
        strokePaint: strokePaint,
      );
      _drawLeaf(
        canvas: canvas,
        center: Offset(size.width * 0.15, size.height * 0.72),
        size: 16,
        angle: 0.8,
        fillPaint: accentPaint,
        strokePaint: strokePaint,
      );
      _drawLeaf(
        canvas: canvas,
        center: Offset(size.width * 0.75, size.height * 0.82),
        size: 20,
        angle: -0.4,
        fillPaint: accentPaint,
        strokePaint: strokePaint,
      );
    }
  }

  void _drawBranch({
    required Canvas canvas,
    required Offset start,
    required Offset end,
    required Paint fillPaint,
    required Paint strokePaint,
  }) {
    // Tallo principal
    canvas.drawLine(start, end, strokePaint);

    final mid = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
    final angle = math.atan2(end.dy - start.dy, end.dx - start.dx);

    _drawLeaf(canvas: canvas, center: end, size: 36, angle: angle, fillPaint: fillPaint, strokePaint: strokePaint);
    _drawLeaf(canvas: canvas, center: mid + Offset(-10, -10), size: 28, angle: angle - 0.7, fillPaint: fillPaint, strokePaint: strokePaint);
    _drawLeaf(canvas: canvas, center: mid + Offset(10, 10), size: 26, angle: angle + 0.7, fillPaint: fillPaint, strokePaint: strokePaint);
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
    path.quadraticBezierTo(size / 2.2, 0, 0, size / 2);
    path.quadraticBezierTo(-size / 2.2, 0, 0, -size / 2);
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Nervadura central
    canvas.drawLine(Offset(0, -size / 2), Offset(0, size / 2), strokePaint);
    // Nervaduras laterales
    canvas.drawLine(Offset(0, -size * 0.2), Offset(size * 0.2, -size * 0.1), strokePaint);
    canvas.drawLine(Offset(0, -size * 0.2), Offset(-size * 0.2, -size * 0.1), strokePaint);
    canvas.drawLine(Offset(0, size * 0.1), Offset(size * 0.2, size * 0.2), strokePaint);
    canvas.drawLine(Offset(0, size * 0.1), Offset(-size * 0.2, size * 0.2), strokePaint);

    canvas.restore();
  }

  void _drawMonsteraLeaf({
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
    path.cubicTo(size * 0.6, -size * 0.3, size * 0.5, size * 0.3, 0, size / 2);
    path.cubicTo(-size * 0.5, size * 0.3, -size * 0.6, -size * 0.3, 0, -size / 2);
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Tallo y nervaduras
    canvas.drawLine(Offset(0, -size / 2), Offset(0, size / 2), strokePaint);
    canvas.drawLine(Offset(0, -size * 0.15), Offset(size * 0.35, -size * 0.05), strokePaint);
    canvas.drawLine(Offset(0, -size * 0.15), Offset(-size * 0.35, -size * 0.05), strokePaint);
    canvas.drawLine(Offset(0, size * 0.15), Offset(size * 0.3, size * 0.25), strokePaint);
    canvas.drawLine(Offset(0, size * 0.15), Offset(-size * 0.3, size * 0.25), strokePaint);

    canvas.restore();
  }

  void _drawTreeWatermark(Canvas canvas, Size size, Paint fillPaint, Paint strokePaint) {
    final center = Offset(size.width * 0.85, size.height * 0.85);
    final treePaint = Paint()
      ..color = leafColor.withValues(alpha: opacity * 0.6)
      ..style = PaintingStyle.fill;

    // Follaje de árbol
    canvas.drawCircle(center, 40, treePaint);
    canvas.drawCircle(center + const Offset(-20, -15), 30, treePaint);
    canvas.drawCircle(center + const Offset(20, -15), 32, treePaint);
    canvas.drawCircle(center + const Offset(0, -35), 28, treePaint);

    // Tronco
    final trunkPath = Path();
    trunkPath.moveTo(center.dx - 8, center.dy + 15);
    trunkPath.lineTo(center.dx + 8, center.dy + 15);
    trunkPath.lineTo(center.dx + 12, center.dy + 60);
    trunkPath.lineTo(center.dx - 12, center.dy + 60);
    trunkPath.close();
    canvas.drawPath(trunkPath, treePaint);
  }

  @override
  bool shouldRepaint(covariant BotanicalLeavesPainter oldDelegate) {
    return oldDelegate.leafColor != leafColor ||
        oldDelegate.opacity != opacity ||
        oldDelegate.showFloatingLeaves != showFloatingLeaves;
  }
}

/// Contenedor botánico enriquecido con hojas y degradado ecológico
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
                    opacity: isDark ? 0.09 : 0.07,
                    showFloatingLeaves: true,
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
