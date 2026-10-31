import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripried/view/auth/services/auth_service.dart';
import 'package:tripried/view/account/sub_features/personal_info/services/user_profile_service.dart';
import '../models/wallet_models.dart';

/// Service managing SPinGO Customer Wallet API operations:
/// - GET  https://spingoride.com/api/v1/wallet
/// - GET  https://spingoride.com/api/v1/wallet/transactions
/// - GET  https://spingoride.com/api/v1/wallet/gateways
/// - POST https://spingoride.com/api/v1/wallet/recharge/initiate
/// - POST https://spingoride.com/api/v1/wallet/recharge/verify
class WalletService extends ChangeNotifier {
  static final WalletService instance = WalletService._internal();
  WalletService._internal();

  static const String baseUrl = 'https://spingoride.com/api/v1/wallet';
  static const String cacheKey = 'spingo_cached_wallet_data';

  WalletDataModel _walletData = WalletDataModel.defaultEmpty();
  List<WalletTransactionModel> _transactions = [];
  WalletMetaModel? _transactionsMeta;
  List<PaymentGatewayModel> _gateways = [
    PaymentGatewayModel.razorpayFallback(),
  ];

  bool _isLoading = false;
  bool _isLoadingTransactions = false;
  String? _errorMessage;

  WalletDataModel get walletData => _walletData;
  double get balance => _walletData.balance;
  String get formattedBalance => _walletData.formattedBalance;
  String get currencySymbol => _walletData.currencySymbol;
  List<WalletTransactionModel> get transactions => _transactions;
  WalletMetaModel? get transactionsMeta => _transactionsMeta;
  List<PaymentGatewayModel> get gateways => _gateways;
  bool get isLoading => _isLoading;
  bool get isLoadingTransactions => _isLoadingTransactions;
  String? get errorMessage => _errorMessage;

  /// Standard request headers with JSON and Bearer auth
  Future<Map<String, String>> _getHeaders() async {
    String? token = AuthService.instance.authToken;
    if (token == null || token.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('auth_token');
    }

    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Initial load from cache, then fetch fresh data from server
  Future<void> init() async {
    await loadFromCache();
    await Future.wait([
      fetchWallet(),
      fetchGateways(),
      fetchTransactions(page: 1),
    ]);
  }

  /// Loads cached wallet info from SharedPreferences
  Future<void> loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(cacheKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final Map<String, dynamic> data =
            jsonDecode(cachedJson) as Map<String, dynamic>;
        _walletData = WalletDataModel.fromJson(data);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cached wallet: $e');
    }
  }

