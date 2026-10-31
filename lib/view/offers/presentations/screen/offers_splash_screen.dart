import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tripried/view/common/widgets/spingo_logo.dart';
import 'package:tripried/view/offers/presentations/screen/offers_screen.dart';
import 'package:tripried/view/offers/presentations/widgets/lowest_price_badge.dart';

class OffersSplashScreen extends StatefulWidget {
  const OffersSplashScreen({super.key});

  @override
  State<OffersSplashScreen> createState() => _OffersSplashScreenState();
}

class _OffersSplashScreenState extends State<OffersSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _spotlightAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _spotlightAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
      ),
    );

    _animController.forward();

    // Auto-navigate to OffersScreen after 2.0 seconds
    _navigationTimer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {

      }
    });
  }

  void _proceedToOffers() {
    _navigationTimer?.cancel();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const OffersScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF111113),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _proceedToOffers,
        child: Stack(
          children: [
            // 1. Spotlight beam shining from the top center
            AnimatedBuilder(
              animation: _spotlightAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: size,
                  painter: _SpotlightBeamPainter(
                    beamIntensity: _spotlightAnimation.value,
                  ),
                );
              },
            ),

            // 2. Back button (optional exit)
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white70),
                    onPressed: () {
                      _navigationTimer?.cancel();
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ),

            // 3. Center Badge and Guarantee Text
            Center(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: child,
                    ),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Lowest Price Guaranteed Octagon Badge
                    const LowestPriceBadge(
                      size: 146,
                      isSilver: false,
                    ),
                    const SizedBox(height: 48),

                    // SPinGO guarantees the Lowest price
                    const SpingoLogo(
                      height: 38,
                      isDark: true,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'guarantees the',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Lowest price',
                      style: TextStyle(
                        color: Color(0xFFF59E0B),
                        fontSize: 29,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Subtle tap to skip prompt at bottom
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    'Tap anywhere to explore deals',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the realistic theatrical conical spotlight beam
class _SpotlightBeamPainter extends CustomPainter {
  final double beamIntensity;

  _SpotlightBeamPainter({required this.beamIntensity});

  @override
  void paint(Canvas canvas, Size size) {
    final topCenter = Offset(size.width / 2, -20);
    final topHalfWidth = size.width * 0.08;
    final bottomHalfWidth = size.width * 0.52;
    final beamHeight = size.height * 0.65;

    final path = Path();
    path.moveTo(topCenter.dx - topHalfWidth, topCenter.dy);
    path.lineTo(topCenter.dx + topHalfWidth, topCenter.dy);
    path.lineTo(topCenter.dx + bottomHalfWidth, beamHeight);
    path.lineTo(topCenter.dx - bottomHalfWidth, beamHeight);
    path.close();

    // Soft gradient beam
    final beamPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.28 * beamIntensity),
          Colors.white.withValues(alpha: 0.12 * beamIntensity),
          Colors.white.withValues(alpha: 0.04 * beamIntensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, beamHeight))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);

    canvas.drawPath(path, beamPaint);

    // Inner bright core
    final corePath = Path();
    corePath.moveTo(topCenter.dx - topHalfWidth * 0.5, topCenter.dy);
    corePath.lineTo(topCenter.dx + topHalfWidth * 0.5, topCenter.dy);
    corePath.lineTo(topCenter.dx + bottomHalfWidth * 0.4, beamHeight * 0.8);
    corePath.lineTo(topCenter.dx - bottomHalfWidth * 0.4, beamHeight * 0.8);
    corePath.close();

    final corePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.35 * beamIntensity),
          Colors.white.withValues(alpha: 0.08 * beamIntensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, beamHeight * 0.8))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.drawPath(corePath, corePaint);
  }

  @override
  bool shouldRepaint(covariant _SpotlightBeamPainter oldDelegate) =>
      oldDelegate.beamIntensity != beamIntensity;
}
