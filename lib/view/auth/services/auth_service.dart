import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/login_model.dart';
import '../models/user_model.dart';
import '../models/logout_model.dart';

class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  static const String baseUrl = 'https://spingoride.com/api/v1';

  UserModel? _currentUser;
  String? _authToken;

  UserModel? get currentUser => _currentUser;
  String? get authToken => _authToken;
  bool get isAuthenticated => _authToken != null && _authToken!.isNotEmpty;

  void setCurrentUser(UserModel? user) {
    _currentUser = user;
  }

  /// Loads saved authentication data from SharedPreferences
  Future<void> loadSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    final name = prefs.getString('user_name');
    final phone = prefs.getString('user_phone');
    final email = prefs.getString('user_email');
    final customerId = prefs.getString('customer_id');
    final gender = prefs.getString('user_gender');
    final dob = prefs.getString('user_dob');


    

    if (name != null && phone != null && email != null) {
      _currentUser = UserModel(
        id: _currentUser?.id ?? 0,
        name: name,
        email: email,
        phone: phone,
        role: 'customer',
        customerDetails: customerId != null || gender != null || dob != null
            ? CustomerDetails(
                customerId: customerId ?? '',
                gender: gender,
                dob: dob,
              )
            : null,
      );
    }
  }

  /// Logs in an existing customer with the SPiNGO API
  Future<LoginResponseModel> login({
    required String login,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login');

    final requestBody = LoginRequestModel(
      login: login,
      password: password,
    ).toJson();

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 15));

      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
      final parsed = LoginResponseModel.fromJson(data);

      if (parsed.success && parsed.data != null) {
        _currentUser = parsed.data!.user;
        _authToken = parsed.data!.token;

        // Persist token and user details
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', parsed.data!.token);
        await prefs.setString('user_name', parsed.data!.user.name);
        await prefs.setString('user_phone', parsed.data!.user.phone);
        await prefs.setString('user_email', parsed.data!.user.email);
        if (parsed.data!.user.customerDetails?.customerId != null) {
          await prefs.setString('customer_id', parsed.data!.user.customerDetails!.customerId);
        }
      }

      return parsed;
    } catch (e) {
      return LoginResponseModel(
        success: false,
        message: 'Network error: Please check your internet connection ($e)',
      );
    }
  }

  /// Registers a new customer with the SPiNGO API
  Future<UserRegistrationResponse> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    String? gender,
    String? city,
    String? referralCode,
  }) async {
    final url = Uri.parse('$baseUrl/auth/register');

    final payload = <String, dynamic>{
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'password': password,
      'password_confirmation': passwordConfirmation,
    };

    if (gender != null && gender.isNotEmpty) {
      payload['gender'] = gender;
    }
    if (city != null && city.isNotEmpty) {
      payload['city'] = city.trim();
    }
    if (referralCode != null && referralCode.trim().isNotEmpty) {
      payload['referral_code'] = referralCode.trim();
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 15));

      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
      final parsed = UserRegistrationResponse.fromJson(data);

      if (parsed.success && parsed.data != null) {
        _currentUser = parsed.data!.user;
        _authToken = parsed.data!.token;

        // Persist token and user details
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', parsed.data!.token);
        await prefs.setString('user_name', parsed.data!.user.name);
        await prefs.setString('user_phone', parsed.data!.user.phone);
        await prefs.setString('user_email', parsed.data!.user.email);
        if (parsed.data!.user.customerDetails?.customerId != null) {
          await prefs.setString('customer_id', parsed.data!.user.customerDetails!.customerId);
        }
      }

      return parsed;
    } catch (e) {
      return UserRegistrationResponse(
        success: false,
        message: 'Network error: Please check your internet connection ($e)',
      );
    }
  }

  /// Fetches profile details from GET https://spingoride.com/api/v1/auth/me
  Future<UserModel?> getProfile() async {
    final url = Uri.parse('$baseUrl/auth/me');

    try {
      if (_authToken == null || _authToken!.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        _authToken = prefs.getString('auth_token');
      }

      final headers = <String, String>{
        'Accept': 'application/json',
      };
      if (_authToken != null && _authToken!.isNotEmpty) {
        headers['Authorization'] = 'Bearer $_authToken';
      }

      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['data'] != null) {
          _currentUser = UserModel.fromJson(body['data'] as Map<String, dynamic>);
          return _currentUser;
        }
      }
    } catch (e) {
      // Error fetching profile
    }
    return _currentUser;
  }

  /// Logs out the user via POST https://spingoride.com/api/v1/auth/logout and clears session
  Future<LogoutResponseModel> logout() async {
    final url = Uri.parse('$baseUrl/auth/logout');
    String message = 'Successfully logged out.';
    bool success = true;

    try {
      if (_authToken == null || _authToken!.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        _authToken = prefs.getString('auth_token');
      }

      final headers = <String, String>{
        'Accept': 'application/json',
      };
      if (_authToken != null && _authToken!.isNotEmpty) {
        headers['Authorization'] = 'Bearer $_authToken';
      }

      final response = await http
          .post(url, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
        final parsed = LogoutResponseModel.fromJson(body);
        success = parsed.success;
        message = parsed.message;
      }
    } catch (e) {
      // Network or parsing error during logout
    }

    _currentUser = null;
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_name');
    await prefs.remove('user_phone');
    await prefs.remove('user_email');
    await prefs.remove('customer_id');
    await prefs.remove('spingo_cached_user_profile');

    return LogoutResponseModel(
      success: success,
      message: message,
      data: null,
    );
  }

  /// Changes user password via POST https://spingoride.com/api/v1/auth/change-password
  Future<ChangePasswordResponseModel> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final url = Uri.parse('$baseUrl/auth/change-password');

    try {
      if (_authToken == null || _authToken!.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        _authToken = prefs.getString('auth_token');
      }

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      if (_authToken != null && _authToken!.isNotEmpty) {
        headers['Authorization'] = 'Bearer $_authToken';
      }

      final payload = {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPasswordConfirmation,
      };

      final response = await http
          .post(url, headers: headers, body: jsonEncode(payload))
          .timeout(const Duration(seconds: 15));

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ChangePasswordResponseModel.fromJson(data);
      } else {
        return ChangePasswordResponseModel(
          success: false,
          message: data['message']?.toString() ??
              'Failed to change password (${response.statusCode})',
          errors: data['errors'] is Map<String, dynamic>
              ? data['errors'] as Map<String, dynamic>
              : null,
        );
      }
    } catch (e) {
      return ChangePasswordResponseModel(
        success: false,
        message: 'Network error: Please check your internet connection ($e)',
      );
    }
  }
}

class ChangePasswordResponseModel {
  final bool success;
  final String message;
  final dynamic data;
  final Map<String, dynamic>? errors;

  ChangePasswordResponseModel({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory ChangePasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return ChangePasswordResponseModel(
      success: json['success'] == true,
      message: json['message'] as String? ?? '',
      data: json['data'],
      errors: json['errors'] is Map<String, dynamic>
          ? json['errors'] as Map<String, dynamic>
          : null,
    );
  }
}

