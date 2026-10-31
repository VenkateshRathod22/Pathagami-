// SPiNGO Bus Domain Data Models
// Matches live endpoints:
// - GET https://spingoride.com/api/v1/bus/cities
// - GET https://spingoride.com/api/v1/bus/routes
// - GET https://spingoride.com/api/v1/bus/search
// - GET https://spingoride.com/api/v1/bus/{id}/details

class BusRouteModel {
  final int id;
  final String name;
  final String sourceCity;
  final String destinationCity;
  final int distanceKm;
  final int estimatedDurationMinutes;
  final String formattedDuration;
  final String status;

  BusRouteModel({
    required this.id,
    required this.name,
    required this.sourceCity,
    required this.destinationCity,
    required this.distanceKm,
    required this.estimatedDurationMinutes,
    required this.formattedDuration,
    required this.status,
  });

  factory BusRouteModel.fromJson(Map<String, dynamic> json) {
    return BusRouteModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      sourceCity: json['source_city'] as String? ?? '',
      destinationCity: json['destination_city'] as String? ?? '',
      distanceKm: json['distance_km'] as int? ?? 0,
      estimatedDurationMinutes: json['estimated_duration_minutes'] as int? ?? 0,
      formattedDuration: json['formatted_duration'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
    );
  }
}

class BusAmenityModel {
  final int id;
  final String name;
  final String icon;
  final String description;

  BusAmenityModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
  });

  factory BusAmenityModel.fromJson(Map<String, dynamic> json) {
    return BusAmenityModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

class BusOperatorModel {
  final int id;
  final String operatorName;
  final String companyName;
  final String? contactPerson;
  final String? email;
  final String? mobile;
  final String city;
  final String state;
  final String? logo;
  final int totalBuses;
  final double rating;
  final String status;

  BusOperatorModel({
    required this.id,
    required this.operatorName,
    required this.companyName,
    this.contactPerson,
    this.email,
    this.mobile,
    this.city = '',
    this.state = '',
    this.logo,
    this.totalBuses = 1,
    this.rating = 4.5,
    this.status = 'active',
  });

  factory BusOperatorModel.fromJson(Map<String, dynamic> json) {
    return BusOperatorModel(
      id: json['id'] as int? ?? 0,
      operatorName: json['operator_name'] as String? ?? '',
      companyName: json['company_name'] as String? ?? '',
      contactPerson: json['contact_person'] as String?,
      email: json['email'] as String?,
      mobile: json['mobile'] as String?,
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      logo: json['logo'] as String?,
      totalBuses: json['total_buses'] as int? ?? 1,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      status: json['status'] as String? ?? 'active',
    );
  }
}

class BusInfoModel {
  final int id;
  final String name;
  final String registrationNumber;
  final String busType;
  final bool isAc;
  final String seatingType; // 'seater', 'sleeper', 'seater/sleeper'
  final String deckType; // 'single', 'double'
  final int totalSeats;
  final List<String> images;
  final List<BusAmenityModel> amenities;
  final String status;

  BusInfoModel({
    required this.id,
    required this.name,
    required this.registrationNumber,
    required this.busType,
    required this.isAc,
    required this.seatingType,
    required this.deckType,
    required this.totalSeats,
    this.images = const [],
    this.amenities = const [],
    this.status = 'active',
  });

  factory BusInfoModel.fromJson(Map<String, dynamic> json) {
    final rawAmenities = json['amenities'] as List<dynamic>? ?? [];
    final amenitiesList = rawAmenities
        .map((a) => BusAmenityModel.fromJson(a as Map<String, dynamic>))
        .toList();

    final rawImages = json['images'] as List<dynamic>? ?? [];
    final imagesList = rawImages.map((img) => img.toString()).toList();

    return BusInfoModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      registrationNumber: json['registration_number'] as String? ?? '',
      busType: json['bus_type'] as String? ?? '',
      isAc: json['is_ac'] == true,
      seatingType: json['seating_type'] as String? ?? 'seater',
      deckType: json['deck_type'] as String? ?? 'single',
      totalSeats: json['total_seats'] as int? ?? 20,
      images: imagesList,
      amenities: amenitiesList,
      status: json['status'] as String? ?? 'active',
    );
  }
}

