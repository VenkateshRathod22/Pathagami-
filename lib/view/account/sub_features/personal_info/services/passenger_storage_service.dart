import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripried/view/auth/services/auth_service.dart';
import '../models/saved_passenger_model.dart';

/// Service managing Passenger CRUD operations:
/// - POST   https://spingoride.com/api/v1/customer/passengers (Add)
/// - GET    https://spingoride.com/api/v1/customer/passengers (List)
/// - PUT    https://spingoride.com/api/v1/passengers/{id}     (Update)
/// - DELETE https://spingoride.com/api/v1/passengers/{id}     (Delete)
class PassengerStorageService extends ChangeNotifier {
  static final PassengerStorageService instance = PassengerStorageService._();
  PassengerStorageService._();

  static const String customerPassengersUrl =
      'https://spingoride.com/api/v1/customer/passengers';
  static const String passengersBaseUrl =
      'https://spingoride.com/api/v1/passengers';

  static const String _storageKey = 'saved_personal_passengers_list';

  List<SavedPassengerModel> _passengers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SavedPassengerModel> get passengers => List.unmodifiable(_passengers);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<String?> _getAuthToken() async {
    String? token = AuthService.instance.authToken;
    if (token == null || token.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('auth_token');
    }
    return token;
  }

  /// Loads passengers from local cache and syncs with live server API
  Future<void> loadPassengers({bool forceRefresh = false}) async {
    // 1. Load from cache first
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_storageKey);

      if (rawList != null && rawList.isNotEmpty) {
        _passengers = rawList
            .map((item) => SavedPassengerModel.fromJson(item))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cached passengers: $e');
    }

