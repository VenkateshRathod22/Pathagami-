import 'package:flutter/material.dart';

class BusOfferModel {
  final String id;
  final String badge;
  final String title;
  final String validity;
  final String code;
  final String description;
  final double? discountAmount;
  final int? discountPercent;
  final double? minBookingAmount;
  final String? applicableRoutes;
  final List<Color> gradientColors;
  final String imagePath;
  final List<String> termsAndConditions;

  BusOfferModel({
    required this.id,
    this.badge = 'Bus',
    required this.title,
    required this.validity,
    required this.code,
    required this.description,
    this.discountAmount,
    this.discountPercent,
    this.minBookingAmount,
    this.applicableRoutes,
    required this.gradientColors,
    required this.imagePath,
    this.termsAndConditions = const [],
  });

  factory BusOfferModel.fromJson(Map<String, dynamic> json) {
    List<Color> colors = [
      const Color(0xFFFFEDD5),
      const Color(0xFFFED7AA),
    ];

    if (json['gradient_colors'] is List) {
      final list = json['gradient_colors'] as List;
      if (list.length >= 2) {
        colors = [
          _hexToColor(list[0].toString()),
          _hexToColor(list[1].toString()),
        ];
      }
    }

    final termsRaw = json['terms'] as List<dynamic>? ?? [];
    final termsList = termsRaw.map((t) => t.toString()).toList();

    return BusOfferModel(
      id: json['id']?.toString() ?? '',
      badge: json['badge']?.toString() ?? 'Bus',
      title: json['title']?.toString() ?? '',
      validity: json['validity']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      discountAmount: (json['discount_amount'] as num?)?.toDouble(),
      discountPercent: (json['discount_percent'] as num?)?.toInt(),
      minBookingAmount: (json['min_booking_amount'] as num?)?.toDouble(),
      applicableRoutes: json['applicable_routes']?.toString(),
      gradientColors: colors,
      imagePath: json['image_path']?.toString() ?? 'assets/images/bus_red_tropical.jpg',
      termsAndConditions: termsList.isNotEmpty
          ? termsList
          : [
              'Offer valid only on bus ticket bookings through SPiNGO app.',
              'Maximum discount applicable as specified in the offer.',
              'Cannot be combined with any other promotional coupon.',
              'Valid on both single and return journey bookings.',
            ],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'badge': badge,
      'title': title,
      'validity': validity,
      'code': code,
      'description': description,
      'discount_amount': discountAmount,
      'discount_percent': discountPercent,
      'min_booking_amount': minBookingAmount,
      'applicable_routes': applicableRoutes,
      'image_path': imagePath,
      'terms': termsAndConditions,
    };
  }

  static Color _hexToColor(String hex) {
    String cleanHex = hex.replaceAll('#', '');
    if (cleanHex.length == 6) {
      cleanHex = 'FF$cleanHex';
    }
    return Color(int.tryParse(cleanHex, radix: 16) ?? 0xFFFFEDD5);
  }
}

class BusOfferResponseModel {
  final bool success;
  final String message;
  final List<BusOfferModel> data;

  BusOfferResponseModel({
    required this.success,
    required this.message,
    this.data = const [],
  });

  factory BusOfferResponseModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'] as List<dynamic>? ?? [];
    return BusOfferResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: rawList
          .map((item) => BusOfferModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
