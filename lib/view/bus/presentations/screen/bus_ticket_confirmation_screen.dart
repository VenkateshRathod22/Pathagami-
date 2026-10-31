import 'package:flutter/material.dart';
import '../../models/bus_booking_model.dart';
import 'package:tripried/view/common/widgets/spingo_logo.dart';
import 'package:tripried/view/main_screen/presentations/screen/main_screen.dart';

class BusTicketConfirmationScreen extends StatelessWidget {
  final ConfirmedBooking booking;

  const BusTicketConfirmationScreen({super.key, required this.booking});

  static const Color brandGreen = Color(0xFF65A30D);
  static const Color darkNavy = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: darkNavy,
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            SpingoLogo(height: 24, isDark: true),
            SizedBox(width: 8),
            Text(
              'Boarding Pass',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MainScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          children: [
            // Celebratory Success Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF65A30D), Color(0xFF84CC16)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: brandGreen.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: brandGreen, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ticket Confirmed! 🎉',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                          ),
                        ),
                        Text(
                          'PNR: ${booking.pnr} • Sent to WhatsApp & SMS',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Main Digital Boarding Pass Ticket Card
            _buildBoardingPass(context),

            const SizedBox(height: 16),

            // Driver & Bus Details Card
            _buildDriverCard(context),

            if (booking.apiBookingData != null) ...[
              const SizedBox(height: 16),
              _buildApiPaymentSummaryCard(context),
              if (booking.apiBookingData!.bus.amenities.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildAmenitiesCard(context),
              ],
            ],

            const SizedBox(height: 20),

            // Primary Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 1,
                    ),
                    onPressed: () => _openLiveTrackingDialog(context),
                    icon: const Icon(Icons.gps_fixed_rounded, size: 18),
                    label: const Text('LIVE TRACK BUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: darkNavy,
                      side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      backgroundColor: Colors.white,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('📥 Ticket PDF downloaded to device storage'),
                          backgroundColor: brandGreen,
                        ),
                      );
                    },
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('E-TICKET PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Go to My Bookings Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: brandGreen,
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MainScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.confirmation_number_outlined),
                label: const Text('VIEW IN MY BOOKINGS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoardingPass(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Ticket Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: darkNavy,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.operatorName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      booking.busType,
                      style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: brandGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'CONFIRMED',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),

          // Journey Details
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                // Route & Times
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // From
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.boardingPoint.time,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: darkNavy),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            booking.fromCity,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkNavy),
                          ),
                          Text(
                            booking.boardingPoint.location,
                            style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),

                    // Arrow
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          const Icon(Icons.directions_bus_rounded, color: brandGreen, size: 24),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            height: 1.5,
                            width: 40,
                            color: Colors.grey.shade300,
                          ),
                          Text(
                            booking.journeyDate,
                            style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),

                    // To
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            booking.droppingPoint.time,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: darkNavy),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            booking.toCity,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkNavy),
                          ),
                          Text(
                            booking.droppingPoint.location,
                            style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                            textAlign: TextAlign.end,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),
                const Divider(height: 1),
                const SizedBox(height: 14),

                // Seats and Passengers
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('SEATS BOOKED', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(
                          booking.seatNumbers.join(', '),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: brandGreen),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('TOTAL FARE PAID', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(
                          '₹${booking.totalFare}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: darkNavy),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Passenger Names
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: booking.passengers.map((p) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person, size: 14, color: brandGreen),
                                const SizedBox(width: 6),
                                Text(
                                  '${p.name} (${p.gender}, ${p.age} yrs)',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: darkNavy),
                                ),
                              ],
                            ),
                            Text('Seat ${p.seatNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: brandGreen)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // QR Code Row for Boarding Pass
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Icon(Icons.qr_code_2_rounded, size: 64, color: darkNavy),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Scan for Boarding', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: darkNavy)),
                        Text('PNR: ${booking.pnr}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        const Text('Show this to Conductor', style: TextStyle(fontSize: 11, color: brandGreen, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFECFCCB),
            radius: 24,
            child: const Icon(Icons.person, color: brandGreen, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.driverName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkNavy),
                ),
                Text(
                  'Vehicle: ${booking.busNumber}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFDCFCE7),
              foregroundColor: const Color(0xFF166534),
            ),
            icon: const Icon(Icons.phone),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling Driver: ${booking.driverPhone}')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _openLiveTrackingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.gps_fixed, color: brandGreen),
            SizedBox(width: 8),
            Text('Live Bus Tracking', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: const Color(0xFFE2E8F0),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/images/spingo_bus_banner.jpg',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 180,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(color: brandGreen, shape: BoxShape.circle),
                        child: const Icon(Icons.directions_bus_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'On-Time • Moving at 74 km/h',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        '45 kms away from ${booking.boardingPoint.location}',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Estimated Boarding Arrival:', style: TextStyle(fontSize: 12)),
                Text(booking.boardingPoint.time, style: const TextStyle(fontWeight: FontWeight.bold, color: brandGreen)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CLOSE', style: TextStyle(color: brandGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildApiPaymentSummaryCard(BuildContext context) {
    final api = booking.apiBookingData!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.receipt_long_rounded, color: brandGreen, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Payment & Invoice Details',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: darkNavy),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  api.paymentGateway.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF166534),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildSummaryRow('Base Fare', '₹${api.baseFare.toStringAsFixed(0)}'),
          _buildSummaryRow('Convenience Fee', '₹${api.convenienceFee.toStringAsFixed(0)}'),
          _buildSummaryRow('Taxes & GST (5%)', '₹${api.taxAmount.toStringAsFixed(1)}'),
          if (api.discountAmount > 0)
            _buildSummaryRow('Discount', '-₹${api.discountAmount.toStringAsFixed(0)}', color: Colors.green),
          const Divider(height: 18),
          _buildSummaryRow('Total Paid', '₹${api.totalAmount.toStringAsFixed(0)}', isBold: true, color: darkNavy),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_rounded, color: brandGreen, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Operator: ${api.operator.companyName} • PNR: ${api.pnr}',
                    style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              color: isBold ? darkNavy : Colors.grey.shade600,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: color ?? darkNavy,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesCard(BuildContext context) {
    final amenities = booking.apiBookingData!.bus.amenities;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.stars_rounded, color: Color(0xFFEAB308), size: 20),
              SizedBox(width: 8),
              Text(
                'Included In-Bus Amenities',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkNavy),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: amenities.map((a) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: brandGreen, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      a.name,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: darkNavy),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