class BusPointModel {
  final int id;
  final int scheduleId;
  final String type; // 'boarding' or 'dropping'
  final String pointName;
  final String cityName;
  final String? landmark;
  final String address;
  final double? latitude;
  final double? longitude;
  final String scheduledTime;
  final int displayOrder;

  BusPointModel({
    required this.id,
    required this.scheduleId,
    required this.type,
    required this.pointName,
    required this.cityName,
    this.landmark,
    required this.address,
    this.latitude,
    this.longitude,
    required this.scheduledTime,
    this.displayOrder = 1,
  });

  factory BusPointModel.fromJson(Map<String, dynamic> json) {
    return BusPointModel(
      id: json['id'] as int? ?? 0,
      scheduleId: json['schedule_id'] as int? ?? 0,
      type: json['type'] as String? ?? 'boarding',
      pointName: json['point_name'] as String? ?? '',
      cityName: json['city_name'] as String? ?? '',
      landmark: json['landmark'] as String?,
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      scheduledTime: json['scheduled_time'] as String? ?? '',
      displayOrder: json['display_order'] as int? ?? 1,
    );
  }
}

class BusScheduleModel {
  final int id;
  final String departureDate;
  final String departureTime;
  final String arrivalDate;
  final String arrivalTime;
  final String formattedDuration;
  final int baseFare;
  final String status;
  final int availableSeatsCount;
  final BusOperatorModel operator;
  final BusInfoModel bus;
  final BusRouteModel route;
  final List<BusPointModel> boardingPoints;
  final List<BusPointModel> droppingPoints;
  final String? bookingOpensAt;
  final String? bookingClosesAt;

  BusScheduleModel({
    required this.id,
    required this.departureDate,
    required this.departureTime,
    required this.arrivalDate,
    required this.arrivalTime,
    required this.formattedDuration,
    required this.baseFare,
    required this.status,
    required this.availableSeatsCount,
    required this.operator,
    required this.bus,
    required this.route,
    required this.boardingPoints,
    required this.droppingPoints,
    this.bookingOpensAt,
    this.bookingClosesAt,
  });

  factory BusScheduleModel.fromJson(Map<String, dynamic> json) {
    final rawBoarding = json['boarding_points'] as List<dynamic>? ?? [];
    final boardingList = rawBoarding
        .map((p) => BusPointModel.fromJson(p as Map<String, dynamic>))
        .toList();

    final rawDropping = json['dropping_points'] as List<dynamic>? ?? [];
    final droppingList = rawDropping
        .map((p) => BusPointModel.fromJson(p as Map<String, dynamic>))
        .toList();

    return BusScheduleModel(
      id: json['id'] as int? ?? 0,
      departureDate: json['departure_date'] as String? ?? '',
      departureTime: json['departure_time'] as String? ?? '',
      arrivalDate: json['arrival_date'] as String? ?? '',
      arrivalTime: json['arrival_time'] as String? ?? '',
      formattedDuration: json['formatted_duration'] as String? ?? '',
      baseFare: json['base_fare'] as int? ?? 0,
      status: json['status'] as String? ?? 'scheduled',
      availableSeatsCount: json['available_seats_count'] as int? ?? 0,
      operator: BusOperatorModel.fromJson(json['operator'] as Map<String, dynamic>? ?? {}),
      bus: BusInfoModel.fromJson(json['bus'] as Map<String, dynamic>? ?? {}),
      route: BusRouteModel.fromJson(json['route'] as Map<String, dynamic>? ?? {}),
      boardingPoints: boardingList,
      droppingPoints: droppingList,
      bookingOpensAt: json['booking_opens_at'] as String?,
      bookingClosesAt: json['booking_closes_at'] as String?,
    );
  }
}

