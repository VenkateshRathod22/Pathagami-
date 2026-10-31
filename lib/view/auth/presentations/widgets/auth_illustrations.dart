import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Clean, vector-rendered Google 'G' Logo
class GoogleLogoWidget extends StatelessWidget {
  final double size;

  const GoogleLogoWidget({super.key, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = size.width * 0.22;

    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Draw 4 color arcs
    // Red: top-left to top-right
    canvas.drawArc(rect, -math.pi * 0.75, math.pi * 0.5, false, redPaint);

    // Yellow: left side
    canvas.drawArc(rect, -math.pi * 1.25, math.pi * 0.5, false, yellowPaint);

    // Green: bottom
    canvas.drawArc(rect, -math.pi * 1.75, math.pi * 0.5, false, greenPaint);

    // Blue: right side into horizontal bar
    canvas.drawArc(rect, -math.pi * 0.25, math.pi * 0.45, false, bluePaint);

    // Horizontal blue bar
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    final barRect = Rect.fromLTRB(
      center.dx - strokeWidth * 0.1,
      center.dy - strokeWidth / 2,
      size.width - strokeWidth * 0.1,
      center.dy + strokeWidth / 2,
    );
    canvas.drawRect(barRect, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Illustration for Slide 1: 4 Happy Indian Travellers with India Map Silhouette
class Slide1TravelersIllustration extends StatelessWidget {
  const Slide1TravelersIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return SizedBox(
          width: w,
          height: h,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Faint India Map Silhouette in background
              Positioned(
                top: 10,
                child: Opacity(
                  opacity: 0.18,
                  child: CustomPaint(
                    size: Size(w * 0.7, h * 0.75),
                    painter: _IndiaMapSilhouettePainter(),
                  ),
                ),
              ),

              // Group of 4 Travellers
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CustomPaint(
                  size: Size(w, h * 0.85),
                  painter: _TravelersGroupPainter(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _IndiaMapSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEAB308)
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;

    // Stylized contour representing map
    path.moveTo(w * 0.5, 0);
    path.lineTo(w * 0.6, h * 0.1);
    path.lineTo(w * 0.55, h * 0.18);
    path.lineTo(w * 0.75, h * 0.25);
    path.lineTo(w * 0.95, h * 0.3);
    path.lineTo(w * 0.85, h * 0.42);
    path.lineTo(w * 0.7, h * 0.45);
    path.lineTo(w * 0.72, h * 0.6);
    path.lineTo(w * 0.58, h * 0.82);
    path.lineTo(w * 0.5, h);
    path.lineTo(w * 0.42, h * 0.82);
    path.lineTo(w * 0.3, h * 0.62);
    path.lineTo(w * 0.25, h * 0.48);
    path.lineTo(w * 0.1, h * 0.4);
    path.lineTo(w * 0.2, h * 0.3);
    path.lineTo(w * 0.38, h * 0.22);
    path.lineTo(w * 0.42, h * 0.1);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TravelersGroupPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 4 Travelers:
    // 1. Woman (Left): Blue Kurti with red/gold border, dark hair, red bindi
    _drawPerson1(canvas, w * 0.14, h);

    // 2. Bearded Man (Middle-Left): Emerald green kurta with yellow mandarin collar
    _drawPerson2(canvas, w * 0.38, h);

    // 3. Woman (Middle-Right): Royal blue top, dark high-waist pants
    _drawPerson3(canvas, w * 0.64, h);

    // 4. Young Man with Glasses (Right): Purple t-shirt, coral pants, round glasses
    _drawPerson4(canvas, w * 0.86, h);
  }

  void _drawPerson1(Canvas canvas, double cx, double h) {
    final skin = Paint()..color = const Color(0xFFFCD3AD);
    final hair = Paint()..color = const Color(0xFF1E293B);
    final dress = Paint()..color = const Color(0xFF0284C7);
    final dupatta = Paint()..color = const Color(0xFFF59E0B);
    final redBorder = Paint()..color = const Color(0xFFDC2626);

    // Body / Kurta
    final body = Path()
      ..moveTo(cx - 36, h)
      ..lineTo(cx - 32, h * 0.45)
      ..quadraticBezierTo(cx - 30, h * 0.40, cx - 18, h * 0.38)
      ..lineTo(cx + 18, h * 0.38)
      ..quadraticBezierTo(cx + 30, h * 0.40, cx + 32, h * 0.45)
      ..lineTo(cx + 36, h)
      ..close();
    canvas.drawPath(body, dress);

    // Yellow Dupatta Drape over shoulder
    final drape = Path()
      ..moveTo(cx - 28, h * 0.42)
      ..lineTo(cx - 14, h * 0.40)
      ..lineTo(cx - 10, h)
      ..lineTo(cx - 24, h)
      ..close();
    canvas.drawPath(drape, dupatta);

    // Dupatta red border
    final drapeBorder = Path()
      ..moveTo(cx - 14, h * 0.40)
      ..lineTo(cx - 10, h * 0.40)
      ..lineTo(cx - 6, h)
      ..lineTo(cx - 10, h)
      ..close();
    canvas.drawPath(drapeBorder, redBorder);

    // Neck embroidery
    final neck = Path()
      ..moveTo(cx - 12, h * 0.38)
      ..quadraticBezierTo(cx, h * 0.52, cx + 12, h * 0.38)
      ..lineTo(cx + 16, h * 0.38)
      ..quadraticBezierTo(cx, h * 0.56, cx - 16, h * 0.38)
      ..close();
    canvas.drawPath(neck, dupatta);

    // Head & Hair
    // Back Hair
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.24), width: 50, height: 60),
      hair,
    );

    // Face
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.25), width: 36, height: 42),
      skin,
    );

