// SPiNGO User & Auth Data Models
// Matches the exact response structure of https://spingoride.com/api/v1/auth/register

class UserRegistrationResponse {
  final bool success;
  final String message;
  final UserRegistrationData? data;
  final Map<String, dynamic>? errors;

  UserRegistrationResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory UserRegistrationResponse.fromJson(Map<String, dynamic> json) {
    return UserRegistrationResponse(
      success: json['success'] == true,
      message: json['message'] as String? ?? '',
      data: json['data'] != null ? UserRegistrationData.fromJson(json['data'] as Map<String, dynamic>) : null,
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }
}

class UserRegistrationData {
  final String token;
  final String tokenType;
  final UserModel user;

  UserRegistrationData({
    required this.token,
    required this.tokenType,
    required this.user,
  });

  factory UserRegistrationData.fromJson(Map<String, dynamic> json) {
    return UserRegistrationData(
      token: json['token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? 'Bearer',
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class UserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? profilePhoto;
  final CustomerDetails? customerDetails;
  final WalletModel? wallet;
  final String? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.profilePhoto,
    this.customerDetails,
    this.wallet,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? 'customer',
      profilePhoto: json['profile_photo'] as String?,
      customerDetails: json['customer_details'] != null
          ? CustomerDetails.fromJson(json['customer_details'] as Map<String, dynamic>)
          : null,
      wallet: json['wallet'] != null ? WalletModel.fromJson(json['wallet'] as Map<String, dynamic>) : null,
      createdAt: json['created_at'] as String?,
    );
  }
}

class CustomerDetails {
  final String customerId;
  final String? gender;
  final String? dob;
  final String? city;
  final int rewardPoints;
  final String? referralCode;
  final int totalReferrals;

  CustomerDetails({
    required this.customerId,
    this.gender,
    this.dob,
    this.city,
    this.rewardPoints = 0,
    this.referralCode,
    this.totalReferrals = 0,
  });

  factory CustomerDetails.fromJson(Map<String, dynamic> json) {
    return CustomerDetails(
      customerId: json['customer_id'] as String? ?? '',
      gender: json['gender'] as String?,
      dob: json['dob'] as String?,
      city: json['city'] as String?,
      rewardPoints: json['reward_points'] as int? ?? 0,
      referralCode: json['referral_code'] as String?,
      totalReferrals: json['total_referrals'] as int? ?? 0,
    );
  }
}

class WalletModel {
  final int balance;
  final String currency;

  WalletModel({
    required this.balance,
    required this.currency,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      balance: (json['balance'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'INR',
    );
  }
}
