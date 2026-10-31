import 'dart:convert';

/// SPiNGO Saved Passenger Model
/// Maps directly to:
/// - POST https://spingoride.com/api/v1/customer/passengers
/// - PUT https://spingoride.com/api/v1/passengers/{id}
/// - DELETE https://spingoride.com/api/v1/passengers/{id}
/// - GET https://spingoride.com/api/v1/customer/passengers

class SavedPassengerModel {
  final String id;
  final String name;
  final int? age;
  final String dob;
  final String gender; // 'male', 'female', 'others' or 'Male', 'Female'
  final String? genderLabel; // 'Male', 'Female', 'Others'
  final bool isSeniorCitizen;
  final bool isChild;
  final String? createdAt;
  final String? formattedDate;
  final String countryCode;
  final String phone;
  final String? berthPreference;
  final String? seatPreference;
  final String? mealPreference;
  final bool isPrimaryUser;

  SavedPassengerModel({
    required this.id,
    required this.name,
    this.age,
    this.dob = '',
    required this.gender,
    this.genderLabel,
    this.isSeniorCitizen = false,
    this.isChild = false,
    this.createdAt,
    this.formattedDate,
    this.countryCode = '+91 (IND)',
    this.phone = '',
    this.berthPreference,
    this.seatPreference,
    this.mealPreference,
    this.isPrimaryUser = false,
  });