    // Front Hair curls
    final frontHair = Path()
      ..moveTo(cx - 20, h * 0.22)
      ..quadraticBezierTo(cx - 10, h * 0.17, cx, h * 0.20)
      ..quadraticBezierTo(cx + 10, h * 0.17, cx + 20, h * 0.22)
      ..lineTo(cx + 22, h * 0.30)
      ..lineTo(cx + 16, h * 0.22)
      ..lineTo(cx - 16, h * 0.22)
      ..lineTo(cx - 22, h * 0.30)
      ..close();
    canvas.drawPath(frontHair, hair);

    // Eyes & Smile
    final feature = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx - 10, h * 0.25), Offset(cx - 4, h * 0.25), feature);
    canvas.drawLine(Offset(cx + 4, h * 0.25), Offset(cx + 10, h * 0.25), feature);

    // Bindi
    canvas.drawCircle(Offset(cx, h * 0.21), 2.5, redBorder);

    // Smile
    final smilePath = Path()
      ..moveTo(cx - 5, h * 0.29)
      ..quadraticBezierTo(cx, h * 0.32, cx + 5, h * 0.29);
    canvas.drawPath(smilePath, feature);
  }

  void _drawPerson2(Canvas canvas, double cx, double h) {
    final skin = Paint()..color = const Color(0xFFF6C298);
    final hair = Paint()..color = const Color(0xFF1E293B);
    final kurta = Paint()..color = const Color(0xFF15803D);
    final yellowTrim = Paint()..color = const Color(0xFFFACC15);

    // Green Kurta Body
    final body = Path()
      ..moveTo(cx - 38, h)
      ..lineTo(cx - 35, h * 0.40)
      ..quadraticBezierTo(cx - 32, h * 0.34, cx - 20, h * 0.32)
      ..lineTo(cx + 20, h * 0.32)
      ..quadraticBezierTo(cx + 32, h * 0.34, cx + 35, h * 0.40)
      ..lineTo(cx + 38, h)
      ..close();
    canvas.drawPath(body, kurta);

    // Yellow mandarin collar / placket
    final placket = Path()
      ..moveTo(cx - 4, h * 0.32)
      ..lineTo(cx + 4, h * 0.32)
      ..lineTo(cx + 5, h * 0.48)
      ..lineTo(cx, h * 0.52)
      ..lineTo(cx - 5, h * 0.48)
      ..close();
    canvas.drawPath(placket, yellowTrim);

    // Head
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.20), width: 44, height: 50),
      hair,
    );

    // Face
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.21), width: 36, height: 40),
      skin,
    );

    // Beard
    final beard = Path()
      ..moveTo(cx - 16, h * 0.21)
      ..quadraticBezierTo(cx - 15, h * 0.30, cx, h * 0.33)
      ..quadraticBezierTo(cx + 15, h * 0.30, cx + 16, h * 0.21)
      ..lineTo(cx + 14, h * 0.25)
      ..quadraticBezierTo(cx, h * 0.28, cx - 14, h * 0.25)
      ..close();
    canvas.drawPath(beard, hair);

    // Moustache & Eyes
    final feature = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx - 10, h * 0.19), Offset(cx - 4, h * 0.19), feature);
    canvas.drawLine(Offset(cx + 4, h * 0.19), Offset(cx + 10, h * 0.19), feature);

    // Cheerful smile
    final smile = Paint()..color = Colors.white;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, h * 0.24), width: 14, height: 8),
      0,
      math.pi,
      true,
      smile,
    );
  }

  void _drawPerson3(Canvas canvas, double cx, double h) {
    final skin = Paint()..color = const Color(0xFFFAD7BD);
    final hair = Paint()..color = const Color(0xFF1E293B);
    final top = Paint()..color = const Color(0xFF1D4ED8);
    final pants = Paint()..color = const Color(0xFF334155);

    // Pants
    final pantsPath = Path()
      ..moveTo(cx - 24, h)
      ..lineTo(cx - 20, h * 0.65)
      ..lineTo(cx + 20, h * 0.65)
      ..lineTo(cx + 24, h)
      ..close();
    canvas.drawPath(pantsPath, pants);

    // Blue Top
    final topPath = Path()
      ..moveTo(cx - 32, h * 0.65)
      ..lineTo(cx - 28, h * 0.40)
      ..quadraticBezierTo(cx - 24, h * 0.34, cx - 16, h * 0.33)
      ..lineTo(cx + 16, h * 0.33)
      ..quadraticBezierTo(cx + 24, h * 0.34, cx + 28, h * 0.40)
      ..lineTo(cx + 32, h * 0.65)
      ..close();
    canvas.drawPath(topPath, top);

    // Belt
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, h * 0.65), width: 42, height: 6),
      hair,
    );

    // Long dark hair
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.24), width: 48, height: 65),
      hair,
    );

    // Face
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.23), width: 34, height: 38),
      skin,
    );

    // Pearl earrings
    final pearl = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx - 16, h * 0.25), 2.5, pearl);
    canvas.drawCircle(Offset(cx + 16, h * 0.25), 2.5, pearl);

    // Eyes & Smile
    final feature = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx - 8, h * 0.22), Offset(cx - 3, h * 0.22), feature);
    canvas.drawLine(Offset(cx + 3, h * 0.22), Offset(cx + 8, h * 0.22), feature);

    final smilePath = Path()
      ..moveTo(cx - 5, h * 0.27)
      ..quadraticBezierTo(cx, h * 0.31, cx + 5, h * 0.27);
    canvas.drawPath(smilePath, feature);
  }

  void _drawPerson4(Canvas canvas, double cx, double h) {
    final skin = Paint()..color = const Color(0xFFFCD3AD);
    final hair = Paint()..color = const Color(0xFF1E293B);
    final tshirt = Paint()..color = const Color(0xFF7C3AED);
    final shorts = Paint()..color = const Color(0xFFEF4444);

    // Red shorts
    final shortsPath = Path()
      ..moveTo(cx - 24, h)
      ..lineTo(cx - 20, h * 0.70)
      ..lineTo(cx + 20, h * 0.70)
      ..lineTo(cx + 24, h)
      ..close();
    canvas.drawPath(shortsPath, shorts);

    // Purple T-Shirt
    final body = Path()
      ..moveTo(cx - 28, h * 0.70)
      ..lineTo(cx - 25, h * 0.44)
      ..quadraticBezierTo(cx - 22, h * 0.36, cx - 14, h * 0.35)
      ..lineTo(cx + 14, h * 0.35)
      ..quadraticBezierTo(cx + 22, h * 0.36, cx + 25, h * 0.44)
      ..lineTo(cx + 28, h * 0.70)
      ..close();
    canvas.drawPath(body, tshirt);

    // Head
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.22), width: 44, height: 48),
      hair,
    );

    // Face
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.23), width: 34, height: 38),
      skin,
    );

    // Stylish hair tuft
    final tuft = Path()
      ..moveTo(cx - 16, h * 0.16)
      ..quadraticBezierTo(cx, h * 0.10, cx + 18, h * 0.15)
      ..lineTo(cx + 14, h * 0.20)
      ..lineTo(cx - 14, h * 0.20)
      ..close();
    canvas.drawPath(tuft, hair);

    // Glasses
    final glasses = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(cx - 7, h * 0.23), 6, glasses);
    canvas.drawCircle(Offset(cx + 7, h * 0.23), 6, glasses);
    canvas.drawLine(Offset(cx - 1, h * 0.23), Offset(cx + 1, h * 0.23), glasses);

    // Smile
    final feature = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final smilePath = Path()
      ..moveTo(cx - 5, h * 0.28)
      ..quadraticBezierTo(cx, h * 0.31, cx + 5, h * 0.28);
    canvas.drawPath(smilePath, feature);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Illustration for Slide 2: Modern Red Bus on Road with GPS Pin & Live Radar
