import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/notification_preferences_model.dart';
import '../../services/notification_preferences_service.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends State<NotificationPreferencesScreen> {
  NotificationPreferencesModel _preferences = const NotificationPreferencesModel();
  bool _isLoading = true;

  // Colors matching Screenshot 1
  static const Color titleColor = Color(0xFF0F172A);
  static const Color subtitleColor = Color(0xFF64748B);
  static const Color bookingSwitchTrackColor = Color(0xFFF09DA6); // Soft rose-pink for booking updates
  static const Color offersSwitchTrackColor = Color(0xFFD83A3A); // Vibrant crimson red for offers
  static const Color inactiveTrackColor = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final loaded = await NotificationPreferencesService.instance.loadPreferences();
    if (mounted) {
      setState(() {
        _preferences = loaded;
        _isLoading = false;
      });
    }
  }

  Future<void> _updatePreferences(NotificationPreferencesModel updated) async {
    HapticFeedback.selectionClick();
    setState(() {
      _preferences = updated;
    });
    await NotificationPreferencesService.instance.savePreferences(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notification preferences',
          style: TextStyle(
            color: titleColor,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFF1F5F9),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD83A3A),
              ),
            )
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              children: [
                // ==========================================
                // SECTION 1: BOOKINGS
                // ==========================================
                const Text(
                  'Bookings',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Mandatory notification for your booking updates',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: subtitleColor,
                  ),
                ),
                const SizedBox(height: 12),

                // Booking SMS
                _buildPreferenceRow(
                  title: 'SMS',
                  value: _preferences.bookingSms,
                  activeColor: bookingSwitchTrackColor,
                  onChanged: (val) {
                    _updatePreferences(_preferences.copyWith(bookingSms: val));
                  },
                ),
                const Divider(height: 1, thickness: 0.8, color: Color(0xFFF1F5F9)),

                // Booking WhatsApp
                _buildPreferenceRow(
                  title: 'WhatsApp',
                  value: _preferences.bookingWhatsapp,
                  activeColor: bookingSwitchTrackColor,
                  onChanged: (val) {
                    _updatePreferences(_preferences.copyWith(bookingWhatsapp: val));
                  },
                ),
                const Divider(height: 1, thickness: 0.8, color: Color(0xFFF1F5F9)),

                // Booking Email
                _buildPreferenceRow(
                  title: 'Email',
                  value: _preferences.bookingEmail,
                  activeColor: bookingSwitchTrackColor,
                  onChanged: (val) {
                    _updatePreferences(_preferences.copyWith(bookingEmail: val));
                  },
                ),
                const Divider(height: 1, thickness: 0.8, color: Color(0xFFF1F5F9)),

                // Booking Push notification
                _buildPreferenceRow(
                  title: 'Push notification',
                  value: _preferences.bookingPush,
                  activeColor: bookingSwitchTrackColor,
                  onChanged: (val) {
                    _updatePreferences(_preferences.copyWith(bookingPush: val));
                  },
                ),
                const Divider(height: 1, thickness: 0.8, color: Color(0xFFF1F5F9)),

                const SizedBox(height: 36),

                // ==========================================
                // SECTION 2: OFFERS & PROMOTIONS
                // ==========================================
                const Text(
                  'Offers & promotions',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Latest offer & promotion updates for you',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: subtitleColor,
                  ),
                ),
                const SizedBox(height: 12),

                // Offers SMS
                _buildPreferenceRow(
                  title: 'SMS',
                  value: _preferences.offersSms,
                  activeColor: offersSwitchTrackColor,
                  onChanged: (val) {
                    _updatePreferences(_preferences.copyWith(offersSms: val));
                  },
                ),
                const Divider(height: 1, thickness: 0.8, color: Color(0xFFF1F5F9)),

                // Offers WhatsApp
                _buildPreferenceRow(
                  title: 'WhatsApp',
                  value: _preferences.offersWhatsapp,
                  activeColor: offersSwitchTrackColor,
                  onChanged: (val) {
                    _updatePreferences(_preferences.copyWith(offersWhatsapp: val));
                  },
                ),
                const Divider(height: 1, thickness: 0.8, color: Color(0xFFF1F5F9)),

                // Offers Email
                _buildPreferenceRow(
                  title: 'Email',
                  value: _preferences.offersEmail,
                  activeColor: offersSwitchTrackColor,
                  onChanged: (val) {
                    _updatePreferences(_preferences.copyWith(offersEmail: val));
                  },
                ),
                const Divider(height: 1, thickness: 0.8, color: Color(0xFFF1F5F9)),

                // Offers Push notification
                _buildPreferenceRow(
                  title: 'Push notification',
                  value: _preferences.offersPush,
                  activeColor: offersSwitchTrackColor,
                  onChanged: (val) {
                    _updatePreferences(_preferences.copyWith(offersPush: val));
                  },
                ),
                const Divider(height: 1, thickness: 0.8, color: Color(0xFFF1F5F9)),

                const SizedBox(height: 40),
              ],
            ),
    );
  }

  Widget _buildPreferenceRow({
    required String title,
    required bool value,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          _CustomSwitch(
            value: value,
            activeColor: activeColor,
            inactiveColor: inactiveTrackColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

/// Custom Switch widget matching Screenshot 1 exact aesthetic:
/// Smooth pill with white circle thumb.
class _CustomSwitch extends StatelessWidget {
  final bool value;
  final Color activeColor;
  final Color inactiveColor;
  final ValueChanged<bool> onChanged;

  const _CustomSwitch({
    required this.value,
    required this.activeColor,
    required this.inactiveColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        width: 52,
        height: 30,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: value ? activeColor : inactiveColor,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
