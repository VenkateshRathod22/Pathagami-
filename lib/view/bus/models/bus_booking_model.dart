import 'bus_api_models.dart';

class BusItem {
  final String id;
  final String operator;
  final String busType;
  final String deptTime;
  final String deptLoc;
  final String arrTime;
  final String arrLoc;
  final String duration;
  final double rating;
  final String reviews;
  final int price;
  final int originalPrice;
  final int seatsLeft;
  final bool isLiveTracking;
  final List<String> amenities;
  final String? hdImage;
  final BusScheduleModel? scheduleModel;

  const BusItem({
    required this.id,
    required this.operator,
    required this.busType,
    required this.deptTime,
    required this.deptLoc,
    required this.arrTime,
    required this.arrLoc,
    required this.duration,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.originalPrice,
    required this.seatsLeft,
    required this.isLiveTracking,
    required this.amenities,
    this.hdImage,
    this.scheduleModel,
  });

  factory BusItem.fromSchedule(BusScheduleModel s) {
    final deptLoc = s.boardingPoints.isNotEmpty
        ? '${s.boardingPoints.first.pointName}, ${s.route.sourceCity}'
        : s.route.sourceCity;
    final arrLoc = s.droppingPoints.isNotEmpty
        ? '${s.droppingPoints.first.pointName}, ${s.route.destinationCity}'
        : s.route.destinationCity;

    return BusItem(
      id: s.id.toString(),
      operator: s.operator.operatorName,
      busType: s.bus.busType,
      deptTime: s.departureTime.length >= 5 ? s.departureTime.substring(0, 5) : s.departureTime,
      deptLoc: deptLoc,
      arrTime: s.arrivalTime.length >= 5 ? s.arrivalTime.substring(0, 5) : s.arrivalTime,
      arrLoc: arrLoc,
      duration: s.formattedDuration,
      rating: s.operator.rating,
      reviews: '2,450',
      price: s.baseFare,
      originalPrice: (s.baseFare * 1.3).round(),
      seatsLeft: s.availableSeatsCount,
      isLiveTracking: true,
      amenities: s.bus.amenities.map((a) => a.name).toList(),
      hdImage: s.bus.images.isNotEmpty ? s.bus.images.first : 'assets/images/modern_luxury_bus.jpg',
      scheduleModel: s,
    );
  }
}

class BusStopPoint {
  final String id;
  final String time;
  final String location;
  final String landmark;

  const BusStopPoint({
    required this.id,
    required this.time,
    required this.location,
    required this.landmark,
  });
}

class PassengerInfo {
  String name;
  int age;
  String gender; // 'Male', 'Female', 'Other'
  String seatNumber;

  PassengerInfo({
    required this.name,
    required this.age,
    required this.gender,
    required this.seatNumber,
  });
}

class ConfirmedBooking {
  final String pnr;
  final String operatorName;
  final String busType;
  final String busNumber;
  final String fromCity;
  final String toCity;
  final String journeyDate;
  final BusStopPoint boardingPoint;
  final BusStopPoint droppingPoint;
  final List<PassengerInfo> passengers;
  final List<String> seatNumbers;
  final int totalFare;
  final String paymentMode;
  final String driverName;
  final String driverPhone;
  final DateTime bookingTimestamp;
  final BusBookingDataModel? apiBookingData;

  ConfirmedBooking({
    required this.pnr,
    required this.operatorName,
    required this.busType,
    required this.busNumber,
    required this.fromCity,
    required this.toCity,
    required this.journeyDate,
    required this.boardingPoint,
    required this.droppingPoint,
    required this.passengers,
    required this.seatNumbers,
    required this.totalFare,
    required this.paymentMode,
    this.driverName = 'Rajesh Kumar (Captain)',
    this.driverPhone = '+91 98765 43210',
    this.apiBookingData,
    DateTime? bookingTimestamp,
  }) : bookingTimestamp = bookingTimestamp ?? DateTime.now();

  factory ConfirmedBooking.fromApiBooking(BusBookingDataModel b) {
    final boardingPt = BusStopPoint(
      id: b.boardingPoint.id.toString(),
      time: b.boardingPoint.scheduledTime.length >= 5
          ? b.boardingPoint.scheduledTime.substring(0, 5)
          : b.boardingPoint.scheduledTime,
      location: b.boardingPoint.pointName.isNotEmpty
          ? '${b.boardingPoint.pointName}, ${b.boardingPoint.cityName}'
          : b.sourceCity,
      landmark: b.boardingPoint.address.isNotEmpty
          ? b.boardingPoint.address
          : (b.boardingPoint.landmark ?? 'Boarding Station'),
    );

    final droppingPt = BusStopPoint(
      id: b.droppingPoint.id.toString(),
      time: b.droppingPoint.scheduledTime.length >= 5
          ? b.droppingPoint.scheduledTime.substring(0, 5)
          : b.droppingPoint.scheduledTime,
      location: b.droppingPoint.pointName.isNotEmpty
          ? '${b.droppingPoint.pointName}, ${b.droppingPoint.cityName}'
          : b.destinationCity,
      landmark: b.droppingPoint.address.isNotEmpty
          ? b.droppingPoint.address
          : (b.droppingPoint.landmark ?? 'Dropping Station'),
    );

    final passengerList = b.passengers.map((p) {
      return PassengerInfo(
        name: p.passengerName,
        age: p.passengerAge,
        gender: p.passengerGender,
        seatNumber: p.seatNumber,
      );
    }).toList();

    return ConfirmedBooking(
      pnr: b.pnr,
      operatorName: b.operator.operatorName.isNotEmpty ? b.operator.operatorName : 'Royal Express Logistics',
      busType: b.bus.busType.isNotEmpty ? b.bus.busType : 'AC Sleeper / Seater',
      busNumber: b.bus.registrationNumber.isNotEmpty ? b.bus.registrationNumber : 'UP-32-BT-9999',
      fromCity: b.sourceCity,
      toCity: b.destinationCity,
      journeyDate: b.journeyDate,
      boardingPoint: boardingPt,
      droppingPoint: droppingPt,
      passengers: passengerList.isNotEmpty
          ? passengerList
          : [
              PassengerInfo(
                name: b.contactName,
                age: 28,
                gender: 'Male',
                seatNumber: b.seatNumbers.isNotEmpty ? b.seatNumbers.first : '1',
              )
            ],
      seatNumbers: b.seatNumbers,
      totalFare: b.totalAmount.round(),
      paymentMode: '${b.paymentGateway.toUpperCase()} • ${b.paymentMethod.toUpperCase()}',
      driverName: b.operator.contactPerson ?? 'Captain Incharge',
      driverPhone: b.operator.mobile ?? '+91 98765 43210',
      apiBookingData: b,
    );
  }
}

