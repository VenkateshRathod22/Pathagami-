import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:tripried/view/common/widgets/spingo_logo.dart';
import '../../../main_screen/presentations/screen/main_screen.dart';
import '../../controllers/login_controller.dart';
import '../../models/user_model.dart';
import '../widgets/auth_illustrations.dart';
import 'signup_sccreen.dart';
import 'package:tripried/view/account/sub_features/customer_profile/services/customer_profile_service.dart';
import 'package:tripried/view/account/sub_features/customer_profile/presentations/screen/customer_profile_screen.dart';

/// Amrita Kumari - Login Screen with Live API Integration
/// API: https://spingoride.com/api/v1/auth/login
/// Single cohesive brand palette (SPiNGO Green & Slate)

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final PageController _pageController = PageController();
  late final LoginController _loginController;

  int _currentPage = 0;
  Timer? _timer;

  static const Color brandGreen = Color(0xFF65A30D);
  static const Color brandGreenDark = Color(0xFF4D7C0F);
  static const Color darkNavy = Color(0xFF0F172A);
  static const Color inputBg = Color(0xFFF8FAFC);
  static const Color borderColor = Color(0xFFE2E8F0);

  final List<_SlideItem> _slides = const [
    _SlideItem(
      title: '20 Years of happy journeys!',
      backgroundColor: Color(0xFFECFCCB),
      bullets: [
        '56+ million satisfied travellers',
        '5200+ bus operators',
        '7.3 lakh+ bus routes',
      ],
      slideType: _SlideType.travelers,
    ),
    _SlideItem(
      title: 'Track your bus in real-time!',
      backgroundColor: Color(0xFFE0F2FE),
      bullets: [
        'Live GPS tracking with arrival estimates',
        'Verified operators & 24/7 SOS safety',
        'Instant refunds on ticket cancellation',
      ],
      slideType: _SlideType.tracking,
    ),
    _SlideItem(
      title: 'Reviewed by 23 Lakh+ travellers!',
      subtitle: 'Check ratings and reviews to choose your bus.',
      backgroundColor: Color(0xFFE8EEF8),
      bullets: [],
      slideType: _SlideType.reviews,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loginController = LoginController();
    _loginController.addListener(_onControllerUpdate);
    _startAutoSlide();
    getFCMToken();
  }

  Future<void> getFCMToken() async {

    await FirebaseMessaging.instance.requestPermission();

    final String? token =
    await FirebaseMessaging.instance.getToken();

    print('FCM TOKEN: $token');
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _slides.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _loginController.removeListener(_onControllerUpdate);
    _loginController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  Future<void> _handleLoginSubmit() async {
    FocusScope.of(context).unfocus();
    final success = await _loginController.login();

    if (!mounted) return;

    if (success && _loginController.loggedInUser != null) {
      CustomerProfileService.instance.loadInitialData();
      CustomerProfileService.instance.fetchProfile(forceRefresh: true);
      final user = _loginController.loggedInUser!;
      final token = _loginController.loginResponse?.data?.token ?? '';
      _showLoginSuccessDialog(user, token);
    }
  }

  /// Displays the full customer data returned from the live login API
  void _showLoginSuccessDialog(UserModel user, String token) {
    final customer = user.customerDetails;
    final wallet = user.wallet;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 18),

                // Success Icon & Welcome
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: brandGreen, size: 40),
                ),
                const SizedBox(height: 10),
                Text(
                  'Welcome Back, ${user.name}! 🎉',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: darkNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Customer logged in successfully via SPiNGO API',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 18),

                // Live Customer Data Details Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Customer ID',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFCCB),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              customer?.customerId ?? 'CUS-${user.id}',
                              style: const TextStyle(
                                color: brandGreenDark,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),

                      _buildDataRow('Full Name', user.name, icon: Icons.person_outline),
                      _buildDataRow('Mobile', '+91 ${user.phone}', icon: Icons.phone_outlined),
                      _buildDataRow('Email', user.email, icon: Icons.email_outlined),
                      _buildDataRow('City', customer?.city ?? 'Noida', icon: Icons.location_city_outlined),
                      _buildDataRow('Gender', customer?.gender ?? 'Female', icon: Icons.badge_outlined),
                      _buildDataRow('Role', user.role.toUpperCase(), icon: Icons.verified_user_outlined),
                      if (customer?.referralCode != null)
                        _buildDataRow('Referral Code', customer!.referralCode!, icon: Icons.card_giftcard_rounded, isHighlight: true),
                      _buildDataRow('Reward Points', '${customer?.rewardPoints ?? 0} pts', icon: Icons.stars_rounded),
                      _buildDataRow('Wallet Balance', '${wallet?.currency ?? "INR"} ${wallet?.balance ?? 0}', icon: Icons.account_balance_wallet_outlined),
                      if (token.isNotEmpty)
                        _buildDataRow(
                          'Token Status',
                          'Active (Bearer)',
                          icon: Icons.vpn_key_outlined,
                          isHighlight: true,
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Button 1: Go to Customer Profile Page
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandGreen,
                      foregroundColor: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CustomerProfileScreen()),
                      );
                    },
                    icon: const Icon(Icons.person_pin_circle_rounded, size: 20),
                    label: const Text(
                      'OPEN CUSTOMER PROFILE PAGE',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Button 2: Continue to Explore
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _navigateToHome();
                    },
                    child: const Text(
                      'CONTINUE TO EXPLORE',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: darkNavy,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDataRow(String label, String value, {required IconData icon, bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: brandGreen),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isHighlight ? brandGreen : darkNavy,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSlide = _slides[_currentPage];
    final size = MediaQuery.of(context).size;
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: currentSlide.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // ============ TOP CAROUSEL ============
                  SizedBox(
                    height: isKeyboardOpen ? size.height * 0.22 : size.height * 0.42,
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          itemCount: _slides.length,
                          onPageChanged: (index) => setState(() => _currentPage = index),
                          itemBuilder: (context, index) {
                            final slide = _slides[index];
                            return Container(
                              color: slide.backgroundColor,
                              padding: const EdgeInsets.fromLTRB(22, 46, 22, 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    slide.title,
                                    style: const TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                      height: 1.25,
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                  const SizedBox(height: 6),

                                  if (slide.subtitle != null && !isKeyboardOpen) ...[
                                    Text(
                                      slide.subtitle!,
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        color: Colors.grey.shade800,
                                        fontWeight: FontWeight.w500,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                  ],

                                  if (slide.bullets.isNotEmpty && !isKeyboardOpen)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Column(
                                        children: slide.bullets.take(2).map((bullet) {
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 5),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(top: 5),
                                                  width: 5.5,
                                                  height: 5.5,
                                                  decoration: const BoxDecoration(
                                                    color: Color(0xFF0F172A),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    bullet,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w600,
                                                      color: Color(0xFF1E293B),
                                                      height: 1.25,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),

                                  // Illustration
                                  Expanded(
                                    child: _buildIllustration(slide.slideType),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        // Top bar: Indicator + Skip
                        Positioned(
                          top: 10,
                          left: 20,
                          right: 16,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SpingoLogo(height: 24),
                              _buildPageIndicator(),
                              TextButton(
                                onPressed: _navigateToHome,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Skip',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ============ BOTTOM LOGIN CARD ============
                  Expanded(
                    child: _buildBottomLoginCard(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_slides.length, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3.5),
          width: isActive ? 18 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF65A30D)
                : Colors.black.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }

  Widget _buildIllustration(_SlideType type) {
    switch (type) {
      case _SlideType.travelers:
        return const Slide1TravelersIllustration();
      case _SlideType.tracking:
        return const Slide2BusTrackingIllustration();
      case _SlideType.reviews:
        return const Slide3FamilyReviewIllustration();
    }
  }

  Widget _buildBottomLoginCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Heading & Subtitle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: darkNavy,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Log in with mobile or email',
                    style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              // Quick Fill Test Account Chip
              InkWell(
                onTap: () {
                  _loginController.quickFillCustomer(login: '9695541750');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Filled customer number: 9695541750'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: brandGreen,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFCCB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: brandGreen.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.touch_app_outlined, size: 14, color: brandGreenDark),
                      SizedBox(width: 4),
                      Text(
                        'Demo User',
                        style: TextStyle(
                          color: brandGreenDark,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 1. Mobile or Email Input
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: inputBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 1.2),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.person_outline_rounded, color: brandGreen, size: 20),
                ),
                Container(width: 1.2, height: 26, color: borderColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: _loginController.loginInputController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: darkNavy,
                      ),
                      onChanged: (_) => _loginController.clearError(),
                      decoration: InputDecoration(
                        hintText: 'Mobile number or email',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 2. Password Input
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: inputBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 1.2),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.lock_outline_rounded, color: brandGreen, size: 20),
                ),
                Container(width: 1.2, height: 26, color: borderColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: _loginController.passwordController,
                      obscureText: _loginController.obscurePassword,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: darkNavy,
                      ),
                      onChanged: (_) => _loginController.clearError(),
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _loginController.obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey.shade500,
                    size: 19,
                  ),
                  onPressed: _loginController.togglePasswordVisibility,
                ),
              ],
            ),
          ),

          // Error Message Box (if any)
          if (_loginController.errorMessage != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _loginController.errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFF991B1B),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Primary Log In Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: brandGreen,
                foregroundColor: Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _loginController.isLoading ? null : _handleLoginSubmit,
              child: _loginController.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text(
                      'LOG IN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 12),

          // OR Divider
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
            ],
          ),

          const SizedBox(height: 12),

          // Google Login Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: darkNavy,
                side: const BorderSide(color: borderColor, width: 1.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Signing in with Google...'),
                    backgroundColor: brandGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                Future.delayed(const Duration(milliseconds: 700), () {
                  if (context.mounted) _navigateToHome();
                });
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GoogleLogoWidget(size: 18),
                  SizedBox(width: 10),
                  Text(
                    'Sign in with Google',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Don't have an account? Sign Up
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupSccreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text.rich(
                  TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(fontSize: 13.5, color: Colors.grey.shade600),
                    children: const [
                      TextSpan(
                        text: 'Sign Up',
                        style: TextStyle(
                          color: brandGreen,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _SlideType { travelers, tracking, reviews }

class _SlideItem {
  final String title;
  final String? subtitle;
  final Color backgroundColor;
  final List<String> bullets;
  final _SlideType slideType;

  const _SlideItem({
    required this.title,
    this.subtitle,
    required this.backgroundColor,
    required this.bullets,
    required this.slideType,
  });
}