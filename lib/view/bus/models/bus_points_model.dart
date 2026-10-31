// SPiNGO Bus Boarding & Dropping Points Data Models
// Maps to:
// GET https://spingoride.com/api/v1/bus/schedules/{id}/boarding-points
// GET https://spingoride.com/api/v1/bus/schedules/{id}/dropping-points

import 'bus_booking_model.dart';

class BoardingPointsResponseModel {
  final bool success;
  final String message;
  final List<BusPointItemModel> data;

  BoardingPointsResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory BoardingPointsResponseModel.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? [];
    return BoardingPointsResponseModel(
      success: json['success'] == true,
      message: json['message'] as String? ?? '',
      data: list.map((item) => BusPointItemModel.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data.map((x) => x.toJson()).toList(),
      };
}

class DroppingPointsResponseModel {
  final bool success;
  final String message;
  final List<BusPointItemModel> data;

  DroppingPointsResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DroppingPointsResponseModel.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? [];
    return DroppingPointsResponseModel(
      success: json['success'] == true,
      message: json['message'] as String? ?? '',
      data: list.map((item) => BusPointItemModel.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data.map((x) => x.toJson()).toList(),
      };
}

class BusPointItemModel {
  final int id;
  final int scheduleId;
  final String type; // 'boarding' or 'dropping'
  final String pointName;
  final String cityName;
  final String? landmark;
  final String address;
  final double? latitude;
  final double? longitude;
  final String scheduledTime;
  final int displayOrder;

  BusPointItemModel({
    required this.id,
    required this.scheduleId,
    required this.type,
    required this.pointName,
    required this.cityName,
    this.landmark,
    required this.address,
    this.latitude,
    this.longitude,
    required this.scheduledTime,
    this.displayOrder = 1,
  });

  factory BusPointItemModel.fromJson(Map<String, dynamic> json) {
    return BusPointItemModel(
      id: json['id'] as int? ?? 0,
      scheduleId: json['schedule_id'] as int? ?? 0,
      type: json['type'] as String? ?? 'boarding',
      pointName: json['point_name'] as String? ?? '',
      cityName: json['city_name'] as String? ?? '',
      landmark: json['landmark'] as String?,
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      scheduledTime: json['scheduled_time'] as String? ?? '00:00:00',
      displayOrder: json['display_order'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'schedule_id': scheduleId,
        'type': type,
        'point_name': pointName,
        'city_name': cityName,
        'landmark': landmark,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'scheduled_time': scheduledTime,
        'display_order': displayOrder,
      };

  /// 24-hour clean time (e.g., "22:00")
  String get formattedTime24h {
    if (scheduledTime.length >= 5) {
      return scheduledTime.substring(0, 5);
    }
    return scheduledTime;
  }

  /// 12-hour formatted time with AM/PM (e.g., "10:00 PM")
  String get formattedTime12h {
    try {
      final parts = scheduledTime.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        final min = parts[1];
        final period = hour >= 12 ? 'PM' : 'AM';
        if (hour == 0) {
          hour = 12;
        } else if (hour > 12) {
          hour -= 12;
        }
        return '${hour.toString().padLeft(2, '0')}:$min $period';
      }
    } catch (_) {}
    return formattedTime24h;
  }

  /// Combined location description
  String get fullLocation => '$pointName, $cityName';

  /// Complete address with landmark
  String get fullAddress {
    if (landmark != null && landmark!.isNotEmpty) {
      return '$address (Near $landmark)';
    }
    return address.isNotEmpty ? address : 'Main station platform';
  }

  /// Converts this model to BusStopPoint for downstream compatibility
  BusStopPoint toBusStopPoint() {
    return BusStopPoint(
      id: id.toString(),
      time: formattedTime24h,
      location: fullLocation,
      landmark: fullAddress,
    );
  }
}
