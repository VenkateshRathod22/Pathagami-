// SPiNGO Customer Profile Data Models
// Maps directly to:
// - GET https://spingoride.com/api/v1/customer/profile
// - PUT https://spingoride.com/api/v1/customer/profile
// - GET https://spingoride.com/api/v1/auth/me
// - Matches customer data returned from https://spingoride.com/api/v1/auth/login

class CustomerProfileResponseModel {
  final bool success;
  final String message;
  final CustomerProfileModel? data;
  final Map<String, dynamic>? errors;

  CustomerProfileResponseModel({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory CustomerProfileResponseModel.fromJson(Map<String, dynamic> json) {
    CustomerProfileModel? parsedModel;
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      final dataMap = json['data'] as Map<String, dynamic>;
      if (dataMap['user'] != null && dataMap['user'] is Map<String, dynamic>) {
        parsedModel = CustomerProfileModel.fromJson(dataMap['user'] as Map<String, dynamic>);
      } else {
        parsedModel = CustomerProfileModel.fromJson(dataMap);
      }
    } else if (json['user'] != null && json['user'] is Map<String, dynamic>) {
      parsedModel = CustomerProfileModel.fromJson(json['user'] as Map<String, dynamic>);
    }

    return CustomerProfileResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: parsedModel,
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

class CustomerProfileModel {
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
  final CustomerProfileDetailsModel? customerDetails;
  final CustomerProfileAddressesModel? addresses;
  final CustomerProfileWalletModel wallet;
  final String? createdAt;

  CustomerProfileModel({
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

  factory CustomerProfileModel.fromJson(Map<String, dynamic> json) {
    // Resolve pin code (supports pin_code / pincode)
    final String? resolvedPin =
        (json['pin_code'] ?? json['pincode'])?.toString();

    return CustomerProfileModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: json['role']?.toString() ?? 'customer',
      profilePhoto: json['profile_photo']?.toString(),
      gender: json['gender']?.toString(),
      city: json['city']?.toString(),
      dob: json['dob']?.toString(),
      address: json['address']?.toString(),
      homeAddress: json['home_address']?.toString(),
      officeAddress: json['office_address']?.toString(),
      pinCode: resolvedPin,
      customerDetails: json['customer_details'] != null &&
              json['customer_details'] is Map<String, dynamic>
          ? CustomerProfileDetailsModel.fromJson(
              json['customer_details'] as Map<String, dynamic>)
          : null,
      addresses: json['addresses'] != null &&
              json['addresses'] is Map<String, dynamic>
          ? CustomerProfileAddressesModel.fromJson(
              json['addresses'] as Map<String, dynamic>)
          : null,
      wallet: json['wallet'] != null && json['wallet'] is Map<String, dynamic>
          ? CustomerProfileWalletModel.fromJson(
              json['wallet'] as Map<String, dynamic>)
          : CustomerProfileWalletModel(balance: 0, currency: 'INR'),
      createdAt: json['created_at']?.toString(),
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

  CustomerProfileModel copyWith({
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
    CustomerProfileDetailsModel? customerDetails,
    CustomerProfileAddressesModel? addresses,
    CustomerProfileWalletModel? wallet,
    String? createdAt,
  }) {
    return CustomerProfileModel(
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

  /// Capitalized title case display name
  String get displayName {
    if (name.trim().isEmpty) return 'SPiNGO Customer';
    return name
        .trim()
        .split(' ')
        .map((w) =>
            w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  /// Formatted initials for profile avatar (e.g. "PV")
  String get initials {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'SC';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  /// Clean formatted phone number (e.g. "+91 96955 41750")
  String get formattedPhone {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    if (clean.length == 10) {
      return '+91 ${clean.substring(0, 5)} ${clean.substring(5)}';
    }
    return phone.isNotEmpty ? '+91 $phone' : 'Not provided';
  }

  /// Alternate mobile if available
  String? get formattedAlternatePhone {
    final alt = effectiveAlternateMobile;
    if (alt.isEmpty) return null;
    final clean = alt.replaceAll(RegExp(r'\D'), '');
    if (clean.length == 10) {
      return '+91 ${clean.substring(0, 5)} ${clean.substring(5)}';
    }
    return '+91 $alt';
  }

  /// Formatted member since text (e.g. "Member since Oct 2026")
  String get memberSinceFormatted {
    if (createdAt == null || createdAt!.isEmpty) {
      return 'Member since Oct 2026';
    }
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

  /// Customer ID string fallback
  String get effectiveCustomerId =>
      customerDetails?.customerId ?? (id > 0 ? 'CUS-${id.toString().padLeft(6, '0')}' : 'CUS-GUEST');

  /// Effective Gender
  String get effectiveGender =>
      gender ?? customerDetails?.gender ?? 'Not specified';

  /// Effective DOB
  String get effectiveDob =>
      dob ?? customerDetails?.dob ?? 'Not provided';

  /// Effective City
  String get effectiveCity =>
      city ?? customerDetails?.city ?? 'Noida';

  /// Effective Alternate Mobile
  String get effectiveAlternateMobile =>
      customerDetails?.alternateMobile ?? '';

  /// Effective PIN code
  String get effectivePinCode =>
      pinCode ??
      customerDetails?.pinCode ??
      addresses?.home?.pinCode ??
      addresses?.office?.pinCode ??
      '201301';

  /// Effective Home Address
  String get effectiveHomeAddress =>
      homeAddress ??
      customerDetails?.homeAddress ??
      addresses?.home?.streetAddress ??
      address ??
      'Not configured';

  /// Effective Office Address
  String get effectiveOfficeAddress =>
      officeAddress ??
      customerDetails?.officeAddress ??
      addresses?.office?.streetAddress ??
      'Not configured';

  /// Full profile photo URL if valid
  String? get profilePhotoUrl {
    if (profilePhoto == null || profilePhoto!.trim().isEmpty) return null;
    final trimmed = profilePhoto!.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return 'https://spingoride.com/$trimmed';
  }

  /// Default fallback data matching live test customer
  factory CustomerProfileModel.defaultFallback() {
    return CustomerProfileModel(
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
      customerDetails: CustomerProfileDetailsModel(
        customerId: 'CUS000005',
        gender: 'Female',
        dob: '1998-05-15',
        city: 'Noida',
        alternateMobile: '9811223344',
        homeAddress: 'Flat 402, Sunshine Apartments, Sector 62',
        officeAddress: 'Tower A, Tech Park, Sector 135',
        pinCode: '201301',
        rewardPoints: 50,
        referralCode: 'REF5021EB',
        totalReferrals: 0,
      ),
      addresses: CustomerProfileAddressesModel.defaultFallback(),
      wallet: CustomerProfileWalletModel(balance: 100, currency: 'INR'),
      createdAt: '2026-10-22T11:33:41+00:00',
    );
  }
}

class CustomerProfileDetailsModel {
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

  CustomerProfileDetailsModel({
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

  factory CustomerProfileDetailsModel.fromJson(Map<String, dynamic> json) {
    final String? resolvedPin =
        (json['pin_code'] ?? json['pincode'])?.toString();

    return CustomerProfileDetailsModel(
      customerId: json['customer_id']?.toString() ?? 'CUS000005',
      gender: json['gender']?.toString(),
      dob: json['dob']?.toString(),
      city: json['city']?.toString(),
      alternateMobile: json['alternate_mobile']?.toString(),
      homeAddress: json['home_address']?.toString(),
      officeAddress: json['office_address']?.toString(),
      pinCode: resolvedPin,
      rewardPoints: (json['reward_points'] as num?)?.toInt() ?? 0,
      referralCode: json['referral_code']?.toString() ?? 'REF5021EB',
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

  CustomerProfileDetailsModel copyWith({
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
    return CustomerProfileDetailsModel(
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
}

class CustomerProfileAddressesModel {
  final CustomerProfileAddressItem? home;
  final CustomerProfileAddressItem? office;

  CustomerProfileAddressesModel({
    this.home,
    this.office,
  });

  factory CustomerProfileAddressesModel.fromJson(Map<String, dynamic> json) {
    return CustomerProfileAddressesModel(
      home: json['home'] != null && json['home'] is Map<String, dynamic>
          ? CustomerProfileAddressItem.fromJson(
              json['home'] as Map<String, dynamic>)
          : null,
      office: json['office'] != null && json['office'] is Map<String, dynamic>
          ? CustomerProfileAddressItem.fromJson(
              json['office'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'home': home?.toJson(),
        'office': office?.toJson(),
      };

  factory CustomerProfileAddressesModel.defaultFallback() {
    return CustomerProfileAddressesModel(
      home: CustomerProfileAddressItem(
        id: 1,
        streetAddress: 'Flat 402, Sunshine Apartments, Sector 62',
        city: 'Noida',
        state: 'UP',
        pinCode: '201301',
      ),
      office: CustomerProfileAddressItem(
        id: 2,
        streetAddress: 'Tower A, Tech Park, Sector 135',
        city: 'Noida',
        state: 'UP',
        pinCode: '201301',
      ),
    );
  }
}

class CustomerProfileAddressItem {
  final int? id;
  final String? streetAddress;
  final String? city;
  final String? state;
  final String? pinCode;

  CustomerProfileAddressItem({
    this.id,
    this.streetAddress,
    this.city,
    this.state,
    this.pinCode,
  });

  factory CustomerProfileAddressItem.fromJson(Map<String, dynamic> json) {
    return CustomerProfileAddressItem(
      id: (json['id'] as num?)?.toInt(),
      streetAddress: json['street_address']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      pinCode: (json['pin_code'] ?? json['pincode'])?.toString(),
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
    return parts.isEmpty ? 'Not set' : parts.join(', ');
  }
}

class CustomerProfileWalletModel {
  final double balance;
  final String currency;

  CustomerProfileWalletModel({
    required this.balance,
    required this.currency,
  });

  factory CustomerProfileWalletModel.fromJson(Map<String, dynamic> json) {
    return CustomerProfileWalletModel(
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'INR',
    );
  }

  Map<String, dynamic> toJson() => {
        'balance': balance,
        'currency': currency,
      };

  String get formattedBalance => '$currency ${balance.toStringAsFixed(balance % 1 == 0 ? 0 : 2)}';
}

/// Request DTO for Customer Edit Profile
/// URL: PUT https://spingoride.com/api/v1/customer/profile
class CustomerProfileUpdateRequest {
  final String name;
  final String gender;
  final String dob;
  final String city;
  final String? alternateMobile;
  final String? pinCode;
  final String? homeAddress;
  final String? officeAddress;
  final String? profilePhotoPath;

  CustomerProfileUpdateRequest({
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
  final CustomerProfileModel? profile;
  final Map<String, dynamic>? errors;

  CustomerProfileUpdateResult({
    required this.success,
    required this.message,
    this.profile,
    this.errors,
  });
}
