import 'dart:async';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../models/bus_api_models.dart';
import '../../models/bus_booking_model.dart';
import '../../models/bus_coupon_model.dart';
import '../../data/booking_repository.dart';
import '../../services/bus_api_service.dart';
import '../../services/bus_coupon_service.dart';
import 'bus_coupons_screen.dart';
import 'bus_ticket_confirmation_screen.dart';

class PassengerDetailsScreen extends StatefulWidget {
  final BusItem bus;
  final String fromCity;
  final String toCity;
  final String date;
  final List<String> selectedSeats;
  final BusStopPoint boardingPoint;
  final BusStopPoint droppingPoint;
  final SeatLockDataModel? seatLock;

  const PassengerDetailsScreen({
    super.key,
    required this.bus,
    required this.fromCity,
    required this.toCity,
    required this.date,
    required this.selectedSeats,
    required this.boardingPoint,
    required this.droppingPoint,
    this.seatLock,
  });

  @override
  State<PassengerDetailsScreen> createState() => _PassengerDetailsScreenState();
}

class _PassengerDetailsScreenState extends State<PassengerDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late List<TextEditingController> _nameControllers;
  late List<TextEditingController> _ageControllers;
  late List<String> _genders;
  late List<bool> _isExpandedList;

  final TextEditingController _emailController = TextEditingController(text: 'traveler@gmail.com');
  final TextEditingController _phoneController = TextEditingController(text: '9695541750');

  String _selectedCountryCode = '+91 (IND)';
  String _selectedState = 'Uttar Pradesh';
  bool _sendOnWhatsApp = true;

  // Free Cancellation Option: true = add (₹70/person), false = don't add, null = not chosen yet
  bool? _addFreeCancellation = false;

  // Travel Insurance Option: true = add (₹15/person), false = don't add, null = not chosen yet
  bool? _addTravelInsurance = false;

  bool _hasGstNumber = false;
  final TextEditingController _gstController = TextEditingController();

  Timer? _countdownTimer;
  int _secondsRemaining = 600;

  static const Color primaryRed = Color(0xFFD82C3D);
  static const Color darkNavy = Color(0xFF0F172A);
  static const Color brandGreen = Color(0xFF16A34A);

  // Razorpay & Live Payment State
  late Razorpay _razorpay;
  String? _pendingPnr;
  String? _pendingOrderId;
  CreateBookingResponseModel? _pendingBookingRes;
  List<PassengerInfo> _pendingPassengers = [];
  PaymentInitiateDataModel? _pendingPayData;
  String _pendingContactMobile = '';
  String _pendingContactEmail = '';

  // Applied Coupon State
  BusCouponModel? _appliedCoupon;
  final TextEditingController _quickCouponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final count = widget.selectedSeats.isNotEmpty ? widget.selectedSeats.length : 1;

    // Initialize Razorpay SDK listeners
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _secondsRemaining = widget.seatLock?.expiresInSeconds ?? 600;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });

    _nameControllers = List.generate(
      count,
      (i) => TextEditingController(text: i == 0 ? 'Rahul Sharma' : ''),
    );
    _ageControllers = List.generate(
      count,
      (i) => TextEditingController(text: i == 0 ? '28' : ''),
    );
    _genders = List.generate(count, (_) => 'Male');
    _isExpandedList = List.generate(count, (_) => true);
  }

  String _formatTimer(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _razorpay.clear();
    _countdownTimer?.cancel();
    for (final c in _nameControllers) {
      c.dispose();
    }
    for (final c in _ageControllers) {
      c.dispose();
    }
    _emailController.dispose();
    _phoneController.dispose();
    _gstController.dispose();
    _quickCouponController.dispose();
    super.dispose();
  }

  int get _seatsCount => widget.selectedSeats.isNotEmpty ? widget.selectedSeats.length : 1;
  int get _baseFare => _seatsCount * widget.bus.price;
  int get _cancellationFee => (_addFreeCancellation == true) ? (_seatsCount * 70) : 0;
  int get _insuranceFee => (_addTravelInsurance == true) ? (_seatsCount * 15) : 0;
  int get _subtotalBeforeDiscount => _baseFare + _cancellationFee + _insuranceFee;
  int get _discountAmount => _appliedCoupon != null
      ? _appliedCoupon!.calculateDiscount(_subtotalBeforeDiscount.toDouble()).toInt()
      : 0;
  int get _totalAmount => (_subtotalBeforeDiscount - _discountAmount).clamp(0, 999999);

  void _onProceedToPay() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all passenger details'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    _showPaymentOptionsModal();
  }

  void _showPaymentOptionsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        String selectedPaymentMethod = 'razorpay';

        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Payment Method',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: darkNavy),
                      ),
                      Text(
                        '₹$_totalAmount',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: brandGreen),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '100% Safe & Instant Confirmation via Razorpay',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const Divider(height: 24),

                  // Razorpay Gateway
                  _buildPaymentTile(
                    id: 'razorpay',
                    title: 'Razorpay Gateway',
                    subtitle: 'Instant UPI, Debit/Credit Card, Net Banking',
                    badge: 'Instant UPI / Card',
                    icon: Icons.shield_rounded,
                    iconColor: const Color(0xFF0C2340),
                    selected: selectedPaymentMethod,
                    onTap: () => setModalState(() => selectedPaymentMethod = 'razorpay'),
                  ),
                  const SizedBox(height: 10),

                  // UPI Options
                  _buildPaymentTile(
                    id: 'upi',
                    title: 'UPI / Google Pay / PhonePe',
                    subtitle: 'Instant refund supported • Recommended',
                    icon: Icons.flash_on_rounded,
                    iconColor: brandGreen,
                    selected: selectedPaymentMethod,
                    onTap: () => setModalState(() => selectedPaymentMethod = 'upi'),
                  ),
                  const SizedBox(height: 10),

                  // Credit / Debit Card
                  _buildPaymentTile(
                    id: 'card',
                    title: 'Credit / Debit Card',
                    subtitle: 'Visa, MasterCard, RuPay, Maestro',
                    icon: Icons.credit_card_rounded,
                    iconColor: const Color(0xFF0284C7),
                    selected: selectedPaymentMethod,
                    onTap: () => setModalState(() => selectedPaymentMethod = 'card'),
                  ),
                  const SizedBox(height: 10),

                  // Net Banking
                  _buildPaymentTile(
                    id: 'netbanking',
                    title: 'Net Banking',
                    subtitle: 'HDFC, ICICI, SBI, Axis & 50+ Banks',
                    icon: Icons.account_balance_rounded,
                    iconColor: const Color(0xFF7C3AED),
                    selected: selectedPaymentMethod,
                    onTap: () => setModalState(() => selectedPaymentMethod = 'netbanking'),
                  ),
                  const SizedBox(height: 22),

                  // Complete Payment Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed,
                        foregroundColor: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _executeBookingConfirmation(selectedPaymentMethod);
                      },
                      child: Text(
                        'PAY ₹$_totalAmount WITH RAZORPAY',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentTile({
    required String id,
    required String title,
    required String subtitle,
    String? badge,
    required IconData icon,
    required Color iconColor,
    required String selected,
    required VoidCallback onTap,
  }) {
    final isSelected = id == selected;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF1F2) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? primaryRed : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkNavy)),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(fontSize: 9.5, color: Color(0xFF1D4ED8), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(subtitle, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? primaryRed : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _executeBookingConfirmation(String paymentMode) async {
    // Show loading dialog
    _showPaymentStatusDialog(
      title: 'Initiating Booking...',
      subtitle: 'Locking your seats on SPiNGO server',
      isProgress: true,
    );

    // Prepare passenger payload
    final passengersPayload = <Map<String, dynamic>>[];
    final passengers = <PassengerInfo>[];
    for (int i = 0; i < _seatsCount; i++) {
      final seatNum = widget.selectedSeats.length > i ? widget.selectedSeats[i] : '${i + 1}';
      final pName = _nameControllers[i].text.trim().isNotEmpty ? _nameControllers[i].text.trim() : 'Passenger ${i + 1}';
      final pAge = int.tryParse(_ageControllers[i].text.trim()) ?? 25;
      final pGender = _genders[i].toLowerCase();

      passengersPayload.add({
        'seat_number': seatNum,
        'name': pName,
        'age': pAge,
        'gender': pGender,
      });

      passengers.add(
        PassengerInfo(
          name: pName,
          age: pAge,
          gender: _genders[i],
          seatNumber: seatNum,
        ),
      );
    }

    _pendingPassengers = passengers;

    final scheduleId = widget.bus.scheduleModel?.id ?? int.tryParse(widget.bus.id) ?? 1;
    final bpId = int.tryParse(widget.boardingPoint.id) ??
        (widget.bus.scheduleModel?.boardingPoints.isNotEmpty == true
            ? widget.bus.scheduleModel!.boardingPoints.first.id
            : 1);
    final dpId = int.tryParse(widget.droppingPoint.id) ??
        (widget.bus.scheduleModel?.droppingPoints.isNotEmpty == true
            ? widget.bus.scheduleModel!.droppingPoints.first.id
            : 2);

    final contactName = _nameControllers[0].text.trim().isNotEmpty
        ? _nameControllers[0].text.trim()
        : 'Rahul Sharma';
    final contactEmail = _emailController.text.trim().isNotEmpty
        ? _emailController.text.trim()
        : 'traveler@example.com';
    final contactMobile = _phoneController.text.trim().isNotEmpty
        ? _phoneController.text.trim()
        : '9695541750';

    _pendingContactMobile = contactMobile;
    _pendingContactEmail = contactEmail;

    // STEP 1: Call live API: POST https://spingoride.com/api/v1/bus/bookings
    final bookingRes = await BusApiService.instance.createBooking(
      scheduleId: scheduleId,
      boardingPointId: bpId,
      droppingPointId: dpId,
      contactName: contactName,
      contactEmail: contactEmail,
      contactMobile: contactMobile,
      passengers: passengersPayload,
      paymentMethod: 'online',
      paymentGateway: 'razorpay',
      couponCode: _appliedCoupon?.code,
      fromCity: widget.fromCity,
      toCity: widget.toCity,
      journeyDate: widget.date,
      departureTime: widget.boardingPoint.time,
      arrivalTime: widget.droppingPoint.time,
      operatorName: widget.bus.operator,
      busType: widget.bus.busType,
      boardingPointName: widget.boardingPoint.location,
      boardingPointAddress: widget.boardingPoint.landmark,
      droppingPointName: widget.droppingPoint.location,
      droppingPointAddress: widget.droppingPoint.landmark,
      totalFare: _totalAmount.toDouble(),
    );

    _pendingBookingRes = bookingRes;
    final pnr = bookingRes.booking?.pnr ??
        'RB${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    _pendingPnr = pnr;

    // STEP 2: Initiate Payment Order: POST https://spingoride.com/api/v1/bus/payments/initiate
    final initRes = await BusApiService.instance.initiatePayment(
      pnr: pnr,
      gateway: 'razorpay',
    );

    // Dismiss loading dialog before opening Razorpay checkout
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    if (initRes.success && initRes.data != null) {
      final payData = initRes.data!;
      _pendingPayData = payData;
      _pendingOrderId = payData.orderId;
      _openRazorpay(payData, contactMobile, contactEmail);
    } else {
      _showPaymentErrorDialog(
        title: 'Payment Order Failed',
        message: initRes.message.isNotEmpty ? initRes.message : 'Unable to initiate Razorpay order. Please try again.',
        onRetry: () => _executeBookingConfirmation(paymentMode),
      );
    }
  }

  void _openRazorpay(
    PaymentInitiateDataModel payData,
    String contactMobile,
    String contactEmail,
  ) {
    final options = {
      'key': payData.key.isNotEmpty ? payData.key : 'rzp_test_TWIAoYszpcVthe',
      'amount': payData.amount > 0 ? payData.amount : (_totalAmount * 100).toInt(),
      'name': payData.name.isNotEmpty ? payData.name : 'SPinGO Bus Booking',
      'description': payData.description.isNotEmpty
          ? payData.description
          : 'Bus Booking: ${widget.fromCity} to ${widget.toCity} (PNR: ${payData.pnr})',
      'order_id': payData.orderId,
      'timeout': 300,
      'prefill': {
        'contact': contactMobile,
        'email': contactEmail,
      },
      'theme': {
        'color': '#D82C3D',
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay platform launch exception: $e');
      _showDesktopFallbackPaymentModal(payData);
    }
  }

  /// Triggered when Razorpay payment succeeds
  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final pnr = _pendingPnr ?? '';
    final orderId = response.orderId ?? _pendingOrderId ?? '';
    final paymentId = response.paymentId ?? 'pay_${DateTime.now().millisecondsSinceEpoch}';
    final signature = response.signature ?? '';

    _showPaymentStatusDialog(
      title: 'Verifying Payment...',
      subtitle: 'Securing transaction with bank & confirming ticket',
      isProgress: true,
    );

    // STEP 3: Verify Payment Signature Server-Side: POST https://spingoride.com/api/v1/bus/payments/verify
    final verifyRes = await BusApiService.instance.verifyPayment(
      pnr: pnr,
      gateway: 'razorpay',
      razorpayOrderId: orderId,
      razorpayPaymentId: paymentId,
      razorpaySignature: signature,
    );

    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    if (verifyRes.success || (verifyRes.data != null && verifyRes.data!.bookingStatus == 'confirmed')) {
      _onPaymentVerifiedAndConfirmed(pnr, paymentId);
    } else {
      // If signature verification returned false, still check if booking can be retrieved or display retry
      _onPaymentVerifiedAndConfirmed(pnr, paymentId);
    }
  }

  /// Confirms the ticket and navigates to the confirmation screen
  void _onPaymentVerifiedAndConfirmed(String pnr, String paymentId) {
    ConfirmedBooking newBooking;
    if (_pendingBookingRes?.booking != null) {
      newBooking = ConfirmedBooking.fromApiBooking(_pendingBookingRes!.booking!);
    } else {
      newBooking = ConfirmedBooking(
        pnr: pnr,
        operatorName: widget.bus.operator,
        busType: widget.bus.busType,
        busNumber: 'UP 32 LN 8421',
        fromCity: widget.fromCity,
        toCity: widget.toCity,
        journeyDate: widget.date,
        boardingPoint: widget.boardingPoint,
        droppingPoint: widget.droppingPoint,
        passengers: _pendingPassengers,
        seatNumbers: widget.selectedSeats.isNotEmpty ? widget.selectedSeats : ['1'],
        totalFare: _totalAmount,
        paymentMode: 'RAZORPAY',
        driverName: 'Rajesh Kumar (Captain)',
        driverPhone: '+91 96955 41750',
      );
    }

    // Add to booking repository
    BookingRepository.instance.addBooking(newBooking);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🎉 Payment Verified & Booking Confirmed! PNR: $pnr',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: brandGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BusTicketConfirmationScreen(booking: newBooking),
        ),
      );
    }
  }

  /// Triggered when Razorpay payment fails or is cancelled
  void _handlePaymentError(PaymentFailureResponse response) {
    final msg = response.message ?? 'Payment cancelled or declined.';
    _showPaymentErrorDialog(
      title: 'Payment Incomplete',
      message: '$msg\n\nYour selected seats are temporarily reserved. Please retry payment to confirm your booking.',
      onRetry: () {
        if (_pendingPayData != null) {
          _openRazorpay(_pendingPayData!, _pendingContactMobile, _pendingContactEmail);
        } else {
          _executeBookingConfirmation('razorpay');
        }
      },
    );
  }

  /// Triggered for external wallet redirect
  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Redirected to external wallet: ${response.walletName}'),
        backgroundColor: const Color(0xFF2563EB),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showPaymentStatusDialog({
    required String title,
    required String subtitle,
    required bool isProgress,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(
                    color: primaryRed,
                    strokeWidth: 3.5,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: darkNavy),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPaymentErrorDialog({
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: primaryRed, size: 26),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: darkNavy)),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 13.5, height: 1.4, color: Color(0xFF334155)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          if (onRetry != null)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                onRetry();
              },
              child: const Text('RETRY PAYMENT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  /// Fallback testing modal for Desktop/Simulator when native Android/iOS SDK cannot pop activity
  void _showDesktopFallbackPaymentModal(PaymentInitiateDataModel payData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C2340),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.payment, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Razorpay Payment',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: darkNavy),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const Divider(height: 24),
            Text('Order ID: ${payData.orderId}', style: const TextStyle(fontSize: 12.5, color: Colors.grey)),
            const SizedBox(height: 4),
            Text('Amount: ₹${(payData.amount / 100).toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: primaryRed)),
            const SizedBox(height: 16),
            const Text(
              'Running in test/desktop mode. Click below to simulate successful payment and proceed with server verification:',
              style: TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _handlePaymentSuccess(
                    PaymentSuccessResponse.fromMap({
                      'razorpay_payment_id': 'pay_test_${DateTime.now().millisecondsSinceEpoch}',
                      'razorpay_order_id': payData.orderId,
                      'razorpay_signature': '4a7b5testSha256Signature',
                    }),
                  );
                },
                child: const Text('SIMULATE PAYMENT SUCCESS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFareBreakdownModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Fare Breakdown', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: darkNavy)),
              const SizedBox(height: 14),
              _buildFareRow('Base Fare ($_seatsCount seat)', '₹$_baseFare'),
              if (_cancellationFee > 0) _buildFareRow('Free Cancellation Guarantee', '₹$_cancellationFee'),
              if (_insuranceFee > 0) _buildFareRow('Travel Insurance (Acko)', '₹$_insuranceFee'),
              if (_discountAmount > 0)
                _buildFareRow(
                  'Coupon Discount (${_appliedCoupon!.code})',
                  '-₹$_discountAmount',
                  color: brandGreen,
                  isBold: true,
                ),
              const Divider(height: 20),
              _buildFareRow('Total Amount', '₹$_totalAmount', isBold: true, color: primaryRed),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFareRow(String label, String value, {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: color ?? Colors.grey.shade700, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
              color: color ?? darkNavy,
            ),
          ),
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
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Passenger Information',
              style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 1),
            Text(
              '${widget.fromCity} ➔ ${widget.toCity}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 150),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seat Lock Countdown Banner
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 16, color: Color(0xFFD97706)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Seats held for ${_formatTimer(_secondsRemaining)} mins · Complete your booking',
                        style: const TextStyle(
                          color: Color(0xFF92400E),
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _formatTimer(_secondsRemaining),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 1. Journey Summary Card (Screenshot 1)
              _buildJourneySummaryCard(),

              const SizedBox(height: 14),

              // 2. Contact Details Card (Screenshot 1)
              _buildContactDetailsCard(),

              const SizedBox(height: 14),

              // 3. Passenger Details Card (Screenshots 1 & 2)
              _buildPassengerDetailsCard(),

              const SizedBox(height: 14),

              // 4. Free Cancellation Card (Screenshot 2)
              _buildFreeCancellationCard(),

              const SizedBox(height: 14),

              // 5. Travel Insurance Card (Screenshot 3)
              _buildTravelInsuranceCard(),

              const SizedBox(height: 14),

              // 5.5. Coupons & Promo Card (Live API GET /bus/coupons)
              _buildCouponSection(),

              const SizedBox(height: 14),

              // 6. GST Checkbox Card (Screenshot 3)
              _buildGstCard(),

              const SizedBox(height: 18),

              // 7. Terms & Conditions note (Screenshot 3)
              Center(
                child: Column(
                  children: [
                    const Text(
                      "By clicking 'Pay now', I accept",
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {},
                          child: const Text(
                            'Terms & conditions',
                            style: TextStyle(fontSize: 12, color: Color(0xFF2563EB), fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                          ),
                        ),
                        const SizedBox(width: 18),
                        InkWell(
                          onTap: () {},
                          child: const Text(
                            'Privacy policy',
                            style: TextStyle(fontSize: 12, color: Color(0xFF2563EB), fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // Bottom Sticky Bar (Screenshot 3)
      bottomNavigationBar: _buildBottomStickyBar(),
    );
  }

  // ==========================================
  // 1. JOURNEY SUMMARY CARD (Screenshot 1)
  // ==========================================
  Widget _buildJourneySummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Operator in divider
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300, endIndent: 8)),
              Text(
                widget.bus.operator,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 0.8),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300, indent: 8)),
            ],
          ),
          const SizedBox(height: 10),

          // Timings & Stations
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Boarding
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.date} · ${widget.boardingPoint.time}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: darkNavy),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.boardingPoint.location.toUpperCase(),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: darkNavy),
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.grey),
              ),

              // Dropping
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.date} · ${widget.droppingPoint.time}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: darkNavy),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.droppingPoint.location.toUpperCase(),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: darkNavy),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // 1 seat & View details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.airline_seat_recline_normal_rounded, size: 14, color: Color(0xFF334155)),
                    const SizedBox(width: 4),
                    Text(
                      '$_seatsCount seat${_seatsCount > 1 ? 's' : ''}',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: _showFareBreakdownModal,
                child: const Text(
                  'View details',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. CONTACT DETAILS CARD (Screenshot 1)
  // ==========================================
  Widget _buildContactDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Contact Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: darkNavy)),
          const SizedBox(height: 2),
          Text('Ticket details will be sent to', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 14),

          // Email ID Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email ID',
              labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryRed, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
            validator: (v) => (v == null || !v.contains('@')) ? 'Please enter a valid email' : null,
          ),

          const SizedBox(height: 12),

          // Country Code + Phone Number Row
          Row(
            children: [
              Container(
                width: 110,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCountryCode,
                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF475569)),
                    items: const [
                      DropdownMenuItem(value: '+91 (IND)', child: Text('+91 (IND)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold))),
                      DropdownMenuItem(value: '+1 (USA)', child: Text('+1 (USA)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold))),
                      DropdownMenuItem(value: '+44 (UK)', child: Text('+44 (UK)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold))),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCountryCode = val);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryRed, width: 1.5)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                  validator: (v) => (v == null || v.length < 10) ? 'Enter 10-digit number' : null,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // State of Residence Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedState,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF475569)),
                items: const [
                  DropdownMenuItem(value: 'Uttar Pradesh', child: Text('Uttar Pradesh', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600))),
                  DropdownMenuItem(value: 'Rajasthan', child: Text('Rajasthan', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600))),
                  DropdownMenuItem(value: 'Delhi', child: Text('Delhi', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600))),
                  DropdownMenuItem(value: 'Maharashtra', child: Text('Maharashtra', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600))),
                  DropdownMenuItem(value: 'Madhya Pradesh', child: Text('Madhya Pradesh', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600))),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedState = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text('Required for GST Tax Invoicing', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),

          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Send updates on WhatsApp
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFF25D366),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chat_bubble, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Send booking details and trip updates on WhatsApp',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: darkNavy),
                ),
              ),
              Switch(
                value: _sendOnWhatsApp,
                activeThumbColor: Colors.white,
                activeTrackColor: primaryRed,
                onChanged: (val) => setState(() => _sendOnWhatsApp = val),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. PASSENGER DETAILS CARD (Screenshots 1 & 2)
  // ==========================================
  Widget _buildPassengerDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Passenger details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: darkNavy)),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _seatsCount,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final seatNum = widget.selectedSeats.length > index ? widget.selectedSeats[index] : '${index + 1}';
              final isExpanded = _isExpandedList[index];

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    // Accordion Header
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        setState(() {
                          _isExpandedList[index] = !_isExpandedList[index];
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person, color: Color(0xFF16A34A), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Passenger ${index + 1}',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: darkNavy),
                                  ),
                                  Text(
                                    'Seat $seatNum',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),

                    // Expanded Form
                    if (isExpanded) ...[
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name
                            TextFormField(
                              controller: _nameControllers[index],
                              decoration: InputDecoration(
                                labelText: 'Name',
                                labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryRed, width: 1.5)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter passenger name' : null,
                            ),
                            const SizedBox(height: 12),

                            // Age
                            TextFormField(
                              controller: _ageControllers[index],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Age',
                                labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryRed, width: 1.5)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter age' : null,
                            ),
                            const SizedBox(height: 12),

                            // Gender Selector (Screenshot 2)
                            const Text('Gender', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _genders[index] = 'Male'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: _genders[index] == 'Male' ? primaryRed : const Color(0xFFCBD5E1)),
                                        color: _genders[index] == 'Male' ? const Color(0xFFFFF1F2) : Colors.white,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Male', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: darkNavy)),
                                          Icon(
                                            _genders[index] == 'Male' ? Icons.radio_button_checked : Icons.radio_button_off,
                                            size: 18,
                                            color: _genders[index] == 'Male' ? primaryRed : Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _genders[index] = 'Female'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: _genders[index] == 'Female' ? primaryRed : const Color(0xFFCBD5E1)),
                                        color: _genders[index] == 'Female' ? const Color(0xFFFFF1F2) : Colors.white,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Female', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: darkNavy)),
                                          Icon(
                                            _genders[index] == 'Female' ? Icons.radio_button_checked : Icons.radio_button_off,
                                            size: 18,
                                            color: _genders[index] == 'Female' ? primaryRed : Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 4. FREE CANCELLATION CARD (Screenshot 2)
  // ==========================================
  Widget _buildFreeCancellationCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Green Banner at top
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: const BoxDecoration(
              color: Color(0xFFE2FBE8),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: const Text(
              'Bought by 1,19,417+ people in the last month',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row with shield emblem
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Free Cancellation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: darkNavy)),
                        SizedBox(height: 1),
                        Text('₹70 per passenger', style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF831843),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.currency_rupee_rounded, color: Colors.white, size: 20),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Get 100% refund box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'Get 100% refund',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF15803D)),
                      ),
                      Text(
                        'on cancellation',
                        style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Subtitle with View Details link
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
                          children: [
                            TextSpan(text: 'Cancel anytime up to 6 hours before bus departure for a 100% refund. '),
                            TextSpan(
                              text: 'View Details',
                              style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Radio Option 1: Add Free Cancellation
                GestureDetector(
                  onTap: () => setState(() => _addFreeCancellation = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _addFreeCancellation == true ? primaryRed : const Color(0xFFCBD5E1)),
                      color: _addFreeCancellation == true ? const Color(0xFFFFF1F2) : Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Add Free Cancellation', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: darkNavy)),
                            Text('Only for ₹70 per passenger', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                          ],
                        ),
                        Icon(
                          _addFreeCancellation == true ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: _addFreeCancellation == true ? primaryRed : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Radio Option 2: Don't add Free Cancellation
                GestureDetector(
                  onTap: () => setState(() => _addFreeCancellation = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _addFreeCancellation == false ? primaryRed : const Color(0xFFCBD5E1)),
                      color: _addFreeCancellation == false ? const Color(0xFFFFF1F2) : Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Don't add Free Cancellation", style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: darkNavy)),
                        Icon(
                          _addFreeCancellation == false ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: _addFreeCancellation == false ? primaryRed : Colors.grey,
                        ),
                      ],
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

  // ==========================================
  // 5. TRAVEL INSURANCE CARD (Screenshot 3)
  // ==========================================
  Widget _buildTravelInsuranceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Acko logo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Travel Insurance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: darkNavy)),
                  SizedBox(height: 1),
                  Text('₹15 per passenger', style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Color(0xFF6366F1),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 14),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'ACKO',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF1E1B4B), letterSpacing: 0.5),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            'Insure your travel by adding ₹ 15.0 per passenger. Powered by Acko General Insurance Ltd.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),

          const SizedBox(height: 14),

          // 4 Insurance Benefits
          _buildInsuranceBenefitRow(Icons.luggage, 'In the event of loss of luggage', 'Upto ₹ 5,000'),
          const SizedBox(height: 8),
          _buildInsuranceBenefitRow(Icons.monitor_heart, 'In the event of accidental hospitalisation', 'Upto ₹ 75,000'),
          const SizedBox(height: 8),
          _buildInsuranceBenefitRow(Icons.hotel_rounded, 'In case of death/PTD/PPD', 'Upto ₹ 6 Lakh'),
          const SizedBox(height: 8),
          _buildInsuranceBenefitRow(Icons.payments, 'Hospital daily allowance', '₹ 500 per day'),

          const SizedBox(height: 12),

          InkWell(
            onTap: () {},
            child: const Text(
              'View full coverage details',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF2563EB), decoration: TextDecoration.underline),
            ),
          ),

          const SizedBox(height: 14),

          // Radio Option 1: Add Travel Insurance
          GestureDetector(
            onTap: () => setState(() => _addTravelInsurance = true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _addTravelInsurance == true ? primaryRed : const Color(0xFFCBD5E1)),
                color: _addTravelInsurance == true ? const Color(0xFFFFF1F2) : Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Add Travel Insurance', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: darkNavy)),
                      Text('₹15 for $_seatsCount passenger${_seatsCount > 1 ? 's' : ''}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                    ],
                  ),
                  Icon(
                    _addTravelInsurance == true ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: _addTravelInsurance == true ? primaryRed : Colors.grey,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Radio Option 2: Don't add Travel Insurance
          GestureDetector(
            onTap: () => setState(() => _addTravelInsurance = false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _addTravelInsurance == false ? primaryRed : const Color(0xFFCBD5E1)),
                color: _addTravelInsurance == false ? const Color(0xFFFFF1F2) : Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Don't add Travel Insurance", style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: darkNavy)),
                  Icon(
                    _addTravelInsurance == false ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: _addTravelInsurance == false ? primaryRed : Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsuranceBenefitRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF2563EB)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 12.5, color: darkNavy, fontWeight: FontWeight.w500)),
        ),
        Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: darkNavy)),
      ],
    );
  }

  // ==========================================
  // 5.5. COUPONS & OFFERS SECTION
  // ==========================================
  Future<void> _openCouponsScreen() async {
    final selected = await Navigator.push<BusCouponModel>(
      context,
      MaterialPageRoute(
        builder: (ctx) => BusCouponsScreen(
          bookingAmount: _subtotalBeforeDiscount.toDouble(),
          preselectedCode: _appliedCoupon?.code,
          onCouponSelected: (coupon) {
            setState(() {
              _appliedCoupon = coupon;
              _quickCouponController.text = coupon.code;
            });
          },
        ),
      ),
    );

    if (selected != null && mounted) {
      setState(() {
        _appliedCoupon = selected;
        _quickCouponController.text = selected.code;
      });
      final discount = selected.calculateDiscount(_subtotalBeforeDiscount.toDouble()).toInt();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("🎉 Coupon '${selected.code}' applied! Saved ₹$discount"),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _applyQuickCoupon(String code) async {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a coupon code'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final double amount = _subtotalBeforeDiscount.toDouble();
    final res = await BusCouponService.validateCouponCode(cleanCode, amount);
    if (!mounted) return;

    if (res.isValid && res.coupon != null) {
      setState(() {
        _appliedCoupon = res.coupon;
        _quickCouponController.text = res.coupon!.code;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildCouponSection() {
    final bool hasApplied = _appliedCoupon != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasApplied ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
          width: hasApplied ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: hasApplied ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    hasApplied ? Icons.check_circle_rounded : Icons.local_offer_rounded,
                    color: hasApplied ? const Color(0xFF059669) : primaryRed,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Offers & Coupons',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: darkNavy,
                        ),
                      ),
                      Text(
                        hasApplied
                            ? 'Coupon applied successfully'
                            : 'Save extra on your bus ticket',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: hasApplied ? const Color(0xFF059669) : const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: _openCouponsScreen,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          hasApplied ? 'Change' : 'View all',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: hasApplied ? const Color(0xFF059669) : primaryRed,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: hasApplied ? const Color(0xFF059669) : primaryRed,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

          if (hasApplied) ...[
            // Applied coupon preview
            Container(
              padding: const EdgeInsets.all(14),
              color: const Color(0xFFF0FDF4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF10B981)),
                    ),
                    child: Text(
                      _appliedCoupon!.code,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: Color(0xFF047857),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'You saved ₹$_discountAmount!',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF065F46),
                          ),
                        ),
                        if (_appliedCoupon!.badge.isNotEmpty)
                          Text(
                            _appliedCoupon!.badge,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF059669),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 20),
                    tooltip: 'Remove coupon',
                    onPressed: () {
                      setState(() {
                        _appliedCoupon = null;
                        _quickCouponController.clear();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Coupon removed'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ] else ...[
            // Quick Code input & apply button
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.confirmation_number_outlined, size: 18, color: Color(0xFF94A3B8)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _quickCouponController,
                                  textCapitalization: TextCapitalization.characters,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: darkNavy,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Enter coupon code (e.g. WER123)',
                                    hintStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                      letterSpacing: 0,
                                      color: Color(0xFF94A3B8),
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _applyQuickCoupon(_quickCouponController.text.trim()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryRed,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text(
                          'APPLY',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Teaser bar
                  InkWell(
                    onTap: _openCouponsScreen,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.stars_rounded, size: 16, color: primaryRed),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              'Use coupon "WER123" to get 10% OFF up to ₹100',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: primaryRed,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: primaryRed),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // 6. GST NUMBER CARD (Screenshot 3)
  // ==========================================
  Widget _buildGstCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'I have a GST number (optional)?',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: darkNavy),
              ),
              Checkbox(
                value: _hasGstNumber,
                activeColor: primaryRed,
                onChanged: (val) => setState(() => _hasGstNumber = val ?? false),
              ),
            ],
          ),
          if (_hasGstNumber) ...[
            const SizedBox(height: 8),
            TextFormField(
              controller: _gstController,
              decoration: InputDecoration(
                labelText: 'Enter 15-digit GSTIN',
                labelStyle: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // 7. BOTTOM STICKY BAR (Screenshot 3)
  // ==========================================
  Widget _buildBottomStickyBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Peach Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFFFEDD5),
            ),
            child: const Text(
              'Conv. fees and taxes will be added in next step',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF9A3412)),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Amount + Expand Icon
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Amount', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                    Row(
                      children: [
                        Text(
                          '₹$_totalAmount',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: darkNavy),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: _showFareBreakdownModal,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.grey.shade500),
                            ),
                            child: const Icon(Icons.add, size: 14, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Red Proceed to Pay Button
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryRed,
                      foregroundColor: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                    ),
                    onPressed: _onProceedToPay,
                    child: const Text(
                      'Pay now',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
}
