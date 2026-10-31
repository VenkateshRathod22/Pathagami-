import 'package:flutter/material.dart';

class CarScreen extends StatefulWidget {
  const CarScreen({super.key});

  @override
  State<CarScreen> createState() => _CarScreenState();
}

class _CarScreenState extends State<CarScreen> {
  final TextEditingController _pickupController =
      TextEditingController(text: 'Indira Gandhi International Airport, T3');
  final TextEditingController _dropController =
      TextEditingController(text: 'Cyber Hub, DLF Phase 2, Gurugram');

  int _selectedTripType = 0; // 0: Daily City, 1: Rentals, 2: Outstation
  int _selectedCarIndex = 1; // Prime Sedan default
  String _selectedPaymentMethod = 'TripRied Wallet (₹250)';

  static const Color primaryRed = Color(0xFFD83A3A);

  final List<Map<String, dynamic>> _cabOptions = [
    {
      'name': 'Mini / Hatchback',
      'models': 'WagonR, Indica, Tiago',
      'seats': '4 seats',
      'tag': 'BEST VALUE',
      'tagColor': Color(0xFF16A34A),
      'fare': '₹349',
      'ratePerKm': '₹9/km',
      'eta': '3 mins',
      'icon': Icons.directions_car_filled_rounded,
      'features': 'Compact • AC • Everyday commute',
    },
    {
      'name': 'Prime Sedan',
      'models': 'Dzire, Etios, Aura',
      'seats': '4 seats',
      'tag': 'MOST POPULAR',
      'tagColor': Color(0xFF2563EB),
      'fare': '₹449',
      'ratePerKm': '₹12/km',
      'eta': '2 mins',
      'icon': Icons.local_taxi_rounded,
      'features': 'Spacious legroom • Large boot • Top rated drivers',
    },
    {
      'name': 'Prime SUV / XL',
      'models': 'Ertiga, Marazzo, Carens',
      'seats': '6-7 seats',
      'tag': 'FAMILY TRAVEL',
      'tagColor': Color(0xFF9333EA),
      'fare': '₹699',
      'ratePerKm': '₹16/km',
      'eta': '5 mins',
      'icon': Icons.airport_shuttle_rounded,
      'features': 'Extra luggage space • 6+ seats • Highway cruise',
    },
    {
      'name': 'Executive Luxury',
      'models': 'Camry, Superb, BMW',
      'seats': '4 seats',
      'tag': 'BUSINESS CLASS',
      'tagColor': Color(0xFFD97706),
      'fare': '₹1,299',
      'ratePerKm': '₹24/km',
      'eta': '8 mins',
      'icon': Icons.directions_car_rounded,
      'features': 'Chauffeur driven • Leather seats • Water & mints',
    },
  ];

  @override
  void dispose() {
    _pickupController.dispose();
    _dropController.dispose();
    super.dispose();
  }

  void _swapLocations() {
    setState(() {
      final temp = _pickupController.text;
      _pickupController.text = _dropController.text;
      _dropController.text = temp;
    });
  }

  void _confirmCabBooking() {
    final cab = _cabOptions[_selectedCarIndex];
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
              'Cab Confirmed!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 6),
            Text(
              'Your ${cab['name']} is arriving in ${cab['eta']}',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
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
                      Text(cab['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(cab['fare'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: primaryRed)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 14),
                      const SizedBox(width: 6),
                      Text('Guaranteed AC • Free cancellation up to 10 mins', style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700)),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Start Ride PIN:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('7291', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 2)),
                      ),
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
                    const SnackBar(content: Text('Tracking cab in real-time...')),
                  );
                },
                child: const Text('VIEW DRIVER DETAILS & LIVE MAP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              'TripRied Cabs & Rentals',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Verified AC Cabs • Upfront Pricing • No Surge',
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
            // Ride Type Tabs (Daily, Rentals, Outstation)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  _buildTripTypeTab(0, 'Daily City', Icons.directions_car),
                  _buildTripTypeTab(1, 'Hourly Rentals', Icons.access_time_rounded),
                  _buildTripTypeTab(2, 'Outstation', Icons.alt_route_rounded),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Pickup & Destination Box
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFDCFCE7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.radio_button_checked, size: 16, color: Color(0xFF16A34A)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _pickupController,
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Pickup Location',
                            labelStyle: TextStyle(fontSize: 11, color: Colors.grey),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Divider(height: 1),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFE4E6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.location_on, size: 16, color: primaryRed),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _dropController,
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: _selectedTripType == 1 ? 'Select Package (Hours / Kms)' : 'Drop Destination',
                            labelStyle: const TextStyle(fontSize: 11, color: Colors.grey),
                            isDense: true,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.swap_vert_rounded, color: primaryRed),
                        onPressed: _swapLocations,
                        tooltip: 'Swap locations',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Vehicle Category Header
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Cab Category',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                Text(
                  'AC Guaranteed',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Cab List
            Column(
              children: List.generate(_cabOptions.length, (index) {
                final cab = _cabOptions[index];
                final isSelected = _selectedCarIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCarIndex = index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFFF1F2) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? primaryRed : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.8 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? primaryRed.withValues(alpha: 0.1) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(cab['icon'] as IconData, size: 28, color: isSelected ? primaryRed : const Color(0xFF334155)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    cab['name'] as String,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (cab['tagColor'] as Color).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      cab['tag'] as String,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: cab['tagColor'] as Color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${cab['models']} • ${cab['seats']}',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                cab['features'] as String,
                                style: const TextStyle(fontSize: 10.5, color: Color(0xFF047857), fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              cab['fare'] as String,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: isSelected ? primaryRed : const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              cab['ratePerKm'] as String,
                              style: const TextStyle(fontSize: 10.5, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cab['eta'] as String,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 12),

            // Guaranteed Assurances
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_user_rounded, color: Color(0xFF16A34A), size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'TripRied Shield: Verified background-checked drivers, GPS live tracking & 24x7 SOS emergency assistance.',
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF166534), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Payment Mode
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF16A34A), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Payment Mode', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text(_selectedPaymentMethod, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (_selectedPaymentMethod.startsWith('TripRied')) {
                          _selectedPaymentMethod = 'UPI / Google Pay';
                        } else {
                          _selectedPaymentMethod = 'TripRied Wallet (₹250)';
                        }
                      });
                    },
                    child: const Text('Change', style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Book Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _confirmCabBooking,
                child: Text(
                  'BOOK ${_cabOptions[_selectedCarIndex]['name'].toString().toUpperCase()} • ${_cabOptions[_selectedCarIndex]['fare']}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.3),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTripTypeTab(int index, String title, IconData icon) {
    final isSelected = _selectedTripType == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTripType = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? primaryRed : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: isSelected ? Colors.white : const Color(0xFF64748B)),
              const SizedBox(width: 5),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
