// SPiNGO Login Models
// Matches the exact response structure of https://spingoride.com/api/v1/auth/login

import 'user_model.dart';

class LoginRequestModel {
  final String login;
  final String password;

  LoginRequestModel({
    required this.login,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'login': login.trim(),
      'password': password,
    };
    if (login.contains('@')) {
      map['email'] = login.trim();
    } else {
      map['phone'] = login.trim();
    }
    return map;
  }
}

class LoginResponseModel {
  final bool success;
  final String message;
  final LoginDataModel? data;
  final Map<String, dynamic>? errors;

  LoginResponseModel({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      success: json['success'] == true,
      message: json['message'] as String? ?? '',
      data: json['data'] != null ? LoginDataModel.fromJson(json['data'] as Map<String, dynamic>) : null,
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }
}

class LoginDataModel {
  final String token;
  final String tokenType;
  final UserModel user;

  LoginDataModel({
    required this.token,
    required this.tokenType,
    required this.user,
  });

  factory LoginDataModel.fromJson(Map<String, dynamic> json) {
    return LoginDataModel(
      token: json['token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? 'Bearer',
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }
}