class Slide2BusTrackingIllustration extends StatelessWidget {
  const Slide2BusTrackingIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: _BusTrackingPainter(),
          ),
        );
      },
    );
  }
}

class _BusTrackingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Road curve
    final roadPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 32;

    final road = Path()
      ..moveTo(-20, h * 0.75)
      ..cubicTo(w * 0.3, h * 0.85, w * 0.7, h * 0.65, w + 20, h * 0.75);
    canvas.drawPath(road, roadPaint);

    // Dashed center line
    final dashPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final dash = Path()
      ..moveTo(-10, h * 0.75)
      ..cubicTo(w * 0.3, h * 0.85, w * 0.7, h * 0.65, w + 10, h * 0.75);
    canvas.drawPath(dash, dashPaint);

    // Pulsing radar circles for live GPS
    final pulsePaint1 = Paint()
      ..color = const Color(0xFFD83A3A).withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    final pulsePaint2 = Paint()
      ..color = const Color(0xFFD83A3A).withValues(alpha: 0.30)
      ..style = PaintingStyle.fill;

    final pinCenter = Offset(w * 0.68, h * 0.30);
    canvas.drawCircle(pinCenter, 34, pulsePaint1);
    canvas.drawCircle(pinCenter, 22, pulsePaint2);

    // GPS Pin
    final pinPaint = Paint()..color = const Color(0xFFD83A3A);
    final pinPath = Path()
      ..moveTo(pinCenter.dx, pinCenter.dy + 16)
      ..quadraticBezierTo(pinCenter.dx - 12, pinCenter.dy - 2, pinCenter.dx - 12, pinCenter.dy - 10)
      ..arcToPoint(
        Offset(pinCenter.dx + 12, pinCenter.dy - 10),
        radius: const Radius.circular(12),
      )
      ..quadraticBezierTo(pinCenter.dx + 12, pinCenter.dy - 2, pinCenter.dx, pinCenter.dy + 16);
    canvas.drawPath(pinPath, pinPaint);

    canvas.drawCircle(Offset(pinCenter.dx, pinCenter.dy - 10), 4.5, Paint()..color = Colors.white);

    // Bus Drawing
    final busX = w * 0.28;
    final busY = h * 0.52;
    final busW = w * 0.52;
    final busH = h * 0.28;

    // Bus Body (Red)
    final busBody = RRect.fromRectAndCorners(
      Rect.fromLTWH(busX, busY, busW, busH),
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(14),
      bottomLeft: const Radius.circular(10),
      bottomRight: const Radius.circular(10),
    );
    canvas.drawRRect(busBody, Paint()..color = const Color(0xFFD83A3A));

    // Bus Roof highlight
    final roof = RRect.fromRectAndCorners(
      Rect.fromLTWH(busX + 4, busY + 2, busW - 8, 8),
      topLeft: const Radius.circular(10),
      topRight: const Radius.circular(10),
    );
    canvas.drawRRect(roof, Paint()..color = const Color(0xFFEF4444));

    // Windshield & Windows (Sleek dark glass)
    final glassPaint = Paint()..color = const Color(0xFF1E293B);

    // Front windshield
    final frontGlass = RRect.fromRectAndCorners(
      Rect.fromLTWH(busX + 8, busY + 12, busW * 0.22, busH * 0.42),
      topLeft: const Radius.circular(12),
      bottomLeft: const Radius.circular(4),
    );
    canvas.drawRRect(frontGlass, glassPaint);

    // Passenger windows
    for (int i = 0; i < 4; i++) {
      final winX = busX + busW * 0.34 + (i * (busW * 0.15));
      final window = RRect.fromRectAndRadius(
        Rect.fromLTWH(winX, busY + 12, busW * 0.12, busH * 0.42),
        const Radius.circular(4),
      );
      canvas.drawRRect(window, glassPaint);
    }

    // Yellow Headlight
    final lightPaint = Paint()..color = const Color(0xFFFDE047);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(busX + 4, busY + busH * 0.65, 8, 12), const Radius.circular(3)),
      lightPaint,
    );

    // Wheels
    final wheelPaint = Paint()..color = const Color(0xFF0F172A);
    final rimPaint = Paint()..color = const Color(0xFF94A3B8);

    void drawWheel(double wx) {
      canvas.drawCircle(Offset(wx, busY + busH + 2), 16, wheelPaint);
      canvas.drawCircle(Offset(wx, busY + busH + 2), 8, rimPaint);
    }

    drawWheel(busX + busW * 0.22);
    drawWheel(busX + busW * 0.80);

    // Floating Trust/Safety Badge on top left
    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.08, h * 0.22, 110, 36),
      const Radius.circular(18),
    );
    canvas.drawRRect(badgeRect, Paint()..color = Colors.white);
    canvas.drawRRect(
      badgeRect,
      Paint()
        ..color = const Color(0xFF22C55E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Illustration for Slide 3: Happy Family with 5-Star Reviews & Chat Bubbles
class Slide3FamilyReviewIllustration extends StatelessWidget {
  const Slide3FamilyReviewIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return SizedBox(
          width: w,
          height: h,
          child: Stack(
            children: [
              // Sparkles / Stars in the background
              Positioned(
                left: w * 0.1,
                top: h * 0.26,
                child: _buildSparkle(const Color(0xFF93C5FD), 14),
              ),
              Positioned(
                right: w * 0.12,
                top: h * 0.32,
                child: _buildSparkle(const Color(0xFF93C5FD), 12),
              ),

              // Teal Chat Bubble on left with 3 white dots
              Positioned(
                left: w * 0.04,
                top: h * 0.12,
                child: _buildTealChatBubble(),
              ),

              // Blue message bubble in upper-center
              Positioned(
                left: w * 0.42,
                top: h * 0.18,
                child: _buildBlueMessageBubble(),
              ),

              // Red Speech Bubble on right with 5 Yellow Stars ★★★★★
              Positioned(
                right: w * 0.04,
                top: h * 0.08,
                child: _buildFiveStarBubble(),
              ),

              // Family Group (Dad thumbs up, Mom thumbs up, boy, girl)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CustomPaint(
                  size: Size(w, h * 0.82),
                  painter: _FamilyPainter(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSparkle(Color color, double size) {
    return Icon(Icons.star, color: color, size: size);
  }

  Widget _buildTealChatBubble() {
    return Container(
      width: 48,
      height: 44,
      decoration: const BoxDecoration(
        color: Color(0xFF0D9488), // Teal
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(radius: 2.5, backgroundColor: Colors.white),
            SizedBox(width: 3),
            CircleAvatar(radius: 2.5, backgroundColor: Colors.white),
            SizedBox(width: 3),
            CircleAvatar(radius: 2.5, backgroundColor: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildBlueMessageBubble() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB), // Blue
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 28, height: 3, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 3),
          Container(width: 18, height: 3, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))),
        ],
      ),
    );
  }

  Widget _buildFiveStarBubble() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626), // Crimson Red
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: Color(0xFFFDE047), size: 18),
          Icon(Icons.star, color: Color(0xFFFDE047), size: 18),
          Icon(Icons.star, color: Color(0xFFFDE047), size: 18),
          Icon(Icons.star, color: Color(0xFFFDE047), size: 18),
          Icon(Icons.star, color: Color(0xFFFDE047), size: 18),
        ],
      ),
    );
  }
}

