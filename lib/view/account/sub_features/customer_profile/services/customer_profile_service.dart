import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripried/view/auth/models/user_model.dart';
import 'package:tripried/view/auth/services/auth_service.dart';
import '../models/customer_profile_model.dart';

/// Service managing Customer Profile Live API operations:
/// - GET {{base_url}}/customer/profile
/// - GET {{base_url}}/auth/me (fallback)
/// - PUT {{base_url}}/customer/profile (update)
class CustomerProfileService extends ChangeNotifier {
  static final CustomerProfileService instance =
      CustomerProfileService._internal();
  CustomerProfileService._internal();

  static const String customerProfileEndpoint =
      'https://spingoride.com/api/v1/customer/profile';
  static const String authMeEndpoint =
      'https://spingoride.com/api/v1/auth/me';
  static const String cacheKey = 'spingo_cached_customer_profile';

  CustomerProfileModel _profile = CustomerProfileModel.defaultFallback();
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastFetchTime;
  bool _isLiveSynced = false;

  CustomerProfileModel get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get lastFetchTime => _lastFetchTime;
  bool get isLiveSynced => _isLiveSynced;

  /// Initializes profile from memory/cache and then fetches fresh data
  Future<void> init() async {
    await loadInitialData();
    await fetchProfile();
  }

