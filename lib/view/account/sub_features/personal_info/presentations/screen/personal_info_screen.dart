import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tripried/view/account/sub_features/referrals/presentations/screen/referrals_screen.dart';
import 'package:tripried/view/account/sub_features/wallet/presentations/screen/wallet_screen.dart';
import 'package:tripried/view/account/sub_features/account_settings/presentations/widgets/logout_dialog.dart';
import '../../models/user_profile_model.dart';
import '../../services/user_profile_service.dart';
import 'edit_profile_screen.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  static const Color primaryRed = Color(0xFFD83A3A);
  static const Color darkNavy = Color(0xFF0F172A);
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color brandGreen = Color(0xFF16A34A);

  @override
  void initState() {
    super.initState();
    UserProfileService.instance.addListener(_onProfileChanged);
    UserProfileService.instance.fetchUserProfile();
  }

  @override
  void dispose() {
    UserProfileService.instance.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onProfileChanged() {
    if (mounted) setState(() {});
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label "$text" copied to clipboard!'),
        backgroundColor: darkNavy,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openEditProfileScreen(UserProfileModel profile) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(profile: profile),
      ),
    );
    if (updated == true && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = UserProfileService.instance.profile;
    final isLoading = UserProfileService.instance.isLoading;

    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Personal Information',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _openEditProfileScreen(profile),
            icon: const Icon(Icons.edit_outlined, size: 16, color: primaryRed),
            label: const Text(
              'Edit',
              style: TextStyle(
                color: primaryRed,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          if (isLoading)
            const LinearProgressIndicator(color: primaryRed, minHeight: 2.5),
          Expanded(
            child: RefreshIndicator(
              color: primaryRed,
              onRefresh: () =>
                  UserProfileService.instance.fetchUserProfile(forceRefresh: true),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Profile Hero Card
                    _buildHeroProfileCard(profile),

                    const SizedBox(height: 18),

                    // 2. Personal & Contact Details Card
                    _buildContactDetailsCard(profile),

                    const SizedBox(height: 18),

                    // 3. Saved Addresses Card (Home & Office)
                    _buildAddressesCard(profile),

                    const SizedBox(height: 18),

                    // 4. Wallet & Referral Benefits Card
                    _buildWalletAndRewardsCard(profile),

                    const SizedBox(height: 18),

                    // 5. Security & Privacy note
                    _buildSecurityAndPrivacyCard(),

                    const SizedBox(height: 22),

                    // 6. Sign Out Button
                    Center(
                      child: TextButton.icon(
                        onPressed: () => LogoutDialog.show(context),
                        icon: const Icon(Icons.logout_rounded,
                            color: primaryRed, size: 20),
                        label: const Text(
                          'SIGN OUT OF ACCOUNT',
                          style: TextStyle(
                            color: primaryRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroProfileCard(UserProfileModel profile) {
    final photoUrl = profile.profilePhotoUrl;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
          // Avatar with edit badge
          Stack(
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEEF2FF),
                ),
                child: ClipOval(
                  child: photoUrl != null
                      ? Image.network(
                          photoUrl,
                          width: 84,
                          height: 84,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _buildHeroInitials(profile),
                        )
                      : _buildHeroInitials(profile),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _openEditProfileScreen(profile),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: primaryRed,
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
          Text(
            profile.displayName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: darkNavy,
            ),
          ),
          const SizedBox(height: 4),

          // Customer ID Pill
          if (profile.customerDetails?.customerId != null &&
              profile.customerDetails!.customerId.isNotEmpty)
            GestureDetector(
              onTap: () => _copyToClipboard(
                  profile.customerDetails!.customerId, 'Customer ID'),
              child: Container(
                margin: const EdgeInsets.only(top: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ID: ${profile.customerDetails!.customerId}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.copy_rounded,
                        size: 12, color: Color(0xFF64748B)),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 8),

          // Member since note
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_user_outlined,
                  size: 14, color: brandGreen),
              const SizedBox(width: 6),
              Text(
                profile.memberSinceFormatted,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroInitials(UserProfileModel profile) {
    return Center(
      child: Text(
        profile.initials,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: Color(0xFF4338CA),
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildContactDetailsCard(UserProfileModel profile) {
    final altMobile = profile.effectiveAlternateMobile;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                  'Account & Contact Details',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: darkNavy,
                  ),
                ),
                GestureDetector(
                  onTap: () => _openEditProfileScreen(profile),
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: primaryRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          _buildProfileRow(
            icon: Icons.person_outline_rounded,
            title: 'Full Name',
            value: profile.displayName,
          ),
          _buildProfileRow(
            icon: Icons.phone_android_rounded,
            title: 'Primary Mobile',
            value: profile.formattedPhone,
            isVerified: true,
          ),
          _buildProfileRow(
            icon: Icons.phone_in_talk_outlined,
            title: 'Alternate Mobile',
            value: altMobile.isNotEmpty ? '+91 $altMobile' : 'Not provided',
            onTap: altMobile.isNotEmpty
                ? () => _copyToClipboard(altMobile, 'Alternate mobile')
                : null,
          ),
          _buildProfileRow(
            icon: Icons.mail_outline_rounded,
            title: 'Email Address',
            value: profile.email.isNotEmpty ? profile.email : 'Not specified',
            isVerified: profile.email.isNotEmpty,
          ),
          _buildProfileRow(
            icon: Icons.wc_rounded,
            title: 'Gender',
            value: profile.effectiveGender,
          ),
          _buildProfileRow(
            icon: Icons.calendar_today_rounded,
            title: 'Date of Birth',
            value: profile.effectiveDob.isNotEmpty
                ? profile.effectiveDob
                : 'Not provided',
          ),
          _buildProfileRow(
            icon: Icons.location_on_outlined,
            title: 'City / Region',
            value: profile.effectiveCity,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressesCard(UserProfileModel profile) {
    final home = profile.addresses?.home;
    final office = profile.addresses?.office;

    final homeText = (home != null && home.streetAddress != null && home.streetAddress!.isNotEmpty)
        ? home.formatted
        : profile.effectiveHomeAddress;

    final officeText = (office != null && office.streetAddress != null && office.streetAddress!.isNotEmpty)
        ? office.formatted
        : profile.effectiveOfficeAddress;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                const Row(
                  children: [
                    Icon(Icons.home_work_outlined, size: 18, color: primaryRed),
                    SizedBox(width: 8),
                    Text(
                      'Saved Addresses',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: darkNavy,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => _openEditProfileScreen(profile),
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: primaryRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Home Address
          _buildAddressRow(
            icon: Icons.home_rounded,
            iconBg: const Color(0xFFFEF2F2),
            iconColor: primaryRed,
            title: 'Home Address',
            subtitle: homeText.isNotEmpty
                ? homeText
                : 'Flat 402, Sunshine Apartments, Sector 62, Noida, UP - 201301',
            pinCode: home?.pinCode ?? profile.effectivePinCode,
          ),

          const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),

          // Office Address
          _buildAddressRow(
            icon: Icons.business_rounded,
            iconBg: const Color(0xFFEFF6FF),
            iconColor: const Color(0xFF2563EB),
            title: 'Office Address',
            subtitle: officeText.isNotEmpty
                ? officeText
                : 'Tower A, Tech Park, Sector 135, Noida, UP - 201301',
            pinCode: office?.pinCode ?? profile.effectivePinCode,
          ),

          const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),

          // PIN Code
          _buildProfileRow(
            icon: Icons.pin_drop_outlined,
            title: 'Postal PIN Code',
            value: profile.effectivePinCode,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String pinCode,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (pinCode.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'PIN: $pinCode',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: darkNavy,
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

  Widget _buildProfileRow({
    required IconData icon,
    required String title,
    required String value,
    bool isVerified = false,
    bool isLast = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: const Color(0xFF64748B), size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: darkNavy,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isVerified)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle,
                            color: Color(0xFF059669), size: 12),
                        SizedBox(width: 3),
                        Text(
                          'Verified',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (onTap != null)
                  const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Icon(Icons.copy_rounded,
                        size: 14, color: Color(0xFF94A3B8)),
                  ),
              ],
            ),
          ),
          if (!isLast)
            const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
        ],
      ),
    );
  }

  Widget _buildWalletAndRewardsCard(UserProfileModel profile) {
    final rewardPoints = profile.customerDetails?.rewardPoints ?? 0;
    final totalReferrals = profile.customerDetails?.totalReferrals ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
              'Wallet & Loyalty Benefits',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: darkNavy,
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Wallet Balance Item
          InkWell(
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const WalletScreen())),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded,
                        color: Color(0xFFD97706), size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SPinGO Wallet Balance',
                          style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹${profile.wallet.balance}.00',
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: darkNavy),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'View Wallet',
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: primaryRed),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 18, color: primaryRed),
                ],
              ),
            ),
          ),

          const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),

          // Referral Code Item
          InkWell(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ReferralsScreen())),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.card_giftcard_rounded,
                        color: Color(0xFF2563EB), size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Referral Code',
                          style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              profile.customerDetails?.referralCode ??
                                  'REF5021EB',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _copyToClipboard(
                                profile.customerDetails?.referralCode ??
                                    'REF5021EB',
                                'Referral code',
                              ),
                              child: const Icon(Icons.copy_rounded,
                                  size: 14, color: Color(0xFF2563EB)),
                            ),
                          ],
                        ),
                        if (totalReferrals > 0 || rewardPoints > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              '$totalReferrals referrals • $rewardPoints reward points',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF16A34A),
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Text(
                    'Refer & Earn',
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: primaryRed),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 18, color: primaryRed),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityAndPrivacyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: Color(0xFF64748B), size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your profile data is encrypted & safe',
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: darkNavy),
                ),
                SizedBox(height: 2),
                Text(
                  'We never share your personal contact information without your explicit permission.',
                  style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF64748B),
                      height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
