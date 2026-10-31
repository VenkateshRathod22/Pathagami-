import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tripried/view/account/presentations/screen/account_screen.dart';
import 'package:tripried/view/bike/presentations/screen/bike_screen.dart';
import 'package:tripried/view/bookings/presentations/screen/bookings_screen.dart';
import 'package:tripried/view/bus/presentations/screen/bus_booking_screen.dart';
import 'package:tripried/view/bus/presentations/screen/apsrtc_screen.dart';
import 'package:tripried/view/bus/presentations/screen/upsrtc_buses_screen.dart';
import 'package:tripried/view/car/presentations/screen/car_screen.dart';
import 'package:tripried/view/getaways/presentations/screen/getaways_screen.dart';
import 'package:tripried/view/help/presentations/screen/help_screen.dart';
import 'package:tripried/view/hotel/presentations/screen/hotel_screen.dart';
import 'package:tripried/view/offers/presentations/screen/offers_splash_screen.dart';
import 'package:tripried/view/bus/presentations/screen/bus_offers_screen.dart';
import 'package:tripried/view/bus/presentations/screen/bus_schedule_points_screen.dart';
import 'package:tripried/view/bus/presentations/widgets/booking_for_women_sheet.dart';
import 'package:tripried/view/parcel/presentations/screen/parcel_screen.dart';
import 'package:tripried/view/common/widgets/spingo_logo.dart';
import 'package:tripried/view/account/sub_features/wallet/presentations/screen/wallet_screen.dart';
import 'package:tripried/view/account/sub_features/wallet/services/wallet_service.dart';
import '../../controllers/bus_controller.dart';

class BusScreen extends StatefulWidget {
  const BusScreen({super.key});

  @override
  State<BusScreen> createState() => _BusScreenState();
}

class _BusScreenState extends State<BusScreen> {
  // Form & Live API State
  late final BusController _busController;
  DateTime _journeyDate = DateTime.now();
  int _selectedQuickDate = 0; // 0: None, 1: Today, 2: Tomorrow
  bool _isWomenBooking = false;

  // AI Voice Search "Ask Ray" State
  final TextEditingController _voiceSearchController = TextEditingController();
  final List<String> _voiceSuggestions = [
    'AC sleeper bus from Delhi to Lucknow',
    'Volvo bus from Bengaluru to Hyderabad',
    'Morning bus from Mumbai to Pune',
    'Garuda bus from Chennai to Vijayawada',
  ];
  int _currentSuggestionIndex = 0;
  Timer? _suggestionTimer;

  // Offers Carousel
  final PageController _offersPageController = PageController(viewportFraction: 0.88);
  int _currentOfferPage = 0;
  Timer? _offersTimer;

  int _currentBottomNavIndex = 0;

  static const Color primaryRed = Color(0xFF65A30D);

  final List<Map<String, dynamic>> _busOffers = [
    {
      'title': 'Save up to Rs 300 on bus tickets',
      'validity': 'Valid till: 25 Oct',
      'code': 'SPINGO300',
      'bgColor': const Color(0xFFECFCCB),
      'saleTag': 'SPINGO\nELECTRIC &\nLUXURY',
      'saleDates': '10th OCT - 25th OCT',
      'imageUrl': 'assets/images/spingo_bus_banner.jpg',
    },
    {
      'title': 'Save up to Rs 250 on first booking',
      'validity': 'Valid till: 31 Oct',
      'code': 'FIRST',
      'bgColor': const Color(0xFFF0FDF4),
      'saleTag': 'SPECIAL\nNEW USER\nBONUS',
      'saleDates': 'VALID ALL MONTH',
      'imageUrl': 'assets/images/modern_luxury_bus.jpg',
    },
    {
      'title': 'Flat 20% off on RTC Govt buses',
      'validity': 'Valid till: 15 Nov',
      'code': 'RTCFESTIVE',
      'bgColor': const Color(0xFFE0F2FE),
      'saleTag': 'GOVT RTC\nSPECIAL\nDISCOUNT',
      'saleDates': 'LIMITED SEATS',
      'imageUrl': 'assets/images/bus_interior_luxury.jpg',
    },
  ];

