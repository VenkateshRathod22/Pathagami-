
/// Response wrapper for GET https://spingoride.com/api/v1/wallet
class WalletResponseModel {
  final bool success;
  final String message;
  final WalletDataModel? data;

  WalletResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory WalletResponseModel.fromJson(Map<String, dynamic> json) {
    return WalletResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? WalletDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data?.toJson(),
      };
}

/// Data payload for GET https://spingoride.com/api/v1/wallet
class WalletDataModel {
  final int id;
  final int customerId;
  final double balance;
  final String currency;
  final String currencySymbol;
  final String formattedBalance;
  final double totalRecharge;
  final double totalSpent;
  final double totalRefund;
  final double pendingRefund;
  final List<WalletTransactionModel> recentTransactions;
  final String updatedAt;

  WalletDataModel({
    required this.id,
    required this.customerId,
    required this.balance,
    required this.currency,
    required this.currencySymbol,
    required this.formattedBalance,
    required this.totalRecharge,
    required this.totalSpent,
    required this.totalRefund,
    required this.pendingRefund,
    required this.recentTransactions,
    required this.updatedAt,
  });

  factory WalletDataModel.fromJson(Map<String, dynamic> json) {
    final recentRaw = json['recent_transactions'];
    List<WalletTransactionModel> recents = [];
    if (recentRaw is List) {
      recents = recentRaw
          .whereType<Map<String, dynamic>>()
          .map((item) => WalletTransactionModel.fromJson(item))
          .toList();
    }

    final numBalance = (json['balance'] as num?)?.toDouble() ?? 0.0;
    final symbol = json['currency_symbol'] as String? ?? '₹';

    return WalletDataModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      customerId: (json['customer_id'] as num?)?.toInt() ?? 0,
      balance: numBalance,
      currency: json['currency'] as String? ?? 'INR',
      currencySymbol: symbol,
      formattedBalance: json['formatted_balance'] as String? ??
          '$symbol${numBalance.toStringAsFixed(2)}',
      totalRecharge: (json['total_recharge'] as num?)?.toDouble() ?? 0.0,
      totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0.0,
      totalRefund: (json['total_refund'] as num?)?.toDouble() ?? 0.0,
      pendingRefund: (json['pending_refund'] as num?)?.toDouble() ?? 0.0,
      recentTransactions: recents,
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer_id': customerId,
        'balance': balance,
        'currency': currency,
        'currency_symbol': currencySymbol,
        'formatted_balance': formattedBalance,
        'total_recharge': totalRecharge,
        'total_spent': totalSpent,
        'total_refund': totalRefund,
        'pending_refund': pendingRefund,
        'recent_transactions':
            recentTransactions.map((x) => x.toJson()).toList(),
        'updated_at': updatedAt,
      };

  WalletDataModel copyWith({
    int? id,
    int? customerId,
    double? balance,
    String? currency,
    String? currencySymbol,
    String? formattedBalance,
    double? totalRecharge,
    double? totalSpent,
    double? totalRefund,
    double? pendingRefund,
    List<WalletTransactionModel>? recentTransactions,
    String? updatedAt,
  }) {
    return WalletDataModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      formattedBalance: formattedBalance ?? this.formattedBalance,
      totalRecharge: totalRecharge ?? this.totalRecharge,
      totalSpent: totalSpent ?? this.totalSpent,
      totalRefund: totalRefund ?? this.totalRefund,
      pendingRefund: pendingRefund ?? this.pendingRefund,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory WalletDataModel.defaultEmpty() {
    return WalletDataModel(
      id: 0,
      customerId: 0,
      balance: 0.0,
      currency: 'INR',
      currencySymbol: '₹',
      formattedBalance: '₹0.00',
      totalRecharge: 0.0,
      totalSpent: 0.0,
      totalRefund: 0.0,
      pendingRefund: 0.0,
      recentTransactions: const [],
      updatedAt: '',
    );
  }
}

/// Response wrapper for GET https://spingoride.com/api/v1/wallet/transactions
class WalletTransactionsResponseModel {
  final bool success;
  final String message;
  final List<WalletTransactionModel> data;
  final WalletMetaModel? meta;

  WalletTransactionsResponseModel({
    required this.success,
    required this.message,
    required this.data,
    this.meta,
  });

