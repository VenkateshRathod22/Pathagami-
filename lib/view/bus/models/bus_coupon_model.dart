class BusCouponModel {
  final int id;
  final String code;
  final String title;
  final String description;
  final String discountType; // 'percentage' or 'fixed'
  final double discountValue;
  final double maxDiscount;
  final double minBookingAmount;
  final String badge;
  final String applicableType;
  final String? startAt;
  final String? endAt;
  final String expiresAtFormatted;
  final bool isValid;

  BusCouponModel({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.maxDiscount,
    required this.minBookingAmount,
    required this.badge,
    this.applicableType = 'all',
    this.startAt,
    this.endAt,
    required this.expiresAtFormatted,
    this.isValid = true,
  });

  factory BusCouponModel.fromJson(Map<String, dynamic> json) {
    return BusCouponModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      code: json['code']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      discountType: json['discount_type']?.toString().toLowerCase() ?? 'percentage',
      discountValue: (json['discount_value'] as num?)?.toDouble() ?? 0.0,
      maxDiscount: (json['max_discount'] as num?)?.toDouble() ?? 0.0,
      minBookingAmount: (json['min_booking_amount'] as num?)?.toDouble() ?? 0.0,
      badge: json['badge']?.toString() ?? '',
      applicableType: json['applicable_type']?.toString() ?? 'all',
      startAt: json['start_at']?.toString(),
      endAt: json['end_at']?.toString(),
      expiresAtFormatted: json['expires_at_formatted']?.toString() ?? '',
      isValid: json['is_valid'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'title': title,
    'description': description,
    'discount_type': discountType,
    'discount_value': discountValue,
    'max_discount': maxDiscount,
    'min_booking_amount': minBookingAmount,
    'badge': badge,
    'applicable_type': applicableType,
    'start_at': startAt,
    'end_at': endAt,
    'expires_at_formatted': expiresAtFormatted,
    'is_valid': isValid,
  };

  /// Calculates actual discount amount given a booking subtotal
  double calculateDiscount(double subtotal) {
    if (subtotal < minBookingAmount || !isValid) {
      return 0.0;
    }
    double calculated = 0.0;
    if (discountType == 'percentage') {
      calculated = (subtotal * discountValue) / 100.0;
      if (maxDiscount > 0 && calculated > maxDiscount) {
        calculated = maxDiscount;
      }
    } else {
      // Fixed discount
      calculated = discountValue;
    }
    return calculated > subtotal ? subtotal : calculated;
  }

  /// Whether this coupon can be applied to a given fare
  bool canApply(double subtotal) {
    return isValid && subtotal >= minBookingAmount;
  }
}

class BusCouponsResponseModel {
  final bool success;
  final String message;
  final List<BusCouponModel> data;

  BusCouponsResponseModel({
    required this.success,
    required this.message,
    this.data = const [],
  });

  factory BusCouponsResponseModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'] as List<dynamic>? ?? [];
    return BusCouponsResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: rawList
          .map((item) => BusCouponModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