  SavedPassengerModel copyWith({
    String? id,
    String? name,
    int? age,
    String? dob,
    String? gender,
    String? genderLabel,
    bool? isSeniorCitizen,
    bool? isChild,
    String? createdAt,
    String? formattedDate,
    String? countryCode,
    String? phone,
    String? berthPreference,
    String? seatPreference,
    String? mealPreference,
    bool? isPrimaryUser,
  }) {
    return SavedPassengerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      genderLabel: genderLabel ?? this.genderLabel,
      isSeniorCitizen: isSeniorCitizen ?? this.isSeniorCitizen,
      isChild: isChild ?? this.isChild,
      createdAt: createdAt ?? this.createdAt,
      formattedDate: formattedDate ?? this.formattedDate,
      countryCode: countryCode ?? this.countryCode,
      phone: phone ?? this.phone,
      berthPreference: berthPreference ?? this.berthPreference,
      seatPreference: seatPreference ?? this.seatPreference,
      mealPreference: mealPreference ?? this.mealPreference,
      isPrimaryUser: isPrimaryUser ?? this.isPrimaryUser,
    );
  }

  /// Capitalized gender display (e.g. "Female")
  String get genderDisplay {
    if (genderLabel != null && genderLabel!.isNotEmpty) {
      return genderLabel!;
    }
    if (gender.isEmpty) return 'Female';
    return '${gender[0].toUpperCase()}${gender.substring(1).toLowerCase()}';
  }

  /// Age display string (e.g. "65 yrs")
  String get ageDisplay {
    if (age != null && age! > 0) {
      return '$age yrs';
    }
    return '';
  }

  /// Combined subtitle (e.g. "Female • 65 yrs")
  String get subtitleDisplay {
    final parts = <String>[];
    parts.add(genderDisplay);
    if (ageDisplay.isNotEmpty) {
      parts.add(ageDisplay);
    }
    return parts.join(' • ');
  }

  /// Initials for circular avatar badge
  String get initials {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'P';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  /// Whether passenger is a senior citizen (computed from flag or age >= 60)
  bool get isSeniorCitizenEffective =>
      isSeniorCitizen || (age != null && age! >= 60);

  /// Whether passenger is a child (computed from flag or age < 12)
  bool get isChildEffective =>
      isChild || (age != null && age! < 12 && age! > 0);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      if (age != null) 'age': age,
      'dob': dob,
      'gender': gender.toLowerCase(),
      if (genderLabel != null) 'gender_label': genderLabel,
      'is_senior_citizen': isSeniorCitizenEffective,
      'is_child': isChildEffective,
      if (createdAt != null) 'created_at': createdAt,
      if (formattedDate != null) 'formatted_date': formattedDate,
      'countryCode': countryCode,
      'phone': phone,
      'berthPreference': berthPreference,
      'seatPreference': seatPreference,
      'mealPreference': mealPreference,
      'isPrimaryUser': isPrimaryUser,
    };
  }

  factory SavedPassengerModel.fromMap(Map<String, dynamic> map) {
    // Resolve age
    int? resolvedAge;
    if (map['age'] != null) {
      resolvedAge = (map['age'] as num).toInt();
    } else if (map['dob'] != null && map['dob'].toString().isNotEmpty) {
      try {
        final parsedDob = DateTime.parse(map['dob'].toString());
        final now = DateTime.now();
        resolvedAge = now.year - parsedDob.year;
        if (now.month < parsedDob.month ||
            (now.month == parsedDob.month && now.day < parsedDob.day)) {
          resolvedAge--;
        }
      } catch (_) {}
    }

    final bool senior = map['is_senior_citizen'] == true ||
        (resolvedAge != null && resolvedAge >= 60);
    final bool child = map['is_child'] == true ||
        (resolvedAge != null && resolvedAge < 12 && resolvedAge > 0);

    final rawGender = map['gender']?.toString() ?? 'Female';
    final genLabel = map['gender_label']?.toString() ??
        map['genderLabel']?.toString() ??
        (rawGender.isNotEmpty
            ? '${rawGender[0].toUpperCase()}${rawGender.substring(1).toLowerCase()}'
            : 'Female');

    final fmtDate = map['formatted_date']?.toString() ??
        (map['created_at'] != null && map['created_at'].toString().isNotEmpty
            ? map['created_at'].toString().split('T').first
            : null);

    return SavedPassengerModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      age: resolvedAge,
      dob: map['dob']?.toString() ?? '',
      gender: rawGender,
      genderLabel: genLabel,
      isSeniorCitizen: senior,
      isChild: child,
      createdAt: map['created_at']?.toString(),
      formattedDate: fmtDate,
      countryCode: map['countryCode']?.toString() ??
          map['country_code']?.toString() ??
          '+91 (IND)',
      phone: map['phone']?.toString() ?? map['mobile']?.toString() ?? '',
      berthPreference: map['berthPreference']?.toString() ??
          map['berth_preference']?.toString(),
      seatPreference: map['seatPreference']?.toString() ??
          map['seat_preference']?.toString(),
      mealPreference: map['mealPreference']?.toString() ??
          map['meal_preference']?.toString(),
      isPrimaryUser:
          map['isPrimaryUser'] == true || map['is_primary_user'] == true,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory SavedPassengerModel.fromJson(String source) =>
      SavedPassengerModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

/// Response model for single passenger operations (Add, Update)
class PassengerSingleResponseModel {
  final bool success;
  final String message;
  final SavedPassengerModel? data;
  final Map<String, dynamic>? errors;

  PassengerSingleResponseModel({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory PassengerSingleResponseModel.fromJson(Map<String, dynamic> json) {
    return PassengerSingleResponseModel(
      success: json['success'] == true,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? SavedPassengerModel.fromMap(json['data'] as Map<String, dynamic>)
          : null,
      errors: json['errors'] is Map<String, dynamic>
          ? json['errors'] as Map<String, dynamic>
          : null,
    );
  }
}

/// Response model for passenger list
class PassengerListResponseModel {
  final bool success;
  final String message;
  final List<SavedPassengerModel> data;

  PassengerListResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PassengerListResponseModel.fromJson(Map<String, dynamic> json) {
    List<SavedPassengerModel> list = [];
    if (json['data'] != null) {
      if (json['data'] is List) {
        list = (json['data'] as List)
            .whereType<Map<String, dynamic>>()
            .map((item) => SavedPassengerModel.fromMap(item))
            .toList();
      } else if (json['data'] is Map<String, dynamic> &&
          json['data']['data'] != null &&
          json['data']['data'] is List) {
        list = (json['data']['data'] as List)
            .whereType<Map<String, dynamic>>()
            .map((item) => SavedPassengerModel.fromMap(item))
            .toList();
      }
    }

    return PassengerListResponseModel(
      success: json['success'] == true,
      message: json['message'] as String? ?? '',
      data: list,
    );
  }
}

/// Result wrapper for service calls
class PassengerApiResponse {
  final bool success;
  final String message;
  final SavedPassengerModel? passenger;
  final Map<String, dynamic>? errors;

  PassengerApiResponse({
    required this.success,
    required this.message,
    this.passenger,
    this.errors,
  });
}
