// SPiNGO Logout Data Model
// Matches exact response: POST https://spingoride.com/api/v1/auth/logout

class LogoutResponseModel {
  final bool success;
  final String message;
  final dynamic data;

  LogoutResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory LogoutResponseModel.fromJson(Map<String, dynamic> json) {
    return LogoutResponseModel(
      success: json['success'] == true,
      message: json['message'] as String? ?? 'Successfully logged out.',
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data,
      };
}