class BusDetailsModel {
  final int id;
  final String name;
  final String registrationNumber;
  final String busType;
  final bool isAc;
  final String seatingType;
  final String deckType;
  final int totalSeats;
  final List<String> images;
  final List<BusAmenityModel> amenities;
  final BusOperatorModel operator;
  final String status;

  BusDetailsModel({
    required this.id,
    required this.name,
    required this.registrationNumber,
    required this.busType,
    required this.isAc,
    required this.seatingType,
    required this.deckType,
    required this.totalSeats,
    this.images = const [],
    this.amenities = const [],
    required this.operator,
    this.status = 'active',
  });

  factory BusDetailsModel.fromJson(Map<String, dynamic> json) {
    final rawAmenities = json['amenities'] as List<dynamic>? ?? [];
    final amenitiesList = rawAmenities
        .map((a) => BusAmenityModel.fromJson(a as Map<String, dynamic>))
        .toList();

    final rawImages = json['images'] as List<dynamic>? ?? [];
    final imagesList = rawImages.map((img) => img.toString()).toList();

    return BusDetailsModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      registrationNumber: json['registration_number'] as String? ?? '',
      busType: json['bus_type'] as String? ?? '',
      isAc: json['is_ac'] == true,
      seatingType: json['seating_type'] as String? ?? 'seater',
      deckType: json['deck_type'] as String? ?? 'single',
      totalSeats: json['total_seats'] as int? ?? 20,
      images: imagesList,
      amenities: amenitiesList,
      operator: BusOperatorModel.fromJson(json['operator'] as Map<String, dynamic>? ?? {}),
      status: json['status'] as String? ?? 'active',
    );
  }
}

class BusSeatItemModel {
  final int id;
  final int busSeatId;
  final String seatNumber;
  final String deck; // 'lower', 'upper'
  final String seatType; // 'sleeper', 'seater'
  final int fare;
  final String status; // 'available', 'booked', 'locked'
  final bool isAvailable;
  final bool isLockedByMe;
  final String? lockedUntil;
  final int rowNumber;
  final int colNumber;
  final String reservationType;
  final String reservationLabel;
  final bool isWomenOnly;
  final bool isSeniorOnly;
  final bool isWindow;
  final bool isAisle;

  BusSeatItemModel({
    required this.id,
    required this.busSeatId,
    required this.seatNumber,
    required this.deck,
    required this.seatType,
    required this.fare,
    required this.status,
    required this.isAvailable,
    this.isLockedByMe = false,
    this.lockedUntil,
    required this.rowNumber,
    required this.colNumber,
    this.reservationType = 'general',
    this.reservationLabel = 'General',
    this.isWomenOnly = false,
    this.isSeniorOnly = false,
    this.isWindow = false,
    this.isAisle = false,
  });

  factory BusSeatItemModel.fromJson(Map<String, dynamic> json) {
    return BusSeatItemModel(
      id: json['id'] as int? ?? 0,
      busSeatId: json['bus_seat_id'] as int? ?? 0,
      seatNumber: json['seat_number'] as String? ?? '',
      deck: json['deck'] as String? ?? 'lower',
      seatType: json['seat_type'] as String? ?? 'seater',
      fare: json['fare'] as int? ?? 0,
      status: json['status'] as String? ?? 'available',
      isAvailable: json['is_available'] == true,
      isLockedByMe: json['is_locked_by_me'] == true,
      lockedUntil: json['locked_until'] as String?,
      rowNumber: json['row_number'] as int? ?? 1,
      colNumber: json['col_number'] as int? ?? 1,
      reservationType: json['reservation_type'] as String? ?? 'general',
      reservationLabel: json['reservation_label'] as String? ?? 'General',
      isWomenOnly: json['is_women_only'] == true,
      isSeniorOnly: json['is_senior_only'] == true,
      isWindow: json['is_window'] == true,
      isAisle: json['is_aisle'] == true,
    );
  }
}

class BusDeckLayoutModel {
  final bool hasUpperDeck;
  final List<BusSeatItemModel> lower;
  final List<BusSeatItemModel> upper;

  BusDeckLayoutModel({
    required this.hasUpperDeck,
    required this.lower,
    required this.upper,
  });

