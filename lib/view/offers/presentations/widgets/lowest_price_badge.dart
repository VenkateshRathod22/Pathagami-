import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Pixel-perfect "LOWEST PRICE GUARANTEED" octagonal / scalloped badge
/// as seen in the redBus offers splash & offers screen screenshots.
class LowestPriceBadge extends StatelessWidget {
  final double size;
  final bool isSilver;

  const LowestPriceBadge({
    super.key,
    this.size = 120,
    this.isSilver = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BadgePainter(isSilver: isSilver),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(size * 0.15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'LOWEST',
                  style: TextStyle(
                    color: isSilver ? const Color(0xFF64748B) : Colors.white,
                    fontSize: size * 0.085,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: size * 0.02),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '★',
                      style: TextStyle(
                        color: isSilver ? const Color(0xFF64748B) : Colors.white,
                        fontSize: size * 0.075,
                      ),
                    ),
                    SizedBox(width: size * 0.03),
                    Text(
                      'PRICE',
                      style: TextStyle(
                        color: isSilver ? const Color(0xFF475569) : Colors.white,
                        fontSize: size * 0.13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(width: size * 0.03),
                    Text(
                      '★',
                      style: TextStyle(
                        color: isSilver ? const Color(0xFF64748B) : Colors.white,
                        fontSize: size * 0.075,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size * 0.02),
                Text(
                  'GUARANTEED',
                  style: TextStyle(
                    color: isSilver ? const Color(0xFF64748B) : Colors.white,
                    fontSize: size * 0.075,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BadgePainter extends CustomPainter {
  final bool isSilver;

  _BadgePainter({required this.isSilver});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer scalloped / 16-point polygon path
    final path = Path();
    const numPoints = 16;
    for (int i = 0; i < numPoints; i++) {
      final angle = (i * 2 * math.pi) / numPoints - math.pi / 2;
      // Slightly alternate radius to give the subtle scalloped coin edge
      final r = (i % 2 == 0) ? radius : radius * 0.94;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Shadow
    canvas.drawShadow(
      path,
      isSilver ? Colors.black26 : const Color(0x66991B1B),
      6,
      true,
    );

    // Main fill
    final Paint fillPaint = Paint()
      ..shader = (isSilver
              ? const LinearGradient(
                  colors: [Color(0xFFF1F5F9), Color(0xFFE2E8F0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ))
          .createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawPath(path, fillPaint);

    // Outer border
    final borderPaint = Paint()
      ..color = isSilver ? const Color(0xFFCBD5E1) : const Color(0xFFB91C1C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.035;
    canvas.drawPath(path, borderPaint);

    // Inner dashed / dotted circle
    final innerCirclePaint = Paint()
      ..color = isSilver
          ? const Color(0xFF94A3B8)
          : Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.012;

    final innerRadius = radius * 0.78;
    const dashCount = 32;
    for (int i = 0; i < dashCount; i++) {
      final startAngle = (i * 2 * math.pi) / dashCount;
      final sweepAngle = math.pi / dashCount;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: innerRadius),
        startAngle,
        sweepAngle,
        false,
        innerCirclePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BadgePainter oldDelegate) =>
      oldDelegate.isSilver != isSilver;
}