  /// Saves wallet data to local cache
  Future<void> _saveToCache(WalletDataModel data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(cacheKey, jsonEncode(data.toJson()));
    } catch (e) {
      debugPrint('Error saving wallet cache: $e');
    }
  }

  /// 1. GET https://spingoride.com/api/v1/wallet
  Future<WalletResponseModel> fetchWallet() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final headers = await _getHeaders();
      final url = Uri.parse(baseUrl);
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body =
            jsonDecode(response.body) as Map<String, dynamic>;
        final model = WalletResponseModel.fromJson(body);

        if (model.success && model.data != null) {
          _walletData = model.data!;
          await _saveToCache(_walletData);
          if (_transactions.isEmpty &&
              _walletData.recentTransactions.isNotEmpty) {
            _transactions = _walletData.recentTransactions;
          }
        }
        _isLoading = false;
        notifyListeners();
        return model;
      } else {
        _errorMessage =
            'Failed to fetch wallet details (${response.statusCode})';
        _isLoading = false;
        notifyListeners();
        return WalletResponseModel(
          success: false,
          message: _errorMessage!,
        );
      }
    } catch (e) {
      debugPrint('Error fetching wallet: $e');
      _errorMessage = 'Network connection error. Showing cached balance.';
      _isLoading = false;
      notifyListeners();
      return WalletResponseModel(
        success: false,
        message: _errorMessage!,
      );
    }
  }

  /// 2. GET https://spingoride.com/api/v1/wallet/transactions
  Future<WalletTransactionsResponseModel> fetchTransactions(
      {int page = 1}) async {
    _isLoadingTransactions = true;
    notifyListeners();

    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/transactions?page=$page');
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body =
            jsonDecode(response.body) as Map<String, dynamic>;
        final model = WalletTransactionsResponseModel.fromJson(body);

        if (model.success) {
          if (page == 1) {
            _transactions = model.data;
          } else {
            _transactions.addAll(model.data);
          }
          _transactionsMeta = model.meta;
        }
        _isLoadingTransactions = false;
        notifyListeners();
        return model;
      } else {
        _isLoadingTransactions = false;
        notifyListeners();
        return WalletTransactionsResponseModel(
          success: false,
          message:
              'Failed to retrieve transactions (${response.statusCode})',
          data: _transactions,
        );
      }
    } catch (e) {
      debugPrint('Error fetching wallet transactions: $e');
      _isLoadingTransactions = false;
      notifyListeners();
      return WalletTransactionsResponseModel(
        success: false,
        message: 'Network error retrieving transactions: $e',
        data: _transactions,
      );
    }
  }

  /// 3. GET https://spingoride.com/api/v1/wallet/gateways
  Future<WalletGatewaysResponseModel> fetchGateways() async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/gateways');
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body =
            jsonDecode(response.body) as Map<String, dynamic>;
        final model = WalletGatewaysResponseModel.fromJson(body);
        if (model.success && model.data.isNotEmpty) {
          _gateways = model.data;
          notifyListeners();
        }
        return model;
      }
    } catch (e) {
      debugPrint('Error fetching payment gateways: $e');
    }
    return WalletGatewaysResponseModel(
      success: true,
      message: 'Default gateway loaded',
      data: _gateways,
    );
  }

  /// 4. POST https://spingoride.com/api/v1/wallet/recharge/initiate
  Future<WalletRechargeInitiateResponseModel> initiateRecharge({
    required double amount,
    String gateway = 'razorpay',
  }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/recharge/initiate');
      final body = jsonEncode({
        'amount': amount,
        'gateway': gateway,
      });

      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 18));

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return WalletRechargeInitiateResponseModel.fromJson(data);
      } else {
        return WalletRechargeInitiateResponseModel(
          success: false,
          message: data['message']?.toString() ??
              'Failed to initiate recharge order (${response.statusCode})',
        );
      }
    } catch (e) {
      debugPrint('Error initiating recharge: $e');
      return WalletRechargeInitiateResponseModel(
        success: false,
        message: 'Network error initiating recharge: $e',
      );
    }
  }

  /// 5. POST https://spingoride.com/api/v1/wallet/recharge/verify
  Future<WalletRechargeVerifyResponseModel> verifyRecharge({
    required double amount,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    String gateway = 'razorpay',
  }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/recharge/verify');
      final body = jsonEncode({
        'amount': amount.toInt() == amount ? amount.toInt() : amount,
        'gateway': gateway,
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
      });

      debugPrint('POST $url');
      debugPrint('Verify Request Body: $body');

      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 20));

      debugPrint('Verify Response Status: ${response.statusCode}');
      debugPrint('Verify Response Body: ${response.body}');

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final verifyResult = WalletRechargeVerifyResponseModel.fromJson(data);

        // Immediate state update from verified backend response
        if (verifyResult.data?.wallet != null) {
          final w = verifyResult.data!.wallet!;
          _walletData = _walletData.copyWith(
            id: w.id > 0 ? w.id : _walletData.id,
            customerId:
                w.customerId > 0 ? w.customerId : _walletData.customerId,
            balance: w.balance,
            currency:
                w.currency.isNotEmpty ? w.currency : _walletData.currency,
            formattedBalance: w.formattedBalance.isNotEmpty
                ? w.formattedBalance
                : '${_walletData.currencySymbol}${w.balance.toStringAsFixed(2)}',
            totalRecharge: w.totalRecharge > 0
                ? w.totalRecharge
                : _walletData.totalRecharge,
            totalSpent:
                w.totalSpent > 0 ? w.totalSpent : _walletData.totalSpent,
          );
          await _saveToCache(_walletData);
        }

        if (verifyResult.data?.transaction != null) {
          final txnModel =
              verifyResult.data!.transaction!.toWalletTransactionModel();
          _transactions.removeWhere((x) =>
              (x.id > 0 && x.id == txnModel.id) ||
              (txnModel.transactionId.isNotEmpty &&
                  x.transactionId == txnModel.transactionId));
          _transactions.insert(0, txnModel);
        }

        notifyListeners();

        // Refresh fresh wallet balance and transactions in background for consistency
        fetchWallet();
        fetchTransactions(page: 1);
        UserProfileService.instance.fetchUserProfile();
        return verifyResult;
      } else {
        return WalletRechargeVerifyResponseModel(
          success: false,
          message: data['message']?.toString() ??
              'Payment verification failed (${response.statusCode})',
        );
      }
    } catch (e) {
      debugPrint('Error verifying recharge: $e');
      return WalletRechargeVerifyResponseModel(
        success: false,
        message: 'Network error verifying recharge: $e',
      );
    }
  }
}
