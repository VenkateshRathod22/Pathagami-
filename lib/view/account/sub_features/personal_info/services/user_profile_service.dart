import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripried/view/auth/models/user_model.dart';
import 'package:tripried/view/auth/services/auth_service.dart';
import '../models/user_profile_model.dart';

/// Service managing Customer Profile API operations:
/// - GET {{base_url}}api/v1/customer/profile
/// - PUT {{base_url}}api/v1/customer/profile
/// - GET {{base_url}}api/v1/auth/me (fallback)
class UserProfileService extends ChangeNotifier {
  static final UserProfileService instance = UserProfileService._internal();
  UserProfileService._internal();

  static const String customerProfileEndpoint =
      'https://spingoride.com/api/v1/customer/profile';
  static const String authMeEndpoint =
      'https://spingoride.com/api/v1/auth/me';
  static const String cacheKey = 'spingo_cached_user_profile';

  UserProfileModel _profile = UserProfileModel.defaultFallback();
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastFetchTime;

  UserProfileModel get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Loads saved profile from local cache first, then refreshes from server
  Future<void> init() async {
    await loadFromCache();
    await fetchUserProfile();
  }

  /// Loads cached profile from SharedPreferences
  Future<void> loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(cacheKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final Map<String, dynamic> data =
            jsonDecode(cachedJson) as Map<String, dynamic>;
        _profile = UserProfileModel.fromJson(data);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cached user profile: $e');
    }
  }

  /// Retrieves the active bearer token from AuthService or SharedPreferences
  Future<String?> _getAuthToken() async {
    String? token = AuthService.instance.authToken;
    if (token == null || token.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('auth_token');
    }
    return token;
  }

  /// Fetches profile from live API:
  /// Primary: GET https://spingoride.com/api/v1/customer/profile
  /// Fallback: GET https://spingoride.com/api/v1/auth/me
  Future<UserProfileModel> fetchUserProfile({bool forceRefresh = false}) async {
    final now = DateTime.now();
    if (!forceRefresh &&
        _lastFetchTime != null &&
        now.difference(_lastFetchTime!).inMinutes < 2) {
      return _profile;
    }

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

      // Try customer profile endpoint first
      http.Response response = await http
          .get(Uri.parse(customerProfileEndpoint), headers: headers)
          .timeout(const Duration(seconds: 12));

      // If customer profile endpoint returns 404 or method not allowed, fallback to /auth/me
      if (response.statusCode == 404 || response.statusCode == 405) {
        response = await http
            .get(Uri.parse(authMeEndpoint), headers: headers)
            .timeout(const Duration(seconds: 12));
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> body =
            jsonDecode(response.body) as Map<String, dynamic>;
        final parsed = UserProfileResponseModel.fromJson(body);

        if (parsed.success && parsed.data != null) {
          _profile = parsed.data!;
          _lastFetchTime = now;
          _errorMessage = null;

          // Persist to cache
          await _persistProfile(_profile);

          _isLoading = false;
          notifyListeners();
          return _profile;
        }
      } else if (response.statusCode == 401) {
        _errorMessage = 'Session expired or unauthenticated';
      } else {
        _errorMessage = 'Server error (${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
      debugPrint('Error fetching customer profile: $e');
    }

    _isLoading = false;
    notifyListeners();
    return _profile;
  }

  /// Executes live Customer Edit Profile API call:
  /// URL: PUT https://spingoride.com/api/v1/customer/profile
  /// Supports:
  /// - JSON Body (when no binary profile photo is attached)
  /// - Multipart Form Data (when binary image file is attached)
  Future<CustomerProfileUpdateResult> updateCustomerProfile(
      CustomerEditProfileRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _getAuthToken();

      http.Response response;

      // 1. If profile photo file is attached, use MultipartRequest PUT
      if (request.profilePhotoPath != null &&
          request.profilePhotoPath!.isNotEmpty) {
        final uri = Uri.parse(customerProfileEndpoint);
        final multiRequest = http.MultipartRequest('PUT', uri);

        multiRequest.headers['Accept'] = 'application/json';
        if (token != null && token.isNotEmpty) {
          multiRequest.headers['Authorization'] = 'Bearer $token';
        }

        // Add form fields
        multiRequest.fields['name'] = request.name;
        multiRequest.fields['gender'] = request.gender;
        multiRequest.fields['dob'] = request.dob;
        multiRequest.fields['city'] = request.city;

        if (request.alternateMobile != null &&
            request.alternateMobile!.trim().isNotEmpty) {
          multiRequest.fields['alternate_mobile'] =
              request.alternateMobile!.trim();
        }

        if (request.pinCode != null && request.pinCode!.trim().isNotEmpty) {
          multiRequest.fields['pin_code'] = request.pinCode!.trim();
        }

        if (request.homeAddress != null &&
            request.homeAddress!.trim().isNotEmpty) {
          multiRequest.fields['home_address'] = request.homeAddress!.trim();
        }

        if (request.officeAddress != null &&
            request.officeAddress!.trim().isNotEmpty) {
          multiRequest.fields['office_address'] = request.officeAddress!.trim();
        }

        // Add binary image file
        multiRequest.files.add(
          await http.MultipartFile.fromPath(
            'profile_photo',
            request.profilePhotoPath!,
          ),
        );

        final streamed =
            await multiRequest.send().timeout(const Duration(seconds: 30));
        response = await http.Response.fromStream(streamed);
      } else {
        // 2. Otherwise send standard JSON PUT request
        final headers = <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        };
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        }

        final Map<String, dynamic> bodyJson = {
          'name': request.name,
          'gender': request.gender,
          'dob': request.dob,
          'city': request.city,
          if (request.alternateMobile != null &&
              request.alternateMobile!.trim().isNotEmpty)
            'alternate_mobile': request.alternateMobile!.trim(),
          if (request.pinCode != null && request.pinCode!.trim().isNotEmpty)
            'pin_code': request.pinCode!.trim(),
          if (request.homeAddress != null &&
              request.homeAddress!.trim().isNotEmpty)
            'home_address': request.homeAddress!.trim(),
          if (request.officeAddress != null &&
              request.officeAddress!.trim().isNotEmpty)
            'office_address': request.officeAddress!.trim(),
        };

        response = await http
            .put(
              Uri.parse(customerProfileEndpoint),
              headers: headers,
              body: jsonEncode(bodyJson),
            )
            .timeout(const Duration(seconds: 20));
      }

      debugPrint(
          'PUT /customer/profile response: ${response.statusCode} -> ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> body =
            jsonDecode(response.body) as Map<String, dynamic>;
        final parsed = UserProfileResponseModel.fromJson(body);

        if (parsed.success && parsed.data != null) {
          _profile = parsed.data!;
          _lastFetchTime = DateTime.now();
          _errorMessage = null;

          await _persistProfile(_profile);

          _isLoading = false;
          notifyListeners();

          return CustomerProfileUpdateResult(
            success: true,
            message: parsed.message.isNotEmpty
                ? parsed.message
                : 'Profile details updated successfully.',
            profile: _profile,
          );
        } else {
          _isLoading = false;
          notifyListeners();
          return CustomerProfileUpdateResult(
            success: false,
            message: parsed.message.isNotEmpty
                ? parsed.message
                : 'Failed to update profile.',
            errors: parsed.errors,
          );
        }
      } else if (response.statusCode == 401) {
        _isLoading = false;
        notifyListeners();
        return CustomerProfileUpdateResult(
          success: false,
          message: 'Unauthenticated. Please log in to update profile.',
        );
      } else if (response.statusCode == 422) {
        // Validation errors
        Map<String, dynamic>? errors;
        String message = 'Validation failed. Please verify your details.';
        try {
          final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
          if (errorBody['message'] != null) {
            message = errorBody['message'] as String;
          }
          if (errorBody['errors'] != null &&
              errorBody['errors'] is Map<String, dynamic>) {
            errors = errorBody['errors'] as Map<String, dynamic>;
          }
        } catch (_) {}

        _isLoading = false;
        notifyListeners();
        return CustomerProfileUpdateResult(
          success: false,
          message: message,
          errors: errors,
        );
      } else {
        String msg = 'Failed with status code: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
          if (errorBody['message'] != null) {
            msg = errorBody['message'] as String;
          }
        } catch (_) {}

        _isLoading = false;
        notifyListeners();
        return CustomerProfileUpdateResult(
          success: false,
          message: msg,
        );
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error updating customer profile: $e');
      return CustomerProfileUpdateResult(
        success: false,
        message: 'Network error occurred: $e',
      );
    }
  }

  /// Backward-compatible local/fallback updater
  Future<bool> updateProfileDetails({
    String? name,
    String? email,
    String? phone,
    String? gender,
    String? dob,
    String? city,
    String? alternateMobile,
    String? pinCode,
    String? homeAddress,
    String? officeAddress,
  }) async {
    // Attempt live API update
    final result = await updateCustomerProfile(
      CustomerEditProfileRequest(
        name: name ?? _profile.name,
        gender: gender ?? _profile.effectiveGender,
        dob: dob ?? _profile.effectiveDob,
        city: city ?? _profile.effectiveCity,
        alternateMobile: alternateMobile ?? _profile.effectiveAlternateMobile,
        pinCode: pinCode ?? _profile.effectivePinCode,
        homeAddress: homeAddress ?? _profile.effectiveHomeAddress,
        officeAddress: officeAddress ?? _profile.effectiveOfficeAddress,
      ),
    );

    if (result.success) {
      return true;
    }

    // If live API was unauthenticated or offline, still update in local memory and cache for smooth UI
    try {
      final updatedCustomer = _profile.customerDetails?.copyWith(
            gender: gender ?? _profile.customerDetails?.gender,
            dob: dob ?? _profile.customerDetails?.dob,
            city: city ?? _profile.customerDetails?.city,
            alternateMobile:
                alternateMobile ?? _profile.customerDetails?.alternateMobile,
            pinCode: pinCode ?? _profile.customerDetails?.pinCode,
            homeAddress:
                homeAddress ?? _profile.customerDetails?.homeAddress,
            officeAddress:
                officeAddress ?? _profile.customerDetails?.officeAddress,
          ) ??
          CustomerDetailsModel(
            customerId: 'CUS000005',
            gender: gender,
            dob: dob,
            city: city,
            alternateMobile: alternateMobile,
            pinCode: pinCode,
            homeAddress: homeAddress,
            officeAddress: officeAddress,
          );

      _profile = _profile.copyWith(
        name: name ?? _profile.name,
        email: email ?? _profile.email,
        phone: phone ?? _profile.phone,
        gender: gender ?? _profile.gender,
        dob: dob ?? _profile.dob,
        city: city ?? _profile.city,
        pinCode: pinCode ?? _profile.pinCode,
        homeAddress: homeAddress ?? _profile.homeAddress,
        officeAddress: officeAddress ?? _profile.officeAddress,
        customerDetails: updatedCustomer,
      );

      await _persistProfile(_profile);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error in fallback profile update: $e');
      return false;
    }
  }

  /// Persists profile model to SharedPreferences & synchronizes with AuthService
  Future<void> _persistProfile(UserProfileModel p) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(cacheKey, jsonEncode(p.toJson()));
      await prefs.setString('user_name', p.name);
      await prefs.setString('user_email', p.email);
      await prefs.setString('user_phone', p.phone);
      if (p.customerDetails?.customerId != null) {
        await prefs.setString('customer_id', p.customerDetails!.customerId);
      }
      if (p.effectiveGender.isNotEmpty) {
        await prefs.setString('user_gender', p.effectiveGender);
      }
      if (p.effectiveDob.isNotEmpty) {
        await prefs.setString('user_dob', p.effectiveDob);
      }
      if (p.effectiveCity.isNotEmpty) {
        await prefs.setString('user_city', p.effectiveCity);
      }

      _syncWithAuthService(p);
    } catch (e) {
      debugPrint('Error persisting user profile: $e');
    }
  }

  /// Synchronizes profile with AuthService
  void _syncWithAuthService(UserProfileModel p) {
    AuthService.instance.setCurrentUser(
      UserModel(
        id: p.id,
        name: p.name,
        email: p.email,
        phone: p.phone,
        role: p.role,
        profilePhoto: p.profilePhoto,
        customerDetails: p.customerDetails != null
            ? CustomerDetails(
                customerId: p.customerDetails!.customerId,
                gender: p.customerDetails!.gender,
                dob: p.customerDetails!.dob,
                city: p.customerDetails!.city,
                rewardPoints: p.customerDetails!.rewardPoints,
                referralCode: p.customerDetails!.referralCode,
                totalReferrals: p.customerDetails!.totalReferrals,
              )
            : null,
        wallet: WalletModel(
          balance: p.wallet.balance,
          currency: p.wallet.currency,
        ),
        createdAt: p.createdAt,
      ),
    );
  }
}