  factory BusDeckLayoutModel.fromJson(Map<String, dynamic> json) {
    final rawLower = json['lower'] as List<dynamic>? ?? [];
    final rawUpper = json['upper'] as List<dynamic>? ?? [];

    return BusDeckLayoutModel(
      hasUpperDeck: json['has_upper_deck'] == true,
      lower: rawLower.map((s) => BusSeatItemModel.fromJson(s as Map<String, dynamic>)).toList(),
      upper: rawUpper.map((s) => BusSeatItemModel.fromJson(s as Map<String, dynamic>)).toList(),
    );
  }
}

class SeatLayoutSummaryModel {
  final int totalSeats;
  final int availableSeats;
  final int bookedSeats;
  final int lockedSeats;

  SeatLayoutSummaryModel({
    required this.totalSeats,
    required this.availableSeats,
    required this.bookedSeats,
    required this.lockedSeats,
  });

  factory SeatLayoutSummaryModel.fromJson(Map<String, dynamic> json) {
    return SeatLayoutSummaryModel(
      totalSeats: json['total_seats'] as int? ?? 0,
      availableSeats: json['available_seats'] as int? ?? 0,
      bookedSeats: json['booked_seats'] as int? ?? 0,
      lockedSeats: json['locked_seats'] as int? ?? 0,
    );
  }
}

class ScheduleSeatLayoutModel {
  final int scheduleId;
  final SeatLayoutSummaryModel summary;
  final BusDeckLayoutModel decks;
  final List<BusSeatItemModel> seats;

  ScheduleSeatLayoutModel({
    required this.scheduleId,
    required this.summary,
    required this.decks,
    required this.seats,
  });

  factory ScheduleSeatLayoutModel.fromJson(Map<String, dynamic> json) {
    final rawSeats = json['seats'] as List<dynamic>? ?? [];

    return ScheduleSeatLayoutModel(
      scheduleId: json['schedule_id'] as int? ?? 0,
      summary: SeatLayoutSummaryModel.fromJson(json['summary'] as Map<String, dynamic>? ?? {}),
      decks: BusDeckLayoutModel.fromJson(json['decks'] as Map<String, dynamic>? ?? {}),
      seats: rawSeats.map((s) => BusSeatItemModel.fromJson(s as Map<String, dynamic>)).toList(),
    );
  }
}

class LockedSeatItemModel {
  final String seatNumber;
  final int fare;
  final String deck;
  final String seatType;

  LockedSeatItemModel({
    required this.seatNumber,
    required this.fare,
    required this.deck,
    required this.seatType,
  });

  factory LockedSeatItemModel.fromJson(Map<String, dynamic> json) {
    return LockedSeatItemModel(
      seatNumber: json['seat_number'] as String? ?? '',
      fare: (json['fare'] as num?)?.toInt() ?? 0,
      deck: json['deck'] as String? ?? 'lower',
      seatType: json['seat_type'] as String? ?? 'seater',
    );
  }

  Map<String, dynamic> toJson() => {
    'seat_number': seatNumber,
    'fare': fare,
    'deck': deck,
    'seat_type': seatType,
  };
}

class SeatLockDataModel {
  final int scheduleId;
  final List<LockedSeatItemModel> lockedSeats;
  final String expiresAt;
  final int expiresInSeconds;
  final String message;

  SeatLockDataModel({
    required this.scheduleId,
    required this.lockedSeats,
    required this.expiresAt,
    required this.expiresInSeconds,
    required this.message,
  });

  factory SeatLockDataModel.fromJson(Map<String, dynamic> json) {
    final rawSeats = json['locked_seats'] as List<dynamic>? ?? [];
    return SeatLockDataModel(
      scheduleId: json['schedule_id'] as int? ?? 0,
      lockedSeats: rawSeats
          .map((s) => LockedSeatItemModel.fromJson(s as Map<String, dynamic>))
          .toList(),
      expiresAt: json['expires_at'] as String? ?? '',
      expiresInSeconds: json['expires_in_seconds'] as int? ?? 600,
      message: json['message'] as String? ?? '',
    );
  }
}

