import 'package:flutter/material.dart';
import '../../models/bus_booking_model.dart';
import '../../services/bus_api_service.dart';
import 'bus_sit.dart';
import 'upsrtc_buses_screen.dart';
import 'bus_schedule_points_screen.dart';

class BusBookingScreen extends StatefulWidget {
  final String fromCity;
  final String toCity;
  final String date;

  const BusBookingScreen({
    super.key,
    this.fromCity = 'Lucknow',
    this.toCity = 'Jaipur (Rajasthan)',
    this.date = '24 Oct Sat',
  });

  @override
  State<BusBookingScreen> createState() => _BusBookingScreenState();
}

class _BusBookingScreenState extends State<BusBookingScreen> with SingleTickerProviderStateMixin {
  String _selectedFilter = 'All';
  bool _isToiletFilterActive = false;
  bool _isDealsFilterActive = false;
  bool _isHighlyRatedActive = false;

  bool _isLoading = true;
  String? _errorMessage;
  List<BusItem> _liveBuses = [];

  final TextEditingController _smartFilterController = TextEditingController();
  String _searchQuery = '';

  static const Color primaryRed = Color(0xFFD82C3D);
  static const Color brandGreen = Color(0xFF16A34A);

  @override
  void initState() {
    super.initState();
    _fetchLiveSchedules();
  }

  @override
  void dispose() {
    _smartFilterController.dispose();
    super.dispose();
  }

  Future<void> _fetchLiveSchedules() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final schedules = await BusApiService.instance.searchBuses(
        sourceCity: widget.fromCity,
        destinationCity: widget.toCity,
      );