  final List<Map<String, dynamic>> _govtBuses = [
    {
      'name': 'APSRTC',
      'rating': '3.85',
      'regionalName': 'ఆంధ్రప్రదేశ్ రాష్ట్ర రోడ్డు రవాణా సంస్థ',
      'servicesCount': '1539 services including Garuda, Garuda Plus and more',
      'partnerText': 'Official booking partner of APSRTC',
      'bottomTag': 'SPinGO is the most trusted place to book APSRTC tickets online',
      'code': 'APSRTC',
      'color': Color(0xFF1E3A8A),
    },
    {
      'name': 'TGSRTC',
      'rating': '3.90',
      'regionalName': 'తెలంగాణ రాష్ట్ర రోడ్డు రవాణా సంస్థ',
      'servicesCount': '1450 services including Rajdhani, Super Luxury and more',
      'partnerText': 'Official booking partner of TGSRTC',
      'bottomTag': 'Use code FIRST on your TGSRTC booking',
      'code': 'TGSRTC',
      'color': Color(0xFF047857),
    },
    {
      'name': 'UPSRTC',
      'rating': '4.10',
      'regionalName': 'उत्तर प्रदेश राज्य सड़क परिवहन निगम',
      'servicesCount': '2800+ services including Janrath, Shatabdi, Scania',
      'partnerText': 'Official booking partner of UPSRTC',
      'bottomTag': '₹0 convenience fee on UPSRTC tickets',
      'code': 'UPSRTC',
      'color': Color(0xFFB45309),
    },
    {
      'name': 'KSRTC',
      'rating': '4.25',
      'regionalName': 'ಕರ್ನಾಟಕ ರಾಜ್ಯ ರಸ್ತೆ ಸಾರಿಗೆ ನಿಗಮ',
      'servicesCount': '3200+ services including Airavat Club Class, Corona',
      'partnerText': 'Official booking partner of KSRTC',
      'bottomTag': 'Book Airavat luxury buses with live GPS',
      'code': 'KSRTC',
      'color': Color(0xFF6B21A8),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadWomenBookingPref();
    _busController = BusController();
    _busController.addListener(_onBusControllerUpdate);
    WalletService.instance.addListener(_onBusControllerUpdate);
    WalletService.instance.loadFromCache();
    WalletService.instance.fetchWallet();
    _busController.loadInitialData();
    _startSuggestionCycle();
    _startOffersAutoScroll();
  }

  Future<void> _loadWomenBookingPref() async {
    final val = await BookingForWomenSheet.getSavedPreference();
    if (mounted) setState(() => _isWomenBooking = val);
  }

  void _onBusControllerUpdate() {
    if (mounted) setState(() {});
  }

  void _startSuggestionCycle() {
    _voiceSearchController.text = _voiceSuggestions[0];
    _suggestionTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentSuggestionIndex = (_currentSuggestionIndex + 1) % _voiceSuggestions.length;
          _voiceSearchController.text = _voiceSuggestions[_currentSuggestionIndex];
        });
      }
    });
  }

  void _startOffersAutoScroll() {
    _offersTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_offersPageController.hasClients) {
        final nextPage = (_currentOfferPage + 1) % _busOffers.length;
        _offersPageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _busController.removeListener(_onBusControllerUpdate);
    WalletService.instance.removeListener(_onBusControllerUpdate);
    _busController.dispose();
    _suggestionTimer?.cancel();
    _voiceSearchController.dispose();
    _offersTimer?.cancel();
    _offersPageController.dispose();
    super.dispose();
  }

  void _swapCities() {
    _busController.swapCities();
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    return '$weekday ${date.day}-$month';
  }

  void _pickCity(bool isFrom) {
    final availableCities = _busController.cities.isNotEmpty
        ? _busController.cities
        : ['Delhi', 'Jaipur', 'Lucknow', 'Bengaluru', 'Hyderabad', 'Mumbai', 'Pune', 'Agra', 'Kanpur'];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isFrom ? 'Select Origin City' : 'Select Destination City',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 6),
              Text(
                'Available on SPiNGO live network',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableCities.map((city) {
                  final isCurrent = isFrom ? _busController.fromCity == city : _busController.toCity == city;
                  return ActionChip(
                    label: Text(city),
                    backgroundColor: isCurrent ? const Color(0xFFECFCCB) : Colors.grey.shade100,
                    labelStyle: TextStyle(
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                      color: isCurrent ? const Color(0xFF4D7C0F) : const Color(0xFF0F172A),
                    ),
                    side: BorderSide(color: isCurrent ? primaryRed : Colors.transparent),
                    onPressed: () {
                      if (isFrom) {
                        _busController.setFromCity(city);
                      } else {
                        _busController.setToCity(city);
                      }
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _searchBuses() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BusBookingScreen(
          fromCity: _busController.fromCity,
          toCity: _busController.toCity,
          date: _formatDate(_journeyDate),
        ),
      ),
    );
  }

  void _showGiftDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.card_giftcard_rounded, color: primaryRed),
            SizedBox(width: 8),
            Text('Exclusive Gift Unlocked!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Text('🎉 ₹200 Cashback Voucher', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF78350F))),
                  SizedBox(height: 6),
                  Text('Use code: LOYALGIFT on any Bus booking today!', style: TextStyle(fontSize: 12, color: Color(0xFF92400E))),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('REDEEM NOW', style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _showWomenBookingSheet() async {
    final result = await BookingForWomenSheet.show(
      context,
      initialValue: _isWomenBooking,
      onConfirmed: (val) {
        if (mounted) setState(() => _isWomenBooking = val);
      },
    );
    if (result != null && mounted) {
      setState(() => _isWomenBooking = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP HEADER (redBus logo + Bus, Wallet ₹0, My Account) - Screenshot 1 & 2
              _buildTopHeader(),

              const SizedBox(height: 6),

              // 2. TOP SERVICE CATEGORIES (Bus, Bike, Car, Parcel, Hotel) - Screenshot 1
              _buildServiceCategories(),

              const SizedBox(height: 16),

              // 3. BUS TICKETS TITLE & SUBTITLE - Screenshot 1
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bus Tickets',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Exciting offers & discounts',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 4. "ASK RAY" AI/VOICE SEARCH BAR - Screenshot 1
              _buildAskRayBar(),

              const SizedBox(height: 14),

              // 5. "or search by yourself" DIVIDER - Screenshot 1
              _buildOrSearchDivider(),

              const SizedBox(height: 14),

              // 6. BUS TICKETS SEARCH CARD - Screenshot 1
              _buildBusSearchCard(),

              const SizedBox(height: 18),

              // LIVE POPULAR ROUTES FROM SPiNGO API
              _buildPopularApiRoutesSection(),

              const SizedBox(height: 14),

              // LIVE BOARDING & DROPPING POINTS SHORTCUT
              _buildBoardingDroppingShortcutCard(),

              const SizedBox(height: 20),

              // 7. TAKING INDIA HOME SALE BANNER - Screenshot 1
              _buildFestiveBanner(),

              const SizedBox(height: 24),

              // 8. OFFERS SECTION - Screenshot 2 & 3
              _buildOffersSection(),

              const SizedBox(height: 20),

              // 9. "WE HAVE AN EXCLUSIVE GIFT FOR YOU" CARD - Screenshot 2 & 3
              _buildExclusiveGiftCard(),

              const SizedBox(height: 26),

              // 10. GOVERNMENT RTC BUSES SECTION - Screenshot 2 & 3
              _buildGovernmentBusesSection(),

              const SizedBox(height: 26),

              // 11. "WHAT'S NEW" SECTION (Acko & Free Cancellation) - Screenshot 2
              _buildWhatsNewSection(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ==========================================
  // 1. TOP HEADER
  // ==========================================
  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (Navigator.canPop(context)) ...[
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black87),
                  ),
                ),
              ],
              const SpingoLogo(height: 30),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF65A30D).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'BUS',
                  style: TextStyle(
                    color: Color(0xFF65A30D),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              // Wallet button
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WalletScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined, size: 15, color: Colors.black87),
                      const SizedBox(width: 4),
                      const Text('Wallet', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.black87)),
                      const SizedBox(width: 4),
                      Text('₹${WalletService.instance.balance.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // My Account button
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountScreen()));
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.person_outline, size: 15, color: Colors.black87),
                      SizedBox(width: 4),
                      Text('My Account', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.black87)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. TOP SERVICE CATEGORIES (Bus, Bike, Car, Parcel, Hotel)
  // ==========================================
  Widget _buildServiceCategories() {
    final categories = [
      {
        'title': 'Bus',
        'badge': '₹300 off',
        'icon': Icons.directions_bus_rounded,
        'color': primaryRed,
        'imageUrl': 'assets/images/modern_luxury_bus.jpg',
      },
      {
        'title': 'Bike',
        'badge': '30% Off',
        'icon': Icons.two_wheeler_rounded,
        'color': const Color(0xFFF59E0B),
        'imageUrl': 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=200&q=80',
      },
      {
        'title': 'Car',
        'badge': 'From ₹9/km',
        'icon': Icons.directions_car_rounded,
        'color': const Color(0xFF0284C7),
        'imageUrl': 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&w=200&q=80',
      },
      {
        'title': 'Parcel',
        'badge': 'Doorstep',
        'icon': Icons.inventory_2_rounded,
        'color': const Color(0xFF10B981),
        'imageUrl': 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?auto=format&fit=crop&w=200&q=80',
      },
      {
        'title': 'Hotel',
        'badge': 'Save 70%',
        'icon': Icons.hotel_rounded,
        'color': const Color(0xFF9333EA),
        'imageUrl': 'https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=200&q=80',
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: categories.map((cat) {
          final isSelected = cat['title'] == 'Bus';
          return GestureDetector(
            onTap: () {
              if (cat['title'] == 'Bike') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const BikeScreen()));
              } else if (cat['title'] == 'Car') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CarScreen()));
              } else if (cat['title'] == 'Parcel') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ParcelScreen()));
              } else if (cat['title'] == 'Hotel') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HotelScreen()));
              }
            },
            child: Container(
              width: 70,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? primaryRed : const Color(0xFFE2E8F0),
                  width: isSelected ? 1.6 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      cat['badge'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF166534),
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: (cat['imageUrl'] as String).startsWith('assets/')
                        ? Image.asset(cat['imageUrl'] as String, width: 40, height: 40, fit: BoxFit.cover)
                        : Image.network(
                            cat['imageUrl'] as String,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              height: 40,
                              width: 40,
                              color: (cat['color'] as Color).withValues(alpha: 0.1),
                              child: Icon(cat['icon'] as IconData, size: 22, color: cat['color'] as Color),
                            ),
                          ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat['title'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? primaryRed : const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==========================================
  // 4. "ASK RAY" AI/VOICE SEARCH BAR
  // ==========================================
  Widget _buildAskRayBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFF818CF8), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Color(0xFF8B5CF6), size: 18),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Ask Ray',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                      ),
                      Text(
                        _voiceSearchController.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Listening... Speak your bus route (e.g. "Delhi to Lucknow AC sleeper")')),
              );
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.mic, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 5. "or search by yourself" DIVIDER
  // ==========================================
  Widget _buildOrSearchDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: const Color(0xFFE2E8F0))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'or search by yourself',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
            ),
          ),
          Expanded(child: Container(height: 1, color: const Color(0xFFE2E8F0))),
        ],
      ),
    );
  }

  // ==========================================
  // 6. BUS TICKETS SEARCH CARD (Screenshot 1)
  // ==========================================
  Widget _buildBusSearchCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFCBD5E1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // FROM & TO Row with Floating Dark Swap Button
            Stack(
              alignment: Alignment.centerRight,
              children: [
                Column(
                  children: [
                    // From
                    InkWell(
                      onTap: () => _pickCity(true),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 60, 14),
                        child: Row(
                          children: [
                            const Icon(Icons.directions_bus_outlined, color: Color(0xFF334155), size: 22),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('From', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                const SizedBox(height: 2),
                                Text(
                                  _busController.fromCity,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Divider(height: 1, indent: 52),

                    // To
                    InkWell(
                      onTap: () => _pickCity(false),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 60, 16),
                        child: Row(
                          children: [
                            const Icon(Icons.directions_bus_outlined, color: Color(0xFF334155), size: 22),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('To', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                const SizedBox(height: 2),
                                Text(
                                  _busController.toCity,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Floating Circular Swap Button (⇅)
                Positioned(
                  right: 16,
                  child: GestureDetector(
                    onTap: _swapCities,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF334155),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.swap_vert, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 1),

            // Date of Journey with Today / Tomorrow Quick Chips
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, color: Color(0xFF334155), size: 20),
                  const SizedBox(width: 14),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _journeyDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 90)),
                        );
                        if (picked != null) {
                          setState(() {
                            _journeyDate = picked;
                            _selectedQuickDate = 0;
                          });
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date of Journey', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(_journeyDate),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // "Today" Pill
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _journeyDate = DateTime.now();
                        _selectedQuickDate = 1;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: _selectedQuickDate == 1 ? const Color(0xFFECFCCB) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _selectedQuickDate == 1 ? primaryRed : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        'Today',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _selectedQuickDate == 1 ? primaryRed : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // "Tomorrow" Pill
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _journeyDate = DateTime.now().add(const Duration(days: 1));
                        _selectedQuickDate = 2;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: _selectedQuickDate == 2 ? const Color(0xFFECFCCB) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _selectedQuickDate == 2 ? primaryRed : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        'Tomorrow',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _selectedQuickDate == 2 ? primaryRed : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Booking for Women row
            InkWell(
              onTap: _showWomenBookingSheet,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.face_3, color: Color(0xFF334155), size: 22),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Booking for women',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                          ),
                          GestureDetector(
                            onTap: _showWomenBookingSheet,
                            child: const Text(
                              'Know more',
                              style: TextStyle(fontSize: 11.5, color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _isWomenBooking,
                      activeTrackColor: primaryRed,
                      onChanged: (val) {
                        setState(() => _isWomenBooking = val);
                        BookingForWomenSheet.savePreference(val);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Search Buses Button (Screenshot 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: _searchBuses,
                  icon: const Icon(Icons.search, color: Colors.white, size: 20),
                  label: const Text(
                    'Search buses',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // LIVE POPULAR ROUTES SECTION (GET /bus/routes)
  // ==========================================
  Widget _buildPopularApiRoutesSection() {
    if (_busController.routes.isEmpty && !_busController.isLoadingRoutes) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.alt_route_rounded, color: primaryRed, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Popular Bus Routes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFCCB),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'LIVE ROUTES',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4D7C0F)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_busController.isLoadingRoutes)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: primaryRed)),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _busController.routes.map((route) {
                  return InkWell(
                    onTap: () {
                      _busController.setFromCity(route.sourceCity);
                      _busController.setToCity(route.destinationCity);
                      _searchBuses();
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      width: 220,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                route.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF0F172A)),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: primaryRed),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.route, size: 13, color: Color(0xFF64748B)),
                              const SizedBox(width: 4),
                              Text(
                                '${route.distanceKm} km',
                                style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.schedule, size: 13, color: Color(0xFF64748B)),
                              const SizedBox(width: 4),
                              Text(
                                route.formattedDuration.trim(),
                                style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Tap to book now',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: primaryRed),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // LIVE BOARDING & DROPPING POINTS SHORTCUT
  // ==========================================
  Widget _buildBoardingDroppingShortcutCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const BusSchedulePointsScreen(
                scheduleId: 15,
                fromCity: 'Lucknow',
                toCity: 'Delhi',
                operatorName: 'SPinGO Express Line',
                busType: 'AC Sleeper (2+1)',
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.pin_drop_rounded, color: Color(0xFF2563EB), size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Boarding & Dropping Points',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Check stops, landmarks & schedule timings for buses',
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 7. FESTIVE BANNER: TAKING INDIA HOME SALE (Screenshot 1)
  // ==========================================
  Widget _buildFestiveBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/spingo_bus_banner.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0F172A).withValues(alpha: 0.9),
                      const Color(0xFF14532D).withValues(alpha: 0.75),
                      Colors.transparent,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF84CC16),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '10th OCT - 25th OCT',
                      style: TextStyle(color: Color(0xFF0F172A), fontSize: 9.5, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'SPINGO FESTIVE SALE',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.2),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Save up to ₹300 on bus tickets using code SPINGO300',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 8. OFFERS SECTION (Screenshot 2 & 3)
  // ==========================================
  Widget _buildOffersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Offers',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  ),
                  Text(
                    'Get best deals with great offers',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const BusOffersScreen()));
                },
                child: const Text(
                  'View all',
                  style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 145,
          child: PageView.builder(
            controller: _offersPageController,
            itemCount: _busOffers.length,
            onPageChanged: (idx) => setState(() => _currentOfferPage = idx),
            itemBuilder: (context, index) {
              final offer = _busOffers[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: offer['bgColor'] as Color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('Bus', style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            offer['title'] as String,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            offer['validity'] as String,
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 8),
                          // Coupon Pill
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: offer['code'] as String));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Code ${offer['code']} copied to clipboard!')),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.local_offer_outlined, size: 12, color: Colors.black87),
                                  const SizedBox(width: 4),
                                  Text(
                                    offer['code'] as String,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: (offer['imageUrl'] as String).startsWith('assets/')
                          ? Image.asset(offer['imageUrl'] as String, width: 70, height: 70, fit: BoxFit.cover)
                          : Image.network(
                              offer['imageUrl'] as String,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => const Icon(Icons.directions_bus, size: 50, color: Colors.grey),
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_busOffers.length, (index) {
            final isCurrent = index == _currentOfferPage;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              width: isCurrent ? 16 : 6,
              height: 5,
              decoration: BoxDecoration(
                color: isCurrent ? primaryRed : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ==========================================
  // 9. EXCLUSIVE GIFT CARD (Screenshot 2 & 3)
  // ==========================================
  Widget _buildExclusiveGiftCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFEDD5), Color(0xFFFCE7F3), Color(0xFFEDE9FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.card_giftcard_rounded, color: primaryRed, size: 36),
          ),
          const SizedBox(height: 10),
          Text(
            'Thank you for being our loyal customer',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
          ),
          const SizedBox(height: 4),
          const Text(
            'We have an exclusive gift for you',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: 170,
            height: 38,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0F172A),
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: _showGiftDialog,
              child: const Text('View your gift', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 10. GOVERNMENT RTC BUSES SECTION (Screenshot 2 & 3)
  // ==========================================
  Widget _buildGovernmentBusesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Government Buses',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 210,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _govtBuses.length,
            itemBuilder: (context, index) {
              final rtc = _govtBuses[index];
              return GestureDetector(
                onTap: () {
                  final code = rtc['code'] as String? ?? '';
                  if (code == 'APSRTC') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ApsrtcScreen(
                          initialFromCity: _busController.fromCity,
                          initialToCity: _busController.toCity,
                        ),
                      ),
                    );
                  } else if (code == 'UPSRTC') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UpsrtcBusesScreen(
                          fromCity: _busController.fromCity,
                          toCity: _busController.toCity,
                          date: _formatDate(_journeyDate),
                        ),
                      ),
                    );
                  } else {
                    _searchBuses();
                  }
                },
                child: Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: (rtc['color'] as Color).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      (rtc['name'] as String).substring(0, 2),
                                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: rtc['color'] as Color),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  rtc['name'] as String,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF16A34A),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star, size: 10, color: Colors.white),
                                      const SizedBox(width: 2),
                                      Text(
                                        rtc['rating'] as String,
                                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              rtc['regionalName'] as String,
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              rtc['servicesCount'] as String,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.verified, size: 13, color: primaryRed),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    rtc['partnerText'] as String,
                                    style: const TextStyle(fontSize: 10.5, color: primaryRed, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFE4E6),
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(17)),
                        ),
                        child: Text(
                          rtc['bottomTag'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF991B1B)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 11. "WHAT'S NEW" SECTION (Screenshot 2)
  // ==========================================
  Widget _buildWhatsNewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "What's new",
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // Card 1: ACKO Travel Protection
              Container(
                width: 270,
                margin: const EdgeInsets.only(right: 14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFC7D2FE)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ACKO', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF4338CA))),
                    const SizedBox(height: 4),
                    const Text('Seamless Travel Protection', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF1E1B4B))),
                    const SizedBox(height: 2),
                    Text('• Cancellation, delay & baggage cover\n• 48-hr claim settlement', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1B4B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Get Started', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              // Card 2: Free Cancellation
              Container(
                width: 270,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF881337),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Free Cancellation', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)),
                    SizedBox(height: 6),
                    Text('Get 100% refund on bus ticket cancellation', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Spacer(),
                    Row(
                      children: [
                        Text('Know more', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 12. BOTTOM NAVIGATION BAR
  // ==========================================
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() => _currentBottomNavIndex = index);
          if (index == 1) {
            // Bookings Tab -> Navigates to Bus Bookings Data!
            Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingsScreen()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const OffersSplashScreen()));
          } else if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const GetawaysScreen()));
          } else if (index == 4) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen()));
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryRed,
        unselectedItemColor: const Color(0xFF64748B),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number_outlined),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.percent_rounded),
            label: 'Offers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wb_sunny_outlined),
            label: 'Getaways',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline_rounded),
            label: 'Help',
          ),
        ],
      ),
    );
  }
}