  /// Loads initial data from AuthService in-memory login data or SharedPreferences cache
  Future<void> loadInitialData() async {
    // 1. First, check if AuthService has currentUser from recent login
    final authUser = AuthService.instance.currentUser;
    if (authUser != null && authUser.id > 0) {
      _applyAuthUserToProfile(authUser);
    }

    // 2. Load cached profile JSON if available
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(cacheKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final Map<String, dynamic> data =
            jsonDecode(cachedJson) as Map<String, dynamic>;
        _profile = CustomerProfileModel.fromJson(data);
        notifyListeners();
      } else if (authUser == null) {
        // Fallback to basic prefs saved at login
        final name = prefs.getString('user_name');
        final phone = prefs.getString('user_phone');
        final email = prefs.getString('user_email');
        final customerId = prefs.getString('customer_id');
        final gender = prefs.getString('user_gender');
        final dob = prefs.getString('user_dob');
        final city = prefs.getString('user_city');

        if (name != null || phone != null) {
          _profile = _profile.copyWith(
            name: name ?? _profile.name,
            phone: phone ?? _profile.phone,
            email: email ?? _profile.email,
            gender: gender ?? _profile.gender,
            city: city ?? _profile.city,
            dob: dob ?? _profile.dob,
            customerDetails: _profile.customerDetails?.copyWith(
              customerId: customerId,
              gender: gender,
              dob: dob,
              city: city,
            ),
          );
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading cached customer profile: $e');
    }
  }

  void _applyAuthUserToProfile(UserModel u) {
    _profile = CustomerProfileModel(
      id: u.id,
      name: u.name.isNotEmpty ? u.name : _profile.name,
      email: u.email.isNotEmpty ? u.email : _profile.email,
      phone: u.phone.isNotEmpty ? u.phone : _profile.phone,
      role: u.role.isNotEmpty ? u.role : _profile.role,
      profilePhoto: u.profilePhoto ?? _profile.profilePhoto,
      gender: u.customerDetails?.gender ?? _profile.gender,
      city: u.customerDetails?.city ?? _profile.city,
      dob: u.customerDetails?.dob ?? _profile.dob,
      address: _profile.address,
      homeAddress: _profile.homeAddress,
      officeAddress: _profile.officeAddress,
      pinCode: _profile.pinCode,
      customerDetails: CustomerProfileDetailsModel(
        customerId: u.customerDetails?.customerId ?? _profile.effectiveCustomerId,
        gender: u.customerDetails?.gender ?? _profile.gender,
        dob: u.customerDetails?.dob ?? _profile.dob,
        city: u.customerDetails?.city ?? _profile.city,
        alternateMobile: _profile.effectiveAlternateMobile,
        homeAddress: _profile.effectiveHomeAddress,
        officeAddress: _profile.effectiveOfficeAddress,
        pinCode: _profile.effectivePinCode,
        rewardPoints: u.customerDetails?.rewardPoints ?? _profile.customerDetails?.rewardPoints ?? 0,
        referralCode: u.customerDetails?.referralCode ?? _profile.customerDetails?.referralCode,
        totalReferrals: u.customerDetails?.totalReferrals ?? _profile.customerDetails?.totalReferrals ?? 0,
      ),
      addresses: _profile.addresses,
      wallet: u.wallet != null
          ? CustomerProfileWalletModel(
              balance: u.wallet!.balance.toDouble(),
              currency: u.wallet!.currency,
            )
          : _profile.wallet,
      createdAt: u.createdAt ?? _profile.createdAt,
    );
    notifyListeners();
  }

  /// Retrieves active Bearer token
  Future<String?> _getAuthToken() async {
    String? token = AuthService.instance.authToken;
    if (token == null || token.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('auth_token');
    }
    return token;
  }

  /// Fetches profile from live API
  Future<CustomerProfileModel> fetchProfile({bool forceRefresh = false}) async {
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

      // Try GET /customer/profile first
      http.Response response = await http
          .get(Uri.parse(customerProfileEndpoint), headers: headers)
          .timeout(const Duration(seconds: 12));

      // Fallback to /auth/me if 404 or 405
      if (response.statusCode == 404 || response.statusCode == 405) {
        response = await http
            .get(Uri.parse(authMeEndpoint), headers: headers)
            .timeout(const Duration(seconds: 12));
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> body =
            jsonDecode(response.body) as Map<String, dynamic>;
        final parsed = CustomerProfileResponseModel.fromJson(body);

        if (parsed.success && parsed.data != null) {
          _profile = parsed.data!;
          _lastFetchTime = now;
          _isLiveSynced = true;
          _errorMessage = null;

          await _persistProfile(_profile);
          _isLoading = false;
          notifyListeners();
          return _profile;
        }
      } else if (response.statusCode == 401) {
        _errorMessage = 'Session expired. Please log in again.';
        _isLiveSynced = false;
      } else {
        _errorMessage = 'Server response: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Network connection error: $e';
      debugPrint('Error fetching customer profile: $e');
    }

    _isLoading = false;
    notifyListeners();
    return _profile;
  }

  /// Updates customer profile via live PUT API
  Future<CustomerProfileUpdateResult> updateProfile(
      CustomerProfileUpdateRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _getAuthToken();
      http.Response response;

      // 1. If image file is attached -> Multipart PUT
      if (request.profilePhotoPath != null &&
          request.profilePhotoPath!.isNotEmpty) {
        final uri = Uri.parse(customerProfileEndpoint);
        final multiRequest = http.MultipartRequest('PUT', uri);

        multiRequest.headers['Accept'] = 'application/json';
        if (token != null && token.isNotEmpty) {
          multiRequest.headers['Authorization'] = 'Bearer $token';
        }

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
        // 2. Standard JSON PUT
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> body =
            jsonDecode(response.body) as Map<String, dynamic>;
        final parsed = CustomerProfileResponseModel.fromJson(body);

        if (parsed.success && parsed.data != null) {
          _profile = parsed.data!;
          _lastFetchTime = DateTime.now();
          _isLiveSynced = true;
          _errorMessage = null;

          await _persistProfile(_profile);
          _isLoading = false;
          notifyListeners();

          return CustomerProfileUpdateResult(
            success: true,
            message: parsed.message.isNotEmpty
                ? parsed.message
                : 'Customer profile updated successfully.',
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
      } else if (response.statusCode == 422) {
        Map<String, dynamic>? errs;
        String msg = 'Validation error. Please verify input fields.';
        try {
          final errBody = jsonDecode(response.body) as Map<String, dynamic>;
          if (errBody['message'] != null) msg = errBody['message'].toString();
          if (errBody['errors'] is Map<String, dynamic>) {
            errs = errBody['errors'] as Map<String, dynamic>;
          }
        } catch (_) {}

        _isLoading = false;
        notifyListeners();
        return CustomerProfileUpdateResult(
          success: false,
          message: msg,
          errors: errs,
        );
      } else {
        _isLoading = false;
        notifyListeners();
        return CustomerProfileUpdateResult(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return CustomerProfileUpdateResult(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  /// Persists to SharedPreferences and updates AuthService
  Future<void> _persistProfile(CustomerProfileModel p) async {
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

      // Sync with AuthService
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
            balance: p.wallet.balance.toInt(),
            currency: p.wallet.currency,
          ),
          createdAt: p.createdAt,
        ),
      );
    } catch (e) {
      debugPrint('Error persisting customer profile: $e');
    }
  }
}
