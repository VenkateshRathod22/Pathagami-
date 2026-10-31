import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripried/view/auth/services/auth_service.dart';
import '../models/bus_points_model.dart';

class BusPointsBundle {
  final List<BusPointItemModel> boardingPoints;
  final List<BusPointItemModel> droppingPoints;

  const BusPointsBundle({
    required this.boardingPoints,
    required this.droppingPoints,
  });
}

class BusPointsService {
  static final BusPointsService instance = BusPointsService._internal();
  BusPointsService._internal();

  static const String baseUrl = 'https://spingoride.com/api/v1/bus';

  final Map<int, List<BusPointItemModel>> _cachedBoardingPoints = {};
  final Map<int, List<BusPointItemModel>> _cachedDroppingPoints = {};

  /// Fallback boarding points matching live schedule 15
  static final List<BusPointItemModel> fallbackBoardingPoints = [
    BusPointItemModel(
      id: 43,
      scheduleId: 15,
      type: 'boarding',
      pointName: 'Alambagh ISBT Platform 3',
      cityName: 'Lucknow',
      landmark: null,
      address: 'Near Metro Station, Alambagh',
      latitude: null,
      longitude: null,
      scheduledTime: '22:00:00',
      displayOrder: 1,
    ),
    BusPointItemModel(
      id: 44,
      scheduleId: 15,
      type: 'boarding',
      pointName: 'Transport Nagar Parking',
      cityName: 'Lucknow',
      landmark: null,
      address: 'Shaheed Path Corner',
      latitude: null,
      longitude: null,
      scheduledTime: '22:30:00',
      displayOrder: 2,
    ),
  ];

  /// Fallback dropping points matching live schedule 15
  static final List<BusPointItemModel> fallbackDroppingPoints = [
    BusPointItemModel(
      id: 45,
      scheduleId: 15,
      type: 'dropping',
      pointName: 'Akshardham Metro Station',
      cityName: 'Delhi',
      landmark: null,
      address: 'Gate 2, East Delhi',
      latitude: null,
      longitude: null,
      scheduledTime: '05:00:00',
      displayOrder: 1,
    ),
    BusPointItemModel(
      id: 46,
      scheduleId: 15,
      type: 'dropping',
      pointName: 'Kashmere Gate ISBT',
      cityName: 'Delhi',
      landmark: null,
      address: 'Maharana Pratap Inter State Bus Terminus',
      latitude: null,
      longitude: null,
      scheduledTime: '05:30:00',
      displayOrder: 2,
    ),
  ];

  Future<Map<String, String>> _getHeaders() async {
    String? token = AuthService.instance.authToken;
    if (token == null || token.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('auth_token');
    }

    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Fetches boarding points for a given schedule ID
  /// API: GET https://spingoride.com/api/v1/bus/schedules/{id}/boarding-points
  Future<List<BusPointItemModel>> getBoardingPoints(int scheduleId, {bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedBoardingPoints.containsKey(scheduleId)) {
      return _cachedBoardingPoints[scheduleId]!;
    }

    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/schedules/$scheduleId/boarding-points');

      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
        final parsed = BoardingPointsResponseModel.fromJson(body);
        if (parsed.success && parsed.data.isNotEmpty) {
          _cachedBoardingPoints[scheduleId] = parsed.data;
          return parsed.data;
        }
      }
    } catch (e) {
      debugPrint('Error fetching boarding points for schedule $scheduleId: $e');
    }

    // Return cached if available
    if (_cachedBoardingPoints.containsKey(scheduleId)) {
      return _cachedBoardingPoints[scheduleId]!;
    }

    // Fallback to default points
    _cachedBoardingPoints[scheduleId] = fallbackBoardingPoints;
    return fallbackBoardingPoints;
  }

  /// Fetches dropping points for a given schedule ID
  /// API: GET https://spingoride.com/api/v1/bus/schedules/{id}/dropping-points
  Future<List<BusPointItemModel>> getDroppingPoints(int scheduleId, {bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedDroppingPoints.containsKey(scheduleId)) {
      return _cachedDroppingPoints[scheduleId]!;
    }

    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/schedules/$scheduleId/dropping-points');

      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
        final parsed = DroppingPointsResponseModel.fromJson(body);
        if (parsed.success && parsed.data.isNotEmpty) {
          _cachedDroppingPoints[scheduleId] = parsed.data;
          return parsed.data;
        }
      }
    } catch (e) {
      debugPrint('Error fetching dropping points for schedule $scheduleId: $e');
    }

    // Return cached if available
    if (_cachedDroppingPoints.containsKey(scheduleId)) {
      return _cachedDroppingPoints[scheduleId]!;
    }

    // Fallback to default points
    _cachedDroppingPoints[scheduleId] = fallbackDroppingPoints;
    return fallbackDroppingPoints;
  }

  /// Fetches both boarding and dropping points in parallel
  Future<BusPointsBundle> getPointsBundle(int scheduleId, {bool forceRefresh = false}) async {
    final results = await Future.wait([
      getBoardingPoints(scheduleId, forceRefresh: forceRefresh),
      getDroppingPoints(scheduleId, forceRefresh: forceRefresh),
    ]);

    return BusPointsBundle(
      boardingPoints: results[0],
      droppingPoints: results[1],
    );
  }
}
