import 'package:flutter/material.dart';

class ParcelScreen extends StatefulWidget {
  const ParcelScreen({super.key});

  @override
  State<ParcelScreen> createState() => _ParcelScreenState();
}

class _ParcelScreenState extends State<ParcelScreen> {
  final TextEditingController _pickupAddressController =
      TextEditingController(text: 'Flat 402, Sunshine Heights, Lajpat Nagar, Delhi');
  final TextEditingController _senderPhoneController =
      TextEditingController(text: '+91 98765 43210');

  final TextEditingController _dropAddressController =
      TextEditingController(text: 'Tower B, DLF Cyber City, Phase 2, Gurugram');
  final TextEditingController _receiverPhoneController =
      TextEditingController(text: '+91 91234 56789');

  int _selectedParcelType = 1; // Small box default
  String _selectedPaymentMethod = 'TripRied Wallet (₹250)';
  bool _isSecureOtpDelivery = true;

  static const Color primaryRed = Color(0xFFD83A3A);

  final List<Map<String, dynamic>> _parcelOptions = [
    {
      'title': 'Documents & Papers',
      'weight': 'Up to 500g',
      'badge': 'INSTANT',
      'badgeColor': Color(0xFF16A34A),
      'fare': '₹39',
      'eta': '30-45 mins',
      'icon': Icons.description_outlined,
      'description': 'Certificates, passports, business legal documents',
    },
    {
      'title': 'Small Box / Essentials',
      'weight': 'Up to 2 kg',
      'badge': 'MOST POPULAR',
      'badgeColor': Color(0xFF2563EB),
      'fare': '₹59',
      'eta': '45-60 mins',
      'icon': Icons.inventory_2_outlined,
      'description': 'Food boxes, apparel, chargers, medicines',
    },
    {
      'title': 'Medium Parcel',
      'weight': 'Up to 5 kg',
      'badge': 'CAREFUL CARRY',
      'badgeColor': Color(0xFF9333EA),
      'fare': '₹99',
      'eta': '50-70 mins',
      'icon': Icons.all_inbox_rounded,
      'description': 'Gift hampers, electronics, books, groceries',
    },
    {
      'title': 'Large Package',
      'weight': 'Up to 15 kg',
      'badge': 'HEAVY DUTY',
      'badgeColor': Color(0xFFD97706),
      'fare': '₹179',
      'eta': '60-90 mins',
      'icon': Icons.local_shipping_outlined,
      'description': 'Appliances, heavy cartons via delivery van',
    },
  ];

  @override
  void dispose() {
    _pickupAddressController.dispose();
    _senderPhoneController.dispose();
    _dropAddressController.dispose();
    _receiverPhoneController.dispose();
    super.dispose();
  }

  void _confirmParcelDelivery() {
    final parcel = _parcelOptions[_selectedParcelType];
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
              'Delivery Partner Assigned!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 6),
            Text(
              'Pickup scheduled in 8 mins • Estimated delivery: ${parcel['eta']}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, color: Colors.grey.shade700),
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
                      Text(parcel['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(parcel['fare'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: primaryRed)),
                    ],
                  ),
                  const Divider(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Delivery Secure OTP:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('8314', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF166534), letterSpacing: 2)),
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
                    const SnackBar(content: Text('Live parcel courier tracking active!')),
                  );
                },
                child: const Text('TRACK COURIER LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              'TripRied Parcel Delivery',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Doorstep Instant City Courier • OTP Verified',
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
            // Safe Delivery Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFDCFCE7), Color(0xFFBBF7D0)],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_clock_rounded, color: Color(0xFF166534), size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Zero Loss Guarantee: Sealed parcel bag, live GPS track & OTP verification upon handover.',
                      style: TextStyle(color: Color(0xFF14532D), fontSize: 11.5, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Pickup (Sender) Details
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.north_east_rounded, color: Color(0xFF16A34A), size: 18),
                      SizedBox(width: 8),
                      Text('1. Sender / Pickup Details', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _pickupAddressController,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'Pickup Address',
                      labelStyle: const TextStyle(fontSize: 11, color: Colors.grey),
                      prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF16A34A), size: 18),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _senderPhoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'Sender Phone Number',
                      labelStyle: const TextStyle(fontSize: 11, color: Colors.grey),
                      prefixIcon: const Icon(Icons.phone_outlined, color: Colors.grey, size: 18),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      isDense: true,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Drop (Receiver) Details
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.south_west_rounded, color: primaryRed, size: 18),
                      SizedBox(width: 8),
                      Text('2. Receiver / Delivery Details', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _dropAddressController,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'Delivery Address',
                      labelStyle: const TextStyle(fontSize: 11, color: Colors.grey),
                      prefixIcon: const Icon(Icons.location_on, color: primaryRed, size: 18),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _receiverPhoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'Receiver Phone Number',
                      labelStyle: const TextStyle(fontSize: 11, color: Colors.grey),
                      prefixIcon: const Icon(Icons.phone_outlined, color: Colors.grey, size: 18),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      isDense: true,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Parcel Package Type Selector
            const Text(
              'Select Parcel Weight / Category',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 10),

            Column(
              children: List.generate(_parcelOptions.length, (index) {
                final parcel = _parcelOptions[index];
                final isSelected = _selectedParcelType == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedParcelType = index),
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
                          child: Icon(parcel['icon'] as IconData, size: 28, color: isSelected ? primaryRed : const Color(0xFF334155)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    parcel['title'] as String,
                                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (parcel['badgeColor'] as Color).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      parcel['badge'] as String,
                                      style: TextStyle(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.bold,
                                        color: parcel['badgeColor'] as Color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${parcel['weight']} • ${parcel['description']}',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Est. Delivery: ${parcel['eta']}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF16A34A)),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          parcel['fare'] as String,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isSelected ? primaryRed : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 12),

            // Secure OTP Handover Check
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.pin_outlined, color: primaryRed, size: 22),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Require OTP at Delivery', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        Text('Receiver provides 4-digit code to complete handover', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _isSecureOtpDelivery,
                    activeTrackColor: primaryRed,
                    onChanged: (val) => setState(() => _isSecureOtpDelivery = val),
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
                          _selectedPaymentMethod = 'UPI / Net Banking';
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

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _confirmParcelDelivery,
                child: Text(
                  'CONFIRM & SEND PARCEL • ${_parcelOptions[_selectedParcelType]['fare']}',
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
}
