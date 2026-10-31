import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/bus_offer_model.dart';

class BusOfferService {
  static final BusOfferService instance = BusOfferService._();
  BusOfferService._();

  /// Default API Endpoint (User can customize or activate anytime)
  static const String offersEndpoint = 'https://spingoride.com/api/v1/bus/offers';

  /// Initial curated offers matching Screenshots exactly
  final List<BusOfferModel> _fallbackOffers = [
    BusOfferModel(
      id: 'offer_festive_300',
      badge: 'Bus',
      title: 'Save up to Rs 300 on bus tickets',
      validity: 'Valid till: 25 Oct',
      code: 'FESTIVE300',
      description: 'Get flat 15% discount up to ₹300 on all festival special AC sleeper buses.',
      discountAmount: 300,
      discountPercent: 15,
      minBookingAmount: 700,
      applicableRoutes: 'All Pan-India Routes',
      gradientColors: [
        const Color(0xFFFFEDD5),
        const Color(0xFFFED7AA),
      ],
      imagePath: 'assets/images/bus_festive_sale.jpg',
      termsAndConditions: [
        'Offer valid till 25th October 2026.',
        'Flat 15% discount up to ₹300 per booking.',
        'Applicable on all private and RTC bus operators.',
        'Coupon can be redeemed once per customer.',
      ],
    ),
    BusOfferModel(
      id: 'offer_gonew_500',
      badge: 'Bus',
      title: 'Save up to ₹500 on bus ticket bookings from AP/TG.',
      validity: 'Valid till: 31 Oct',
      code: 'GONEW500',
      description: 'Special discount for travelers across Andhra Pradesh and Telangana corridors.',
      discountAmount: 500,
      discountPercent: 20,
      minBookingAmount: 1000,
      applicableRoutes: 'AP & Telangana Routes (APSRTC, TGSRTC, Private)',
      gradientColors: [
        const Color(0xFFFDE8E8),
        const Color(0xFFFBCFE8),
      ],
      imagePath: 'assets/images/bus_red_tropical.jpg',
      termsAndConditions: [
        'Valid on bus departures origin from AP or TG.',
        'Maximum savings up to ₹500 on minimum fare of ₹1,000.',
        'Valid on Sleeper, Seater, and Luxury Volvo coaches.',
        'Valid till 31st October 2026.',
      ],
    ),
    BusOfferModel(
      id: 'offer_first_250',
      badge: 'Bus',
      title: 'Save up to Rs 250 on bus tickets',
      validity: 'Valid till: 31 Oct',
      code: 'FIRST',
      description: 'Welcome bonus on your very first bus booking with SPiNGO TripRied.',
      discountAmount: 250,
      discountPercent: 25,
      minBookingAmount: 500,
      applicableRoutes: 'All Routes (First Booking)',
      gradientColors: [
        const Color(0xFFFFE4E6),
        const Color(0xFFFECDD3),
      ],
      imagePath: 'assets/images/bus_red_tropical.jpg',
      termsAndConditions: [
        'Applicable exclusively for new customers on first booking.',
        'Flat 25% instant rebate up to ₹250.',
        'Instant discount applied directly at checkout.',
        'Valid till 31st October 2026.',
      ],
    ),
    BusOfferModel(
      id: 'offer_superhit_300',
      badge: 'Bus',
      title: 'Save up to Rs. 300 in AP, Telangana routes',
      validity: 'Valid till: 31 Oct',
      code: 'SUPERHIT',
      description: 'Unlock superhit festive savings on top intercity routes.',
      discountAmount: 300,
      discountPercent: 15,
      minBookingAmount: 800,
      applicableRoutes: 'Hyderabad, Vijayawada, Vizag, Tirupati & Bangalore',
      gradientColors: [
        const Color(0xFFFDF2F8),
        const Color(0xFFFBCFE8),
      ],
      imagePath: 'assets/images/bus_red_tropical.jpg',
      termsAndConditions: [
        'Valid across all high-demand South Indian routes.',
        'Maximum discount capped at ₹300.',
        'Applicable on single and round-trip journeys.',
        'Valid till 31st October 2026.',
      ],
    ),
    BusOfferModel(
      id: 'offer_bus_300',
      badge: 'Bus',
      title: 'Save up to Rs 300 on bus tickets',
      validity: 'Valid till: 31 Oct',
      code: 'BUS300',
      description: 'Enjoy assured cash savings on AC Sleeper and Multi-axle buses.',
      discountAmount: 300,
      discountPercent: 12,
      minBookingAmount: 900,
      applicableRoutes: 'Interstate AC Buses',
      gradientColors: [
        const Color(0xFFFFF1F2),
        const Color(0xFFFFE4E6),
      ],
      imagePath: 'assets/images/bus_red_tropical.jpg',
      termsAndConditions: [
        'Valid on all major bus operators.',
        'Discount applied automatically when coupon is entered.',
        'Non-refundable on cancellation.',
        'Valid till 31st October 2026.',
      ],
    ),
    BusOfferModel(
      id: 'offer_cash_300',
      badge: 'Bus',
      title: 'Save up to Rs 300 on Karnataka, Tamil Nadu, Kerala routes',
      validity: 'Valid till: 31 Oct',
      code: 'CASH300',
      description: 'Instant cashback reward for South India highway travel.',
      discountAmount: 300,
      discountPercent: 18,
      minBookingAmount: 850,
      applicableRoutes: 'Karnataka, Tamil Nadu & Kerala',
      gradientColors: [
        const Color(0xFFF3E8FF),
        const Color(0xFFE9D5FF),
      ],
      imagePath: 'assets/images/bus_cashback_girl.jpg',
      termsAndConditions: [
        'Valid on Bengaluru, Chennai, Kochi, Coimbatore, Madurai routes.',
        'Save up to ₹300 instantly.',
        'Valid on bookings made before 31st October.',
      ],
    ),
  ];

  /// Loads bus offers. First tries live API if active; otherwise returns curated offers.
  Future<List<BusOfferModel>> getOffers({String? authToken}) async {
    try {
      final headers = <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      if (authToken != null && authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final uri = Uri.parse(offersEndpoint);
      final response = await http.get(uri, headers: headers).timeout(
        const Duration(seconds: 4),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        final parsed = BusOfferResponseModel.fromJson(data);
        if (parsed.success && parsed.data.isNotEmpty) {
          return parsed.data;
        }
      }
      return _fallbackOffers;
    } catch (_) {
      // Graceful fallback so UI is always lightning-fast and never empty
      return _fallbackOffers;
    }
  }
}
