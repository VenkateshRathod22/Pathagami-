import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tripried/view/common/widgets/spingo_logo.dart';
import '../main_screen/presentations/screen/main_screen.dart';
import '../auth/services/auth_service.dart';
import '../auth/presentations/screen/signup_sccreen.dart';

/// Amrita Kumari - SPiNGO Animated Splash Screen
/// Features smooth glowing animations, brand identity, and auto-auth routing

class SplaceScreen extends StatefulWidget {
  const SplaceScreen({super.key});

  @override
  State<SplaceScreen> createState() => _SplaceScreenState();
}

// Alias for standard naming
typedef SplashScreen = SplaceScreen;

class _SplaceScreenState extends State<SplaceScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _slideAnimation;
  Timer? _navigationTimer;

  static const Color brandGreen = Color(0xFF65A30D);
  static const Color brandGreenLight = Color(0xFF84CC16);
  static const Color brandNavy = Color(0xFF0F172A);
  static const Color darkBg = Color(0xFF0A0F1D);



  @override
  void initState() {
    super.initState();
    _setupSystemUI();
    _setupAnimations();
    _startAppFlow();
  }

  void _setupSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: darkBg,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _setupAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOutBack),
      ),
    );

    _slideAnimation = Tween<double>(begin: 24, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
  }

  Future<void> _startAppFlow() async {
    // 1. Check existing authentication session in background
    await AuthService.instance.loadSavedUser();

    // 2. Wait for splash presentation (2.4 seconds total for smooth WOW effect)
    _navigationTimer = Timer(const Duration(milliseconds: 2400), () {
      if (!mounted) return;

      // 3. Navigate based on authentication status
      if (AuthService.instance.isAuthenticated) {
        // User already logged in -> go straight to MainScreen
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const MainScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 550),
          ),
        );
      } else {
        // New / Unauthenticated user -> go to Signup screen
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const SignupSccreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 550),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Gradient with ambient glows
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.15),
                radius: 1.1,
                colors: [
                  Color(0xFF1E293B),
                  Color(0xFF0F172A),
                  Color(0xFF0A0F1D),
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),

          // Subtle Green Brand Glow Sphere
          Positioned(
            top: size.height * 0.28,
            left: (size.width - 260) / 2,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: brandGreen.withValues(alpha: 0.12),
                boxShadow: [
                  BoxShadow(
                    color: brandGreen.withValues(alpha: 0.22),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          // Main Center Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // Animated Icon + Logo Block
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Luxury Brand Badge with Glowing Border
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF84CC16),
                                Color(0xFF65A30D),
                                Color(0xFF4D7C0F),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: brandGreen.withValues(alpha: 0.45),
                                blurRadius: 32,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 88,
                              height: 88,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: brandNavy,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.directions_bus_filled_rounded,
                                  size: 46,
                                  color: brandGreenLight,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Official SPiNGO Brand Logo
                        const SpingoLogo(
                          height: 44,
                          isDark: true,
                        ),

                        const SizedBox(height: 12),

                        // Tagline
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: const Text(
                            'SMART BUS & RIDE BOOKING',
                            style: TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Feature Pills
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: child,
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildFeaturePill(Icons.verified_user_outlined, 'Safe & Verified'),
                        const SizedBox(width: 8),
                        _buildFeaturePill(Icons.gps_fixed_rounded, 'Live GPS'),
                        const SizedBox(width: 8),
                        _buildFeaturePill(Icons.flash_on_rounded, 'Instant Ticket'),
                      ],
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Bottom Loading Indicator & Version
                  Column(
                    children: [
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            brandGreenLight.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'India’s Premier Ride & Bus Network',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'v2.4.0 • SPiNGO Technologies',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 10.5,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: brandGreenLight),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
