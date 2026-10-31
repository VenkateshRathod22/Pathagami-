import 'package:flutter/material.dart';
import '../../models/bus_booking_model.dart';
import 'bus_sit.dart';

class UpsrtcBusesScreen extends StatefulWidget {
  final String fromCity;
  final String toCity;
  final String date;

  const UpsrtcBusesScreen({
    super.key,
    this.fromCity = 'Lucknow',
    this.toCity = 'Jaipur (Rajasthan)',
    this.date = '24 Oct Sat',
  });

  @override
  State<UpsrtcBusesScreen> createState() => _UpsrtcBusesScreenState();
}

class _UpsrtcBusesScreenState extends State<UpsrtcBusesScreen> {
  String _selectedFilter = 'All';

  final List<BusItem> _upsrtcBuses = [
    const BusItem(
      id: 'cbg0054',
      operator: 'UPSRTC - CBG0054',
      busType: 'Ordinary Non AC Seater 2+3',
      deptTime: '18:00',
      deptLoc: 'Alambagh ISBT, Lucknow',
      arrTime: '08:30',
      arrLoc: 'Sindhi Camp, Jaipur',
      duration: '14h 30m',
      rating: 3.3,
      reviews: '524',
      price: 833,
      originalPrice: 833,
      seatsLeft: 52,
      isLiveTracking: true,
      amenities: ['Luggage Space', 'Emergency Exit', 'First Aid'],
      hdImage: 'assets/images/modern_luxury_bus.jpg',
    ),
    const BusItem(
      id: 'igd0600',
      operator: 'UPSRTC - IGD0600',
      busType: 'Ordinary Non AC Seater 2+3',
      deptTime: '19:51',
      deptLoc: 'Charbagh Depot, Lucknow',
      arrTime: '09:20',
      arrLoc: 'Sindhi Camp, Jaipur',
      duration: '13h 29m',
      rating: 3.3,
      reviews: '418',
      price: 833,
      originalPrice: 833,
      seatsLeft: 48,
      isLiveTracking: true,
      amenities: ['Luggage Space', 'Emergency Exit'],
      hdImage: 'assets/images/modern_luxury_bus.jpg',
    ),
    const BusItem(
      id: 'igd0809',
      operator: 'UPSRTC - IGD0809',
      busType: 'Ordinary Non AC Seater 2+3',
      deptTime: '02:30',
      deptLoc: 'Transport Nagar, Lucknow',
      arrTime: '16:00',
      arrLoc: 'Sindhi Camp, Jaipur',
      duration: '13h 30m',
      rating: 3.3,
      reviews: '612',
      price: 833,
      originalPrice: 833,
      seatsLeft: 52,
      isLiveTracking: true,
      amenities: ['Luggage Space', 'Emergency Exit', 'Speed Governor'],
      hdImage: 'assets/images/modern_luxury_bus.jpg',
    ),
  ];

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

  @override
  Widget build(BuildContext context) {
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
                const Text(
                  'UPSRTC Buses ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  '(${_upsrtcBuses.length} Buses)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 1),
            Text(
              '${widget.fromCity} ➔ ${widget.toCity}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Child passenger concession banner (Screenshot 4)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFDBEAFE)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Color(0xFFBFDBFE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.child_care_rounded, color: Color(0xFF1D4ED8), size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'UPSRTC Concessions',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                        ),
                        SizedBox(height: 1),
                        Text(
                          'For child passengers under 5 years free travel',
                          style: TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Filter Chips (Screenshot 4)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildFilterChip('Filter & Sort', icon: Icons.tune_rounded),
                  const SizedBox(width: 8),
                  _buildFilterChip('Free Cancellation', icon: Icons.currency_rupee_rounded),
                  const SizedBox(width: 8),
                  _buildFilterChip('SEATER', icon: Icons.event_seat_rounded),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // "FILTER BY BUS TYPE" divider (Screenshot 4)
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade300, indent: 16, endIndent: 8)),
                Text(
                  'FILTER BY BUS TYPE',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.shade700,
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey.shade300, indent: 8, endIndent: 16)),
              ],
            ),

            const SizedBox(height: 12),

            // Bus type thumbnail card (Screenshot 4)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: 130,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ordinary',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      'NONAC SEATER',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 6),
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 60,
                            width: double.infinity,
                            color: Colors.grey.shade100,
                            child: Image.asset(
                              'assets/images/modern_luxury_bus.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Icon(Icons.directions_bus, color: Colors.grey),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '3 buses',
                              style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // List of UPSRTC Buses (Screenshot 4)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _upsrtcBuses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final bus = _upsrtcBuses[index];
                return _buildUpsrtcCard(bus, index);
              },
            ),

            const SizedBox(height: 24),

            // End of the list footer (Screenshot 4)
            Center(
              child: Text(
                'End of the list',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),
            ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {IconData? icon}) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = isSelected ? 'All' : label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFEE2E2) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFD82C3D) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: isSelected ? const Color(0xFFD82C3D) : const Color(0xFF475569),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: isSelected ? const Color(0xFFD82C3D) : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpsrtcCard(BusItem bus, int index) {
    String? viaTag;
    bool isNextDay = false;
    if (index == 0) {
      viaTag = 'Via AGRA ISBT';
    } else if (index == 2) {
      viaTag = 'Via AGRA EXPRESSWAY';
      isNextDay = true;
    }

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
                // Tag like "Via AGRA ISBT" (Screenshot 4)
                if (viaTag != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE9FE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      viaTag,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6D28D9),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // Timings Row & Price (Screenshot 4)
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
                            if (isNextDay) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Next Day',
                                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                              ),
                            ],
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
                        Text(
                          '${bus.duration}  ·  ${bus.seatsLeft} Seats',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    // Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${bus.price}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const Text(
                          'Onwards',
                          style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Operator Name & Rating (Screenshot 4)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bus.operator,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            bus.busType,
                            style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    // Amber Rating Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706),
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
