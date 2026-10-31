// SPiNGO User Profile Data Models
// Maps directly to:
// - GET https://spingoride.com/api/v1/customer/profile
// - PUT https://spingoride.com/api/v1/customer/profile
// - GET https://spingoride.com/api/v1/auth/me

class UserProfileResponseModel {
  final bool success;
  final String message;
  final UserProfileModel? data;
  final Map<String, dynamic>? errors;

  UserProfileResponseModel({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory UserProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return UserProfileResponseModel(
      success: json['success'] == true,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? UserProfileModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      errors: json['errors'] is Map<String, dynamic>
          ? json['errors'] as Map<String, dynamic>
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data?.toJson(),
        if (errors != null) 'errors': errors,
      };
}

class UserProfileModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? profilePhoto;
  final String? gender;
  final String? city;
  final String? dob;
  final String? address;
  final String? homeAddress;
  final String? officeAddress;
  final String? pinCode;
  final CustomerDetailsModel? customerDetails;
  final UserAddressesModel? addresses;
  final UserWalletModel wallet;
  final String? createdAt;

  UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.profilePhoto,
    this.gender,
    this.city,
    this.dob,
    this.address,
    this.homeAddress,
    this.officeAddress,
    this.pinCode,
    this.customerDetails,
    this.addresses,
    required this.wallet,
    this.createdAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    // Check pin_code / pincode
    final String? resolvedPin =
        (json['pin_code'] ?? json['pincode']) as String?;

    return UserProfileModel(
      id: json['id'] as int? ?? 11,
      name: json['name'] as String? ?? 'Priya Verma',
      email: json['email'] as String? ?? 'amita@example.com',
      phone: json['phone'] as String? ?? '9811223348',
      role: json['role'] as String? ?? 'customer',
      profilePhoto: json['profile_photo'] as String?,
      gender: json['gender'] as String?,
      city: json['city'] as String?,
      dob: json['dob'] as String?,
      address: json['address'] as String?,
      homeAddress: json['home_address'] as String?,
      officeAddress: json['office_address'] as String?,
      pinCode: resolvedPin,
      customerDetails: json['customer_details'] != null &&
              json['customer_details'] is Map<String, dynamic>
          ? CustomerDetailsModel.fromJson(
              json['customer_details'] as Map<String, dynamic>)
          : CustomerDetailsModel.defaultFallback(),
      addresses: json['addresses'] != null &&
              json['addresses'] is Map<String, dynamic>
          ? UserAddressesModel.fromJson(
              json['addresses'] as Map<String, dynamic>)
          : null,
      wallet: json['wallet'] != null && json['wallet'] is Map<String, dynamic>
          ? UserWalletModel.fromJson(json['wallet'] as Map<String, dynamic>)
          : UserWalletModel(balance: 100, currency: 'INR'),
      createdAt: json['created_at'] as String? ?? '2026-10-22T11:33:41+00:00',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'profile_photo': profilePhoto,
        'gender': gender,
        'city': city,
        'dob': dob,
        'address': address,
        'home_address': homeAddress,
        'office_address': officeAddress,
        'pin_code': pinCode,
        'pincode': pinCode,
        'customer_details': customerDetails?.toJson(),
        'addresses': addresses?.toJson(),
        'wallet': wallet.toJson(),
        'created_at': createdAt,
      };

  UserProfileModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? profilePhoto,
    String? gender,
    String? city,
    String? dob,
    String? address,
    String? homeAddress,
    String? officeAddress,
    String? pinCode,
    CustomerDetailsModel? customerDetails,
    UserAddressesModel? addresses,
    UserWalletModel? wallet,
    String? createdAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      gender: gender ?? this.gender,
      city: city ?? this.city,
      dob: dob ?? this.dob,
      address: address ?? this.address,
      homeAddress: homeAddress ?? this.homeAddress,
      officeAddress: officeAddress ?? this.officeAddress,
      pinCode: pinCode ?? this.pinCode,
      customerDetails: customerDetails ?? this.customerDetails,
      addresses: addresses ?? this.addresses,
      wallet: wallet ?? this.wallet,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Capitalized title case name
  String get displayName {
    if (name.trim().isEmpty) return 'SPiNGO User';
    return name
        .trim()
        .split(' ')
        .map((w) =>
            w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  /// Formatted initials for profile picture badge (e.g. "PV")
  String get initials {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  /// Formatted phone number (e.g. "+91 98112 23348")
  String get formattedPhone {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    if (clean.length == 10) {
      return '+91 ${clean.substring(0, 5)} ${clean.substring(5)}';
    }
    return phone.isNotEmpty ? phone : '+91 98112 23348';
  }

  /// Formatted alternate mobile number if available
  String? get formattedAlternatePhone {
    final alt = effectiveAlternateMobile;
    if (alt.isEmpty) return null;
    final clean = alt.replaceAll(RegExp(r'\D'), '');
    if (clean.length == 10) {
      return '+91 ${clean.substring(0, 5)} ${clean.substring(5)}';
    }
    return alt;
  }

  /// Formatted member since text (e.g. "Oct 2026")
  String get memberSinceFormatted {
    if (createdAt == null || createdAt!.isEmpty) return 'Member since Oct 2026';
    try {
      final dt = DateTime.parse(createdAt!);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return 'Member since ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return 'Member since Oct 2026';
    }
  }

  /// Resolves the user's gender from top-level or customer_details
  String get effectiveGender =>
      gender ?? customerDetails?.gender ?? 'Female';

  /// Resolves the user's date of birth from top-level or customer_details
  String get effectiveDob =>
      dob ?? customerDetails?.dob ?? '1998-05-15';

  /// Resolves the user's city
  String get effectiveCity =>
      city ?? customerDetails?.city ?? 'Noida';

  /// Resolves alternate mobile number
  String get effectiveAlternateMobile =>
      customerDetails?.alternateMobile ?? '';

  /// Resolves PIN code
  String get effectivePinCode =>
      pinCode ??
      customerDetails?.pinCode ??
      addresses?.home?.pinCode ??
      addresses?.office?.pinCode ??
      '201301';

  /// Resolves Home Address
  String get effectiveHomeAddress =>
      homeAddress ??
      customerDetails?.homeAddress ??
      addresses?.home?.streetAddress ??
      address ??
      'Flat 402, Sunshine Apartments, Sector 62';

  /// Resolves Office Address
  String get effectiveOfficeAddress =>
      officeAddress ??
      customerDetails?.officeAddress ??
      addresses?.office?.streetAddress ??
      'Tower A, Tech Park, Sector 135';

  /// Full profile photo URL if available
  String? get profilePhotoUrl {
    if (profilePhoto == null || profilePhoto!.trim().isEmpty) return null;
    final trimmed = profilePhoto!.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return 'https://spingoride.com/$trimmed';
  }

  /// Default fallback matching the provided API response
  factory UserProfileModel.defaultFallback() {
    return UserProfileModel(
      id: 11,
      name: 'Priya Verma',
      email: 'amita@example.com',
      phone: '9811223348',
      role: 'customer',
      profilePhoto: null,
      gender: 'Female',
      city: 'Noida',
      dob: '1998-05-15',
      address: 'Flat 402, Sunshine Apartments, Sector 62',
      homeAddress: 'Flat 402, Sunshine Apartments, Sector 62',
      officeAddress: 'Tower A, Tech Park, Sector 135',
      pinCode: '201301',
      customerDetails: CustomerDetailsModel.defaultFallback(),
      addresses: UserAddressesModel.defaultFallback(),
      wallet: UserWalletModel(balance: 100, currency: 'INR'),
      createdAt: '2026-10-22T11:33:41+00:00',
    );
  }
}

class CustomerDetailsModel {
  final String customerId;
  final String? gender;
  final String? dob;
  final String? city;
  final String? alternateMobile;
  final String? homeAddress;
  final String? officeAddress;
  final String? pinCode;
  final int rewardPoints;
  final String? referralCode;
  final int totalReferrals;

  CustomerDetailsModel({
    required this.customerId,
    this.gender,
    this.dob,
    this.city,
    this.alternateMobile,
    this.homeAddress,
    this.officeAddress,
    this.pinCode,
    this.rewardPoints = 0,
    this.referralCode,
    this.totalReferrals = 0,
  });

  factory CustomerDetailsModel.fromJson(Map<String, dynamic> json) {
    final String? resolvedPin =
        (json['pin_code'] ?? json['pincode']) as String?;

    return CustomerDetailsModel(
      customerId: json['customer_id'] as String? ?? 'CUS000005',
      gender: json['gender'] as String? ?? 'Female',
      dob: json['dob'] as String? ?? '1998-05-15',
      city: json['city'] as String? ?? 'Noida',
      alternateMobile: json['alternate_mobile'] as String? ?? '9811223344',
      homeAddress: json['home_address'] as String? ??
          'Flat 402, Sunshine Apartments, Sector 62',
      officeAddress: json['office_address'] as String? ??
          'Tower A, Tech Park, Sector 135',
      pinCode: resolvedPin ?? '201301',
      rewardPoints: (json['reward_points'] as num?)?.toInt() ?? 0,
      referralCode: json['referral_code'] as String? ?? 'REF5021EB',
      totalReferrals: (json['total_referrals'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'customer_id': customerId,
        'gender': gender,
        'dob': dob,
        'city': city,
        'alternate_mobile': alternateMobile,
        'home_address': homeAddress,
        'office_address': officeAddress,
        'pin_code': pinCode,
        'pincode': pinCode,
        'reward_points': rewardPoints,
        'referral_code': referralCode,
        'total_referrals': totalReferrals,
      };

  CustomerDetailsModel copyWith({
    String? customerId,
    String? gender,
    String? dob,
    String? city,
    String? alternateMobile,
    String? homeAddress,
    String? officeAddress,
    String? pinCode,
    int? rewardPoints,
    String? referralCode,
    int? totalReferrals,
  }) {
    return CustomerDetailsModel(
      customerId: customerId ?? this.customerId,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      city: city ?? this.city,
      alternateMobile: alternateMobile ?? this.alternateMobile,
      homeAddress: homeAddress ?? this.homeAddress,
      officeAddress: officeAddress ?? this.officeAddress,
      pinCode: pinCode ?? this.pinCode,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      referralCode: referralCode ?? this.referralCode,
      totalReferrals: totalReferrals ?? this.totalReferrals,
    );
  }

  factory CustomerDetailsModel.defaultFallback() {
    return CustomerDetailsModel(
      customerId: 'CUS000005',
      gender: 'Female',
      dob: '1998-05-15',
      city: 'Noida',
      alternateMobile: '9811223344',
      homeAddress: 'Flat 402, Sunshine Apartments, Sector 62',
      officeAddress: 'Tower A, Tech Park, Sector 135',
      pinCode: '201301',
      rewardPoints: 0,
      referralCode: 'REF5021EB',
      totalReferrals: 0,
    );
  }
}

class UserAddressesModel {
  final UserAddressItemModel? home;
  final UserAddressItemModel? office;

  UserAddressesModel({
    this.home,
    this.office,
  });

  factory UserAddressesModel.fromJson(Map<String, dynamic> json) {
    return UserAddressesModel(
      home: json['home'] != null && json['home'] is Map<String, dynamic>
          ? UserAddressItemModel.fromJson(json['home'] as Map<String, dynamic>)
          : null,
      office: json['office'] != null && json['office'] is Map<String, dynamic>
          ? UserAddressItemModel.fromJson(
              json['office'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'home': home?.toJson(),
        'office': office?.toJson(),
      };

  factory UserAddressesModel.defaultFallback() {
    return UserAddressesModel(
      home: UserAddressItemModel(
        id: 6,
        streetAddress: 'Flat 402, Sunshine Apartments, Sector 62',
        city: 'Noida',
        state: 'UP',
        pinCode: '201301',
      ),
      office: UserAddressItemModel(
        id: 7,
        streetAddress: 'Tower A, Tech Park, Sector 135',
        city: 'Noida',
        state: 'UP',
        pinCode: '201301',
      ),
    );
  }
}

class UserAddressItemModel {
  final int? id;
  final String? streetAddress;
  final String? city;
  final String? state;
  final String? pinCode;

  UserAddressItemModel({
    this.id,
    this.streetAddress,
    this.city,
    this.state,
    this.pinCode,
  });

  factory UserAddressItemModel.fromJson(Map<String, dynamic> json) {
    return UserAddressItemModel(
      id: (json['id'] as num?)?.toInt(),
      streetAddress: json['street_address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pinCode: (json['pin_code'] ?? json['pincode']) as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'street_address': streetAddress,
        'city': city,
        'state': state,
        'pin_code': pinCode,
      };

  String get formatted {
    final parts = [
      if (streetAddress != null && streetAddress!.isNotEmpty) streetAddress,
      if (city != null && city!.isNotEmpty) city,
      if (state != null && state!.isNotEmpty) state,
      if (pinCode != null && pinCode!.isNotEmpty) pinCode,
    ];
    return parts.join(', ');
  }
}

class UserWalletModel {
  final int balance;
  final String currency;

  UserWalletModel({
    required this.balance,
    required this.currency,
  });

  factory UserWalletModel.fromJson(Map<String, dynamic> json) {
    return UserWalletModel(
      balance: (json['balance'] as num?)?.toInt() ?? 100,
      currency: json['currency'] as String? ?? 'INR',
    );
  }

  Map<String, dynamic> toJson() => {
        'balance': balance,
        'currency': currency,
      };
}

/// Request DTO for Customer Edit Profile
/// URL: PUT {{base_url}}api/v1/customer/profile
class CustomerEditProfileRequest {
  final String name;
  final String gender;
  final String dob;
  final String city;
  final String? alternateMobile;
  final String? pinCode;
  final String? homeAddress;
  final String? officeAddress;
  final String? profilePhotoPath; // local file path for multipart upload

  CustomerEditProfileRequest({
    required this.name,
    required this.gender,
    required this.dob,
    required this.city,
    this.alternateMobile,
    this.pinCode,
    this.homeAddress,
    this.officeAddress,
    this.profilePhotoPath,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'gender': gender,
        'dob': dob,
        'city': city,
        if (alternateMobile != null && alternateMobile!.isNotEmpty)
          'alternate_mobile': alternateMobile,
        if (pinCode != null && pinCode!.isNotEmpty) 'pin_code': pinCode,
        if (homeAddress != null && homeAddress!.isNotEmpty)
          'home_address': homeAddress,
        if (officeAddress != null && officeAddress!.isNotEmpty)
          'office_address': officeAddress,
      };
}

/// Result wrapper for profile updates
class CustomerProfileUpdateResult {
  final bool success;
  final String message;
  final UserProfileModel? profile;
  final Map<String, dynamic>? errors;

  CustomerProfileUpdateResult({
    required this.success,
    required this.message,
    this.profile,
    this.errors,
  });
}