class _FamilyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Dad on left (Red shirt)
    _drawDad(canvas, w * 0.25, h);

    // Mom on right (Navy blue dress)
    _drawMom(canvas, w * 0.73, h);

    // Son in center-left (Green shirt)
    _drawBoy(canvas, w * 0.38, h);

    // Daughter in center-right (Yellow dress)
    _drawGirl(canvas, w * 0.60, h);
  }

  void _drawDad(Canvas canvas, double cx, double h) {
    final skin = Paint()..color = const Color(0xFFFCD3AD);
    final hair = Paint()..color = const Color(0xFF1E293B);
    final redShirt = Paint()..color = const Color(0xFFDC2626);

    // Red polo body
    final body = Path()
      ..moveTo(cx - 50, h)
      ..lineTo(cx - 45, h * 0.38)
      ..quadraticBezierTo(cx - 35, h * 0.30, cx - 20, h * 0.28)
      ..lineTo(cx + 20, h * 0.28)
      ..quadraticBezierTo(cx + 35, h * 0.30, cx + 45, h * 0.38)
      ..lineTo(cx + 50, h)
      ..close();
    canvas.drawPath(body, redShirt);

    // Collar
    final collar = Path()
      ..moveTo(cx - 16, h * 0.28)
      ..lineTo(cx, h * 0.36)
      ..lineTo(cx + 16, h * 0.28)
      ..lineTo(cx, h * 0.30)
      ..close();
    canvas.drawPath(collar, Paint()..color = const Color(0xFFB91C1C));

    // Thumbs up arm on left
    final arm = Path()
      ..moveTo(cx - 45, h * 0.50)
      ..lineTo(cx - 60, h * 0.44)
      ..lineTo(cx - 56, h * 0.38)
      ..close();
    canvas.drawPath(arm, redShirt);

    // Thumbs up hand
    canvas.drawCircle(Offset(cx - 62, h * 0.40), 7, skin);
    canvas.drawRect(Rect.fromLTWH(cx - 64, h * 0.34, 4, 8), skin); // thumb pointing up

    // Head & Hair
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.16), width: 50, height: 56),
      hair,
    );

    // Face
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.17), width: 40, height: 44),
      skin,
    );

    // Front Hair
    final frontHair = Path()
      ..moveTo(cx - 20, h * 0.13)
      ..quadraticBezierTo(cx - 5, h * 0.08, cx + 18, h * 0.12)
      ..lineTo(cx + 20, h * 0.17)
      ..lineTo(cx - 18, h * 0.17)
      ..close();
    canvas.drawPath(frontHair, hair);

    // Eyes & Smile
    final feature = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx - 10, h * 0.16), Offset(cx - 4, h * 0.16), feature);
    canvas.drawLine(Offset(cx + 4, h * 0.16), Offset(cx + 10, h * 0.16), feature);

    // Cheerful big smile
    final smile = Paint()..color = Colors.white;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, h * 0.21), width: 16, height: 9),
      0,
      math.pi,
      true,
      smile,
    );
  }

  void _drawMom(Canvas canvas, double cx, double h) {
    final skin = Paint()..color = const Color(0xFFFAD7BD);
    final hair = Paint()..color = const Color(0xFF1E293B);
    final dress = Paint()..color = const Color(0xFF1E3A8A); // Navy Blue

    // Navy Blue Dress Body
    final body = Path()
      ..moveTo(cx - 45, h)
      ..lineTo(cx - 40, h * 0.42)
      ..quadraticBezierTo(cx - 30, h * 0.35, cx - 18, h * 0.34)
      ..lineTo(cx + 18, h * 0.34)
      ..quadraticBezierTo(cx + 30, h * 0.35, cx + 40, h * 0.42)
      ..lineTo(cx + 45, h)
      ..close();
    canvas.drawPath(body, dress);

    // Thumbs up arm on right
    final arm = Path()
      ..moveTo(cx + 40, h * 0.45)
      ..lineTo(cx + 58, h * 0.38)
      ..lineTo(cx + 52, h * 0.34)
      ..close();
    canvas.drawPath(arm, dress);

    // Thumbs up hand
    canvas.drawCircle(Offset(cx + 60, h * 0.35), 7, skin);
    canvas.drawRect(Rect.fromLTWH(cx + 60, h * 0.28, 4, 8), skin); // thumb pointing up

    // Long dark hair
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.20), width: 56, height: 72),
      hair,
    );

    // Face
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.20), width: 38, height: 42),
      skin,
    );

    // Pearl Earring
    canvas.drawCircle(Offset(cx + 18, h * 0.22), 3, Paint()..color = Colors.white);

    // Eyes & Smile
    final feature = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx - 9, h * 0.18), Offset(cx - 3, h * 0.18), feature);
    canvas.drawLine(Offset(cx + 3, h * 0.18), Offset(cx + 9, h * 0.18), feature);

    final smile = Paint()..color = Colors.white;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, h * 0.24), width: 16, height: 8),
      0,
      math.pi,
      true,
      smile,
    );
  }

  void _drawBoy(Canvas canvas, double cx, double h) {
    final skin = Paint()..color = const Color(0xFFFCD3AD);
    final hair = Paint()..color = const Color(0xFF1E293B);
    final greenShirt = Paint()..color = const Color(0xFF10B981); // Emerald Green

    // Body
    final body = Path()
      ..moveTo(cx - 30, h)
      ..lineTo(cx - 26, h * 0.58)
      ..quadraticBezierTo(cx - 20, h * 0.52, cx - 12, h * 0.50)
      ..lineTo(cx + 12, h * 0.50)
      ..quadraticBezierTo(cx + 20, h * 0.52, cx + 26, h * 0.58)
      ..lineTo(cx + 30, h)
      ..close();
    canvas.drawPath(body, greenShirt);

    // Head
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.38), width: 44, height: 46),
      hair,
    );

    // Face
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.39), width: 36, height: 38),
      skin,
    );

    // Cute Boy Hair cut
    final frontHair = Path()
      ..moveTo(cx - 18, h * 0.34)
      ..quadraticBezierTo(cx, h * 0.28, cx + 18, h * 0.34)
      ..lineTo(cx + 16, h * 0.38)
      ..lineTo(cx - 16, h * 0.38)
      ..close();
    canvas.drawPath(frontHair, hair);

    // Eyes & Smile
    canvas.drawCircle(Offset(cx - 7, h * 0.38), 2, Paint()..color = const Color(0xFF1E293B));
    canvas.drawCircle(Offset(cx + 7, h * 0.38), 2, Paint()..color = const Color(0xFF1E293B));

    final smile = Paint()..color = Colors.white;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, h * 0.43), width: 12, height: 7),
      0,
      math.pi,
      true,
      smile,
    );
  }

  void _drawGirl(Canvas canvas, double cx, double h) {
    final skin = Paint()..color = const Color(0xFFFCD3AD);
    final hair = Paint()..color = const Color(0xFF1E293B);
    final yellowDress = Paint()..color = const Color(0xFFFACC15); // Bright Yellow

    // Yellow Dress Body
    final body = Path()
      ..moveTo(cx - 30, h)
      ..lineTo(cx - 24, h * 0.58)
      ..quadraticBezierTo(cx - 18, h * 0.53, cx - 10, h * 0.52)
      ..lineTo(cx + 10, h * 0.52)
      ..quadraticBezierTo(cx + 18, h * 0.53, cx + 24, h * 0.58)
      ..lineTo(cx + 30, h)
      ..close();
    canvas.drawPath(body, yellowDress);

    // Waving / Peace hand on right
    final arm = Path()
      ..moveTo(cx + 22, h * 0.60)
      ..lineTo(cx + 36, h * 0.54)
      ..close();
    canvas.drawPath(arm, Paint()..color = skin.color..strokeWidth = 6..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);

    // Pigtails Hair
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 18, h * 0.42), width: 14, height: 26),
      hair,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 18, h * 0.42), width: 14, height: 26),
      hair,
    );

    // Head
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.40), width: 42, height: 44),
      hair,
    );

    // Face
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.41), width: 34, height: 36),
      skin,
    );

    // Eyes & Smile
    canvas.drawCircle(Offset(cx - 6, h * 0.40), 2, Paint()..color = const Color(0xFF1E293B));
    canvas.drawCircle(Offset(cx + 6, h * 0.40), 2, Paint()..color = const Color(0xFF1E293B));

    final smile = Paint()..color = Colors.white;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, h * 0.45), width: 11, height: 6),
      0,
      math.pi,
      true,
      smile,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
