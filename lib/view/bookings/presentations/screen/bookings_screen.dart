import 'package:flutter/material.dart';
import 'package:tripried/view/bus/presentations/screen/bus_booking_screen.dart';
import 'package:tripried/view/help/presentations/screen/help_screen.dart';
import 'package:tripried/view/bus/data/booking_repository.dart';
import 'package:tripried/view/bus/services/bus_api_service.dart';
import 'package:tripried/view/bus/models/bus_booking_model.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  int _selectedFilterTab = 0; // 0: All, 1: Upcoming, 2: Completed, 3: Cancelled
  final TextEditingController _searchController = TextEditingController();
  bool _isLoadingApiBookings = false;

  static const Color primaryRed = Color(0xFF65A30D);

  final List<Map<String, dynamic>> _allBookings = [
    {
      'id': 'TRIP-BUS-94821',
      'status': 'CONFIRMED',
      'statusColor': Color(0xFF16A34A),
      'isUpcoming': true,
      'isCompleted': false,
      'operator': 'IntrCity SmartBus',
      'busType': 'Volvo 9600 AC Sleeper (2+1)',
      'fromCity': 'Delhi',
      'fromStop': 'ISBT Kashmere Gate (Gate 4)',
      'toCity': 'Lucknow',
      'toStop': 'Alambagh Bus Terminal',
      'deptDate': 'Thu, 24 Oct',
      'deptTime': '09:30 PM',
      'arrTime': '06:00 AM (Next Day)',
      'duration': '8h 30m',
      'seat': 'U4',
      'seatType': 'Upper Single Sleeper (Window)',
      'passengerName': 'Rahul Sharma',
      'passengerAge': 28,
      'passengerGender': 'Male',
      'fare': '₹899',
      'paymentMode': 'UPI • Google Pay',
      'driverName': 'Vikram Singh (Captain)',
      'driverPhone': '+91 98765 12340',
      'busNumber': 'DL 01 AB 9482',
      'liveGpsAvailable': true,
    },
    {
      'id': 'TRIP-BUS-82019',
      'status': 'COMPLETED',
      'statusColor': Color(0xFF2563EB),
      'isUpcoming': false,
      'isCompleted': true,
      'operator': 'Orange Tours & Travels',
      'busType': 'BharatBenz Multi-Axle AC Sleeper',
      'fromCity': 'Bengaluru',
      'fromStop': 'Kempegowda Bus Station (Majestic)',
      'toCity': 'Hyderabad',
      'toStop': 'MGBS Bus Stand (Platform 12)',
      'deptDate': 'Sun, 15 Oct',
      'deptTime': '10:00 PM',
      'arrTime': '06:30 AM',
      'duration': '8h 30m',
      'seat': 'L12',
      'seatType': 'Lower Sleeper',
      'passengerName': 'Rahul Sharma',
      'passengerAge': 28,
      'passengerGender': 'Male',
      'fare': '₹1,150',
      'paymentMode': 'TripRied Wallet',
      'driverName': 'K. Prasad',
      'driverPhone': '+91 98765 88990',
      'busNumber': 'KA 05 MN 1829',
      'liveGpsAvailable': false,
    },
    {
      'id': 'TRIP-BUS-73910',
      'status': 'COMPLETED',
      'statusColor': Color(0xFF2563EB),
      'isUpcoming': false,
      'isCompleted': true,
      'operator': 'Zingbus Plus (Electric Luxury)',
      'busType': 'Volvo AC Seater (2+2)',
      'fromCity': 'Mumbai',
      'fromStop': 'Borivali East (Near National Park)',
      'toCity': 'Pune',
      'toStop': 'Swargate Bus Stand',
      'deptDate': 'Mon, 02 Oct',
      'deptTime': '07:00 AM',
      'arrTime': '10:30 AM',
      'duration': '3h 30m',
      'seat': '14A',
      'seatType': 'Window Seater',
      'passengerName': 'Rahul Sharma',
      'passengerAge': 28,
      'passengerGender': 'Male',
      'fare': '₹420',
      'paymentMode': 'Debit Card',
      'driverName': 'Santosh Patil',
      'driverPhone': '+91 98765 44321',
      'busNumber': 'MH 12 QX 4021',
      'liveGpsAvailable': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    BookingRepository.instance.addListener(_onRepositoryChanged);
    _syncBookings();
    _fetchLiveApiBookings();
  }

  void _onRepositoryChanged() {
    if (mounted) setState(() => _syncBookings());
  }

  Future<void> _fetchLiveApiBookings() async {
    if (mounted) setState(() => _isLoadingApiBookings = true);
    try {
      final apiBookings = await BusApiService.instance.getMyBookings();
      for (final b in apiBookings) {
        final confirmed = ConfirmedBooking.fromApiBooking(b);
        final alreadyInRepo = BookingRepository.instance.bookings.any((item) => item.pnr == b.pnr);
        if (!alreadyInRepo) {
          BookingRepository.instance.addBooking(confirmed);
        }
      }
    } catch (_) {}
    if (mounted) {
      setState(() {
        _isLoadingApiBookings = false;
        _syncBookings();
      });
    }
  }

  void _syncBookings() {
    for (final b in BookingRepository.instance.bookings) {
      final exists = _allBookings.any((item) => item['id'] == b.pnr);
      if (!exists) {
        _allBookings.insert(0, {
          'id': b.pnr,
          'status': 'CONFIRMED',
          'statusColor': const Color(0xFF16A34A),
          'isUpcoming': true,
          'isCompleted': false,
          'operator': b.operatorName,
          'busType': b.busType,
          'fromCity': b.fromCity,
          'fromStop': b.boardingPoint.location,
          'toCity': b.toCity,
          'toStop': b.droppingPoint.location,
          'deptDate': b.journeyDate,
          'deptTime': b.boardingPoint.time,
          'arrTime': b.droppingPoint.time,
          'duration': '8h 30m',
          'seat': b.seatNumbers.join(', '),
          'seatType': 'Reserved Seat(s)',
          'passengerName': b.passengers.first.name,
          'passengerAge': b.passengers.first.age,
          'passengerGender': b.passengers.first.gender,
          'fare': '₹${b.totalFare}',
          'paymentMode': b.paymentMode,
          'driverName': b.driverName,
          'driverPhone': b.driverPhone,
          'busNumber': b.busNumber,
          'liveGpsAvailable': true,
        });
      }
    }
  }

  @override
  void dispose() {
    BookingRepository.instance.removeListener(_onRepositoryChanged);
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredBookings {
    final query = _searchController.text.trim().toLowerCase();
    return _allBookings.where((booking) {
      if (_selectedFilterTab == 1 && !booking['isUpcoming']) return false;
      if (_selectedFilterTab == 2 && !booking['isCompleted']) return false;
      if (_selectedFilterTab == 3) return false; // None cancelled currently

      if (query.isNotEmpty) {
        final id = (booking['id'] as String).toLowerCase();
        final from = (booking['fromCity'] as String).toLowerCase();
        final to = (booking['toCity'] as String).toLowerCase();
        final op = (booking['operator'] as String).toLowerCase();
        return id.contains(query) || from.contains(query) || to.contains(query) || op.contains(query);
      }
      return true;
    }).toList();
  }

  void _showLiveTrackingModal(Map<String, dynamic> booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.gps_fixed_rounded, color: Color(0xFF16A34A), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Live GPS Bus Tracking',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                      ),
                      Text(
                        'Bus Number: ${booking['busNumber']}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.circle, color: Color(0xFF16A34A), size: 8),
                      SizedBox(width: 4),
                      Text('LIVE', style: TextStyle(color: Color(0xFF16A34A), fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Tracking Progress Map simulation box
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=600&q=80',
                        fit: BoxFit.cover,
                        color: Colors.white.withValues(alpha: 0.15),
                        colorBlendMode: BlendMode.dstATop,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Estimated Arrival at Pickup: In 25 Mins',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF1E3A8A)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Current Location: 4.2 km before ${booking['fromStop']}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF1E40AF)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Driver: ${booking['driverName']} • ${booking['driverPhone']}',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Calling driver ${booking['driverPhone']}...')),
                      );
                    },
                    icon: const Icon(Icons.call, size: 16, color: Color(0xFF0F172A)),
                    label: const Text('Call Captain', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryRed,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Live tracking link shared on WhatsApp!')),
                      );
                    },
                    icon: const Icon(Icons.share, size: 16, color: Colors.white),
                    label: const Text('Share Live Link', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTicketDetailsModal(Map<String, dynamic> booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking['operator'] as String, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                    Text(booking['busType'] as String, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (booking['statusColor'] as Color).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    booking['status'] as String,
                    style: TextStyle(color: booking['statusColor'] as Color, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking['fromCity'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    Text(booking['deptTime'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryRed)),
                    Text(booking['fromStop'] as String, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700)),
                  ],
                ),
                const Icon(Icons.arrow_forward_rounded, color: Colors.grey),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(booking['toCity'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    Text(booking['arrTime'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
                    Text(booking['toStop'] as String, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700)),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Passenger', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Text(booking['passengerName'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Seat No.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Text(booking['seat'] as String, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: primaryRed)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Total Fare', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Text(booking['fare'] as String, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('E-Ticket downloaded to your phone gallery!')),
                  );
                },
                icon: const Icon(Icons.download_rounded, color: Colors.white, size: 18),
                label: const Text('DOWNLOAD M-TICKET (PDF)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: primaryRed,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Bus Bookings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: Colors.white),
            tooltip: 'Booking Support',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs (All, Upcoming, Completed, Cancelled)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                // Search box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() {}),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      hintText: 'Search by PNR, City or Bus Operator...',
                      hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ★★★ FIX: Horizontal scrollable filter pills ★★★
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildFilterPill(0, 'All (${_allBookings.length})'),
                      const SizedBox(width: 8),
                      _buildFilterPill(1, 'Upcoming (1)'),
                      const SizedBox(width: 8),
                      _buildFilterPill(2, 'Completed (2)'),
                      const SizedBox(width: 8),
                      _buildFilterPill(3, 'Cancelled (0)'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (_isLoadingApiBookings)
            const LinearProgressIndicator(color: primaryRed, minHeight: 3),

          // Bookings List
          Expanded(
            child: RefreshIndicator(
              color: primaryRed,
              onRefresh: _fetchLiveApiBookings,
              child: _filteredBookings.isEmpty
                  ? Center(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.directions_bus_outlined, size: 60, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            const Text(
                              'No bus bookings found',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Pull to refresh or try changing filters',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      itemCount: _filteredBookings.length,
                      itemBuilder: (context, index) {
                      final booking = _filteredBookings[index];
                      final isUpcoming = booking['isUpcoming'] as bool;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isUpcoming ? primaryRed.withValues(alpha: 0.3) : const Color(0xFFE2E8F0),
                            width: isUpcoming ? 1.4 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Card Top Header
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isUpcoming ? const Color(0xFFFFF1F2) : const Color(0xFFF8FAFC),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.directions_bus_rounded,
                                        size: 16,
                                        color: isUpcoming ? primaryRed : const Color(0xFF475569),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        booking['id'] as String,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: isUpcoming ? primaryRed : const Color(0xFF334155),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: (booking['statusColor'] as Color).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      booking['status'] as String,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: booking['statusColor'] as Color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Main Details Body
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking['operator'] as String,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    booking['busType'] as String,
                                    style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                                  ),
                                  const SizedBox(height: 14),

                                  // Route & Time Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // From
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            booking['deptTime'] as String,
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            booking['fromCity'] as String,
                                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            booking['deptDate'] as String,
                                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                          ),
                                        ],
                                      ),

                                      // Duration line
                                      Column(
                                        children: [
                                          Text(
                                            booking['duration'] as String,
                                            style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
                                              Container(width: 40, height: 1.2, color: const Color(0xFFCBD5E1)),
                                              const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Colors.grey),
                                            ],
                                          ),
                                        ],
                                      ),

                                      // To
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            booking['arrTime'].toString().split(' ')[0],
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            booking['toCity'] as String,
                                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            booking['deptDate'] as String,
                                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const Divider(height: 22),

                                  // Passenger & Seat Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.person_outline, size: 15, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${booking['passengerName']} • Seat ${booking['seat']}',
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        booking['fare'] as String,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: primaryRed),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 14),

                                  // Action Buttons
                                  if (isUpcoming) ...[
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF16A34A),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              padding: const EdgeInsets.symmetric(vertical: 9),
                                            ),
                                            onPressed: () => _showLiveTrackingModal(booking),
                                            icon: const Icon(Icons.gps_fixed, size: 14, color: Colors.white),
                                            label: const Text('TRACK BUS LIVE', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white)),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              padding: const EdgeInsets.symmetric(vertical: 9),
                                            ),
                                            onPressed: () => _showTicketDetailsModal(booking),
                                            icon: const Icon(Icons.confirmation_number_outlined, size: 14, color: Color(0xFF0F172A)),
                                            label: const Text('VIEW TICKET', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ] else ...[
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              padding: const EdgeInsets.symmetric(vertical: 9),
                                            ),
                                            onPressed: () => _showTicketDetailsModal(booking),
                                            icon: const Icon(Icons.receipt_long_outlined, size: 14, color: Color(0xFF0F172A)),
                                            label: const Text('VIEW INVOICE', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: primaryRed,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              padding: const EdgeInsets.symmetric(vertical: 9),
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => BusBookingScreen(
                                                    fromCity: booking['fromCity'] as String,
                                                    toCity: booking['toCity'] as String,
                                                    date: 'Today',
                                                  ),
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.refresh, size: 14, color: Colors.white),
                                            label: const Text('BOOK AGAIN', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill(int index, String label) {
    final isSelected = _selectedFilterTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilterTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primaryRed : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}
