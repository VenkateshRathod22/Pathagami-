import 'package:flutter/material.dart';
import 'package:tripried/view/bookings/presentations/screen/bookings_screen.dart';
import 'package:tripried/view/getaways/presentations/screen/getaways_screen.dart';
import 'package:tripried/view/help/presentations/screen/help_screen.dart';
import 'package:tripried/view/offers/presentations/screen/offers_splash_screen.dart';
import 'package:tripried/view/account/sub_features/account_settings/presentations/screen/account_settings_screen.dart';
import 'package:tripried/view/account/sub_features/passengers/presentations/screen/passengers_screen.dart';
import 'package:tripried/view/account/sub_features/payment_methods/presentations/screen/payment_methods_screen.dart';
import 'package:tripried/view/account/sub_features/customer_profile/presentations/screen/customer_profile_screen.dart';
import 'package:tripried/view/account/sub_features/customer_profile/services/customer_profile_service.dart';
import 'package:tripried/view/account/sub_features/scratch_card/presentations/screen/scratch_card_screen.dart';
import 'package:tripried/view/account/sub_features/wallet/presentations/screen/wallet_screen.dart';
import 'package:tripried/view/account/sub_features/wallet/services/wallet_service.dart';
import 'package:tripried/view/account/sub_features/notifications/presentations/screen/notification_preferences_screen.dart';
import 'package:tripried/view/account/sub_features/personal_info/services/user_profile_service.dart';
import 'package:tripried/view/account/sub_features/account_settings/presentations/widgets/logout_dialog.dart';
import 'package:tripried/view/bus/presentations/widgets/booking_for_women_sheet.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  int _currentBottomNavIndex = 0;
  String _selectedLanguage = 'English';

  final List<String> _languages = ['English', 'हिंदी (Hindi)', 'मराठी (Marathi)', 'தமிழ் (Tamil)'];
  bool _isWomenBookingPreference = false;

  @override
  void initState() {
    super.initState();
    _loadWomenPreference();
    UserProfileService.instance.addListener(_onProfileChanged);
    CustomerProfileService.instance.addListener(_onProfileChanged);
    WalletService.instance.addListener(_onProfileChanged);
    CustomerProfileService.instance.loadInitialData();
    CustomerProfileService.instance.fetchProfile();
    UserProfileService.instance.fetchUserProfile();
    WalletService.instance.loadFromCache();
    WalletService.instance.fetchWallet();
  }

  @override
  void dispose() {
    UserProfileService.instance.removeListener(_onProfileChanged);
    CustomerProfileService.instance.removeListener(_onProfileChanged);
    WalletService.instance.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onProfileChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadWomenPreference() async {
    final val = await BookingForWomenSheet.getSavedPreference();
    if (mounted) {
      setState(() {
        _isWomenBookingPreference = val;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TOP SCENIC BANNER (Sky, Sun, Hills, River, Sailboat & User Details)
            _buildScenicHeader(context),

            const SizedBox(height: 18),

            // 2. TRY REDBUS IN YOUR LANGUAGE
            _buildLanguageSection(),

            const SizedBox(height: 24),

            // 3. MY DETAILS SECTION
            _buildMyDetailsSection(),

            const SizedBox(height: 24),

            // 4. PAYMENTS SECTION
            _buildPaymentsSection(),

            const SizedBox(height: 24),

            // 5. MORE SECTION
            _buildMoreSection(),

            const SizedBox(height: 24),

            // 6. PREFERENCES SECTION
            _buildPreferencesSection(),

            const SizedBox(height: 18),

            // 6.5. LOGOUT SECTION
            _buildLogoutSection(),

            const SizedBox(height: 28),

            // 7. APP VERSION FOOTER
            const Center(
              child: Text(
                'V82.6.5',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),

      // BOTTOM NAVIGATION BAR
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ==========================================
  // 1. TOP SCENIC HEADER
  // ==========================================
  Widget _buildScenicHeader(BuildContext context) {
    return SizedBox(
      height: 240,
      width: double.infinity,
      child: Stack(
        children: [
          // Background scenic illustration painter
          Positioned.fill(
            child: CustomPaint(
              painter: _ScenicHeaderPainter(),
            ),
          ),

          // Circular Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black87, size: 22),
              ),
            ),
          ),

          // User Profile Info
          Positioned(
            left: 20,
            bottom: 24,
            child: Builder(
              builder: (ctx) {
                final profile = CustomerProfileService.instance.profile;
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CustomerProfileScreen()),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            profile.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.formattedPhone,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile.memberSinceFormatted,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. LANGUAGE SECTION
  // ==========================================
  Widget _buildLanguageSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Try SPinGO in your language',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _languages.map((lang) {
                final isSelected = _selectedLanguage == lang;
                return GestureDetector(
                  onTap: () => setState(() => _selectedLanguage = lang),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFDC2626) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFDC2626) : const Color(0xFFCBD5E1),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      lang,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. MY DETAILS SECTION
  // ==========================================
  Widget _buildMyDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'My details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
        ),
        const SizedBox(height: 4),
        _buildListTile(
          icon: Icons.format_list_bulleted,
          title: 'Bookings',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingsScreen())),
        ),
        _buildListTile(
          icon: Icons.card_giftcard_outlined,
          title: 'Scratch Card',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScratchCardScreen())),
        ),
        _buildListTile(
          icon: Icons.person_outline,
          title: 'My Profile & Details',
          subtitle: 'Live API synced customer data',
          subtitleColor: const Color(0xFF65A30D),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerProfileScreen())),
        ),
        _buildListTile(
          icon: Icons.group_outlined,
          title: 'Passengers',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PassengersScreen())),
        ),
        _buildListTile(
          icon: Icons.two_wheeler_outlined,
          title: 'Ride & Delivery Preferences',
          subtitle: 'Bike, Cab & Parcel saved options',
          subtitleColor: const Color(0xFF16A34A),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ride & delivery preferences are up to date!')),
            );
          },
        ),
      ],
    );
  }

  // ==========================================
  // 4. PAYMENTS SECTION
  // ==========================================
  Widget _buildPaymentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Payments',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
        ),
        const SizedBox(height: 4),
        _buildListTile(
          icon: Icons.account_balance_wallet_outlined,
          title: 'SPinGO Wallet',
          subtitle: 'Balance: ₹${WalletService.instance.balance.toStringAsFixed(2)}',
          subtitleColor: const Color(0xFF16A34A),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen())),
        ),
        _buildListTile(
          icon: Icons.payments_outlined,
          title: 'Payment methods',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsScreen())),
        ),
      ],
    );
  }

  // ==========================================
  // 5. MORE SECTION
  // ==========================================
  Widget _buildMoreSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'More',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
        ),
        const SizedBox(height: 4),
        _buildListTile(
          icon: Icons.local_offer_outlined,
          title: 'Offers',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OffersSplashScreen())),
        ),
        _buildListTile(
          icon: Icons.info_outline,
          title: 'Know about SPinGO',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('SPinGO: World\'s Leading Travel & Mobility Platform')),
            );
          },
        ),
        _buildListTile(
          icon: Icons.help_outline,
          title: 'Help',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen())),
        ),
        _buildListTile(
          icon: Icons.manage_accounts_outlined,
          title: 'Account settings',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountSettingsScreen())),
        ),
      ],
    );
  }

  // ==========================================
  // 6. PREFERENCES SECTION
  // ==========================================
  Widget _buildPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Preferences',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
        ),
        const SizedBox(height: 4),
        _buildListTile(
          icon: Icons.notifications_none,
          title: 'Notifications',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationPreferencesScreen()),
            );
          },
        ),
        _buildListTile(
          customLeading: Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(color: Color(0xFFFCE7F3), shape: BoxShape.circle),
            child: const Icon(Icons.face_3, color: Color(0xFFEC4899), size: 18),
          ),
          title: 'Booking for women',
          subtitle: _isWomenBookingPreference ? 'Yes' : 'No',
          onTap: () async {
            final result = await BookingForWomenSheet.show(
              context,
              initialValue: _isWomenBookingPreference,
            );
            if (result != null && mounted) {
              setState(() {
                _isWomenBookingPreference = result;
              });
            }
          },
        ),
      ],
    );
  }

  // ==========================================
  // 6.5. LOGOUT SECTION
  // ==========================================
  Widget _buildLogoutSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () => LogoutDialog.show(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFEE2E2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded, color: Color(0xFFD83A3A), size: 20),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Log out',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD83A3A),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Sign out of your account on this device',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFD83A3A)),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // LIST TILE BUILDER
  // ==========================================
  Widget _buildListTile({
    IconData? icon,
    Widget? customLeading,
    required String title,
    String? subtitle,
    Color? subtitleColor,
    String? trailingBadge,
    bool showChevron = true,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
          leading: customLeading ?? Icon(icon, color: Colors.black87, size: 24),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: subtitleColor ?? Colors.grey.shade600,
                    fontWeight: subtitleColor != null ? FontWeight.bold : FontWeight.normal,
                  ),
                )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailingBadge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    trailingBadge,
                    style: const TextStyle(
                      color: Color(0xFF16A34A),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (showChevron)
                const Icon(Icons.chevron_right, color: Colors.black45, size: 22),
            ],
          ),
          onTap: onTap,
        ),
        const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0xFFF1F5F9)),
      ],
    );
  }

  // ==========================================
  // BOTTOM NAVIGATION BAR
  // ==========================================
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentBottomNavIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFD83A3A),
        unselectedItemColor: const Color(0xFF64748B),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        onTap: (index) {
          setState(() => _currentBottomNavIndex = index);
          if (index == 0) {
            Navigator.pop(context);
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingsScreen()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const OffersSplashScreen()));
          } else if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const GetawaysScreen()));
          } else if (index == 4) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen()));
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.format_list_bulleted),
            label: 'Bookings',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.percent),
            label: 'Offers',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.wb_sunny_outlined),
                Positioned(
                  top: -4,
                  right: -8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'New',
                      style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            label: 'Getaways',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            label: 'Help',
          ),
        ],
      ),
    );
  }
}