  factory WalletTransactionsResponseModel.fromJson(Map<String, dynamic> json) {
    List<WalletTransactionModel> list = [];
    if (json['data'] is List) {
      list = (json['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => WalletTransactionModel.fromJson(item))
          .toList();
    }

    return WalletTransactionsResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: list,
      meta: json['meta'] is Map<String, dynamic>
          ? WalletMetaModel.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data.map((x) => x.toJson()).toList(),
        'meta': meta?.toJson(),
      };
}

/// Pagination metadata
class WalletMetaModel {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMorePages;

  WalletMetaModel({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.hasMorePages,
  });

  factory WalletMetaModel.fromJson(Map<String, dynamic> json) {
    return WalletMetaModel(
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      lastPage: (json['last_page'] as num?)?.toInt() ?? 1,
      perPage: (json['per_page'] as num?)?.toInt() ?? 15,
      total: (json['total'] as num?)?.toInt() ?? 0,
      hasMorePages: json['has_more_pages'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'current_page': currentPage,
        'last_page': lastPage,
        'per_page': perPage,
        'total': total,
        'has_more_pages': hasMorePages,
      };
}

/// Single transaction item
class WalletTransactionModel {
  final int id;
  final int? customerId;
  final String transactionId;
  final String type; // 'credit', 'debit', 'recharge', 'refund', 'payment'
  final double amount;
  final double? credit;
  final double? debit;
  final String? formattedAmount;
  final double? balanceAfter;
  final String description;
  final String? remarks;
  final String status; // 'success', 'completed', 'pending', 'failed'
  final String? referenceId;
  final String? orderId;
  final String? paymentId;
  final String? gateway;
  final String? formattedDate;
  final String createdAt;

  WalletTransactionModel({
    required this.id,
    this.customerId,
    this.transactionId = '',
    required this.type,
    required this.amount,
    this.credit,
    this.debit,
    this.formattedAmount,
    this.balanceAfter,
    required this.description,
    this.remarks,
    required this.status,
    this.referenceId,
    this.orderId,
    this.paymentId,
    this.gateway,
    this.formattedDate,
    required this.createdAt,
  });

  bool get isCredit {
    final lower = type.toLowerCase();
    return lower == 'credit' ||
        lower == 'recharge' ||
        lower == 'refund' ||
        lower == 'cashback' ||
        lower == 'bonus';
  }

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    final numAmount = (json['amount'] as num?)?.toDouble() ?? 0.0;
    final typeStr = json['type'] as String? ?? 'credit';
    final lowerType = typeStr.toLowerCase();
    final isCred = lowerType == 'credit' ||
        lowerType == 'recharge' ||
        lowerType == 'refund' ||
        lowerType == 'cashback' ||
        lowerType == 'bonus';

    final numCredit = (json['credit'] as num?)?.toDouble() ??
        (isCred ? numAmount : null);
    final numDebit = (json['debit'] as num?)?.toDouble() ??
        (!isCred ? numAmount : null);

    final txnId = json['transaction_id'] as String? ??
        json['reference_id'] as String? ??
        '';

    final fmtAmount = json['formatted_amount'] as String? ??
        '${isCred ? '+' : '-'} ₹${numAmount.toStringAsFixed(2)}';

    return WalletTransactionModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      customerId: (json['customer_id'] as num?)?.toInt(),
      transactionId: txnId,
      type: typeStr,
      amount: numAmount,
      credit: numCredit,
      debit: numDebit,
      formattedAmount: fmtAmount,
      balanceAfter: (json['balance'] as num?)?.toDouble() ??
          (json['balance_after'] as num?)?.toDouble(),
      description: json['description'] as String? ??
          json['remarks'] as String? ??
          json['title'] as String? ??
          'Wallet Transaction',
      remarks: json['remarks'] as String?,
      status: json['status'] as String? ?? 'completed',
      referenceId: txnId.isNotEmpty ? txnId : json['reference_id'] as String?,
      orderId: json['order_id'] as String?,
      paymentId: json['payment_id'] as String?,
      gateway: json['gateway'] as String?,
      formattedDate: json['formatted_date'] as String?,
      createdAt: json['created_at'] as String? ??
          json['formatted_date'] as String? ??
          json['date'] as String? ??
          DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer_id': customerId,
        'transaction_id': transactionId,
        'type': type,
        'amount': amount,
        'credit': credit,
        'debit': debit,
        'formatted_amount': formattedAmount,
        'balance': balanceAfter,
        'balance_after': balanceAfter,
        'description': description,
        'remarks': remarks,
        'status': status,
        'reference_id': referenceId,
        'order_id': orderId,
        'payment_id': paymentId,
        'gateway': gateway,
        'formatted_date': formattedDate,
        'created_at': createdAt,
      };
}

/// Response wrapper for GET https://spingoride.com/api/v1/wallet/gateways
class WalletGatewaysResponseModel {
  final bool success;
  final String message;
  final List<PaymentGatewayModel> data;

  WalletGatewaysResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory WalletGatewaysResponseModel.fromJson(Map<String, dynamic> json) {
    List<PaymentGatewayModel> list = [];
    if (json['data'] is List) {
      list = (json['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => PaymentGatewayModel.fromJson(item))
          .toList();
    }
    return WalletGatewaysResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: list,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data.map((x) => x.toJson()).toList(),
      };
}

/// Payment Gateway item from GET https://spingoride.com/api/v1/wallet/gateways
class PaymentGatewayModel {
  final String code; // 'razorpay'
  final String name; // 'Razorpay'
  final String mode; // 'live' / 'test'
  final String icon; // 'feather-credit-card'
  final String badge; // 'Instant UPI / Card'
  final String color; // '#0c2340'

  PaymentGatewayModel({
    required this.code,
    required this.name,
    required this.mode,
    required this.icon,
    required this.badge,
    required this.color,
  });

  factory PaymentGatewayModel.fromJson(Map<String, dynamic> json) {
    return PaymentGatewayModel(
      code: json['code'] as String? ?? 'razorpay',
      name: json['name'] as String? ?? 'Razorpay',
      mode: json['mode'] as String? ?? 'live',
      icon: json['icon'] as String? ?? 'feather-credit-card',
      badge: json['badge'] as String? ?? 'Instant UPI / Card',
      color: json['color'] as String? ?? '#0c2340',
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'mode': mode,
        'icon': icon,
        'badge': badge,
        'color': color,
      };

  factory PaymentGatewayModel.razorpayFallback() {
    return PaymentGatewayModel(
      code: 'razorpay',
      name: 'Razorpay',
      mode: 'live',
      icon: 'feather-credit-card',
      badge: 'Instant UPI / Card',
      color: '#0c2340',
    );
  }
}

/// Response wrapper for POST https://spingoride.com/api/v1/wallet/recharge/initiate
class WalletRechargeInitiateResponseModel {
  final bool success;
  final String message;
  final WalletRechargeDataModel? data;

  WalletRechargeInitiateResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory WalletRechargeInitiateResponseModel.fromJson(
      Map<String, dynamic> json) {
    return WalletRechargeInitiateResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] is Map<String, dynamic>
          ? WalletRechargeDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data?.toJson(),
      };
}

/// Recharge Order Initiation Data
class WalletRechargeDataModel {
  final String gateway;
  final String orderId;
  final double amount;
  final String currency;
  final String key;
  final String? redirectUrl;
  final String checkoutMode;
  final WalletCustomerModel customer;
  final WalletPayloadModel payload;

  WalletRechargeDataModel({
    required this.gateway,
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.key,
    this.redirectUrl,
    required this.checkoutMode,
    required this.customer,
    required this.payload,
  });

  factory WalletRechargeDataModel.fromJson(Map<String, dynamic> json) {
    return WalletRechargeDataModel(
      gateway: json['gateway'] as String? ?? 'razorpay',
      orderId: json['order_id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
      key: json['key'] as String? ?? '',
      redirectUrl: json['redirect_url'] as String?,
      checkoutMode: json['checkout_mode'] as String? ?? 'popup',
      customer: json['customer'] is Map<String, dynamic>
          ? WalletCustomerModel.fromJson(json['customer'] as Map<String, dynamic>)
          : WalletCustomerModel.empty(),
      payload: json['payload'] is Map<String, dynamic>
          ? WalletPayloadModel.fromJson(json['payload'] as Map<String, dynamic>)
          : WalletPayloadModel.empty(),
    );
  }

  Map<String, dynamic> toJson() => {
        'gateway': gateway,
        'order_id': orderId,
        'amount': amount,
        'currency': currency,
        'key': key,
        'redirect_url': redirectUrl,
        'checkout_mode': checkoutMode,
        'customer': customer.toJson(),
        'payload': payload.toJson(),
      };
}

class WalletCustomerModel {
  final String name;
  final String email;
  final String phone;

  WalletCustomerModel({
    required this.name,
    required this.email,
    required this.phone,
  });

  factory WalletCustomerModel.fromJson(Map<String, dynamic> json) {
    return WalletCustomerModel(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
      };

  factory WalletCustomerModel.empty() => WalletCustomerModel(
        name: '',
        email: '',
        phone: '',
      );
}

class WalletPayloadModel {
  final String name;
  final String description;

  WalletPayloadModel({
    required this.name,
    required this.description,
  });

  factory WalletPayloadModel.fromJson(Map<String, dynamic> json) {
    return WalletPayloadModel(
      name: json['name'] as String? ?? 'SPinGO',
      description: json['description'] as String? ?? 'Wallet Recharge',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
      };

  factory WalletPayloadModel.empty() => WalletPayloadModel(
        name: 'SPinGO',
        description: 'Wallet Recharge',
      );
}

/// Response wrapper for POST https://spingoride.com/api/v1/wallet/recharge/verify
class WalletRechargeVerifyResponseModel {
  final bool success;
  final String message;
  final WalletVerifyDataModel? data;

  WalletRechargeVerifyResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory WalletRechargeVerifyResponseModel.fromJson(Map<String, dynamic> json) {
    return WalletRechargeVerifyResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? WalletVerifyDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data?.toJson(),
      };
}

/// Data container from POST /api/v1/wallet/recharge/verify
class WalletVerifyDataModel {
  final WalletVerifyWalletModel? wallet;
  final WalletVerifyTransactionModel? transaction;

  WalletVerifyDataModel({
    this.wallet,
    this.transaction,
  });

  factory WalletVerifyDataModel.fromJson(Map<String, dynamic> json) {
    return WalletVerifyDataModel(
      wallet: json['wallet'] != null && json['wallet'] is Map<String, dynamic>
          ? WalletVerifyWalletModel.fromJson(
              json['wallet'] as Map<String, dynamic>)
          : null,
      transaction: json['transaction'] != null &&
              json['transaction'] is Map<String, dynamic>
          ? WalletVerifyTransactionModel.fromJson(
              json['transaction'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'wallet': wallet?.toJson(),
        'transaction': transaction?.toJson(),
      };
}

/// Wallet object from POST /api/v1/wallet/recharge/verify
class WalletVerifyWalletModel {
  final int id;
  final int customerId;
  final double balance;
  final String currency;
  final String formattedBalance;
  final double totalRecharge;
  final double totalSpent;

  WalletVerifyWalletModel({
    required this.id,
    required this.customerId,
    required this.balance,
    required this.currency,
    required this.formattedBalance,
    required this.totalRecharge,
    required this.totalSpent,
  });

  factory WalletVerifyWalletModel.fromJson(Map<String, dynamic> json) {
    return WalletVerifyWalletModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      customerId: (json['customer_id'] as num?)?.toInt() ?? 0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
      formattedBalance: json['formatted_balance'] as String? ?? '',
      totalRecharge: (json['total_recharge'] as num?)?.toDouble() ?? 0.0,
      totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer_id': customerId,
        'balance': balance,
        'currency': currency,
        'formatted_balance': formattedBalance,
        'total_recharge': totalRecharge,
        'total_spent': totalSpent,
      };
}

/// Transaction object from POST /api/v1/wallet/recharge/verify
class WalletVerifyTransactionModel {
  final int id;
  final String transactionId;
  final String type;
  final double amount;
  final double credit;
  final double debit;
  final double balanceAfter;
  final String formattedAmount;
  final String description;
  final String status;
  final String formattedDate;

  WalletVerifyTransactionModel({
    required this.id,
    required this.transactionId,
    required this.type,
    required this.amount,
    required this.credit,
    required this.debit,
    required this.balanceAfter,
    required this.formattedAmount,
    required this.description,
    required this.status,
    required this.formattedDate,
  });

  factory WalletVerifyTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletVerifyTransactionModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      transactionId: json['transaction_id'] as String? ?? '',
      type: json['type'] as String? ?? 'credit',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      credit: (json['credit'] as num?)?.toDouble() ?? 0.0,
      debit: (json['debit'] as num?)?.toDouble() ?? 0.0,
      balanceAfter: (json['balance_after'] as num?)?.toDouble() ?? 0.0,
      formattedAmount: json['formatted_amount'] as String? ?? '',
      description: json['description'] as String? ?? 'Wallet Recharged',
      status: json['status'] as String? ?? 'success',
      formattedDate: json['formatted_date'] as String? ?? '',
    );
  }

  WalletTransactionModel toWalletTransactionModel() {
    return WalletTransactionModel(
      id: id,
      customerId: null,
      transactionId: transactionId,
      type: type,
      amount: amount,
      credit: credit,
      debit: debit,
      formattedAmount: formattedAmount.isNotEmpty
          ? formattedAmount
          : '+ ₹${amount.toStringAsFixed(2)}',
      balanceAfter: balanceAfter,
      description: description,
      status: status,
      referenceId: transactionId,
      formattedDate: formattedDate,
      createdAt: formattedDate.isNotEmpty
          ? formattedDate
          : DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'transaction_id': transactionId,
        'type': type,
        'amount': amount,
        'credit': credit,
        'debit': debit,
        'balance_after': balanceAfter,
        'formatted_amount': formattedAmount,
        'description': description,
        'status': status,
        'formatted_date': formattedDate,
      };
}
