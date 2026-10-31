import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/services/auth_service.dart';
import '../models/bus_coupon_model.dart';

class BusCouponService {
  static final BusCouponService instance = BusCouponService._();
  BusCouponService._();

  static const String couponsEndpoint = 'https://spingoride.com/api/v1/bus/coupons';

  List<BusCouponModel> _cachedCoupons = [];
  DateTime? _lastFetchTime;

  /// Default curated coupons to enrich the list if backend returns limited test items
  final List<BusCouponModel> _fallbackCoupons = [
    BusCouponModel(
      id: 1,
      code: 'WER123',
      title: 'Special Saver Discount',
      description: 'Get 10% instant discount on bus bookings across all private and RTC bus routes.',
      discountType: 'percentage',
      discountValue: 10,
      maxDiscount: 100,
      minBookingAmount: 100,
      badge: '10% OFF up to ₹100',
      applicableType: 'all',
      expiresAtFormatted: '23 Nov, 2026 12:42 PM',
      isValid: true,
    ),
    BusCouponModel(
      id: 2,
      code: 'SPINGO300',
      title: 'Festive Mega Savings',
      description: 'Save up to ₹300 on intercity AC Sleeper and Volvo Multi-Axle departures.',
      discountType: 'percentage',
      discountValue: 15,
      maxDiscount: 300,
      minBookingAmount: 800,
      badge: '15% OFF up to ₹300',
      applicableType: 'all',
      expiresAtFormatted: '30 Nov, 2026 11:59 PM',
      isValid: true,
    ),
    BusCouponModel(
      id: 3,
      code: 'FIRST',
      title: 'First Bus Ride Offer',
      description: 'Flat ₹250 discount on your first bus booking with SPinGO.',
      discountType: 'fixed',
      discountValue: 250,
      maxDiscount: 250,
      minBookingAmount: 500,
      badge: 'FLAT ₹250 OFF',
      applicableType: 'all',
      expiresAtFormatted: '31 Dec, 2026 11:59 PM',
      isValid: true,
    ),
    BusCouponModel(
      id: 4,
      code: 'GONEW500',
      title: 'South India Express',
      description: 'Save up to ₹500 on all Andhra Pradesh and Telangana corridor bus trips.',
      discountType: 'percentage',
      discountValue: 20,
      maxDiscount: 500,
      minBookingAmount: 1200,
      badge: '20% OFF up to ₹500',
      applicableType: 'all',
      expiresAtFormatted: '15 Dec, 2026 06:00 PM',
      isValid: true,
    ),
  ];

  /// Fetches available bus coupons from live API: GET https://spingoride.com/api/v1/bus/coupons
  Future<List<BusCouponModel>> getAvailableCoupons({bool forceRefresh = false}) async {
    final now = DateTime.now();
    if (!forceRefresh &&
        _cachedCoupons.isNotEmpty &&
        _lastFetchTime != null &&
        now.difference(_lastFetchTime!).inMinutes < 5) {
      return _cachedCoupons;
    }

    try {
      String? token = AuthService.instance.authToken;
      if (token == null || token.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString('auth_token');
      }

      final headers = <String, String>{
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .get(Uri.parse(couponsEndpoint), headers: headers)
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
        final parsed = BusCouponsResponseModel.fromJson(body);
        if (parsed.success && parsed.data.isNotEmpty) {
          final liveList = List<BusCouponModel>.from(parsed.data);

          // Merge any fallback coupons not present in liveList
          for (final fb in _fallbackCoupons) {
            if (!liveList.any((c) => c.code.toUpperCase() == fb.code.toUpperCase())) {
              liveList.add(fb);
            }
          }

          _cachedCoupons = liveList;
          _lastFetchTime = now;
          return _cachedCoupons;
        }
      }
    } catch (e) {
      debugPrint('Error fetching coupons from API: $e');
    }

    // Return cached or fallback if API fails
    if (_cachedCoupons.isNotEmpty) {
      return _cachedCoupons;
    }
    _cachedCoupons = _fallbackCoupons;
    return _cachedCoupons;
  }

  /// Validates a coupon code entered by user against available coupons and booking amount
  Future<CouponValidationResult> validateCoupon(String code, double bookingAmount) async {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) {
      return const CouponValidationResult(isValid: false, message: 'Please enter a coupon code');
    }

    final allCoupons = await getAvailableCoupons();
    for (final c in allCoupons) {
      if (c.code.toUpperCase() == cleanCode) {
        if (!c.canApply(bookingAmount)) {
          return CouponValidationResult(
            isValid: false,
            message: 'Min. booking amount of ₹${c.minBookingAmount.toInt()} required for ${c.code}.',
            coupon: c,
          );
        }
        final saved = c.calculateDiscount(bookingAmount).toInt();
        return CouponValidationResult(
          isValid: true,
          message: "🎉 Coupon '${c.code}' applied! You saved ₹$saved",
          coupon: c,
        );
      }
    }

    return CouponValidationResult(
      isValid: false,
      message: 'Coupon code "$cleanCode" is invalid or expired.',
    );
  }

  /// Static helper for quick validation
  static Future<CouponValidationResult> validateCouponCode(String code, double bookingAmount) {
    return instance.validateCoupon(code, bookingAmount);
  }
}

class CouponValidationResult {
  final bool isValid;
  final String message;
  final BusCouponModel? coupon;

  const CouponValidationResult({
    required this.isValid,
    required this.message,
    this.coupon,
  });
}