// ==========================================
// SCENIC HEADER PAINTER
// (Sky, Sun, Clouds, Green Hills, Tree, River & Sailboat)
// ==========================================
class _ScenicHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Sky Gradient
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0284C7), Color(0xFF38BDF8), Color(0xFFBAE6FD)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);

    // 2. Sun with soft glow
    final sunCenter = Offset(w * 0.85, h * 0.28);
    canvas.drawCircle(
      sunCenter,
      24,
      Paint()..color = const Color(0xFFFEF08A).withValues(alpha: 0.4),
    );
    canvas.drawCircle(
      sunCenter,
      18,
      Paint()..color = const Color(0xFFFDE047),
    );

    // 3. Clouds
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.92, h * 0.48), width: 60, height: 20), cloudPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.90, h * 0.44), width: 34, height: 22), cloudPaint);

    // 4. Distant dark green hill
    final backHill = Path()
      ..moveTo(0, h * 0.65)
      ..quadraticBezierTo(w * 0.35, h * 0.58, w * 0.6, h * 0.66)
      ..lineTo(w, h * 0.72)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(backHill, Paint()..color = const Color(0xFF1E3A1A));

    // 5. River curve on right
    final river = Path()
      ..moveTo(w * 0.68, h)
      ..quadraticBezierTo(w * 0.82, h * 0.75, w * 0.84, h * 0.72)
      ..lineTo(w * 0.88, h * 0.72)
      ..quadraticBezierTo(w * 0.86, h * 0.78, w * 0.82, h)
      ..close();
    canvas.drawPath(river, Paint()..color = const Color(0xFF7DD3FC));

    // Small Sailboat on river
    final boatHull = Path()
      ..moveTo(w * 0.73, h * 0.86)
      ..lineTo(w * 0.81, h * 0.86)
      ..lineTo(w * 0.79, h * 0.88)
      ..lineTo(w * 0.75, h * 0.88)
      ..close();
    canvas.drawPath(boatHull, Paint()..color = const Color(0xFF78350F));

    final sail = Path()
      ..moveTo(w * 0.77, h * 0.76)
      ..lineTo(w * 0.77, h * 0.85)
      ..lineTo(w * 0.80, h * 0.85)
      ..close();
    canvas.drawPath(sail, Paint()..color = Colors.white);

    // 6. Main Lush Green Rolling Hill
    final frontHill = Path()
      ..moveTo(0, h * 0.62)
      ..quadraticBezierTo(w * 0.45, h * 0.62, w * 0.75, h * 0.88)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(frontHill, Paint()..color = const Color(0xFF166534));

    // 7. Tree on the hill
    final treeX = w * 0.60;
    final treeY = h * 0.58;

    // Trunk
    canvas.drawRect(
      Rect.fromLTWH(treeX - 2.5, treeY + 12, 5, 24),
      Paint()..color = const Color(0xFF78350F),
    );
    // Tree Foliage
    canvas.drawOval(
      Rect.fromCenter(center: Offset(treeX, treeY), width: 30, height: 46),
      Paint()..color = const Color(0xFF22C55E),
    );

    // Second small tree
    final tree2X = w * 0.83;
    final tree2Y = h * 0.66;
    canvas.drawRect(
      Rect.fromLTWH(tree2X - 2, tree2Y + 8, 4, 16),
      Paint()..color = const Color(0xFF78350F),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(tree2X, tree2Y), width: 20, height: 30),
      Paint()..color = const Color(0xFF4ADE80),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