      if (schedules.isNotEmpty) {
        _liveBuses = schedules.map((s) => BusItem.fromSchedule(s)).toList();
      } else {
        _liveBuses = _defaultBuses;
      }
    } catch (e) {
      _errorMessage = 'Could not fetch live buses: $e';
      _liveBuses = _defaultBuses;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Realistic fallback data matching Screenshots 2 & 3
  static const List<BusItem> _defaultBuses = [
    BusItem(
      id: 'rsrtc-213172',
      operator: 'RSRTC - 213172',
      busType: 'AC Sleeper (2+1)',
      deptTime: '21:00',
      deptLoc: 'Lucknow Expressway Hub',
      arrTime: '06:45',
      arrLoc: 'Sindhi Camp, Jaipur',
      duration: '9h 45m',
      rating: 4.5,
      reviews: '759',
      price: 1408,
      originalPrice: 1550,
      seatsLeft: 16,
      isLiveTracking: true,
      amenities: ['Air Conditioning', 'Clean Blanket', 'Reading Light', 'Charging Point', 'Expressway Route'],
      hdImage: 'assets/images/modern_luxury_bus.jpg',
    ),
    BusItem(
      id: 'sethi-1',
      operator: 'Sethi Yatra Company',
      busType: 'A/C Seater / Sleeper (2+1)',
      deptTime: '20:00',
      deptLoc: 'Alambagh Bus Terminal, Lucknow',
      arrTime: '05:30',
      arrLoc: 'Jaipur Bypass Highway',
      duration: '9h 30m',
      rating: 4.5,
      reviews: '759',
      price: 699,
      originalPrice: 777,
      seatsLeft: 14,
      isLiveTracking: true,
      amenities: ['Toilet', 'Air Conditioning', 'Free Wi-Fi', 'Charging Point'],
      hdImage: 'assets/images/bus_interior_luxury.jpg',
    ),
    BusItem(
      id: 'dev-express',
      operator: 'Dev Express®',
      busType: 'A/C Sleeper (2+1)',
      deptTime: '21:00',
      deptLoc: 'Transport Nagar, Lucknow',
      arrTime: '06:20',
      arrLoc: 'Gopalbari, Jaipur',
      duration: '9h 20m',
      rating: 4.4,
      reviews: '430',
      price: 834,
      originalPrice: 927,
      seatsLeft: 23,
      isLiveTracking: true,
      amenities: ['Air Conditioning', 'Charging Point', 'Live Tracking', 'Clean Linen'],
      hdImage: 'assets/images/modern_luxury_bus.jpg',
    ),
    BusItem(
      id: 'sethi-2',
      operator: 'Sethi Yatra Company',
      busType: 'A/C Seater / Sleeper (2+1)',
      deptTime: '21:05',
      deptLoc: 'Charbagh Depot, Lucknow',
      arrTime: '06:35',
      arrLoc: 'Sindhi Camp, Jaipur',
      duration: '9h 30m',
      rating: 4.3,
      reviews: '649',
      price: 629,
      originalPrice: 699,
      seatsLeft: 16,
      isLiveTracking: true,
      amenities: ['Toilet', 'Air Conditioning', 'Water Bottle'],
      hdImage: 'assets/images/bus_interior_luxury.jpg',
    ),
    BusItem(
      id: 'primo-night',
      operator: 'IntrCity SmartBus',
      busType: 'Volvo AC Sleeper (2+1)',
      deptTime: '22:15',
      deptLoc: 'Kamta Chauraha, Lucknow',
      arrTime: '07:30',
      arrLoc: 'Sindhi Camp, Jaipur',
      duration: '9h 15m',
      rating: 4.6,
      reviews: '1,200',
      price: 649,
      originalPrice: 799,
      seatsLeft: 18,
      isLiveTracking: true,
      amenities: ['Toilet', 'Air Conditioning', 'Live Tracking', 'Blanket', 'Pillow'],
      hdImage: 'assets/images/modern_luxury_bus.jpg',
    ),
  ];

  List<BusItem> get _filteredBuses {
    var list = _liveBuses.isNotEmpty ? _liveBuses : _defaultBuses;

    // Smart Filter search query
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((b) {
        return b.operator.toLowerCase().contains(q) ||
            b.busType.toLowerCase().contains(q) ||
            b.deptTime.contains(q) ||
            b.price.toString().contains(q);
      }).toList();
    }

    // Toilet Filter
    if (_isToiletFilterActive) {
      list = list.where((b) => b.amenities.any((a) => a.toLowerCase().contains('toilet'))).toList();
    }

    // Highly Rated
    if (_isHighlyRatedActive) {
      list = list.where((b) => b.rating >= 4.4).toList();
    }

    // Deals filter
    if (_isDealsFilterActive) {
      list = list.where((b) => b.originalPrice > b.price).toList();
    }

    // Category Filter
    if (_selectedFilter == 'AC') {
      return list.where((b) => b.busType.contains('AC') || b.busType.contains('A/C')).toList();
    } else if (_selectedFilter == 'Sleeper') {
      return list.where((b) => b.busType.toLowerCase().contains('sleeper')).toList();
    } else if (_selectedFilter == 'Seater') {
      return list.where((b) => b.busType.toLowerCase().contains('seater')).toList();
    }

    return list;
  }

  void _openSeatSelection(BusItem bus) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BusSeatSelectionScreen(
          bus: bus,
          fromCity: widget.fromCity,
          toCity: widget.toCity,
          date: widget.date,
        ),
      ),
    );
  }

  void _openUpsrtcScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UpsrtcBusesScreen(
          fromCity: widget.fromCity,
          toCity: widget.toCity,
          date: widget.date,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final busesCount = _filteredBuses.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.fromCity,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text(
                  widget.toCity,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 1),
            Text(
              '$busesCount Buses',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          // Date Pill on Top Right (Screenshots 2 & 3)
          Container(
            margin: const EdgeInsets.only(right: 14, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.date.contains(' ') ? '${widget.date.split(' ')[0]} ${(widget.date.split(' ').length > 1 ? widget.date.split(' ')[1] : '')}' : widget.date,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  widget.date.contains(' ') && widget.date.split(' ').length > 2 ? widget.date.split(' ')[2] : 'Sat',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Buses & Hotels Tab Bar (Screenshots 2 & 3)
                Container(
                  color: Colors.white,
                  child: Row(
                    children: [
                      // Buses Tab
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Color(0xFFD82C3D), width: 2.5),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Buses',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Hotels Tab
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Hotels',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Upto 70% Off',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF16A34A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Horizontal Promo Cards (Screenshots 2 & 3)
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildPromoCard(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFEF08A), Color(0xFFFDE047)],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF1E3A8A),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.star, color: Colors.yellow, size: 20),
                            ),
                            const SizedBox(width: 10),
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Primo', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E3A8A))),
                                Text('Rising Stars\non redBus', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      _buildPromoCard(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFCE7F3), Color(0xFFFBCFE8)],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFDB2777),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.currency_rupee, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 10),
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Free Cancellation', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF831843))),
                                SizedBox(height: 2),
                                Text('Get a full refund if\nyou cancel', style: TextStyle(fontSize: 10.5, color: Color(0xFF475569))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      _buildPromoCard(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFEDD5), Color(0xFFFED7AA)],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFEA580C),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.flash_on, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 10),
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Last min.', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF7C2D12))),
                                SizedBox(height: 2),
                                Text('Limited time\nsteal deals', style: TextStyle(fontSize: 10.5, color: Color(0xFF475569))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Filter Chips Row (Screenshots 2 & 3)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      // Filter & Sort with red count badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD82C3D),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text('1', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.tune_rounded, size: 15, color: Color(0xFF0F172A)),
                            const SizedBox(width: 6),
                            const Text(
                              'Filter & Sort',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Toilet Filter (Toggleable, red when active)
                      GestureDetector(
                        onTap: () {
                          setState(() => _isToiletFilterActive = !_isToiletFilterActive);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: _isToiletFilterActive ? const Color(0xFFD82C3D) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _isToiletFilterActive ? const Color(0xFFD82C3D) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Toilet',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: _isToiletFilterActive ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                              if (_isToiletFilterActive) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.close, size: 14, color: Colors.white),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Deals Filter
                      GestureDetector(
                        onTap: () {
                          setState(() => _isDealsFilterActive = !_isDealsFilterActive);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _isDealsFilterActive ? const Color(0xFFFEE2E2) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _isDealsFilterActive ? const Color(0xFFD82C3D) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.percent_rounded, size: 14, color: Color(0xFF0F172A)),
                              const SizedBox(width: 4),
                              Text(
                                'Deals',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: _isDealsFilterActive ? const Color(0xFFD82C3D) : const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Highly Rated
                      GestureDetector(
                        onTap: () {
                          setState(() => _isHighlyRatedActive = !_isHighlyRatedActive);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _isHighlyRatedActive ? const Color(0xFFFEE2E2) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _isHighlyRatedActive ? const Color(0xFFD82C3D) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.person_rounded, size: 15, color: Color(0xFF0F172A)),
                              const SizedBox(width: 4),
                              Text(
                                'Highly rated',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: _isHighlyRatedActive ? const Color(0xFFD82C3D) : const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // AC Filter
                      _buildSimpleFilterChip('AC'),
                      const SizedBox(width: 8),
                      // Sleeper Filter
                      _buildSimpleFilterChip('Sleeper'),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // AI Smart Filter Search Bar (Screenshots 2 & 3)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, size: 14, color: Colors.purple.shade400),
                          const SizedBox(width: 4),
                          Text(
                            'AI Smart filter',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.purple.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFA855F7), width: 1.2),
                        ),
                        child: TextField(
                          controller: _smartFilterController,
                          onChanged: (val) => setState(() => _searchQuery = val),
                          decoration: const InputDecoration(
                            hintText: "Search 'AC sleeper under 1000'",
                            hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            suffixIcon: Icon(Icons.mic_none_rounded, color: Color(0xFF0F172A)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Special UPSRTC Buses Promo Card (Screenshots 2 & 3)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: _openUpsrtcScreen,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                          // Top coupon tag
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFEDD5),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(18),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Use Code UPSRTC to Get Upto ₹300 off on UPSRTC',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF9A3412),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                // Logo
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.directions_bus, color: Color(0xFFD82C3D), size: 24),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'UPSRTC Buses',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      SizedBox(height: 1),
                                      Text(
                                        'उत्तर प्रदेश राज्य सड़क परिवहन निगम',
                                        style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '3 Buses starting from ₹833',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFEE2E2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFD82C3D)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Bus List (Screenshots 2 & 3)
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(color: primaryRed),
                    ),
                  )
                else if (_filteredBuses.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
                    child: Center(
                      child: Text(
                        _errorMessage ?? 'No buses found for this filter or route.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                    itemCount: _filteredBuses.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final bus = _filteredBuses[index];
                      return _buildBusCard(bus, index);
                    },
                  ),
              ],
            ),
          ),

          // Floating "Ask Ray" button (Screenshots 2 & 3)
          Positioned(
            bottom: 20,
            right: 0,
            left: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFA855F7), Color(0xFFEC4899)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFA855F7).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Ask Ray',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard({required Gradient gradient, required Widget child}) {
    return Container(
      width: 175,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _buildSimpleFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedFilter = isSelected ? 'All' : label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFEE2E2) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFD82C3D) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: isSelected ? const Color(0xFFD82C3D) : const Color(0xFF0F172A),
          ),
        ),
      ),
    );
  }

  Widget _buildBusCard(BusItem bus, int index) {
    // Badges like "Via EXPRESSWAY", "Primo On Time Guarantee", "Exclusive 10% OFF"
    final bool isPrimo = bus.operator.contains('Sethi') || bus.operator.contains('Dev') || bus.operator.contains('IntrCity');
    final String discountTag = index % 2 == 0 ? 'Exclusive 10% OFF' : 'Women 10% OFF';
    final bool isExpressway = bus.operator.contains('RSRTC') || index == 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _openSeatSelection(bus),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Badges Row (Screenshots 2 & 3)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isExpressway)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE9FE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Via EXPRESSWAY',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF6D28D9)),
                        ),
                      )
                    else if (isPrimo)
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 16, color: Color(0xFF1E3A8A)),
                          const SizedBox(width: 4),
                          const Text(
                            'Primo ',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF1E3A8A)),
                          ),
                          Text(
                            'On Time\nGuarantee',
                            style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.blue.shade900, height: 1.1),
                          ),
                        ],
                      )
                    else
                      const SizedBox.shrink(),

                    // Discount Pill (Right)
                    if (discountTag.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: discountTag.contains('Women') ? const Color(0xFFFCE7F3) : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          discountTag,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: discountTag.contains('Women') ? const Color(0xFFBE185D) : const Color(0xFFB45309),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Timings Row & Price (Screenshots 2 & 3)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              bus.deptTime,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const Text(
                              '  —  ',
                              style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              bus.arrTime,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              '${bus.duration}  ·  ${bus.seatsLeft} Seats ',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '(3 Single)',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFFEA580C),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Price on Right
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            if (bus.originalPrice > bus.price) ...[
                              Text(
                                '₹${bus.originalPrice}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              '₹${bus.price}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          'Onwards',
                          style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Operator & Rating (Screenshots 2 & 3)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                bus.operator,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              if (bus.operator.contains('Dev')) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.bus_alert, size: 14, color: Colors.grey),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            bus.busType,
                            style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),

                    // Rating Badge with review count
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: brandGreen,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, size: 11, color: Colors.white),
                              const SizedBox(width: 2),
                              Text(
                                bus.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          bus.reviews,
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        final schedId = bus.scheduleModel?.id ?? int.tryParse(bus.id) ?? 15;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BusSchedulePointsScreen(
                              scheduleId: schedId,
                              fromCity: widget.fromCity,
                              toCity: widget.toCity,
                              operatorName: bus.operator,
                              busType: bus.busType,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF2563EB)),
                            const SizedBox(width: 4),
                            Text(
                              'Boarding & Dropping points',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Row(
                      children: [
                        Text(
                          'SELECT SEATS',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFD82C3D),
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(Icons.chevron_right_rounded, size: 15, color: Color(0xFFD82C3D)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
