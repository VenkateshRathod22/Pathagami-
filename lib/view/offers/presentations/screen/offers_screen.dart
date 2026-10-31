import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  String _selectedCategory = 'ALL';

  static const Color primaryRed = Color(0xFFD83A3A);

  final List<String> _categories = ['ALL', 'BUS', 'BIKE', 'CAR', 'PARCEL', 'HOTEL'];

  final List<Map<String, dynamic>> _offers = [
    {
      'category': 'BUS',
      'title': 'Save up to Rs 300 on bus tickets',
      'validity': 'Valid till: 25 Oct',
      'code': 'FESTIVE300',
      'desc': 'Get flat 15% discount up to ₹300 on all interstate AC sleeper buses.',
      'badgeColor': Color(0xFFD83A3A),
    },
    {
      'category': 'BUS',
      'title': 'Save up to Rs 250 on first booking',
      'validity': 'Valid till: 31 Oct',
      'code': 'FIRST',
      'desc': 'Applicable on your first bus booking on TripRied.',
      'badgeColor': Color(0xFFD83A3A),
    },
    {
      'category': 'BUS',
      'title': 'Flat 20% off on Govt RTC Buses',
      'validity': 'Valid till: 15 Nov',
      'code': 'RTCBUS',
      'desc': 'Special festive concession across APSRTC, TGSRTC, UPSRTC & KSRTC routes.',
      'badgeColor': Color(0xFFD83A3A),
    },
    {
      'category': 'BIKE',
      'title': 'Flat 30% off on first 3 Bike Taxi rides',
      'validity': 'Valid till: 15 Nov',
      'code': 'BIKE30',
      'desc': 'Beat daily traffic with swift, affordable doorstep bike taxi rides.',
      'badgeColor': Color(0xFFD97706),
    },
    {
      'category': 'CAR',
      'title': 'Save up to ₹150 on Prime Cabs & Rentals',
      'validity': 'Valid till: 20 Nov',
      'code': 'RIDE150',
      'desc': 'Guaranteed AC sedans & SUVs with verified drivers and zero surge pricing.',
      'badgeColor': Color(0xFF0284C7),
    },
    {
      'category': 'PARCEL',
      'title': 'Flat ₹40 off on Doorstep Parcel Delivery',
      'validity': 'Valid till: 25 Nov',
      'code': 'EXPRESS40',
      'desc': 'Express same-day parcel courier across the city with secure OTP handover.',
      'badgeColor': Color(0xFF059669),
    },
    {
      'category': 'HOTEL',
      'title': 'Save up to 70% on hotels',
      'validity': 'Valid till: 30 Nov',
      'code': 'HOTEL70',
      'desc': 'Enjoy luxury & budget hotel stays starting at just ₹399.',
      'badgeColor': Color(0xFF9333EA),
    },
  ];

  List<Map<String, dynamic>> get _filteredOffers {
    if (_selectedCategory == 'ALL') return _offers;
    return _offers.where((o) => o['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: primaryRed,
        elevation: 0,
        title: const Text(
          'Offers & Deals',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Category Filter Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryRed : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? primaryRed : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Offers List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              itemCount: _filteredOffers.length,
              itemBuilder: (context, index) {
                final offer = _filteredOffers[index];
                final badgeColor = (offer['badgeColor'] as Color?) ?? Colors.black87;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: badgeColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                offer['category'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Text(
                              offer['validity'] as String,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          offer['title'] as String,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          offer['desc'] as String,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.3),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.local_offer_outlined, size: 16, color: primaryRed),
                                  const SizedBox(width: 6),
                                  Text(
                                    offer['code'] as String,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                final code = offer['code'] as String;
                                Clipboard.setData(ClipboardData(text: code));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Coupon $code copied to clipboard!'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: const Text(
                                'COPY CODE',
                                style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
