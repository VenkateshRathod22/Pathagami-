import 'package:flutter/material.dart';
import 'package:tripried/view/account/sub_features/personal_info/services/user_profile_service.dart';
import 'package:tripried/view/auth/presentations/screen/login_screen.dart';
import 'package:tripried/view/auth/services/auth_service.dart';

class LogoutDialog {
  static const Color primaryRed = Color(0xFFD83A3A);
  static const Color darkNavy = Color(0xFF0F172A);

  /// Displays the interactive Logout confirmation dialog
  static Future<void> show(BuildContext context, {VoidCallback? onLoggedOut}) async {
    final profile = UserProfileService.instance.profile;

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          contentPadding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Red circular icon
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFEE2E2), width: 2),
                ),
                child: const Center(
                  child: Icon(Icons.logout_rounded, color: primaryRed, size: 30),
                ),
              ),
              const SizedBox(height: 18),

              // Title
              const Text(
                'Log out of SPinGO?',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: darkNavy,
                ),
              ),
              const SizedBox(height: 8),

              // Current User Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFFEEF2FF),
                      child: Text(
                        profile.initials,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4338CA),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.displayName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: darkNavy,
                            ),
                          ),
                          Text(
                            profile.formattedPhone,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Description
              const Text(
                'Are you sure you want to log out? You will need to sign in again to access your tickets, rewards, and wallet balance.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Buttons Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(dialogCtx, false),
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(dialogCtx, true),
                      child: const Text(
                        'LOG OUT',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (shouldLogout == true && context.mounted) {
      await _executeLogout(context, onLoggedOut: onLoggedOut);
    }
  }

  /// Executes logout API, clears preferences, and redirects
  static Future<void> _executeLogout(BuildContext context, {VoidCallback? onLoggedOut}) async {
    // 1. Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(color: primaryRed, strokeWidth: 2.5),
                ),
                SizedBox(width: 18),
                Text(
                  'Logging out...',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: darkNavy),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // 2. Call live API: POST https://spingoride.com/api/v1/auth/logout
    final logoutRes = await AuthService.instance.logout();

    // 3. Dismiss loading dialog
    if (context.mounted) {
      Navigator.pop(context);
    }

    // 4. Show success feedback
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  logoutRes.message.isNotEmpty ? logoutRes.message : 'Successfully logged out.',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    if (onLoggedOut != null) {
      onLoggedOut();
    }

    // 5. Navigate to LoginScreen clearing navigation stack
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}
