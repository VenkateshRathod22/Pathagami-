import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tripried/view/account/sub_features/account_settings/presentations/widgets/logout_dialog.dart';
import 'package:tripried/view/account/sub_features/wallet/presentations/screen/wallet_screen.dart';
import 'package:tripried/view/account/sub_features/customer_profile/models/customer_profile_model.dart';
import 'package:tripried/view/account/sub_features/customer_profile/services/customer_profile_service.dart';
import 'edit_customer_profile_screen.dart';

/// Amrita Kumari - Customer Profile Screen
/// Connected directly to SPiNGO Live API:
/// - GET https://spingoride.com/api/v1/customer/profile
/// - GET https://spingoride.com/api/v1/auth/me (fallback)
/// - One-tap Direct Call capability for client demonstration
class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  static const Color brandGreen = Color(0xFF65A30D);
  static const Color brandGreenDark = Color(0xFF4D7C0F);
  static const Color brandGreenLight = Color(0xFFECFCCB);
  static const Color darkNavy = Color(0xFF0F172A);
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color slateBorder = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    CustomerProfileService.instance.addListener(_onProfileUpdated);
    CustomerProfileService.instance.loadInitialData();
    CustomerProfileService.instance.fetchProfile(forceRefresh: true);
  }

  @override
  void dispose() {
    CustomerProfileService.instance.removeListener(_onProfileUpdated);
    super.dispose();
  }

  void _onProfileUpdated() {
    if (mounted) setState(() {});
  }

  /// Triggers a direct phone call using url_launcher (tel:...)
  Future<void> _makePhoneCall(String phoneNumber) async {
    final clean = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (clean.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number not available to call.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    final uri = Uri.parse('tel:$clean');

    try {
      final canCall = await canLaunchUrl(uri);
      if (canCall) {
        await launchUrl(uri);
      } else {
        _showDialModal(clean);
      }
    } catch (e) {
      _showDialModal(clean);
    }
  }

  /// Modal fallback for devices without cellular/SIM dialers
  void _showDialModal(String cleanNumber) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: brandGreenLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.phone_in_talk_rounded,
                      color: brandGreenDark, size: 36),
                ),
                const SizedBox(height: 14),
                Text(
                  'Call Customer: $cleanNumber',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: darkNavy,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tap Dial Call to initiate phone dialer or copy the number.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: slateBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _copyToClipboard(cleanNumber, 'Mobile Number');
                        },
                        child: const Text('Copy Number',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        onPressed: () async {
                          Navigator.pop(ctx);
                          final telUri = Uri.parse('tel:$cleanNumber');
                          await launchUrl(telUri);
                        },
                        icon: const Icon(Icons.call, size: 18),
                        label: const Text('Dial Call',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$label "$text" copied to clipboard!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: darkNavy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openEditProfile(CustomerProfileModel profile) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditCustomerProfileScreen(profile: profile),
      ),
    );

    if (updated == true && mounted) {
      CustomerProfileService.instance.fetchProfile(forceRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = CustomerProfileService.instance.profile;
    final isLoading = CustomerProfileService.instance.isLoading;

    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Customer Profile',
          style: TextStyle(
            color: darkNavy,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        actions: [
          // 1. One-tap Call button in AppBar
          IconButton(
            tooltip: 'Call Customer Phone',
            icon: const Icon(Icons.call_rounded, color: brandGreenDark),
            onPressed: () => _makePhoneCall(profile.phone),
          ),
          // 2. Trigger Live API Call
          IconButton(
            tooltip: 'Call Live API (Refresh)',
            icon: const Icon(Icons.refresh_rounded, color: brandGreenDark),
            onPressed: () {
              HapticFeedback.lightImpact();
              CustomerProfileService.instance.fetchProfile(forceRefresh: true);
            },
          ),
          // 3. Edit Profile
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () => _openEditProfile(profile),
              icon: const Icon(Icons.edit_outlined,
                  size: 16, color: brandGreenDark),
              label: const Text(
                'Edit',
                style: TextStyle(
                  color: brandGreenDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (isLoading)
            const LinearProgressIndicator(
              color: brandGreen,
              backgroundColor: brandGreenLight,
              minHeight: 2.5,
            ),
          Expanded(
            child: RefreshIndicator(
              color: brandGreen,
              onRefresh: () => CustomerProfileService.instance
                  .fetchProfile(forceRefresh: true),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Live API Sync Status Banner with "CALL API" action
                    _buildApiSyncStatusBanner(),

                    const SizedBox(height: 14),

                    // 2. Hero Profile Card with Direct Call Button
                    _buildHeroProfileCard(profile),

                    const SizedBox(height: 16),

                    // 3. Contact & Personal Details Card with Call actions
                    _buildContactDetailsCard(profile),

                    const SizedBox(height: 16),

                    // 4. Wallet, Rewards & Referral Card
                    _buildWalletAndRewardsCard(profile),

                    const SizedBox(height: 16),

                    // 5. Saved Addresses Card (Home & Office)
                    _buildAddressesCard(profile),

                    const SizedBox(height: 16),

                    // 6. Security & Session Card
                    _buildSecurityCard(),

                    const SizedBox(height: 24),

                    // 7. Sign Out Button
                    Center(
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(color: Color(0xFFFCA5A5)),
                          ),
                        ),
                        onPressed: () => LogoutDialog.show(context),
                        icon: const Icon(Icons.logout_rounded, size: 18),
                        label: const Text(
                          'SIGN OUT OF ACCOUNT',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Live API synchronization status header
  Widget _buildApiSyncStatusBanner() {
    final isSynced = CustomerProfileService.instance.isLiveSynced;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isSynced ? const Color(0xFFF0FDF4) : const Color(0xFFFEFCE8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSynced ? const Color(0xFFBBF7D0) : const Color(0xFFFEF08A),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: isSynced ? brandGreen : Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isSynced
                  ? 'Connected to SPiNGO Live API • v1/customer/profile'
                  : 'Cached profile active • Pull down to sync live',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSynced ? brandGreenDark : const Color(0xFF854D0E),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              CustomerProfileService.instance.fetchProfile(forceRefresh: true);
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
              decoration: BoxDecoration(
                color: brandGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sync_rounded, color: Colors.white, size: 12),
                  SizedBox(width: 4),
                  Text(
                    'CALL API',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 1. Hero Card: Photo, Name, Customer ID, Member Since, Direct Call
  Widget _buildHeroProfileCard(CustomerProfileModel profile) {
    final photoUrl = profile.profilePhotoUrl;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: slateBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: brandGreenLight,
                ),
                child: ClipOval(
                  child: photoUrl != null
                      ? Image.network(
                          photoUrl,
                          width: 88,
                          height: 88,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              _buildHeroInitials(profile),
                        )
                      : _buildHeroInitials(profile),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _openEditProfile(profile),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: brandGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.edit_rounded,
                        color: Colors.white, size: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // User Name
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                profile.displayName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: darkNavy,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.verified_rounded, color: brandGreen, size: 18),
            ],
          ),
          const SizedBox(height: 6),

          // Customer ID Tag with Copy Button
          GestureDetector(
            onTap: () => _copyToClipboard(
                profile.effectiveCustomerId, 'Customer ID'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: brandGreenLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD9F99D)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.badge_rounded,
                      size: 13, color: brandGreenDark),
                  const SizedBox(width: 5),
                  Text(
                    'ID: ${profile.effectiveCustomerId}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: brandGreenDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.copy_rounded,
                      size: 13, color: brandGreenDark),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // PROMINENT DIRECT CALL BUTTON
          InkWell(
            onTap: () => _makePhoneCall(profile.phone),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [brandGreenDark, brandGreen],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: brandGreen.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.call_rounded, color: Colors.white, size: 17),
                  const SizedBox(width: 8),
                  Text(
                    'Call Customer: ${profile.formattedPhone}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Role and Member Since
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  profile.role.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text('•', style: TextStyle(color: Colors.grey)),
              const SizedBox(width: 8),
              Text(
                profile.memberSinceFormatted,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroInitials(CustomerProfileModel profile) {
    return Center(
      child: Text(
        profile.initials,
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w900,
          color: brandGreenDark,
          letterSpacing: 1,
        ),
      ),
    );
  }

  /// 2. Personal & Contact Details Card
  Widget _buildContactDetailsCard(CustomerProfileModel profile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: slateBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Personal & Contact Info',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: darkNavy,
                  ),
                ),
                GestureDetector(
                  onTap: () => _openEditProfile(profile),
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: brandGreenDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: slateBorder),

          _buildDetailRow(
            icon: Icons.phone_android_rounded,
            title: 'Mobile Number',
            value: profile.formattedPhone,
            canCopy: true,
            canCall: true,
            onCall: () => _makePhoneCall(profile.phone),
          ),
          _buildDetailRow(
            icon: Icons.email_outlined,
            title: 'Email Address',
            value: profile.email.isNotEmpty ? profile.email : 'Not configured',
            canCopy: profile.email.isNotEmpty,
          ),
          if (profile.effectiveAlternateMobile.isNotEmpty)
            _buildDetailRow(
              icon: Icons.call_outlined,
              title: 'Alternate Mobile',
              value: profile.formattedAlternatePhone ??
                  profile.effectiveAlternateMobile,
              canCopy: true,
              canCall: true,
              onCall: () => _makePhoneCall(profile.effectiveAlternateMobile),
            ),
          _buildDetailRow(
            icon: Icons.person_outline_rounded,
            title: 'Gender',
            value: profile.effectiveGender,
          ),
          _buildDetailRow(
            icon: Icons.cake_outlined,
            title: 'Date of Birth',
            value: profile.effectiveDob,
          ),
          _buildDetailRow(
            icon: Icons.location_city_rounded,
            title: 'City',
            value: profile.effectiveCity,
          ),
          _buildDetailRow(
            icon: Icons.pin_drop_outlined,
            title: 'Postal PIN Code',
            value: profile.effectivePinCode,
            isLast: true,
          ),
        ],
      ),
    );
  }

  /// 3. Financial & Rewards Benefits Card (Wallet, Points, Referrals)
  Widget _buildWalletAndRewardsCard(CustomerProfileModel profile) {
    final details = profile.customerDetails;
    final wallet = profile.wallet;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: slateBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Text(
              'Wallet & Rewards Benefits',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: darkNavy,
              ),
            ),
          ),
          const Divider(height: 1, color: slateBorder),

          // Wallet Card Inside
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: brandGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SPiNGO Wallet Balance',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          wallet.formattedBalance,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WalletScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'View Wallet',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Reward Points & Referral Code
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                // Reward Points
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.stars_rounded,
                                color: Color(0xFFD97706), size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Reward Points',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${details?.rewardPoints ?? 0} pts',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF78350F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Referral Code
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final code = details?.referralCode ?? 'REF5021EB';
                      _copyToClipboard(code, 'Referral Code');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: brandGreenLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFD9F99D)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.card_giftcard_rounded,
                                  color: brandGreenDark, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Referral Code',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: brandGreenDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                details?.referralCode ?? 'REF5021EB',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: brandGreenDark,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const Icon(Icons.copy_rounded,
                                  size: 14, color: brandGreenDark),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 4. Saved Addresses Card
  Widget _buildAddressesCard(CustomerProfileModel profile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: slateBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Saved Addresses',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: darkNavy,
                  ),
                ),
                GestureDetector(
                  onTap: () => _openEditProfile(profile),
                  child: const Text(
                    'Manage',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: brandGreenDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: slateBorder),

          _buildAddressRow(
            icon: Icons.home_rounded,
            title: 'Home Address',
            address: profile.effectiveHomeAddress,
            city: profile.effectiveCity,
            pin: profile.effectivePinCode,
          ),
          const Divider(height: 1, indent: 56, color: slateBorder),
          _buildAddressRow(
            icon: Icons.business_rounded,
            title: 'Office Address',
            address: profile.effectiveOfficeAddress,
            city: profile.effectiveCity,
            pin: profile.effectivePinCode,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressRow({
    required IconData icon,
    required String title,
    required String address,
    required String city,
    required String pin,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: brandGreenLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: brandGreenDark, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: darkNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF475569),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$city - $pin',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 5. Security & Session Information Card
  Widget _buildSecurityCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: slateBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_outline_rounded,
                color: brandGreen, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Encrypted Live Session',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: darkNavy,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Your profile and travel records are securely synchronized with the SPiNGO API cloud with 256-bit authentication.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
    bool canCopy = false,
    bool canCall = false,
    VoidCallback? onCall,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: canCopy ? () => _copyToClipboard(value, title) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF64748B)),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Text(
                value,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: darkNavy,
                ),
              ),
            ),
            if (canCall && onCall != null) ...[
              const SizedBox(width: 8),
              InkWell(
                onTap: onCall,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: brandGreenLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD9F99D)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.call_rounded,
                          size: 12, color: brandGreenDark),
                      SizedBox(width: 4),
                      Text(
                        'CALL',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: brandGreenDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (canCopy) ...[
              const SizedBox(width: 6),
              const Icon(Icons.copy_rounded,
                  size: 13, color: Color(0xFF94A3B8)),
            ],
          ],
        ),
      ),
    );
  }
}
