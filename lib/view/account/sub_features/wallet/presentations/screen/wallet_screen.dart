import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:tripried/view/account/sub_features/wallet/models/wallet_models.dart';
import 'package:tripried/view/account/sub_features/wallet/services/wallet_service.dart';
import 'package:tripried/view/auth/services/auth_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  late final Razorpay _razorpay;
  late final TextEditingController _amountController;
  final ScrollController _scrollController = ScrollController();

  // State
  String? _pendingOrderId;
  double _pendingAmount = 100.0;
  String _selectedFilter = 'all'; // 'all', 'credit', 'debit', 'refund'
  bool _isInitiating = false;

  final List<double> _presetAmounts = [100, 200, 500, 1000, 2000];

  static const Color brandGreen = Color(0xFF65A30D);
  static const Color brandNavy = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '100');

    // Setup Razorpay
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    WalletService.instance.addListener(_onWalletUpdated);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WalletService.instance.init();
    });
  }

  @override
  void dispose() {
    WalletService.instance.removeListener(_onWalletUpdated);
    _razorpay.clear();
    _amountController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onWalletUpdated() {
    if (mounted) setState(() {});
  }

  // =========================================================================
  // RAZORPAY CHECKOUT FLOW
  // =========================================================================

  Future<void> _startRechargeFlow() async {
    final text = _amountController.text.trim();
    final amount = double.tryParse(text);

    if (amount == null || amount < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid recharge amount (min ₹1)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isInitiating = true;
      _pendingAmount = amount;
    });

    FocusScope.of(context).unfocus();

    // 1. Call POST https://spingoride.com/api/v1/wallet/recharge/initiate
    final initRes = await WalletService.instance.initiateRecharge(
      amount: amount,
      gateway: 'razorpay',
    );

    if (!mounted) return;
    setState(() => _isInitiating = false);

    if (initRes.success && initRes.data != null) {
      final payData = initRes.data!;
      _pendingOrderId = payData.orderId;
      _openRazorpayCheckout(payData);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(initRes.message.isNotEmpty
              ? initRes.message
              : 'Failed to initiate recharge order. Please try again.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  void _openRazorpayCheckout(WalletRechargeDataModel payData) {
    final user = AuthService.instance.currentUser;
    final contactMobile = payData.customer.phone.isNotEmpty
        ? payData.customer.phone
        : (user?.phone ?? '');
    final contactEmail = payData.customer.email.isNotEmpty
        ? payData.customer.email
        : (user?.email ?? 'customer@spingoride.com');

    // In Razorpay SDK, amount is in paise (1 INR = 100 paise)
    final int paiseAmount = (payData.amount < 10000
            ? (payData.amount * 100)
            : payData.amount)
        .round();

    final options = {
      'key': payData.key.isNotEmpty
          ? payData.key
          : 'rzp_test_TWIAoYszpcVthe',
      'amount': paiseAmount,
      'name': payData.payload.name.isNotEmpty
          ? payData.payload.name
          : 'SPinGO Wallet Recharge',
      'description': payData.payload.description.isNotEmpty
          ? payData.payload.description
          : 'Recharge ₹${payData.amount.toStringAsFixed(0)}',
      'order_id': payData.orderId,
      'timeout': 300,
      'prefill': {
        'contact': contactMobile,
        'email': contactEmail,
      },
      'theme': {
        'color': '#0F172A',
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
    final orderId = response.orderId ?? _pendingOrderId ?? '';
    final paymentId =
        response.paymentId ?? 'pay_${DateTime.now().millisecondsSinceEpoch}';
    final signature = response.signature ?? '';

    _showVerifyingModal();

    // 2. Call POST https://spingoride.com/api/v1/wallet/recharge/verify
    final verifyRes = await WalletService.instance.verifyRecharge(
      amount: _pendingAmount,
      razorpayOrderId: orderId,
      razorpayPaymentId: paymentId,
      razorpaySignature: signature,
      gateway: 'razorpay',
    );

    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context); // Close verifying modal
    }

    if (!mounted) return;

    if (verifyRes.success) {
      final txn = verifyRes.data?.transaction;
      final effectiveAmount = txn?.amount ?? _pendingAmount;
      final effectiveTxnId = (txn?.transactionId.isNotEmpty == true)
          ? txn!.transactionId
          : paymentId;

      _showRechargeSuccessDialog(
        amount: effectiveAmount,
        paymentId: effectiveTxnId,
        message: verifyRes.message.isNotEmpty
            ? verifyRes.message
            : '₹${effectiveAmount.toStringAsFixed(2)} has been successfully credited to your wallet.',
        verifyData: verifyRes.data,
      );
    } else {
      // If verification endpoint returns error but payment succeeded, refresh balance anyway
      await WalletService.instance.fetchWallet();
      _showRechargeSuccessDialog(
        amount: _pendingAmount,
        paymentId: paymentId,
        message: verifyRes.message.isNotEmpty
            ? verifyRes.message
            : 'Recharge processed. Your balance is being updated.',
      );
    }
  }

  /// Triggered when Razorpay payment fails or is cancelled
  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment cancelled or failed: ${response.message ?? ""}'),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Redirected to external wallet: ${response.walletName}'),
        backgroundColor: Colors.blue.shade700,
      ),
    );
  }

  void _showVerifyingModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(brandGreen),
                  strokeWidth: 3.5,
                ),
                SizedBox(height: 20),
                Text(
                  'Verifying Recharge...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Confirming payment with bank & updating your SPinGO wallet',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRechargeSuccessDialog({
    required double amount,
    required String paymentId,
    required String message,
    WalletVerifyDataModel? verifyData,
  }) {
    final wallet = verifyData?.wallet;
    final txn = verifyData?.transaction;
    final formattedBal = wallet?.formattedBalance.isNotEmpty == true
        ? wallet!.formattedBalance
        : '₹${WalletService.instance.balance.toStringAsFixed(2)}';
    final txnId = txn?.transactionId.isNotEmpty == true
        ? txn!.transactionId
        : paymentId;
    final dateStr = txn?.formattedDate.isNotEmpty == true
        ? txn!.formattedDate
        : _formatDate(DateTime.now().toIso8601String());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              // Success Icon with Glow
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF86EFAC), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF16A34A).withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF16A34A), size: 48),
              ),
              const SizedBox(height: 16),
              const Text(
                'Recharge Successful!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF15803D),
                ),
              ),
              const SizedBox(height: 18),

              // Updated Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Color(0xFF86EFAC),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CURRENT WALLET BALANCE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF94A3B8),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formattedBal,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF86EFAC).withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        '+ ₹${amount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF86EFAC),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Full Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildSuccessDetailRow(
                      label: 'Transaction ID',
                      value: txnId,
                      copyable: true,
                    ),
                    const Divider(height: 20, color: Color(0xFFE2E8F0)),
                    _buildSuccessDetailRow(
                      label: 'Date & Time',
                      value: dateStr,
                    ),
                    const Divider(height: 20, color: Color(0xFFE2E8F0)),
                    _buildSuccessDetailRow(
                      label: 'Amount Added',
                      value: txn?.formattedAmount.isNotEmpty == true
                          ? txn!.formattedAmount
                          : '+ ₹${amount.toStringAsFixed(2)}',
                      valueColor: const Color(0xFF16A34A),
                      isBold: true,
                    ),
                    if (txn != null && txn.description.isNotEmpty) ...[
                      const Divider(height: 20, color: Color(0xFFE2E8F0)),
                      _buildSuccessDetailRow(
                        label: 'Description',
                        value: txn.description,
                      ),
                    ],
                    const Divider(height: 20, color: Color(0xFFE2E8F0)),
                    _buildSuccessDetailRow(
                      label: 'Payment Method',
                      value: 'Razorpay Instant UPI / Card',
                    ),
                    if (wallet != null && wallet.totalRecharge > 0) ...[
                      const Divider(height: 20, color: Color(0xFFE2E8F0)),
                      _buildSuccessDetailRow(
                        label: 'Total Recharged',
                        value: '₹${wallet.totalRecharge.toStringAsFixed(2)}',
                      ),
                    ],
                    const Divider(height: 20, color: Color(0xFFE2E8F0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Payment Status',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  size: 13, color: Color(0xFF16A34A)),
                              const SizedBox(width: 4),
                              Text(
                                (txn?.status ?? 'SUCCESS').toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF16A34A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'DONE',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessDetailRow({
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
    bool copyable = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                    color: valueColor ?? const Color(0xFF0F172A),
                  ),
                ),
              ),
              if (copyable) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copied $label: $value'),
                        duration: const Duration(seconds: 2),
                        backgroundColor: const Color(0xFF0F172A),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.copy_rounded,
                    size: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Simulator fallback for test environments or desktop
  void _showDesktopFallbackPaymentModal(WalletRechargeDataModel payData) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF0C2340).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.credit_card, color: Color(0xFF0C2340)),
            ),
            const SizedBox(width: 10),
            const Text('Razorpay Test Mode',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: ${payData.orderId}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
            const SizedBox(height: 4),
            Text('Amount: ₹${payData.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A))),
            const SizedBox(height: 12),
            const Text(
              'Desktop environment detected. You can simulate the successful payment response directly.',
              style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: brandGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              _handlePaymentSuccess(
                PaymentSuccessResponse(
                  'pay_simulated_${DateTime.now().millisecondsSinceEpoch}',
                  payData.orderId,
                  'simulated_signature_ok',
                  null,
                ),
              );
            },
            child: const Text('Simulate Success'),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // BUILD METHOD
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    final wallet = WalletService.instance.walletData;
    final isLoading = WalletService.instance.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF0F172A), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            Text(
              'SPinGO Wallet',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.verified, color: brandGreen, size: 16),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Wallet',
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(brandGreen),
                    ),
                  )
                : const Icon(Icons.refresh_rounded, color: Color(0xFF0F172A)),
            onPressed: () async {
              await WalletService.instance.fetchWallet();
              await WalletService.instance.fetchTransactions(page: 1);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: brandGreen,
        onRefresh: () async {
          await WalletService.instance.fetchWallet();
          await WalletService.instance.fetchTransactions(page: 1);
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HERO BALANCE CARD
              _buildBalanceCard(wallet),

              // 2. QUICK STATS SUMMARY
              _buildStatsGrid(wallet),

              // 3. TOP-UP / RECHARGE WALLET SECTION
              _buildRechargeSection(),

              // 4. RECENT TRANSACTIONS HEADER & FILTER TABS
              _buildTransactionsSection(),

              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 1. HERO BALANCE CARD
  // =========================================================================

  Widget _buildBalanceCard(WalletDataModel wallet) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
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
                      color: Colors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Color(0xFFFBBF24),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Available Balance',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF16A34A).withValues(alpha: 0.4),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 3,
                      backgroundColor: Color(0xFF4ADE80),
                    ),
                    SizedBox(width: 5),
                    Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: Color(0xFF4ADE80),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                wallet.currencySymbol,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                wallet.balance.toStringAsFixed(2),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.flash_on_rounded,
                    color: Color(0xFFFBBF24), size: 15),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Use wallet for 1-tap instant booking & refund credits',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
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

  // =========================================================================
  // 2. QUICK STATS SUMMARY
  // =========================================================================

  Widget _buildStatsGrid(WalletDataModel wallet) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              title: 'Total Recharge',
              amount: '₹${wallet.totalRecharge.toStringAsFixed(0)}',
              icon: Icons.add_circle_outline,
              iconColor: const Color(0xFF16A34A),
              bgColor: const Color(0xFFDCFCE7),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatItem(
              title: 'Total Spent',
              amount: '₹${wallet.totalSpent.toStringAsFixed(0)}',
              icon: Icons.arrow_outward_rounded,
              iconColor: const Color(0xFF2563EB),
              bgColor: const Color(0xFFDBEAFE),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatItem(
              title: 'Total Refund',
              amount: '₹${wallet.totalRefund.toStringAsFixed(0)}',
              icon: Icons.replay_rounded,
              iconColor: const Color(0xFF7C3AED),
              bgColor: const Color(0xFFF3E8FF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String amount,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 14),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 3. TOP-UP / RECHARGE WALLET SECTION
  // =========================================================================

  Widget _buildRechargeSection() {
    final gateway = WalletService.instance.gateways.firstWhere(
      (g) => g.code == 'razorpay',
      orElse: () => PaymentGatewayModel.razorpayFallback(),
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.add_card_rounded, color: brandNavy, size: 20),
              SizedBox(width: 8),
              Text(
                'Top Up Wallet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Preset amount chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _presetAmounts.map((amt) {
                final isSelected = _amountController.text == amt.toStringAsFixed(0);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      '+ ₹${amt.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: brandGreen,
                    backgroundColor: const Color(0xFFF1F5F9),
                    side: BorderSide(
                      color: isSelected ? brandGreen : const Color(0xFFE2E8F0),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _amountController.text = amt.toStringAsFixed(0);
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // Amount input field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Row(
              children: [
                const Text(
                  '₹',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (val) => setState(() {}),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter amount',
                      hintStyle: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.normal,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (_amountController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18, color: Color(0xFF94A3B8)),
                    onPressed: () {
                      _amountController.clear();
                      setState(() {});
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Gateway badge row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C2340),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.credit_card, color: Colors.white, size: 14),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gateway.name,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        gateway.badge,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle_rounded, color: brandGreen, size: 18),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Proceed Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: brandGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
              ),
              onPressed: _isInitiating ? null : _startRechargeFlow,
              child: _isInitiating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'PROCEED TO RECHARGE ${_amountController.text.isNotEmpty ? "₹${_amountController.text}" : ""}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
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

  // =========================================================================
  // 4. RECENT TRANSACTIONS SECTION
  // =========================================================================

  Widget _buildTransactionsSection() {
    final allTransactions = WalletService.instance.transactions;
    final isLoadingTransactions =
        WalletService.instance.isLoadingTransactions;

    // Filter transactions
    final filtered = allTransactions.where((item) {
      if (_selectedFilter == 'credit') return item.isCredit;
      if (_selectedFilter == 'debit') return !item.isCredit;
      if (_selectedFilter == 'refund') {
        return item.type.toLowerCase().contains('refund');
      }
      return true;
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Transaction History',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              if (isLoadingTransactions)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(brandGreen),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Filter pills
          Row(
            children: [
              _buildFilterPill('All', 'all'),
              const SizedBox(width: 8),
              _buildFilterPill('Credits', 'credit'),
              const SizedBox(width: 8),
              _buildFilterPill('Debits', 'debit'),
              const SizedBox(width: 8),
              _buildFilterPill('Refunds', 'refund'),
            ],
          ),
          const SizedBox(height: 14),

          // List or Empty state
          if (filtered.isEmpty)
            _buildEmptyTransactions()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (_, index) =>
                  _buildTransactionTile(filtered[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterPill(String title, String key) {
    final isSelected = _selectedFilter == key;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = key),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTile(WalletTransactionModel item) {
    final isCredit = item.isCredit;
    final displayDate = item.formattedDate?.isNotEmpty == true
        ? item.formattedDate!
        : _formatDate(item.createdAt);
    final displayTxnId = item.transactionId.isNotEmpty
        ? item.transactionId
        : (item.referenceId ?? '');
    final displayAmount = item.formattedAmount?.isNotEmpty == true
        ? item.formattedAmount!
        : '${isCredit ? "+" : "-"} ₹${item.amount.toStringAsFixed(2)}';

    return InkWell(
      onTap: () => _showTransactionDetailsBottomSheet(item),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isCredit
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCredit
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                color: isCredit
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFDC2626),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    displayDate,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  if (displayTxnId.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'ID: $displayTxnId',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  displayAmount,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isCredit
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFDC2626),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.status.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetailsBottomSheet(WalletTransactionModel item) {
    final isCredit = item.isCredit;
    final displayDate = item.formattedDate?.isNotEmpty == true
        ? item.formattedDate!
        : _formatDate(item.createdAt);
    final displayTxnId = item.transactionId.isNotEmpty
        ? item.transactionId
        : (item.referenceId ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isCredit
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCredit
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color: isCredit
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFDC2626),
                  size: 32,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                item.formattedAmount?.isNotEmpty == true
                    ? item.formattedAmount!
                    : '${isCredit ? "+" : "-"} ₹${item.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: isCredit
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFDC2626),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    if (displayTxnId.isNotEmpty) ...[
                      _buildSuccessDetailRow(
                        label: 'Transaction ID',
                        value: displayTxnId,
                        copyable: true,
                      ),
                      const Divider(height: 18, color: Color(0xFFE2E8F0)),
                    ],
                    _buildSuccessDetailRow(
                      label: 'Date & Time',
                      value: displayDate,
                    ),
                    const Divider(height: 18, color: Color(0xFFE2E8F0)),
                    _buildSuccessDetailRow(
                      label: 'Type',
                      value: item.type.toUpperCase(),
                      valueColor: isCredit
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFDC2626),
                      isBold: true,
                    ),
                    if (item.credit != null && item.credit! > 0) ...[
                      const Divider(height: 18, color: Color(0xFFE2E8F0)),
                      _buildSuccessDetailRow(
                        label: 'Credit',
                        value: '₹${item.credit!.toStringAsFixed(2)}',
                        valueColor: const Color(0xFF16A34A),
                      ),
                    ],
                    if (item.debit != null && item.debit! > 0) ...[
                      const Divider(height: 18, color: Color(0xFFE2E8F0)),
                      _buildSuccessDetailRow(
                        label: 'Debit',
                        value: '₹${item.debit!.toStringAsFixed(2)}',
                        valueColor: const Color(0xFFDC2626),
                      ),
                    ],
                    if (item.balanceAfter != null) ...[
                      const Divider(height: 18, color: Color(0xFFE2E8F0)),
                      _buildSuccessDetailRow(
                        label: 'Balance After',
                        value: '₹${item.balanceAfter!.toStringAsFixed(2)}',
                        isBold: true,
                      ),
                    ],
                    if (item.gateway != null && item.gateway!.isNotEmpty) ...[
                      const Divider(height: 18, color: Color(0xFFE2E8F0)),
                      _buildSuccessDetailRow(
                        label: 'Gateway',
                        value: item.gateway!,
                      ),
                    ],
                    const Divider(height: 18, color: Color(0xFFE2E8F0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.status.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CLOSE'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTransactions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 36,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No Transactions Yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Recharge your wallet to enjoy fast 1-tap bookings and automated instant refunds.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  String _formatDate(String rawDate) {
    if (rawDate.isEmpty) return '';
    try {
      final parsed = DateTime.parse(rawDate).toLocal();
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      final hour = parsed.hour % 12 == 0 ? 12 : parsed.hour % 12;
      final ampm = parsed.hour >= 12 ? 'PM' : 'AM';
      final minute = parsed.minute.toString().padLeft(2, '0');
      return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}, $hour:$minute $ampm';
    } catch (_) {
      return rawDate;
    }
  }
}