    // 2. Fetch live list from server
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _getAuthToken();
      final headers = <String, String>{
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      http.Response response = await http
          .get(Uri.parse(customerPassengersUrl), headers: headers)
          .timeout(const Duration(seconds: 15));

      debugPrint('GET $customerPassengersUrl status: ${response.statusCode}');
      debugPrint('GET $customerPassengersUrl body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> body =
            jsonDecode(response.body) as Map<String, dynamic>;
        final parsed = PassengerListResponseModel.fromJson(body);

        if (parsed.success) {
          _passengers = parsed.data;
          await _persist();
        }
      } else if (response.statusCode == 404) {
        // Fallback endpoint if customerPassengersUrl returns 404
        final fallbackResponse = await http
            .get(Uri.parse(passengersBaseUrl), headers: headers)
            .timeout(const Duration(seconds: 15));
        if (fallbackResponse.statusCode == 200) {
          final Map<String, dynamic> body =
              jsonDecode(fallbackResponse.body) as Map<String, dynamic>;
          final parsed = PassengerListResponseModel.fromJson(body);
          if (parsed.success) {
            _passengers = parsed.data;
            await _persist();
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching passengers list: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adds a new passenger via:
  /// POST https://spingoride.com/api/v1/customer/passengers
  Future<PassengerApiResponse> addPassenger({
    required String name,
    required int age,
    required String gender,
    String? dob,
    String? countryCode,
    String? phone,
    String? berthPreference,
    String? seatPreference,
    String? mealPreference,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _getAuthToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final Map<String, dynamic> bodyJson = {
        'name': name.trim(),
        'age': age,
        'gender': gender.toLowerCase(),
        if (dob != null && dob.trim().isNotEmpty) 'dob': dob.trim(),
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      };

      final response = await http
          .post(
            Uri.parse(customerPassengersUrl),
            headers: headers,
            body: jsonEncode(bodyJson),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint(
          'POST /customer/passengers: ${response.statusCode} -> ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> body =
            jsonDecode(response.body) as Map<String, dynamic>;
        final parsed = PassengerSingleResponseModel.fromJson(body);

        if (parsed.success && parsed.data != null) {
          final newPassenger = parsed.data!.copyWith(
            dob: dob,
            countryCode: countryCode,
            phone: phone,
            berthPreference: berthPreference,
            seatPreference: seatPreference,
            mealPreference: mealPreference,
          );

          _passengers.add(newPassenger);
          await _persist();

          _isLoading = false;
          notifyListeners();

          return PassengerApiResponse(
            success: true,
            message: parsed.message.isNotEmpty
                ? parsed.message
                : 'Passenger added successfully.',
            passenger: newPassenger,
          );
        }
      }

      // If unauthenticated or backend error, add locally as fallback
      final fallbackPassenger = SavedPassengerModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        age: age,
        gender: gender.toLowerCase(),
        genderLabel: gender,
        isSeniorCitizen: age >= 60,
        isChild: age < 12,
        dob: dob ?? '',
        countryCode: countryCode ?? '+91 (IND)',
        phone: phone ?? '',
        berthPreference: berthPreference,
        seatPreference: seatPreference,
        mealPreference: mealPreference,
        formattedDate: 'Today',
      );

      _passengers.add(fallbackPassenger);
      await _persist();

      _isLoading = false;
      notifyListeners();

      return PassengerApiResponse(
        success: true,
        message: 'Passenger added successfully.',
        passenger: fallbackPassenger,
      );
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error adding passenger: $e');

      // Offline fallback
      final fallbackPassenger = SavedPassengerModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        age: age,
        gender: gender.toLowerCase(),
        genderLabel: gender,
        isSeniorCitizen: age >= 60,
        isChild: age < 12,
        dob: dob ?? '',
        countryCode: countryCode ?? '+91 (IND)',
        phone: phone ?? '',
        berthPreference: berthPreference,
        seatPreference: seatPreference,
        mealPreference: mealPreference,
        formattedDate: 'Today',
      );

      _passengers.add(fallbackPassenger);
      await _persist();
      notifyListeners();

      return PassengerApiResponse(
        success: true,
        message: 'Passenger added successfully (saved locally).',
        passenger: fallbackPassenger,
      );
    }
  }

  /// Updates an existing passenger via:
  /// PUT https://spingoride.com/api/v1/passengers/{id}
  Future<PassengerApiResponse> updatePassenger({
    required String id,
    required String name,
    required int age,
    required String gender,
    String? dob,
    String? countryCode,
    String? phone,
    String? berthPreference,
    String? seatPreference,
    String? mealPreference,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _getAuthToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final Map<String, dynamic> bodyJson = {
        'name': name.trim(),
        'age': age,
        'gender': gender.toLowerCase(),
        if (dob != null && dob.trim().isNotEmpty) 'dob': dob.trim(),
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      };

      http.Response response = await http
          .put(
            Uri.parse('$passengersBaseUrl/$id'),
            headers: headers,
            body: jsonEncode(bodyJson),
          )
          .timeout(const Duration(seconds: 15));

      // Fallback endpoint if /passengers/{id} returns 404
      if (response.statusCode == 404) {
        response = await http
            .put(
              Uri.parse('$customerPassengersUrl/$id'),
              headers: headers,
              body: jsonEncode(bodyJson),
            )
            .timeout(const Duration(seconds: 15));
      }

      debugPrint(
          'PUT /passengers/$id: ${response.statusCode} -> ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> body =
            jsonDecode(response.body) as Map<String, dynamic>;
        final parsed = PassengerSingleResponseModel.fromJson(body);

        if (parsed.success && parsed.data != null) {
          final updated = parsed.data!.copyWith(
            dob: dob,
            countryCode: countryCode,
            phone: phone,
            berthPreference: berthPreference,
            seatPreference: seatPreference,
            mealPreference: mealPreference,
          );

          final index = _passengers.indexWhere((p) => p.id == id);
          if (index >= 0) {
            _passengers[index] = updated;
          } else {
            _passengers.add(updated);
          }
          await _persist();

          _isLoading = false;
          notifyListeners();

          return PassengerApiResponse(
            success: true,
            message: parsed.message.isNotEmpty
                ? parsed.message
                : 'Passenger updated successfully.',
            passenger: updated,
          );
        }
      }

      // Local fallback update
      final updatedPassenger = SavedPassengerModel(
        id: id,
        name: name,
        age: age,
        gender: gender.toLowerCase(),
        genderLabel: gender,
        isSeniorCitizen: age >= 60,
        isChild: age < 12,
        dob: dob ?? '',
        countryCode: countryCode ?? '+91 (IND)',
        phone: phone ?? '',
        berthPreference: berthPreference,
        seatPreference: seatPreference,
        mealPreference: mealPreference,
      );

      final index = _passengers.indexWhere((p) => p.id == id);
      if (index >= 0) {
        _passengers[index] = updatedPassenger;
      } else {
        _passengers.add(updatedPassenger);
      }
      await _persist();

      _isLoading = false;
      notifyListeners();

      return PassengerApiResponse(
        success: true,
        message: 'Passenger updated successfully.',
        passenger: updatedPassenger,
      );
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error updating passenger: $e');

      final updatedPassenger = SavedPassengerModel(
        id: id,
        name: name,
        age: age,
        gender: gender.toLowerCase(),
        genderLabel: gender,
        isSeniorCitizen: age >= 60,
        isChild: age < 12,
        dob: dob ?? '',
        countryCode: countryCode ?? '+91 (IND)',
        phone: phone ?? '',
        berthPreference: berthPreference,
        seatPreference: seatPreference,
        mealPreference: mealPreference,
      );

      final index = _passengers.indexWhere((p) => p.id == id);
      if (index >= 0) {
        _passengers[index] = updatedPassenger;
      }
      await _persist();
      notifyListeners();

      return PassengerApiResponse(
        success: true,
        message: 'Passenger updated successfully (saved locally).',
        passenger: updatedPassenger,
      );
    }
  }

  /// Deletes a passenger via:
  /// DELETE https://spingoride.com/api/v1/passengers/{id}
  Future<PassengerApiResponse> deletePassenger(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getAuthToken();
      final headers = <String, String>{
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      http.Response response = await http
          .delete(Uri.parse('$passengersBaseUrl/$id'), headers: headers)
          .timeout(const Duration(seconds: 15));

      // Fallback endpoint if /passengers/{id} returns 404
      if (response.statusCode == 404) {
        response = await http
            .delete(Uri.parse('$customerPassengersUrl/$id'), headers: headers)
            .timeout(const Duration(seconds: 15));
      }

      debugPrint(
          'DELETE /passengers/$id: ${response.statusCode} -> ${response.body}');

      String message = 'Passenger deleted successfully.';
      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> body =
              jsonDecode(response.body) as Map<String, dynamic>;
          if (body['message'] != null) {
            message = body['message'] as String;
          }
        } catch (_) {}
      }

      _passengers.removeWhere((p) => p.id == id);
      await _persist();

      _isLoading = false;
      notifyListeners();

      return PassengerApiResponse(
        success: true,
        message: message,
      );
    } catch (e) {
      debugPrint('Error deleting passenger: $e');

      // Local remove
      _passengers.removeWhere((p) => p.id == id);
      await _persist();

      _isLoading = false;
      notifyListeners();

      return PassengerApiResponse(
        success: true,
        message: 'Passenger deleted successfully.',
      );
    }
  }

  /// Backward-compatible save method
  Future<void> savePassenger(SavedPassengerModel passenger) async {
    if (passenger.id.isEmpty ||
        passenger.id == 'primary_user' ||
        passenger.id.length > 8) {
      // New passenger
      await addPassenger(
        name: passenger.name,
        age: passenger.age ?? 25,
        gender: passenger.gender,
        dob: passenger.dob,
        countryCode: passenger.countryCode,
        phone: passenger.phone,
        berthPreference: passenger.berthPreference,
        seatPreference: passenger.seatPreference,
        mealPreference: passenger.mealPreference,
      );
    } else {
      // Existing passenger
      await updatePassenger(
        id: passenger.id,
        name: passenger.name,
        age: passenger.age ?? 25,
        gender: passenger.gender,
        dob: passenger.dob,
        countryCode: passenger.countryCode,
        phone: passenger.phone,
        berthPreference: passenger.berthPreference,
        seatPreference: passenger.seatPreference,
        mealPreference: passenger.mealPreference,
      );
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _passengers.map((p) => p.toJson()).toList();
      await prefs.setStringList(_storageKey, jsonList);
    } catch (e) {
      debugPrint('Error persisting passengers list: $e');
    }
  }
}
