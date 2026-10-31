import 'package:flutter/material.dart';

class HotelScreen extends StatefulWidget {
  const HotelScreen({super.key});

  @override
  State<HotelScreen> createState() => _HotelScreenState();
}

class _HotelScreenState extends State<HotelScreen> {
  final TextEditingController _cityController =
      TextEditingController(text: 'Goa (North & South)');
  DateTime _checkInDate = DateTime.now();
  DateTime _checkOutDate = DateTime.now().add(const Duration(days: 2));

  final int _rooms = 1;
  int _guests = 2;
  bool _isHourlyStay = false;
  String _selectedFilter = 'All';

  static const Color primaryRed = Color(0xFFD83A3A);

  final List<String> _filters = ['All', 'Free WiFi', 'AC Stays', 'Breakfast Included', 'Early Check-in', 'Pool Villa'];

  final List<Map<String, dynamic>> _hotelList = [
    {
      'name': 'Grand Comfort Inn & Suites',
      'location': 'Calangute Beach, Goa',
      'rating': '4.6',
      'reviews': '1,420 reviews',
      'price': '₹1,299',
      'originalPrice': '₹3,499',
      'discount': '63% OFF',
      'badge': 'BESTSELLER',
      'badgeColor': Color(0xFF16A34A),
      'amenities': 'Free Breakfast • Swimming Pool • AC • Free WiFi',
      'imageUrl': 'https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=600&q=80',
    },
    {
      'name': 'The Royal Palm Luxury Resort',
      'location': 'Baga Road, North Goa',
      'rating': '4.8',
      'reviews': '2,890 reviews',
      'price': '₹2,499',
      'originalPrice': '₹5,999',
      'discount': '58% OFF',
      'badge': 'EARLY CHECK-IN',
      'badgeColor': Color(0xFF2563EB),
      'amenities': 'Private Balcony • Sea View • Spa • Buffet Dinner',
      'imageUrl': 'https://images.unsplash.com/photo-1566665797739-1674de7a421a?auto=format&fit=crop&w=600&q=80',
    },
    {
      'name': 'Heritage Palace & Spa Stay',
      'location': 'Candolim, Goa',
      'rating': '4.7',
      'reviews': '950 reviews',
      'price': '₹1,899',
      'originalPrice': '₹4,200',
      'discount': '55% OFF',
      'badge': 'PREMIUM',
      'badgeColor': Color(0xFF9333EA),
      'amenities': 'Heritage Architecture • Bar & Lounge • Gym',
      'imageUrl': 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=600&q=80',
    },
    {
      'name': 'Urban Boutique Villa',
      'location': 'Anjuna Flea Market Road, Goa',
      'rating': '4.5',
      'reviews': '680 reviews',
      'price': '₹999',
      'originalPrice': '₹2,500',
      'discount': '60% OFF',
      'badge': 'BUDGET VALUE',
      'badgeColor': Color(0xFFD97706),
      'amenities': 'Free Cancellation • AC • Workstation • Kitchenette',
      'imageUrl': 'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?auto=format&fit=crop&w=600&q=80',
    },
  ];

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  void _bookHotel(Map<String, dynamic> hotel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 40),
            ),
            const SizedBox(height: 12),
            const Text(
              'Hotel Booking Confirmed!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 6),
            Text(
              hotel['name'] as String,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: primaryRed),
            ),
            const SizedBox(height: 4),
            Text(
              '${_formatDate(_checkInDate)} to ${_formatDate(_checkOutDate)} • $_rooms Room, $_guests Guests',
              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount Payable:', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        hotel['price'] as String,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: primaryRed),
                      ),
                    ],
                  ),
                  const Divider(height: 18),
                  const Row(
                    children: [
                      Icon(Icons.credit_card_outlined, size: 16, color: Color(0xFF16A34A)),
                      SizedBox(width: 8),
                      Text('Pay at Hotel available • Zero Cancellation Fee', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF166534))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Hotel booking voucher sent to your registered email & WhatsApp!')),
                  );
                },
                child: const Text('VIEW BOOKING VOUCHER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TripRied Hotels & Stays',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Clean, verified stays across 150+ Indian cities',
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  // City / Location
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.hotel_rounded, size: 18, color: primaryRed),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _cityController,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            labelText: 'City, Area or Hotel Name',
                            labelStyle: TextStyle(fontSize: 11, color: Colors.grey),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  // Check-in and Check-out Row
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _checkInDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 90)),
                            );
                            if (picked != null) setState(() => _checkInDate = picked);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Check-in', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded, size: 14, color: primaryRed),
                                  const SizedBox(width: 6),
                                  Text(_formatDate(_checkInDate), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(width: 1, height: 32, color: const Color(0xFFE2E8F0)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _checkOutDate,
                              firstDate: _checkInDate.add(const Duration(days: 1)),
                              lastDate: DateTime.now().add(const Duration(days: 90)),
                            );
                            if (picked != null) setState(() => _checkOutDate = picked);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Check-out', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_month_rounded, size: 14, color: primaryRed),
                                  const SizedBox(width: 6),
                                  Text(_formatDate(_checkOutDate), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  // Rooms & Guests
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.people_outline, size: 18, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            '$_rooms Room, $_guests Guests',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, size: 20, color: Colors.grey),
                            onPressed: () {
                              if (_guests > 1) setState(() => _guests--);
                            },
                          ),
                          Text('$_guests', style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, size: 20, color: primaryRed),
                            onPressed: () => setState(() => _guests++),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Hourly Stay Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time_filled_rounded, color: Color(0xFFD97706), size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Book Hourly Stays (3h, 6h, 12h)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                        Text('Save up to 60% on layovers & day use', style: TextStyle(fontSize: 10.5, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _isHourlyStay,
                    activeTrackColor: primaryRed,
                    onChanged: (val) => setState(() => _isHourlyStay = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryRed : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? primaryRed : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF334155),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Featured Verified Stays',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),

            // Hotel Deals List
            Column(
              children: _hotelList.map((hotel) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hotel Image with Tag & Rating
                      Stack(
                        children: [
                          Image.network(
                            hotel['imageUrl'] as String,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              height: 150,
                              color: const Color(0xFFF1F5F9),
                              child: const Icon(Icons.hotel, size: 48, color: Colors.grey),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: hotel['badgeColor'] as Color,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                hotel['badge'] as String,
                                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF16A34A),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, size: 12, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    hotel['rating'] as String,
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Details
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hotel['name'] as String,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 13, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${hotel['location']} • ${hotel['reviews']}',
                                    style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              hotel['amenities'] as String,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF047857), fontWeight: FontWeight.w600),
                            ),
                            const Divider(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          hotel['price'] as String,
                                          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: primaryRed),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          hotel['originalPrice'] as String,
                                          style: const TextStyle(fontSize: 11, decoration: TextDecoration.lineThrough, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '+ taxes & fees • ${hotel['discount']}',
                                      style: const TextStyle(fontSize: 10, color: Color(0xFF16A34A), fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryRed,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  ),
                                  onPressed: () => _bookHotel(hotel),
                                  child: const Text('BOOK NOW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
