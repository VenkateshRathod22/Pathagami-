import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/bus_coupon_model.dart';
import '../../services/bus_coupon_service.dart';

class BusCouponsScreen extends StatefulWidget {
  final double? bookingAmount;
  final String? preselectedCode;
  final ValueChanged<BusCouponModel>? onCouponSelected;

  const BusCouponsScreen({
    super.key,
    this.bookingAmount,
    this.preselectedCode,
    this.onCouponSelected,
  });

  @override
  State<BusCouponsScreen> createState() => _BusCouponsScreenState();
}

class _BusCouponsScreenState extends State<BusCouponsScreen> {
  final TextEditingController _codeController = TextEditingController();
  List<BusCouponModel> _coupons = [];
  bool _isLoading = true;
  String _inputError = '';

  static const Color primaryRed = Color(0xFFD83A3A);
  static const Color darkNavy = Color(0xFF0F172A);
  static const Color brandGreen = Color(0xFF16A34A);

  @override
  void initState() {
    super.initState();
    if (widget.preselectedCode != null && widget.preselectedCode!.isNotEmpty) {
      _codeController.text = widget.preselectedCode!;
    }
    _loadCoupons();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadCoupons({bool forceRefresh = false}) async {
    setState(() => _isLoading = true);
    final results = await BusCouponService.instance.getAvailableCoupons(forceRefresh: forceRefresh);
    if (mounted) {
      setState(() {
        _coupons = results;
        _isLoading = false;
      });
    }
  }

  void _applyCoupon(BusCouponModel coupon) {
    HapticFeedback.mediumImpact();
    if (widget.bookingAmount != null) {
      if (!coupon.canApply(widget.bookingAmount!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Minimum booking amount of ₹${coupon.minBookingAmount.toInt()} required for this coupon.',
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    if (widget.onCouponSelected != null) {
      widget.onCouponSelected!(coupon);
    }

    Navigator.pop(context, coupon);
  }

  void _copyCouponCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 Coupon code "$code" copied to clipboard!'),
        backgroundColor: darkNavy,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _validateManualInput() {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _inputError = 'Please enter a coupon code');
      return;
    }

    final match = _coupons.firstWhere(
      (c) => c.code.toUpperCase() == code,
      orElse: () => BusCouponModel(
        id: 999,
        code: code,
        title: 'Custom Coupon $code',
        description: 'Promotional discount code',
        discountType: 'percentage',
        discountValue: 10,
        maxDiscount: 150,
        minBookingAmount: 100,
        badge: 'Special Promo',
        expiresAtFormatted: 'Limited Time',
        isValid: true,
      ),
    );

    setState(() => _inputError = '');
    _applyCoupon(match);
  }

  void _showTermsModal(BusCouponModel coupon) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        coupon.code,
                        style: const TextStyle(fontWeight: FontWeight.w900, color: primaryRed, fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text('Terms & Conditions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const Divider(height: 20),
            Text(coupon.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: darkNavy)),
            const SizedBox(height: 6),
            Text(coupon.description, style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4)),
            const SizedBox(height: 14),
            _buildTermBullet('Valid till ${coupon.expiresAtFormatted}.'),
            _buildTermBullet('Minimum booking amount: ₹${coupon.minBookingAmount.toInt()}.'),
            _buildTermBullet(
              coupon.discountType == 'percentage'
                  ? 'Maximum discount capped at ₹${coupon.maxDiscount.toInt()}.'
                  : 'Flat discount of ₹${coupon.discountValue.toInt()} applied directly.',
            ),
            _buildTermBullet('Valid on all AC, Sleeper, and Govt RTC route bookings.'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _applyCoupon(coupon);
                },
                child: const Text('APPLY THIS COUPON', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: primaryRed)),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12.5, color: Colors.grey.shade800))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Coupons & Offers',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: darkNavy),
            ),
            if (widget.bookingAmount != null)
              Text(
                'Booking Fare: ₹${widget.bookingAmount!.toInt()}',
                style: const TextStyle(fontSize: 12, color: brandGreen, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadCoupons(forceRefresh: true),
        color: primaryRed,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.all(16),
          children: [
            // Manual Input Card
            _buildManualInputCard(),

            const SizedBox(height: 20),

            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Available Bus Coupons',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: darkNavy),
                ),
                Text(
                  '${_coupons.length} Offers',
                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Coupon Cards List
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: primaryRed),
                ),
              )
            else if (_coupons.isEmpty)
              _buildEmptyState()
            else
              ..._coupons.map((coupon) => _buildCouponCard(coupon)),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildManualInputCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Have a Coupon Code?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkNavy),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _inputError.isNotEmpty ? Colors.redAccent : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_offer_outlined, color: primaryRed, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _codeController,
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                            LengthLimitingTextInputFormatter(16),
                          ],
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 1),
                          decoration: const InputDecoration(
                            hintText: 'Enter coupon code (e.g. WER123)',
                            hintStyle: TextStyle(fontSize: 12.5, fontWeight: FontWeight.normal, letterSpacing: 0),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onSubmitted: (_) => _validateManualInput(),
                        ),
                      ),
                      if (_codeController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _codeController.clear();
                            setState(() => _inputError = '');
                          },
                          child: const Icon(Icons.close, size: 18, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    elevation: 0,
                  ),
                  onPressed: _validateManualInput,
                  child: const Text('APPLY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                ),
              ),
            ],
          ),
          if (_inputError.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(_inputError, style: const TextStyle(color: Colors.redAccent, fontSize: 11.5, fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    );
  }

  Widget _buildCouponCard(BusCouponModel coupon) {
    final isEligible = widget.bookingAmount == null || coupon.canApply(widget.bookingAmount!);
    final savings = widget.bookingAmount != null ? coupon.calculateDiscount(widget.bookingAmount!) : coupon.maxDiscount;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEligible ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Code Pill + Badge + Apply/Copy Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Code Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.confirmation_number_outlined, size: 14, color: primaryRed),
                          const SizedBox(width: 6),
                          Text(
                            coupon.code,
                            style: const TextStyle(
                              color: primaryRed,
                              fontWeight: FontWeight.w900,
                              fontSize: 13.5,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Badge
                    if (coupon.badge.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          coupon.badge,
                          style: const TextStyle(
                            color: brandGreen,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),

                // Action: Apply or Copy
                if (widget.bookingAmount != null)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEligible ? primaryRed : Colors.grey.shade300,
                      foregroundColor: isEligible ? Colors.white : Colors.grey.shade600,
                      elevation: 0,
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                    ),
                    onPressed: isEligible ? () => _applyCoupon(coupon) : null,
                    child: const Text('APPLY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  )
                else
                  InkWell(
                    onTap: () => _copyCouponCode(coupon.code),
                    child: const Row(
                      children: [
                        Icon(Icons.copy_rounded, size: 14, color: primaryRed),
                        SizedBox(width: 4),
                        Text(
                          'COPY',
                          style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Divider
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Description & Details
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coupon.title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: darkNavy),
                ),
                const SizedBox(height: 4),
                Text(
                  coupon.description,
                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700, height: 1.35),
                ),
                const SizedBox(height: 10),

                // Info tags: Validity & Min Booking
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 13, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          'Valid till ${coupon.expiresAtFormatted}',
                          style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => _showTermsModal(coupon),
                      child: const Text(
                        'Terms & Conditions',
                        style: TextStyle(color: Color(0xFF2563EB), fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                if (widget.bookingAmount != null && isEligible && savings > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Text(
                      '🎉 Save ₹${savings.toInt()} on this booking with this coupon!',
                      style: const TextStyle(color: brandGreen, fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ] else if (widget.bookingAmount != null && !isEligible) ...[
                  const SizedBox(height: 8),
                  Text(
                    '⚠️ Add ₹${(coupon.minBookingAmount - widget.bookingAmount!).toInt()} more fare to unlock this coupon.',
                    style: TextStyle(color: Colors.amber.shade900, fontSize: 11.5, fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Icon(Icons.confirmation_number_outlined, size: 54, color: Colors.grey),
          const SizedBox(height: 14),
          const Text('No Coupons Available', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Text('Check back later for exciting offers and festival discounts!', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        ],
      ),
    );
  }
}
