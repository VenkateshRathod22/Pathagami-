import 'package:flutter/foundation.dart';
import '../models/bus_booking_model.dart';

class BookingRepository extends ChangeNotifier {
  static final BookingRepository instance = BookingRepository._();
  BookingRepository._();

  final List<ConfirmedBooking> _bookings = [
    ConfirmedBooking(
      pnr: 'SPN-BUS-94821',
      operatorName: 'IntrCity SmartBus',
      busType: 'Volvo 9600 Multi-Axle AC Sleeper (2+1)',
      busNumber: 'DL 01 AB 9482',
      fromCity: 'Delhi',
      toCity: 'Lucknow',
      journeyDate: 'Thu, 24 Oct',
      boardingPoint: const BusStopPoint(
        id: 'b1',
        time: '09:30 PM',
        location: 'ISBT Kashmere Gate',
        landmark: 'Near Gate No. 4, Metro Pillar 42',
      ),
      droppingPoint: const BusStopPoint(
        id: 'd1',
        time: '06:00 AM',
        location: 'Alambagh Bus Terminal',
        landmark: 'Platform 5, Lucknow',
      ),
      passengers: [
        PassengerInfo(name: 'Rahul Sharma', age: 28, gender: 'Male', seatNumber: 'U4'),
      ],
      seatNumbers: ['U4'],
      totalFare: 899,
      paymentMode: 'UPI • Google Pay',
      driverName: 'Vikram Singh (Captain)',
      driverPhone: '+91 98765 12340',
    ),
  ];

  List<ConfirmedBooking> get bookings => List.unmodifiable(_bookings);

  void addBooking(ConfirmedBooking booking) {
    _bookings.insert(0, booking);
    notifyListeners();
  }
}