class SeatLockResponseModel {
  final bool success;
  final String message;
  final SeatLockDataModel? data;

  SeatLockResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory SeatLockResponseModel.fromJson(Map<String, dynamic> json) {
    return SeatLockResponseModel(
      success: json['success'] == true,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? SeatLockDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class BusBookingPassengerModel {
  final int id;
  final String seatNumber;
  final String passengerName;
  final int passengerAge;
  final String passengerGender;
  final double fare;
  final String status;

  BusBookingPassengerModel({
    required this.id,
    required this.seatNumber,
    required this.passengerName,
    required this.passengerAge,
    required this.passengerGender,
    required this.fare,
    this.status = 'confirmed',
  });

  factory BusBookingPassengerModel.fromJson(Map<String, dynamic> json) {
    return BusBookingPassengerModel(
      id: json['id'] as int? ?? 0,
      seatNumber: json['seat_number'] as String? ?? '',
      passengerName: json['passenger_name'] as String? ?? '',
      passengerAge: (json['passenger_age'] as num?)?.toInt() ?? 25,
      passengerGender: json['passenger_gender'] as String? ?? 'male',
      fare: (json['fare'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'confirmed',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'seat_number': seatNumber,
    'passenger_name': passengerName,
    'passenger_age': passengerAge,
    'passenger_gender': passengerGender,
    'fare': fare,
    'status': status,
  };
}

class PaymentGatewayModel {
  final String code;
  final String name;
  final String mode;
  final String icon;
  final String badge;
  final String color;

  PaymentGatewayModel({
    required this.code,
    required this.name,
    this.mode = 'live',
    this.icon = 'feather-credit-card',
    this.badge = 'Instant UPI / Card',
    this.color = '#0c2340',
  });

  factory PaymentGatewayModel.fromJson(Map<String, dynamic> json) {
    return PaymentGatewayModel(
      code: json['code'] as String? ?? 'razorpay',
      name: json['name'] as String? ?? 'Razorpay',
      mode: json['mode'] as String? ?? 'live',
      icon: json['icon'] as String? ?? 'feather-credit-card',
      badge: json['badge'] as String? ?? 'Instant UPI / Card',
      color: json['color'] as String? ?? '#0c2340',
    );
  }
}

class BusBookingDataModel {
  final int id;
  final String pnr;
  final String journeyDate;
  final String departureTime;
  final String arrivalTime;
  final String sourceCity;
  final String destinationCity;
  final int totalPassengers;
  final List<String> seatNumbers;
  final double baseFare;
  final double convenienceFee;
  final double taxAmount;
  final String? couponCode;
  final double discountAmount;
  final double walletAmountUsed;
  final double onlineAmountPaid;
  final double totalAmount;
  final String paymentMethod;
  final String paymentGateway;
  final String paymentStatus;
  final String bookingStatus;
  final String contactName;
  final String contactEmail;
  final String contactMobile;
  final bool isCancellable;
  final String? cancellationReason;
  final String? cancelledAt;
  final BusOperatorModel operator;
  final BusInfoModel bus;
  final BusRouteModel route;
  final BusPointModel boardingPoint;
  final BusPointModel droppingPoint;
  final List<BusBookingPassengerModel> passengers;
  final String createdAt;

  BusBookingDataModel({
    required this.id,
    required this.pnr,
    required this.journeyDate,
    required this.departureTime,
    required this.arrivalTime,
    required this.sourceCity,
    required this.destinationCity,
    required this.totalPassengers,
    required this.seatNumbers,
    required this.baseFare,
    required this.convenienceFee,
    required this.taxAmount,
    this.couponCode,
    this.discountAmount = 0.0,
    this.walletAmountUsed = 0.0,
    required this.onlineAmountPaid,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentGateway,
    required this.paymentStatus,
    required this.bookingStatus,
    required this.contactName,
    required this.contactEmail,
    required this.contactMobile,
    this.isCancellable = false,
    this.cancellationReason,
    this.cancelledAt,
    required this.operator,
    required this.bus,
    required this.route,
    required this.boardingPoint,
    required this.droppingPoint,
    required this.passengers,
    required this.createdAt,
  });

  factory BusBookingDataModel.fromJson(Map<String, dynamic> json) {
    final rawSeats = json['seat_numbers'] as List<dynamic>? ?? [];
    final seatsList = rawSeats.map((s) => s.toString()).toList();

    final rawPassengers = json['passengers'] as List<dynamic>? ?? [];
    final passengersList = rawPassengers
        .map((p) => BusBookingPassengerModel.fromJson(p as Map<String, dynamic>))
        .toList();

    return BusBookingDataModel(
      id: json['id'] as int? ?? 0,
      pnr: json['pnr'] as String? ?? '',
      journeyDate: json['journey_date'] as String? ?? '',
      departureTime: json['departure_time'] as String? ?? '',
      arrivalTime: json['arrival_time'] as String? ?? '',
      sourceCity: json['source_city'] as String? ?? '',
      destinationCity: json['destination_city'] as String? ?? '',
      totalPassengers: (json['total_passengers'] as num?)?.toInt() ?? seatsList.length,
      seatNumbers: seatsList,
      baseFare: (json['base_fare'] as num?)?.toDouble() ?? 0.0,
      convenienceFee: (json['convenience_fee'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0.0,
      couponCode: json['coupon_code'] as String?,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      walletAmountUsed: (json['wallet_amount_used'] as num?)?.toDouble() ?? 0.0,
      onlineAmountPaid: (json['online_amount_paid'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method'] as String? ?? 'online',
      paymentGateway: json['payment_gateway'] as String? ?? 'razorpay',
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      bookingStatus: json['booking_status'] as String? ?? 'confirmed',
      contactName: json['contact_name'] as String? ?? '',
      contactEmail: json['contact_email'] as String? ?? '',
      contactMobile: json['contact_mobile'] as String? ?? '',
      isCancellable: json['is_cancellable'] == true,
      cancellationReason: json['cancellation_reason'] as String?,
      cancelledAt: json['cancelled_at'] as String?,
      operator: BusOperatorModel.fromJson(json['operator'] as Map<String, dynamic>? ?? {}),
      bus: BusInfoModel.fromJson(json['bus'] as Map<String, dynamic>? ?? {}),
      route: BusRouteModel.fromJson(json['route'] as Map<String, dynamic>? ?? {}),
      boardingPoint: BusPointModel.fromJson(json['boarding_point'] as Map<String, dynamic>? ?? {}),
      droppingPoint: BusPointModel.fromJson(json['dropping_point'] as Map<String, dynamic>? ?? {}),
      passengers: passengersList,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

class CreateBookingResponseModel {
  final bool success;
  final String message;
  final BusBookingDataModel? booking;
  final bool paymentRequired;
  final double onlineAmount;
  final List<PaymentGatewayModel> availableGateways;

  CreateBookingResponseModel({
    required this.success,
    required this.message,
    this.booking,
    this.paymentRequired = true,
    this.onlineAmount = 0.0,
    this.availableGateways = const [],
  });

  factory CreateBookingResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final bookingJson = data?['booking'] as Map<String, dynamic>?;
    final rawGateways = data?['available_gateways'] as List<dynamic>? ?? [];

    return CreateBookingResponseModel(
      success: json['success'] == true,
      message: json['message'] as String? ?? '',
      booking: bookingJson != null ? BusBookingDataModel.fromJson(bookingJson) : null,
      paymentRequired: data?['payment_required'] == true,
      onlineAmount: (data?['online_amount'] as num?)?.toDouble() ?? 0.0,
      availableGateways: rawGateways
          .map((g) => PaymentGatewayModel.fromJson(g as Map<String, dynamic>))
          .toList(),
    );
  }
}

class GetBookingsResponseModel {
  final bool success;
  final String message;
  final List<BusBookingDataModel> data;
  final int total;

  GetBookingsResponseModel({
    required this.success,
    required this.message,
    this.data = const [],
    this.total = 0,
  });

  factory GetBookingsResponseModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'] as List<dynamic>? ?? [];
    final meta = json['meta'] as Map<String, dynamic>?;

    return GetBookingsResponseModel(
      success: json['success'] == true,
      message: json['message'] as String? ?? '',
      data: rawList
          .map((item) => BusBookingDataModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: (meta?['total'] as num?)?.toInt() ?? rawList.length,
    );
  }
}

class PaymentInitiateDataModel {
  final String pnr;
  final String gateway;
  final String orderId;
  final int amount; // in paise (e.g. 107500 for Rs. 1075)
  final String currency;
  final String key;
  final String? redirectUrl;
  final String name;
  final String description;

  PaymentInitiateDataModel({
    required this.pnr,
    required this.gateway,
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.key,
    this.redirectUrl,
    required this.name,
    required this.description,
  });

  factory PaymentInitiateDataModel.fromJson(Map<String, dynamic> json) {
    final payload = json['payload'] as Map<String, dynamic>? ?? {};
    return PaymentInitiateDataModel(
      pnr: json['pnr']?.toString() ?? '',
      gateway: json['gateway']?.toString() ?? 'razorpay',
      orderId: json['order_id']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      currency: json['currency']?.toString() ?? 'INR',
      key: json['key']?.toString() ?? '',
      redirectUrl: json['redirect_url'] as String?,
      name: payload['name']?.toString() ?? 'SPinGO',
      description: payload['description']?.toString() ?? 'Bus Booking Payment',
    );
  }

  Map<String, dynamic> toJson() => {
    'pnr': pnr,
    'gateway': gateway,
    'order_id': orderId,
    'amount': amount,
    'currency': currency,
    'key': key,
    'redirect_url': redirectUrl,
    'payload': {
      'name': name,
      'description': description,
    },
  };
}

class PaymentInitiateResponseModel {
  final bool success;
  final String message;
  final PaymentInitiateDataModel? data;

  PaymentInitiateResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory PaymentInitiateResponseModel.fromJson(Map<String, dynamic> json) {
    return PaymentInitiateResponseModel(
      success: json['success'] == true,
      message: json['message'] as String? ?? '',
      data: json['data'] != null ? PaymentInitiateDataModel.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }
}

class PaymentVerifyDataModel {
  final String pnr;
  final String bookingStatus;
  final String paymentStatus;
  final String paymentGateway;

  PaymentVerifyDataModel({
    required this.pnr,
    required this.bookingStatus,
    required this.paymentStatus,
    required this.paymentGateway,
  });

  factory PaymentVerifyDataModel.fromJson(Map<String, dynamic> json) {
    return PaymentVerifyDataModel(
      pnr: json['pnr']?.toString() ?? '',
      bookingStatus: json['booking_status']?.toString() ?? 'confirmed',
      paymentStatus: json['payment_status']?.toString() ?? 'paid',
      paymentGateway: json['payment_gateway']?.toString() ?? 'razorpay',
    );
  }

  Map<String, dynamic> toJson() => {
    'pnr': pnr,
    'booking_status': bookingStatus,
    'payment_status': paymentStatus,
    'payment_gateway': paymentGateway,
  };
}

class PaymentVerifyResponseModel {
  final bool success;
  final String message;
  final PaymentVerifyDataModel? data;

  PaymentVerifyResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory PaymentVerifyResponseModel.fromJson(Map<String, dynamic> json) {
    return PaymentVerifyResponseModel(
      success: json['success'] == true,
      message: json['message'] as String? ?? '',
      data: json['data'] != null ? PaymentVerifyDataModel.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }
}

class PaymentWebhookResponseModel {
  final String status;

  PaymentWebhookResponseModel({required this.status});

  factory PaymentWebhookResponseModel.fromJson(Map<String, dynamic> json) {
    return PaymentWebhookResponseModel(
      status: json['status']?.toString() ?? 'handled',
    );
  }

  Map<String, dynamic> toJson() => {'status': status};
}

