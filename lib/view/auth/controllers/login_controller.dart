import 'package:flutter/material.dart';
import '../models/login_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Controller managing Login state, API communication, and validation
class LoginController extends ChangeNotifier {
  final TextEditingController loginInputController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  LoginResponseModel? _loginResponse;
  UserModel? _loggedInUser;

  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  String? get errorMessage => _errorMessage;
  LoginResponseModel? get loginResponse => _loginResponse;
  UserModel? get loggedInUser => _loggedInUser;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Prefills customer credentials from the provided test data
  void quickFillCustomer({String login = '9695541750', String password = ''}) {
    loginInputController.text = login;
    if (password.isNotEmpty) {
      passwordController.text = password;
    }
    notifyListeners();
  }

  /// Executes live login API call: POST https://spingoride.com/api/v1/auth/login
  Future<bool> login() async {
    final loginInput = loginInputController.text.trim();
    final password = passwordController.text;

    // Client-side validations
    if (loginInput.isEmpty) {
      _errorMessage = 'Please enter your mobile number or email address';
      notifyListeners();
      return false;
    }

    if (password.isEmpty) {
      _errorMessage = 'Please enter your password';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await AuthService.instance.login(
        login: loginInput,
        password: password,
      );

      _loginResponse = response;
      _isLoading = false;

      if (response.success && response.data != null) {
        _loggedInUser = response.data!.user;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        // Extract server error message
        String msg = response.message;
        if (response.errors != null && response.errors!.isNotEmpty) {
          final firstErrorList = response.errors!.values.first;
          if (firstErrorList is List && firstErrorList.isNotEmpty) {
            msg = firstErrorList.first.toString();
          }
        }
        _errorMessage = msg.isNotEmpty ? msg : 'Login failed. Please check your credentials.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'An unexpected error occurred: $e';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    loginInputController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
