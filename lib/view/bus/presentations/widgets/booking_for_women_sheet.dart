import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingForWomenSheet extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool>? onConfirmed;

  const BookingForWomenSheet({
    super.key,
    this.initialValue = false,
    this.onConfirmed,
  });

  static const String storageKey = 'spingo_booking_for_women';

  /// Convenience method to show bottom sheet anywhere (Bus screen, Account screen, etc.)
  static Future<bool?> show(
    BuildContext context, {
    bool initialValue = false,
    ValueChanged<bool>? onConfirmed,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BookingForWomenSheet(
        initialValue: initialValue,
        onConfirmed: onConfirmed,
      ),
    );
  }

  /// Get persisted preference
  static Future<bool> getSavedPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(storageKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Save preference
  static Future<void> savePreference(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(storageKey, value);
    } catch (_) {}
  }

  @override
  State<BookingForWomenSheet> createState() => _BookingForWomenSheetState();
}

class _BookingForWomenSheetState extends State<BookingForWomenSheet> {
  late bool _selectedValue;
  bool _isInfoExpanded = false;

  static const Color primaryRed = Color(0xFFD83A3A);
  static const Color titleColor = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  void _showInfoDetails() {
    HapticFeedback.lightImpact();
    setState(() {
      _isInfoExpanded = !_isInfoExpanded;
    });
  }

  Future<void> _handleConfirm() async {
    HapticFeedback.mediumImpact();
    await BookingForWomenSheet.savePreference(_selectedValue);
    if (widget.onConfirmed != null) {
      widget.onConfirmed!(_selectedValue);
    }
    if (mounted) {
      Navigator.pop(context, _selectedValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title and Close 'X'
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Booking for women',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                  letterSpacing: -0.2,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.close, color: Colors.black87, size: 24),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Subtitle
          const Text(
            'Providing helpful details to smartly choose bus travel for women',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
              height: 1.35,
            ),
          ),

          const SizedBox(height: 10),

          // "Know more" Link (Blue underline)
          GestureDetector(
            onTap: _showInfoDetails,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Know more',
                  style: TextStyle(
                    color: Color(0xFF1D4ED8),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xFF1D4ED8),
                    decorationThickness: 1.5,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _isInfoExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: const Color(0xFF1D4ED8),
                  size: 18,
                ),
              ],
            ),
          ),

          // Expanded "Know more" explanation
          if (_isInfoExpanded) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoBullet(
                    icon: Icons.shield_outlined,
                    text: 'Adjacent seat protection: Male passengers cannot book adjoining berths/seats next to female solo travelers.',
                  ),
                  SizedBox(height: 8),
                  _InfoBullet(
                    icon: Icons.verified_user_outlined,
                    text: 'Verified female-friendly operators with verified drivers and live CCTV on select coaches.',
                  ),
                  SizedBox(height: 8),
                  _InfoBullet(
                    icon: Icons.sos_outlined,
                    text: '24x7 Emergency SOS helpline with 1-tap live location sharing directly to your emergency contacts.',
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Option: "Yes"
          InkWell(
            onTap: () {
              setState(() => _selectedValue = true);
              HapticFeedback.selectionClick();
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Yes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                  _RadioIndicator(isSelected: _selectedValue == true),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Option: "No"
          InkWell(
            onTap: () {
              setState(() => _selectedValue = false);
              HapticFeedback.selectionClick();
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'No',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                  _RadioIndicator(isSelected: _selectedValue == false),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Bottom Confirm Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryRed,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              onPressed: _handleConfirm,
              child: const Text(
                'Confirm',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Radio Indicator matching Screenshot 2:
/// - Selected: outer ring red + inner dot red
/// - Unselected: outer ring grey + transparent inside
class _RadioIndicator extends StatelessWidget {
  final bool isSelected;

  const _RadioIndicator({required this.isSelected});

  static const Color primaryRed = Color(0xFFD83A3A);
  static const Color unselectedColor = Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? primaryRed : unselectedColor,
          width: 2.2,
        ),
      ),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: isSelected ? 11 : 0,
          height: isSelected ? 11 : 0,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: primaryRed,
          ),
        ),
      ),
    );
  }
}

class _InfoBullet extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoBullet({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFFD83A3A)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: Color(0xFF334155),
            ),
          ),
        ),
      ],
    );
  }
}
